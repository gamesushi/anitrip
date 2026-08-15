import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'package:anitrip/data/anitabi_client.dart';
import 'package:anitrip/data/sample_pilgrimage_repository.dart';
import 'package:anitrip/explore/explore_work_item.dart';
import 'package:anitrip/explore/work_importer.dart';
import 'package:anitrip/plan/pilgrimage_models.dart';

/// AnitabiClient stub that returns fixed points instead of hitting the network.
class _FakeAnitabiClient extends AnitabiClient {
  _FakeAnitabiClient(this._points);

  final List<AnitabiPoint> _points;

  @override
  Future<List<AnitabiPoint>> fetchPoints(
    int bangumiId, {
    AnitabiBangumiLite? lite,
    String? languageCode,
  }) async {
    if (_points.isEmpty) {
      throw AnitabiNoPointsException(bangumiId);
    }
    return _points;
  }
}

AnitabiPoint _point(
  int bangumiId,
  String id, [
  double lat = 35.0,
  double lng = 135.0,
]) => AnitabiPoint(
  bangumiId: bangumiId,
  id: id,
  name: 'Point $id',
  subtitle: '',
  position: LatLng(lat, lng),
  episodeLabel: 'EP1',
  referenceImageUrl: null,
  origin: 'Anitabi',
  originUrl: null,
);

PilgrimagePlan _emptyPlan() => PilgrimagePlan(
  id: 'test-plan',
  name: 'Test',
  area: 'Tokyo',
  works: const [],
  points: const [],
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

const _item = ExploreWorkItem(
  title: 'Test Work',
  subtitle: 'テスト',
  city: 'Tokyo',
  pointCount: 2,
  bangumiId: 999,
);

void main() {
  group('WorkImporter.importWork', () {
    test('adds the work and all its points in one step', () async {
      final plan = _emptyPlan();
      final repo = SamplePilgrimageRepository(plans: [plan]);
      final importer = _importerWith([_point(999, 'a'), _point(999, 'b')]);

      final result = await importer.importWork(
        repository: repo,
        planId: plan.id,
        currentPlan: plan,
        item: _item,
      );

      expect(result.addedPointCount, 2);
      expect(result.plan.works.map((w) => w.bangumiId), contains(999));
      expect(result.plan.points.length, 2);
      expect(result.plan.points.map((p) => p.id),
          containsAll(['anitabi-999-a', 'anitabi-999-b']));
      // The work carried by each point matches the imported work.
      expect(result.plan.points.first.work.id, 'bangumi-999');
    });

    test('does not duplicate points already in the plan', () async {
      final plan = _emptyPlan();
      final repo = SamplePilgrimageRepository(plans: [plan]);
      final importer = _importerWith([_point(999, 'a'), _point(999, 'b')]);

      final first = await importer.importWork(
        repository: repo,
        planId: plan.id,
        currentPlan: plan,
        item: _item,
      );
      final second = await importer.importWork(
        repository: repo,
        planId: plan.id,
        currentPlan: first.plan,
        item: _item,
      );

      expect(second.addedPointCount, 0);
      expect(second.plan.points.length, 2);
    });

    test('adds the work with zero points when it has no spots', () async {
      final plan = _emptyPlan();
      final repo = SamplePilgrimageRepository(plans: [plan]);
      final importer = _importerWith(const []);

      final result = await importer.importWork(
        repository: repo,
        planId: plan.id,
        currentPlan: plan,
        item: _item,
      );

      expect(result.addedPointCount, 0);
      expect(result.plan.works.map((w) => w.bangumiId), contains(999));
    });

    test('autoPartition groups imported points into named areas', () async {
      final plan = _emptyPlan();
      final repo = SamplePilgrimageRepository(plans: [plan]);
      // Two far-apart clusters of 3 points each.
      final importer = _importerWith([
        _point(999, 'a0', 35.0000, 135.0000),
        _point(999, 'a1', 35.0002, 135.0002),
        _point(999, 'a2', 35.0004, 135.0004),
        _point(999, 'b0', 35.5000, 135.5000),
        _point(999, 'b1', 35.5002, 135.5002),
        _point(999, 'b2', 35.5004, 135.5004),
      ]);

      final result = await importer.importWork(
        repository: repo,
        planId: plan.id,
        currentPlan: plan,
        item: _item,
        autoPartition: true,
        fallbackAreaName: (index) => 'Area $index',
      );

      expect(result.addedPointCount, 6);
      expect(result.areaCount, 2);
      expect(result.createdAreas.length, 2);
      expect(result.plan.groups.length, 2);
      expect(result.plan.groups.map((g) => g.name), containsAll(['Area 0', 'Area 1']));
      // Every imported point landed in a group with a centroid anchor.
      expect(result.plan.points.every((p) => p.groupId != null), isTrue);
      expect(result.plan.groups.every((g) => g.anchorLatitude != null), isTrue);
      // Created areas expose centroids for background station naming.
      expect(result.createdAreas.every((a) => a.groupId.isNotEmpty), isTrue);
    });
  });
}

WorkImporter _importerWith(List<AnitabiPoint> points) =>
    WorkImporter(anitabiClient: _FakeAnitabiClient(points));
