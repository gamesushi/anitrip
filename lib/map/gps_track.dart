import 'dart:math' as math;

/// 默认的最小采样间距（米）：与上一个采样点至少相距这么远才记录，
/// 用于抑制原地 GPS 漂移造成的里程虚增与无效采样。
const double kGpsTrackMinDistanceMeters = 10;

/// 水平精度差于此值（米）的定位直接丢弃。
const double kGpsTrackMaxAccuracyMeters = 30;

/// 轨迹状态。前台录制模式下，App 进入后台会自动暂停。
enum TrackStatus {
  recording,
  paused,
  completed;

  static TrackStatus fromName(String? name) {
    return TrackStatus.values.firstWhere(
      (value) => value.name == name,
      orElse: () => TrackStatus.recording,
    );
  }
}

/// 一次定位结果。刻意不依赖 geolocator 的 Position，
/// 便于录制器在纯 Dart 环境下测试（由适配层做转换）。
class GpsFix {
  const GpsFix({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.accuracy,
    this.altitude,
  });

  final double latitude;
  final double longitude;
  final DateTime timestamp;

  /// 水平精度（米）。数值越小越准；为 null 表示平台未测得该值
  /// （geolocator 在这种情况下给的是 0.0 占位符，不能当成「零误差」）。
  final double? accuracy;
  final double? altitude;
}

/// 轨迹中的一个采样点。
class TrackSample {
  const TrackSample({
    required this.latitude,
    required this.longitude,
    required this.recordedAt,
    this.altitude,
    this.accuracy,
  });

  final double latitude;
  final double longitude;
  final DateTime recordedAt;
  final double? altitude;
  final double? accuracy;

  TrackSample.fromFix(GpsFix fix)
    : latitude = fix.latitude,
      longitude = fix.longitude,
      recordedAt = fix.timestamp,
      altitude = fix.altitude,
      accuracy = fix.accuracy;
}

/// 轨迹的汇总信息（不含坐标，供列表展示）。
class TrackRecord {
  const TrackRecord({
    required this.id,
    required this.startedAt,
    required this.status,
    required this.pointCount,
    required this.distanceMeters,
    this.planId,
    this.title = '',
    this.endedAt,
  });

  final String id;
  final String? planId;
  final String title;
  final DateTime startedAt;
  final DateTime? endedAt;
  final TrackStatus status;
  final int pointCount;
  final double distanceMeters;

  Duration get elapsed {
    final end = endedAt;
    return (end == null ? DateTime.now() : end).difference(startedAt);
  }

  TrackRecord copyWith({
    String? title,
    DateTime? endedAt,
    TrackStatus? status,
    int? pointCount,
    double? distanceMeters,
  }) {
    return TrackRecord(
      id: id,
      planId: planId,
      title: title ?? this.title,
      startedAt: startedAt,
      endedAt: endedAt ?? this.endedAt,
      status: status ?? this.status,
      pointCount: pointCount ?? this.pointCount,
      distanceMeters: distanceMeters ?? this.distanceMeters,
    );
  }
}

/// 轨迹持久化抽象。录制器只依赖它，不感知 drift / 具体平台。
abstract class GpsTrackStore {
  Future<void> createTrack(TrackRecord track);

  /// 追加一批采样点；[startSeq] 是这批点在轨迹内的起始序号。
  Future<void> appendSamples(
    String trackId,
    int startSeq,
    List<TrackSample> samples,
  );

  Future<void> updateTrack(TrackRecord track);

  Future<List<TrackRecord>> loadTracks({String? planId});

  Future<List<TrackSample>> loadSamples(String trackId);

  Future<void> deleteTrack(String trackId);
}

/// 内存版轨迹存储：用于测试，以及在拿不到数据库的平台上优雅降级
/// （轨迹只在本次会话内可见，不做持久化）。
class InMemoryGpsTrackStore implements GpsTrackStore {
  final Map<String, TrackRecord> _tracks = <String, TrackRecord>{};
  final Map<String, List<TrackSample>> _samples = <String, List<TrackSample>>{};

  @override
  Future<void> createTrack(TrackRecord track) async {
    _tracks[track.id] = track;
    _samples.putIfAbsent(track.id, () => <TrackSample>[]);
  }

  @override
  Future<void> appendSamples(
    String trackId,
    int startSeq,
    List<TrackSample> samples,
  ) async {
    _samples.putIfAbsent(trackId, () => <TrackSample>[]).addAll(samples);
  }

  @override
  Future<void> updateTrack(TrackRecord track) async {
    _tracks[track.id] = track;
  }

  @override
  Future<List<TrackRecord>> loadTracks({String? planId}) async {
    final tracks = _tracks.values
        .where((track) => planId == null || track.planId == planId)
        .toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return tracks;
  }

  @override
  Future<List<TrackSample>> loadSamples(String trackId) async {
    return List<TrackSample>.unmodifiable(
      _samples[trackId] ?? const <TrackSample>[],
    );
  }

  @override
  Future<void> deleteTrack(String trackId) async {
    _tracks.remove(trackId);
    _samples.remove(trackId);
  }
}

/// 两点间的球面距离（米），Haversine 近似。
double haversineDistanceMeters(
  double lat1,
  double lng1,
  double lat2,
  double lng2,
) {
  const earthRadiusMeters = 6371000.0;
  final dLat = _toRadians(lat2 - lat1);
  final dLng = _toRadians(lng2 - lng1);
  final a =
      math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_toRadians(lat1)) *
          math.cos(_toRadians(lat2)) *
          math.sin(dLng / 2) *
          math.sin(dLng / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return earthRadiusMeters * c;
}

double _toRadians(double degree) => degree * math.pi / 180.0;

/// 采样判定：精度达标、且与上一个采样点拉开足够距离才记录。
///
/// 这样可以避免原地漂移产生大量无效点（既省电量又不会虚增里程）。
/// [previous] 为 null 时表示轨迹的第一个点，总是记录。
bool shouldRecordSample({
  required TrackSample? previous,
  required TrackSample candidate,
  required double minDistanceMeters,
  required double maxAccuracyMeters,
}) {
  final accuracy = candidate.accuracy;
  if (accuracy != null && accuracy > maxAccuracyMeters) {
    return false;
  }
  if (previous == null) {
    return true;
  }
  final moved = haversineDistanceMeters(
    previous.latitude,
    previous.longitude,
    candidate.latitude,
    candidate.longitude,
  );
  return moved >= minDistanceMeters;
}
