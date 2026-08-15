import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'package:anitrip/plan/pilgrimage_models.dart';
import 'package:anitrip/plan/plan_partition.dart';

const _work = PilgrimageWork(
  id: 'bangumi-1',
  title: 'W',
  subtitle: '',
  city: 'Tokyo',
  source: WorkSource.bangumi,
);

PilgrimagePoint _pt(String id, double lat, double lng) => PilgrimagePoint(
  id: id,
  work: _work,
  name: id,
  subtitle: '',
  position: LatLng(lat, lng),
  episodeLabel: '',
  referenceLabel: '',
);

/// Builds [count] points tightly packed (~5m apart) around a center.
List<PilgrimagePoint> _cluster(String prefix, double lat, double lng, int count) {
  return [
    for (var i = 0; i < count; i += 1)
      _pt('$prefix-$i', lat + i * 0.00005, lng + i * 0.00005),
  ];
}

void main() {
  group('partitionByDistance', () {
    test('separates three far-apart clusters into three areas', () {
      final points = [
        ..._cluster('a', 35.0000, 135.0000, 3),
        ..._cluster('b', 35.2000, 135.2000, 3), // ~26km away
        ..._cluster('c', 35.4000, 135.4000, 3), // far again
      ];

      final clusters = partitionByDistance(points, thresholdMeters: 800);

      expect(clusters.length, 3);
      // Every point assigned exactly once.
      final assigned = clusters.expand((c) => c.pointIds).toSet();
      expect(assigned.length, points.length);
    });

    test('merges neighbours within the threshold into one area', () {
      // Two sub-groups 300m apart -> single-linkage should merge them.
      final points = [
        ..._cluster('a', 35.0000, 135.0000, 4),
        ..._cluster('b', 35.0027, 135.0000, 4), // ~300m north
      ];

      final clusters = partitionByDistance(points, thresholdMeters: 800);
      expect(clusters.length, 1);
      expect(clusters.single.pointIds.length, 8);
    });

    test('returns a single cluster for small plans', () {
      final points = _cluster('a', 35.0, 135.0, 3);
      final clusters = partitionByDistance(points, thresholdMeters: 100);
      expect(clusters.length, 1);
    });

    test('handles empty and single-point input', () {
      expect(partitionByDistance(const []), isEmpty);
      final one = partitionByDistance([_pt('x', 35, 135)]);
      expect(one.length, 1);
      expect(one.single.pointIds, {'x'});
    });

    test('all-isolated points each form their own area', () {
      final points = [
        _pt('a', 35.0, 135.0),
        _pt('b', 35.5, 135.5),
        _pt('c', 36.0, 136.0),
        _pt('d', 36.5, 136.5),
        _pt('e', 37.0, 137.0),
        _pt('f', 37.5, 137.5),
      ];
      final clusters = partitionByDistance(points, thresholdMeters: 500);
      expect(clusters.length, 6);
    });

    test('re-splits an oversized chained cluster into balanced areas', () {
      // 50 tightly-packed points chain into one single-linkage cluster; the
      // oversized-split should break it up (ceil(50/20) = 3 areas).
      final points = _cluster('big', 35.0000, 135.0000, 50);
      final clusters = partitionByDistance(points, thresholdMeters: 800);

      expect(clusters.length, 3);
      final assigned = clusters.expand((c) => c.pointIds).toSet();
      expect(assigned.length, 50);
      // No single area swallows most of the plan anymore.
      expect(clusters.every((c) => c.size < 30), isTrue);
    });

    test('keeps clusters within the size cap (no over-splitting)', () {
      // Three separated clusters of 25 each: each is ≤ maxAreaSize (30) and
      // below 40% of the total, so none is re-split.
      final points = [
        ..._cluster('a', 35.0, 135.0, 25),
        ..._cluster('b', 36.0, 136.0, 25),
        ..._cluster('c', 37.0, 137.0, 25),
      ];
      final clusters = partitionByDistance(points, thresholdMeters: 800);
      expect(clusters.length, 3);
    });

    test('centroid is the mean of member positions', () {
      final points = [
        _pt('a', 35.0, 135.0),
        _pt('b', 35.0, 135.2),
      ];
      final clusters = partitionByDistance(
        points,
        thresholdMeters: 100000,
        minPointsForSplit: 2,
      );
      expect(clusters.length, 1);
      expect(clusters.single.centroid.latitude, closeTo(35.0, 1e-9));
      expect(clusters.single.centroid.longitude, closeTo(135.1, 1e-9));
    });
  });

  group('partitionByCount', () {
    test('splits into exactly k areas covering all points', () {
      final points = [
        ..._cluster('a', 35.0, 135.0, 5),
        ..._cluster('b', 35.3, 135.3, 5),
        ..._cluster('c', 35.6, 135.6, 5),
      ];
      final clusters = partitionByCount(points, groupCount: 3);
      expect(clusters.length, 3);
      final assigned = clusters.expand((c) => c.pointIds).toSet();
      expect(assigned.length, points.length);
    });

    test('clamps k to the point count', () {
      final points = _cluster('a', 35.0, 135.0, 2);
      final clusters = partitionByCount(points, groupCount: 10);
      expect(clusters.length, lessThanOrEqualTo(2));
      expect(clusters.expand((c) => c.pointIds).toSet().length, 2);
    });
  });
}
