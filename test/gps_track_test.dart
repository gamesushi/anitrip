import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:anitrip/map/gps_track.dart';
import 'package:anitrip/map/gps_track_recorder.dart';

/// 记录每次落库的起始序号，用于验证分批写入的序号连续。
class _RecordingStore extends InMemoryGpsTrackStore {
  final List<int> startSeqs = <int>[];

  @override
  Future<void> appendSamples(
    String trackId,
    int startSeq,
    List<TrackSample> samples,
  ) async {
    startSeqs.add(startSeq);
    await super.appendSamples(trackId, startSeq, samples);
  }
}

/// 让录制器里的异步落库有机会完成。
Future<void> _pump() => Future<void>.delayed(const Duration(milliseconds: 1));

GpsFix _fix(double lat, double lng, {double? accuracy}) =>
    GpsFix(latitude: lat, longitude: lng, accuracy: accuracy, timestamp: DateTime.now());

void main() {
  group('haversineDistanceMeters', () {
    test('一个纬度约 111 公里', () {
      expect(haversineDistanceMeters(0, 0, 1, 0), closeTo(111195, 500));
    });

    test('同点距离为零', () {
      expect(haversineDistanceMeters(35.0, 139.0, 35.0, 139.0), closeTo(0, 0.001));
    });
  });

  group('shouldRecordSample', () {
    final base = TrackSample(
      latitude: 35.0,
      longitude: 139.0,
      recordedAt: DateTime(2026, 1, 1),
    );

    test('第一个点总是记录', () {
      expect(
        shouldRecordSample(
          previous: null,
          candidate: base,
          minDistanceMeters: 10,
          maxAccuracyMeters: 30,
        ),
        isTrue,
      );
    });

    test('精度超阈值的点被丢弃', () {
      expect(
        shouldRecordSample(
          previous: null,
          candidate: TrackSample(
            latitude: 35.0,
            longitude: 139.0,
            recordedAt: DateTime(2026, 1, 1),
            accuracy: 50,
          ),
          minDistanceMeters: 10,
          maxAccuracyMeters: 30,
        ),
        isFalse,
      );
    });

    test('未测得精度（null）不做精度过滤', () {
      expect(
        shouldRecordSample(
          previous: base,
          candidate: TrackSample(
            latitude: 35.01,
            longitude: 139.0,
            recordedAt: DateTime(2026, 1, 1, 0, 1),
            accuracy: null,
          ),
          minDistanceMeters: 10,
          maxAccuracyMeters: 30,
        ),
        isTrue,
      );
    });

    test('位移不足的点被丢弃（抑制原地漂移）', () {
      expect(
        shouldRecordSample(
          previous: base,
          candidate: TrackSample(
            // 约 1.1 米，小于 10 米阈值。
            latitude: 35.00001,
            longitude: 139.0,
            recordedAt: DateTime(2026, 1, 1, 0, 1),
            accuracy: 5,
          ),
          minDistanceMeters: 10,
          maxAccuracyMeters: 30,
        ),
        isFalse,
      );
    });
  });

  group('GpsTrackRecorder', () {
    late _RecordingStore store;
    late StreamController<GpsFix> fixes;
    late GpsTrackRecorder recorder;

    setUp(() {
      store = _RecordingStore();
      fixes = StreamController<GpsFix>.broadcast();
      recorder = GpsTrackRecorder(
        store: store,
        streamFactory: () => fixes.stream,
        flushBatchSize: 2,
      );
    });

    tearDown(() {
      recorder.dispose();
      fixes.close();
    });

    test('开始录制会建轨迹，采样点按批落库且序号连续', () async {
      await recorder.start(planId: 'plan-1', title: '宇治巡礼');
      expect(recorder.isRecording, isTrue);
      expect(recorder.track!.planId, 'plan-1');

      fixes.add(_fix(35.0, 139.0, accuracy: 5));
      await _pump();
      // 未达到批量大小（2），先只留在内存里。
      expect(recorder.pointCount, 1);
      expect(store.startSeqs, isEmpty);

      fixes.add(_fix(35.001, 139.0, accuracy: 5));
      await _pump();
      expect(recorder.pointCount, 2);
      expect(store.startSeqs, [0]);

      fixes.add(_fix(35.002, 139.0, accuracy: 5));
      fixes.add(_fix(35.003, 139.0, accuracy: 5));
      await _pump();
      // 第二批从序号 2 开始，保证导出/渲染顺序连续。
      expect(store.startSeqs, [0, 2]);

      final samples = await store.loadSamples(recorder.track!.id);
      expect(samples.length, 4);
    });

    test('累积里程并丢弃漂移点与低精度点', () async {
      await recorder.start();
      fixes.add(_fix(35.0, 139.0, accuracy: 5));
      await _pump();
      // 精度 50 米 > 30 米阈值，丢弃。
      fixes.add(_fix(35.001, 139.0, accuracy: 50));
      await _pump();
      // 位移约 1 米，丢弃。
      fixes.add(_fix(35.00001, 139.0, accuracy: 5));
      await _pump();
      fixes.add(_fix(35.001, 139.0, accuracy: 5));
      await _pump();

      expect(recorder.pointCount, 2);
      // 0.001 纬度约 111 米。
      expect(recorder.distanceMeters, closeTo(111.2, 2));
    });

    test('暂停后不再接受定位，恢复后继续', () async {
      await recorder.start();
      fixes.add(_fix(35.0, 139.0, accuracy: 5));
      await _pump();

      await recorder.pause();
      expect(recorder.isPaused, isTrue);
      expect(recorder.track!.status, TrackStatus.paused);

      fixes.add(_fix(35.01, 139.0, accuracy: 5));
      await _pump();
      expect(recorder.pointCount, 1, reason: '暂停期间不应记录');

      await recorder.resume();
      expect(recorder.isRecording, isTrue);
      fixes.add(_fix(35.01, 139.0, accuracy: 5));
      await _pump();
      expect(recorder.pointCount, 2);
    });

    test('结束录制写入汇总信息并清空状态', () async {
      await recorder.start(planId: 'plan-1');
      fixes.add(_fix(35.0, 139.0, accuracy: 5));
      fixes.add(_fix(35.001, 139.0, accuracy: 5));
      await _pump();

      final finished = await recorder.stop();
      expect(finished, isNotNull);
      expect(finished!.status, TrackStatus.completed);
      expect(finished.endedAt, isNotNull);
      expect(finished.pointCount, 2);
      expect(finished.distanceMeters, closeTo(111.2, 2));

      expect(recorder.isActive, isFalse);
      expect(recorder.samples, isEmpty);

      final tracks = await store.loadTracks(planId: 'plan-1');
      expect(tracks.single.status, TrackStatus.completed);
      expect(tracks.single.pointCount, 2);
    });

    test('丢弃轨迹会清除已落库的数据', () async {
      await recorder.start();
      fixes.add(_fix(35.0, 139.0, accuracy: 5));
      await _pump();
      final trackId = recorder.track!.id;

      await recorder.discard();
      expect(recorder.isActive, isFalse);
      expect(await store.loadTracks(), isEmpty);
      expect(await store.loadSamples(trackId), isEmpty);
    });
  });
}
