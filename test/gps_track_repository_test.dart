import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:anitrip/data/local/app_database.dart';
import 'package:anitrip/data/local/gps_track_repository.dart';
import 'package:anitrip/map/gps_track.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('轨迹与采样点往返持久化', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final repository = GpsTrackRepository(database: database);

    final track = TrackRecord(
      id: 'track-1',
      planId: 'plan-1',
      title: '宇治巡礼',
      startedAt: DateTime(2026, 1, 1, 9),
      status: TrackStatus.recording,
      pointCount: 0,
      distanceMeters: 0,
    );
    await repository.createTrack(track);

    await repository.appendSamples('track-1', 0, [
      TrackSample(
        latitude: 35.0,
        longitude: 139.0,
        recordedAt: DateTime(2026, 1, 1, 9),
        accuracy: 5,
        altitude: 12.5,
      ),
      TrackSample(
        latitude: 35.001,
        longitude: 139.001,
        recordedAt: DateTime(2026, 1, 1, 9, 5),
        accuracy: 8,
      ),
    ]);

    await repository.updateTrack(
      track.copyWith(
        status: TrackStatus.completed,
        endedAt: DateTime(2026, 1, 1, 10),
        pointCount: 2,
        distanceMeters: 123.4,
      ),
    );

    final tracks = await repository.loadTracks(planId: 'plan-1');
    expect(tracks.length, 1);
    expect(tracks.single.id, 'track-1');
    expect(tracks.single.title, '宇治巡礼');
    expect(tracks.single.status, TrackStatus.completed);
    expect(tracks.single.pointCount, 2);
    expect(tracks.single.distanceMeters, closeTo(123.4, 0.001));
    expect(tracks.single.endedAt, DateTime(2026, 1, 1, 10));

    final samples = await repository.loadSamples('track-1');
    expect(samples.length, 2);
    // 按写入顺序（seq）返回，保证轨迹渲染/导出不会乱序。
    expect(samples.first.latitude, closeTo(35.0, 0.000001));
    expect(samples.last.latitude, closeTo(35.001, 0.000001));
    expect(samples.first.altitude, closeTo(12.5, 0.001));
    expect(samples.last.accuracy, closeTo(8, 0.001));

    // 其他计划的轨迹不应被带出来
    expect(await repository.loadTracks(planId: 'plan-2'), isEmpty);

    await repository.deleteTrack('track-1');
    expect(await repository.loadTracks(), isEmpty);
    expect(await repository.loadSamples('track-1'), isEmpty);
  });
}
