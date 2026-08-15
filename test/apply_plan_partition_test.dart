import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'package:anitrip/data/sample_pilgrimage_repository.dart';
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

void main() {
  test('applyPlanPartition creates groups with anchors and moves points', () async {
    // Two clearly-separated clusters of ungrouped points.
    final points = [
      _pt('a0', 35.0000, 135.0000),
      _pt('a1', 35.0002, 135.0002),
      _pt('a2', 35.0004, 135.0004),
      _pt('b0', 35.5000, 135.5000),
      _pt('b1', 35.5002, 135.5002),
      _pt('b2', 35.5004, 135.5004),
    ];
    final plan = PilgrimagePlan(
      id: 'plan-1',
      name: 'Test',
      area: 'Tokyo',
      works: const [_work],
      points: points,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );
    final repo = SamplePilgrimageRepository(plans: [plan]);

    final clusters = partitionByDistance(points, thresholdMeters: 800);
    expect(clusters.length, 2);

    final now = DateTime(2026, 1, 2);
    final inputs = [
      for (var i = 0; i < clusters.length; i += 1)
        PlanPartitionInput(
          group: PilgrimagePlanGroup(
            id: 'group-$i',
            name: 'Area ${i + 1}',
            orderIndex: i,
            anchorLatitude: clusters[i].centroid.latitude,
            anchorLongitude: clusters[i].centroid.longitude,
            createdAt: now,
          ),
          pointIds: clusters[i].pointIds,
        ),
    ];

    final result = await repo.applyPlanPartition(
      planId: plan.id,
      groups: inputs,
    );

    // Groups created with anchors.
    expect(result.groups.length, 2);
    expect(result.groups.every((g) => g.anchorLatitude != null), isTrue);
    // Every point is now assigned to a group.
    expect(result.points.every((p) => p.groupId != null), isTrue);
    // Points landed in the right groups.
    for (final input in inputs) {
      for (final pointId in input.pointIds) {
        final point = result.points.firstWhere((p) => p.id == pointId);
        expect(point.groupId, input.group.id);
      }
    }
  });
}
