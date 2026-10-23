import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'package:anitrip/l10n/app_localizations.dart';
import 'package:anitrip/plan/pilgrimage_models.dart';
import 'package:anitrip/plan_transfer/plan_share_summary.dart';

PilgrimageWork _work(String id) {
  return PilgrimageWork(
    id: id,
    title: 'Work $id',
    subtitle: '',
    city: 'anime',
    source: WorkSource.manual,
  );
}

PilgrimagePoint _point(String id, PilgrimageWork work) {
  return PilgrimagePoint(
    id: id,
    work: work,
    name: 'Point $id',
    subtitle: '',
    position: const LatLng(35.0, 139.0),
    episodeLabel: '',
    referenceLabel: '',
  );
}

PilgrimagePlan _plan({
  required List<PilgrimageWork> works,
  required List<PilgrimagePoint> points,
  Set<String> completedPointIds = const <String>{},
  String area = 'Tokyo',
  List<PilgrimagePlanGroup> groups = const <PilgrimagePlanGroup>[],
}) {
  final now = DateTime(2026);
  return PilgrimagePlan(
    id: 'plan-1',
    name: 'Kimi no Na wa',
    area: area,
    works: works,
    groups: groups,
    points: points,
    createdAt: now,
    updatedAt: now,
    completedPointIds: completedPointIds,
  );
}

void main() {
  final l10n = planShareFallbackLocalizations();

  test('counts works, points and groups', () {
    final works = [_work('w1'), _work('w2')];
    final summary = buildPlanShareSummary(
      plan: _plan(
        works: works,
        points: [
          _point('p1', works[0]),
          _point('p2', works[1]),
          _point('p3', works[1]),
        ],
        groups: [
          PilgrimagePlanGroup(
            id: 'g1',
            name: 'Day 1',
            orderIndex: 0,
            createdAt: DateTime(2026),
          ),
        ],
      ),
    );

    expect(summary.planName, 'Kimi no Na wa');
    expect(summary.workCount, 2);
    expect(summary.pointCount, 3);
    expect(summary.groupCount, 1);
    expect(summary.recordCount, 0);
    expect(summary.completedCount, 0);
    expect(summary.isEmpty, isFalse);
    expect(summary.hasProgress, isFalse);
  });

  test('falls back to point works when the plan has no work entries', () {
    final work = _work('w9');
    final summary = buildPlanShareSummary(
      plan: _plan(
        works: const <PilgrimageWork>[],
        points: [_point('p1', work), _point('p2', work)],
      ),
    );

    expect(summary.workCount, 1);
    expect(summary.pointCount, 2);
  });

  test('ignores completed ids that no longer match a point', () {
    final works = [_work('w1')];
    final summary = buildPlanShareSummary(
      plan: _plan(
        works: works,
        points: [
          _point('p1', works[0]),
          _point('p2', works[0]),
          _point('p3', works[0]),
          _point('p4', works[0]),
        ],
        completedPointIds: {'p1', 'p3', 'deleted-point'},
      ),
    );

    expect(summary.completedCount, 2);
    expect(summary.progressPercent, 50);
    expect(summary.hasProgress, isTrue);
  });

  test('reports zero progress for an empty plan', () {
    final summary = buildPlanShareSummary(
      plan: _plan(works: const <PilgrimageWork>[], points: const []),
    );

    expect(summary.pointCount, 0);
    expect(summary.isEmpty, isTrue);
    expect(summary.progressPercent, 0);
  });

  test('message includes title, stats and footer', () {
    final works = [_work('w1')];
    final summary = buildPlanShareSummary(
      plan: _plan(works: works, points: [_point('p1', works[0])]),
    );
    final message = buildPlanShareMessage(l10n, summary);

    expect(message, contains('Kimi no Na wa'));
    expect(message, contains(l10n.planShareStats(1, 1)));
    expect(message, contains(l10n.planShareArea('Tokyo')));
    expect(message, endsWith(l10n.planShareFooter));
    // 没有打卡、没有记录时不出现对应行。
    expect(message, isNot(contains(l10n.planShareRecords(0))));
  });

  test('message omits area when the plan has none', () {
    final works = [_work('w1')];
    final summary = buildPlanShareSummary(
      plan: _plan(works: works, points: [_point('p1', works[0])], area: '  '),
    );
    final message = buildPlanShareMessage(l10n, summary);

    expect(summary.area, isEmpty);
    expect(message, isNot(contains(l10n.planShareArea(''))));
  });

  test('message adds progress and record lines when available', () {
    final works = [_work('w1')];
    final summary = buildPlanShareSummary(
      plan: _plan(
        works: works,
        points: [_point('p1', works[0]), _point('p2', works[0])],
        completedPointIds: {'p1'},
      ),
      visitRecords: [
        PilgrimageVisitRecord(
          id: 'r1',
          planId: 'plan-1',
          pointId: 'p1',
          workId: 'w1',
          photoPath: '/tmp/1.jpg',
          referenceMode: 'official',
          capturedAt: DateTime(2026),
        ),
      ],
    );
    final message = buildPlanShareMessage(l10n, summary);

    expect(message, contains(l10n.planShareProgress(1, 2, 50)));
    expect(message, contains(l10n.planShareRecords(1)));
  });

  test('subject reuses the title line', () {
    final works = [_work('w1')];
    final summary = buildPlanShareSummary(
      plan: _plan(works: works, points: [_point('p1', works[0])]),
    );

    expect(buildPlanShareSubject(l10n, summary), l10n.planShareTitle('Kimi no Na wa'));
  });

  test('empty message helper points at adding spots first', () {
    expect(planShareEmptyMessage(l10n), l10n.planShareEmpty);
  });
}
