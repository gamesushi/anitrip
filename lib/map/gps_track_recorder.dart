import 'dart:async';

import 'package:flutter/foundation.dart';

import 'gps_track.dart';

/// 累积多少个采样点后批量落库一次。
///
/// 逐点写盘会让长时间行走产生大量小事务，既耗电又拖慢 UI；
/// 批量写入在「崩溃丢数据」和「写盘开销」之间取折中。
const int kGpsTrackFlushBatchSize = 20;

/// 定位流工厂。由适配层把 geolocator 的 Position 转成 [GpsFix]，
/// 让录制器本身不依赖任何定位插件，可在纯 Dart 下测试。
typedef GpsFixStreamFactory = Stream<GpsFix> Function();

/// 前台 GPS 轨迹录制器。
///
/// 采用「仅前台记录」模式：App 进入后台时由页面侧调用 [pause]，
/// 回到前台调用 [resume]。录制期间轨迹实时可供渲染（[samples]），
/// 并按批持久化到 [GpsTrackStore]。
class GpsTrackRecorder extends ChangeNotifier {
  GpsTrackRecorder({
    required GpsTrackStore store,
    required GpsFixStreamFactory streamFactory,
    String Function()? idFactory,
    this.minDistanceMeters = 10,
    this.maxAccuracyMeters = 30,
    this.flushBatchSize = kGpsTrackFlushBatchSize,
  }) : _store = store,
       _streamFactory = streamFactory,
       _idFactory = idFactory ?? _defaultTrackId;

  final GpsTrackStore _store;
  final GpsFixStreamFactory _streamFactory;
  final String Function() _idFactory;

  /// 与上一个采样点至少相距多少米才记录（抑制原地漂移）。
  final double minDistanceMeters;

  /// 水平精度差于此值（米）的定位直接丢弃。
  final double maxAccuracyMeters;

  final int flushBatchSize;

  TrackRecord? _track;
  final List<TrackSample> _samples = <TrackSample>[];
  final List<TrackSample> _pendingFlush = <TrackSample>[];
  int _flushedCount = 0;
  double _distanceMeters = 0;
  StreamSubscription<GpsFix>? _subscription;
  bool _paused = false;

  static String _defaultTrackId() =>
      'track_${DateTime.now().microsecondsSinceEpoch}';

  bool get isActive => _track != null;
  bool get isRecording => _track != null && !_paused;
  bool get isPaused => _track != null && _paused;

  TrackRecord? get track => _track;
  double get distanceMeters => _distanceMeters;
  int get pointCount => _samples.length;

  /// 已接收的采样点（按时间顺序），供地图实时渲染。
  List<TrackSample> get samples => List<TrackSample>.unmodifiable(_samples);

  Duration get elapsed {
    final track = _track;
    if (track == null) {
      return Duration.zero;
    }
    return DateTime.now().difference(track.startedAt);
  }

  /// 供界面每秒调用一次以刷新时长显示。
  ///
  /// 刻意走 [notifyListeners] 而不是让页面 setState：只有监听录制器的
  /// 部件会重建，避免整张地图每秒重绘。
  void tick() => notifyListeners();

  /// 开始一条新轨迹。已在录制中则忽略。
  Future<void> start({String? planId, String title = ''}) async {
    if (_track != null) {
      return;
    }
    final now = DateTime.now();
    final record = TrackRecord(
      id: _idFactory(),
      planId: planId,
      title: title,
      startedAt: now,
      status: TrackStatus.recording,
      pointCount: 0,
      distanceMeters: 0,
    );
    await _store.createTrack(record);
    _track = record;
    _samples.clear();
    _pendingFlush.clear();
    _flushedCount = 0;
    _distanceMeters = 0;
    _paused = false;
    _subscribe();
    notifyListeners();
  }

  /// 暂停录制：会真正断开定位流，避免后台/暂停期间继续耗电。
  Future<void> pause() async {
    final track = _track;
    if (track == null || _paused) {
      return;
    }
    await _cancelSubscription();
    await _flush();
    _paused = true;
    _track = track.copyWith(status: TrackStatus.paused);
    await _persistTrack();
    notifyListeners();
  }

  /// 从暂停中恢复。
  Future<void> resume() async {
    final track = _track;
    if (track == null || !_paused) {
      return;
    }
    _paused = false;
    _track = track.copyWith(status: TrackStatus.recording);
    _subscribe();
    await _persistTrack();
    notifyListeners();
  }

  /// 结束录制并落库汇总信息，返回最终轨迹。
  Future<TrackRecord?> stop() async {
    final track = _track;
    if (track == null) {
      return null;
    }
    await _cancelSubscription();
    await _flush();
    final finished = track.copyWith(
      endedAt: DateTime.now(),
      status: TrackStatus.completed,
      pointCount: _samples.length,
      distanceMeters: _distanceMeters,
    );
    await _store.updateTrack(finished);
    _track = null;
    _samples.clear();
    _pendingFlush.clear();
    _flushedCount = 0;
    _distanceMeters = 0;
    _paused = false;
    notifyListeners();
    return finished;
  }

  /// 丢弃当前轨迹（不保存汇总，但已落库的采样点会一并清除）。
  Future<void> discard() async {
    final track = _track;
    if (track == null) {
      return;
    }
    await _cancelSubscription();
    _pendingFlush.clear();
    await _store.deleteTrack(track.id);
    _track = null;
    _samples.clear();
    _flushedCount = 0;
    _distanceMeters = 0;
    _paused = false;
    notifyListeners();
  }

  void _subscribe() {
    _subscription?.cancel();
    _subscription = _streamFactory().listen(
      _onFix,
      onError: (Object error) {
        // 定位流异常时不打断已录到的轨迹，交由页面提示。
        debugPrint('GPS track stream error: $error');
      },
    );
  }

  Future<void> _cancelSubscription() async {
    final subscription = _subscription;
    _subscription = null;
    if (subscription != null) {
      await subscription.cancel();
    }
  }

  void _onFix(GpsFix fix) {
    if (_track == null || _paused) {
      return;
    }
    final candidate = TrackSample.fromFix(fix);
    final previous = _samples.isEmpty ? null : _samples.last;
    if (!shouldRecordSample(
      previous: previous,
      candidate: candidate,
      minDistanceMeters: minDistanceMeters,
      maxAccuracyMeters: maxAccuracyMeters,
    )) {
      return;
    }
    if (previous != null) {
      _distanceMeters += haversineDistanceMeters(
        previous.latitude,
        previous.longitude,
        candidate.latitude,
        candidate.longitude,
      );
    }
    _samples.add(candidate);
    _pendingFlush.add(candidate);
    _track = _track!.copyWith(
      pointCount: _samples.length,
      distanceMeters: _distanceMeters,
    );
    if (_pendingFlush.length >= flushBatchSize) {
      unawaited(_flush());
    } else {
      notifyListeners();
    }
  }

  Future<void> _flush() async {
    final track = _track;
    if (track == null || _pendingFlush.isEmpty) {
      return;
    }
    final batch = List<TrackSample>.unmodifiable(_pendingFlush);
    _pendingFlush.clear();
    await _store.appendSamples(track.id, _flushedCount, batch);
    _flushedCount += batch.length;
    if (hasListeners) {
      notifyListeners();
    }
  }

  Future<void> _persistTrack() async {
    final track = _track;
    if (track == null) {
      return;
    }
    await _store.updateTrack(track);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    super.dispose();
  }
}
