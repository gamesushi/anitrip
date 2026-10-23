import 'package:anitrip/map/map_spots.dart';
import 'package:anitrip/plan/pilgrimage_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

PilgrimageWork _work(String id, {int? bangumiId}) => PilgrimageWork(
  id: id,
  bangumiId: bangumiId,
  title: id,
  subtitle: '',
  city: '',
  source: WorkSource.bangumi,
);

PilgrimagePoint _point(
  String id,
  PilgrimageWork work,
  double lat,
  double lon, {
  String? sourceId,
}) => PilgrimagePoint(
  id: id,
  work: work,
  name: id,
  subtitle: '',
  position: LatLng(lat, lon),
  episodeLabel: '',
  referenceLabel: '',
  sourceId: sourceId,
);

PilgrimagePlan _plan(String id, List<PilgrimagePoint> points) => PilgrimagePlan(
  id: id,
  name: id,
  area: '',
  works: const [],
  points: points,
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

void main() {
  final workA = _work('a', bangumiId: 1);
  final workB = _work('b', bangumiId: 2);
  final workC = _work('c', bangumiId: 3);

  test('merges points of different works within the threshold', () {
    // ~11 m apart in latitude.
    final entries = flattenPlanPoints([
      _plan('pa', [_point('a1', workA, 35.0, 135.0)]),
      _plan('pb', [_point('b1', workB, 35.0001, 135.0)]),
    ]);

    final spots = clusterSpots(entries);

    expect(spots, hasLength(1));
    expect(spots.single.isShared, isTrue);
    expect(spots.single.entries.map((e) => e.planId), ['pa', 'pb']);
  });

  test('keeps distant points apart', () {
    // ~110 m apart.
    final entries = flattenPlanPoints([
      _plan('pa', [_point('a1', workA, 35.0, 135.0)]),
      _plan('pb', [_point('b1', workB, 35.001, 135.0)]),
    ]);

    expect(clusterSpots(entries), hasLength(2));
  });

  test('merges across grid cell and longitude boundaries', () {
    // Dense sweep: every pair ~20 m apart along longitude must merge no matter
    // where the cell boundaries fall.
    for (var i = 0; i < 200; i += 1) {
      final lon = 135.0 + i * 0.00003;
      final entries = flattenPlanPoints([
        _plan('pa', [_point('a$i', workA, 35.0, lon)]),
        _plan('pb', [_point('b$i', workB, 35.0, lon + 0.0002)]),
      ]);
      expect(clusterSpots(entries), hasLength(1), reason: 'lon=$lon');
    }
  });

  test('never merges two points of the same work', () {
    final entries = flattenPlanPoints([
      _plan('pa', [
        _point('a1', workA, 35.0, 135.0),
        _point('a2', workA, 35.00005, 135.0),
      ]),
    ]);

    expect(clusterSpots(entries), hasLength(2));
  });

  test('three works at one place form one spot with three entries', () {
    final entries = flattenPlanPoints([
      _plan('pa', [_point('a1', workA, 35.0, 135.0)]),
      _plan('pb', [_point('b1', workB, 35.00005, 135.0)]),
      _plan('pc', [_point('c1', workC, 35.0, 135.00005)]),
    ]);

    final spots = clusterSpots(entries);

    expect(spots, hasLength(1));
    expect(spots.single.entries, hasLength(3));
  });

  test('same work imported into two plans is deduplicated', () {
    final sameWorkOtherId = _work('a-copy', bangumiId: 1);
    final entries = flattenPlanPoints([
      _plan('active', [_point('a1', workA, 35.0, 135.0, sourceId: 's1')]),
      _plan('other', [
        _point('a1-copy', sameWorkOtherId, 35.0, 135.0, sourceId: 's1'),
        _point('a2-copy', sameWorkOtherId, 35.5, 135.5, sourceId: 's2'),
      ]),
    ]);

    expect(entries.map((e) => e.point.id), ['a1', 'a2-copy']);
    expect(entries.first.planId, 'active');
  });

  test('work key prefers bangumi id and color is deterministic', () {
    expect(workKeyOf(workA), '1');
    expect(workKeyOf(_work('manual-x')), 'manual-x');
    expect(mapColorForWorkKey('1'), mapColorForWorkKey('1'));
  });
}
