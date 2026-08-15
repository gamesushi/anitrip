import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'package:anitrip/data/local/app_database.dart';
import 'package:anitrip/data/local/sqlite_pilgrimage_repository.dart';
import 'package:anitrip/plan/pilgrimage_models.dart';
import 'package:anitrip/plan/plan_partition.dart';

const _work = PilgrimageWork(
  id: 'bangumi-1',
  bangumiId: 1,
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
  // Exercises the REAL sqlite implementation (incl. the transaction that calls
  // movePointsToGroup) against an in-memory database — the path a phone uses.
  test('sqlite applyPlanPartition creates groups and moves points', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = SqlitePilgrimageRepository(database: db);

    final created = await repo.createPlan(name: 'T', area: 'Tokyo');
    final points = [
      _pt('a0', 35.0000, 135.0000),
      _pt('a1', 35.0002, 135.0002),
      _pt('a2', 35.0004, 135.0004),
      _pt('b0', 35.5000, 135.5000),
      _pt('b1', 35.5002, 135.5002),
      _pt('b2', 35.5004, 135.5004),
    ];
    await repo.addPointsToPlan(planId: created.id, points: points);

    final clusters = partitionByDistance(points, thresholdMeters: 800);
    expect(clusters.length, 2);

    final now = DateTime(2026);
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
      planId: created.id,
      groups: inputs,
    );

    expect(result.groups.length, 2);
    expect(result.groups.every((g) => g.anchorLatitude != null), isTrue);
    expect(result.points.length, 6);
    expect(result.points.every((p) => p.groupId != null), isTrue);
    for (final input in inputs) {
      for (final pointId in input.pointIds) {
        final point = result.points.firstWhere((p) => p.id == pointId);
        expect(point.groupId, input.group.id);
      }
    }
  });
}
