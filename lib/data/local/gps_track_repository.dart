import 'package:drift/drift.dart';

import '../../map/gps_track.dart';
import 'app_database.dart';

/// 基于 drift 的 GPS 轨迹仓储。
///
/// 复用业务库的同一个 [AppDatabase] 连接，避免为同一个数据库文件再开一路连接。
class GpsTrackRepository implements GpsTrackStore {
  GpsTrackRepository({required AppDatabase database}) : _database = database;

  final AppDatabase _database;

  @override
  Future<void> createTrack(TrackRecord track) async {
    await _database.into(_database.gpsTracks).insert(_insertCompanion(track));
  }

  @override
  Future<void> appendSamples(
    String trackId,
    int startSeq,
    List<TrackSample> samples,
  ) async {
    if (samples.isEmpty) {
      return;
    }
    await _database.batch((batch) {
      batch.insertAll(_database.gpsTrackSamples, [
        for (var i = 0; i < samples.length; i++)
          _sampleCompanion(trackId, startSeq + i, samples[i]),
      ]);
    });
  }

  @override
  Future<void> updateTrack(TrackRecord track) async {
    await (_database.update(
      _database.gpsTracks,
    )..where((table) => table.id.equals(track.id))).write(
      GpsTracksCompanion(
        planId: Value(track.planId),
        title: Value(track.title),
        startedAt: Value(track.startedAt.millisecondsSinceEpoch),
        endedAt: Value(track.endedAt?.millisecondsSinceEpoch),
        status: Value(track.status.name),
        pointCount: Value(track.pointCount),
        distanceMeters: Value(track.distanceMeters),
      ),
    );
  }

  @override
  Future<List<TrackRecord>> loadTracks({String? planId}) async {
    final query = _database.select(_database.gpsTracks)
      ..orderBy([(table) => OrderingTerm.desc(table.startedAt)]);
    if (planId != null) {
      query.where((table) => table.planId.equals(planId));
    }
    final rows = await query.get();
    return rows.map(_trackFromRow).toList(growable: false);
  }

  @override
  Future<List<TrackSample>> loadSamples(String trackId) async {
    final rows = await (_database.select(_database.gpsTrackSamples)
          ..where((table) => table.trackId.equals(trackId))
          ..orderBy([(table) => OrderingTerm.asc(table.seq)]))
        .get();
    return rows.map(_sampleFromRow).toList(growable: false);
  }

  @override
  Future<void> deleteTrack(String trackId) async {
    await (_database.delete(
      _database.gpsTrackSamples,
    )..where((table) => table.trackId.equals(trackId))).go();
    await (_database.delete(
      _database.gpsTracks,
    )..where((table) => table.id.equals(trackId))).go();
  }

  GpsTracksCompanion _insertCompanion(TrackRecord track) {
    return GpsTracksCompanion.insert(
      id: track.id,
      planId: Value(track.planId),
      title: Value(track.title),
      startedAt: track.startedAt.millisecondsSinceEpoch,
      endedAt: Value(track.endedAt?.millisecondsSinceEpoch),
      status: Value(track.status.name),
      pointCount: Value(track.pointCount),
      distanceMeters: Value(track.distanceMeters),
    );
  }

  GpsTrackSamplesCompanion _sampleCompanion(
    String trackId,
    int seq,
    TrackSample sample,
  ) {
    return GpsTrackSamplesCompanion.insert(
      id: '${trackId}_$seq',
      trackId: trackId,
      seq: seq,
      latitude: sample.latitude,
      longitude: sample.longitude,
      altitude: Value(sample.altitude),
      accuracy: Value(sample.accuracy),
      recordedAt: sample.recordedAt.millisecondsSinceEpoch,
    );
  }

  TrackRecord _trackFromRow(GpsTrack row) {
    return TrackRecord(
      id: row.id,
      planId: row.planId,
      title: row.title,
      startedAt: DateTime.fromMillisecondsSinceEpoch(row.startedAt),
      endedAt: row.endedAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(row.endedAt!),
      status: TrackStatus.fromName(row.status),
      pointCount: row.pointCount,
      distanceMeters: row.distanceMeters,
    );
  }

  TrackSample _sampleFromRow(GpsTrackSample row) {
    return TrackSample(
      latitude: row.latitude,
      longitude: row.longitude,
      recordedAt: DateTime.fromMillisecondsSinceEpoch(row.recordedAt),
      altitude: row.altitude,
      accuracy: row.accuracy,
    );
  }
}
