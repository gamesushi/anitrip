import 'package:anitrip/plan/pilgrimage_models.dart';
import 'package:anitrip/plan/plan_completion_summary.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

PilgrimageWork work([String id = 'work-1']) => PilgrimageWork(
      id: id,
      title: 'すずめの戸締まり',
      subtitle: '2022',
      city: 'Tokyo',
      source: WorkSource.manual,
    );

PilgrimagePoint point(
  String id, {
  String? groupId = 'g1',
  int? order,
  String name = 'spot',
}) {
  return PilgrimagePoint(
    id: id,
    work: work(),
    name: name,
    subtitle: 'subtitle',
    position: const LatLng(35.7, 139.7),
    episodeLabel: 'ep',
    referenceLabel: 'ref',
    groupId: groupId,
    groupOrderIndex: order,
  );
}

PilgrimagePlan planWith({
  required List<PilgrimagePoint> points,
  Set<String> completed = const {},
  List<PilgrimagePlanGroup>? groups,
}) {
  final now = DateTime.utc(2026, 1, 1);
  return PilgrimagePlan(
    id: 'plan-1',
    name: '秩父巡礼',
    area: '埼玉',
    works: [work()],
    groups: groups ??
        [
          PilgrimagePlanGroup(
            id: 'g1',
            name: '_zone_a',
            orderIndex: 0,
            createdAt: now,
          ),
        ],
    points: points,
    completedPointIds: completed,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('PlanCompletionSummary counts', () {
    test('reports zero progress for a fresh plan', () {
      final summary = PlanCompletionSummary.of(
        planWith(points: [point('p1'), point('p2'), point('p3')]),
      );

      expect(summary.total, 3);
      expect(summary.completed, 0);
      expect(summary.remaining, 3);
      expect(summary.percent, 0);
      expect(summary.ratio, 0.0);
      expect(summary.isComplete, isFalse);
      expect(summary.isEmpty, isFalse);
      expect(summary.remainingPoints.map((p) => p.id), ['p1', 'p2', 'p3']);
      expect(summary.visitedPoints, isEmpty);
    });

    test('partial progress rounds instead of truncating', () {
      // 2 of 3 = 66.7% -> 67, and the ring must not read as complete.
      final summary = PlanCompletionSummary.of(
        planWith(
          points: [point('p1'), point('p2'), point('p3')],
          completed: {'p1', 'p2'},
        ),
      );

      expect(summary.completed, 2);
      expect(summary.percent, 67);
      expect(summary.ratio, closeTo(0.6667, 0.0001));
      expect(summary.isComplete, isFalse);
    });

    test('a fully walked plan is complete but never empty', () {
      final summary = PlanCompletionSummary.of(
        planWith(
          points: [point('p1'), point('p2')],
          completed: {'p1', 'p2'},
        ),
      );

      expect(summary.percent, 100);
      expect(summary.ratio, 1.0);
      expect(summary.isComplete, isTrue);
      expect(summary.isEmpty, isFalse);
      expect(summary.remainingPoints, isEmpty);
    });

    test('an empty plan reports 0%, not 100%', () {
      final summary = PlanCompletionSummary.of(planWith(points: []));

      expect(summary.total, 0);
      expect(summary.percent, 0);
      expect(summary.ratio, 0.0);
      expect(summary.isEmpty, isTrue);
      expect(summary.isComplete, isFalse);
    });

    test('ignores completed ids whose points no longer exist', () {
      final summary = PlanCompletionSummary.of(
        planWith(
          points: [point('p1'), point('p2')],
          completed: {'p1', 'deleted-point'},
        ),
      );

      expect(summary.total, 2);
      expect(summary.completed, 1);
      expect(summary.percent, 50);
      expect(summary.visitedPoints.map((p) => p.id), ['p1']);
    });
  });

  group('group roll-up', () {
    final groups = <PilgrimagePlanGroup>[
      PilgrimagePlanGroup(
        id: 'g-a',
        name: '秩父站周辺',
        orderIndex: 0,
        createdAt: DateTime.utc(2026, 1, 1),
      ),
      PilgrimagePlanGroup(
        id: 'g-b',
        name: '三峯',
        orderIndex: 1,
        createdAt: DateTime.utc(2026, 1, 1),
      ),
    ];

    test('splits points by group and keeps group order', () {
      final summary = PlanCompletionSummary.of(
        planWith(
          groups: groups,
          points: [
            point('a1', groupId: 'g-a'),
            point('a2', groupId: 'g-a'),
            point('b1', groupId: 'g-b'),
          ],
          completed: {'a1', 'b1'},
        ),
      );

      expect(summary.groups.map((g) => g.id), ['g-a', 'g-b']);
      final bucketA = summary.groups.first;
      expect(bucketA.name, '秩父站周辺');
      expect(bucketA.total, 2);
      expect(bucketA.completed, 1);
      expect(bucketA.percent, 50);
      expect(bucketA.isComplete, isFalse);

      final bucketB = summary.groups[1];
      expect(bucketB.percent, 100);
      expect(bucketB.isComplete, isTrue);
    });

    test('collects ungrouped points into a flagged bucket', () {
      final summary = PlanCompletionSummary.of(
        planWith(
          groups: groups,
          points: [
            point('a1', groupId: 'g-a'),
            point('loose', groupId: null),
          ],
        ),
      );

      final ungrouped = summary.groups.last;
      expect(ungrouped.isUngrouped, isTrue);
      expect(ungrouped.total, 1);
      expect(summary.groups.first.isUngrouped, isFalse);
    });

    test('points pointing at a removed group count as ungrouped', () {
      final summary = PlanCompletionSummary.of(
        planWith(
          groups: groups,
          points: [
            point('a1', groupId: 'g-a'),
            point('orphan', groupId: 'g-deleted'),
          ],
          completed: {'orphan'},
        ),
      );

      final orphans = summary.groups.last;
      expect(orphans.isUngrouped, isTrue);
      expect(orphans.total, 1);
      expect(orphans.completed, 1);
    });

    test('omits the ungrouped bucket when every point has a group', () {
      final summary = PlanCompletionSummary.of(
        planWith(groups: groups, points: [point('a1', groupId: 'g-a')]),
      );

      // g-b has no points, so it is skipped as well — only g-a remains.
      expect(summary.groups, hasLength(1));
      expect(summary.groups.single.id, 'g-a');
      expect(summary.groups.single.isUngrouped, isFalse);
    });

    test('skips groups that hold no points', () {
      final emptyGroup = PilgrimagePlanGroup(
        id: 'g-empty',
        name: 'empty',
        orderIndex: 0,
        createdAt: DateTime.utc(2026, 1, 1),
      );
      final summary = PlanCompletionSummary.of(
        planWith(groups: [emptyGroup], points: []),
      );

      expect(summary.groups, isEmpty);
      final manual = const PlanGroupCompletion(
        id: 'x',
        name: 'x',
        points: [],
        completedPoints: [],
      );
      expect(manual.percent, 0);
      expect(manual.isComplete, isFalse);
    });
  });
}
