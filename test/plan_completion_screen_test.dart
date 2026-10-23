import 'package:anitrip/app_theme.dart';
import 'package:anitrip/l10n/app_localizations.dart';
import 'package:anitrip/plan/pilgrimage_models.dart';
import 'package:anitrip/plan/plan_completion_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

PilgrimagePoint point(String id, String name, {String? groupId}) {
  return PilgrimagePoint(
    id: id,
    work: PilgrimageWork(
      id: 'work-1',
      title: 'Suzume',
      subtitle: '2022',
      city: 'Tokyo',
      source: WorkSource.manual,
    ),
    name: name,
    subtitle: 'subtitle',
    position: const LatLng(35.7, 139.7),
    episodeLabel: 'ep',
    referenceLabel: 'ref',
    groupId: groupId,
  );
}

PilgrimagePlan buildPlan({
  required List<PilgrimagePoint> points,
  Set<String> completed = const {},
  List<PilgrimagePlanGroup> groups = const [],
}) {
  final now = DateTime.utc(2026, 1, 1);
  return PilgrimagePlan(
    id: 'plan-1',
    name: 'Chichibu pilgrimage',
    area: 'Saitama',
    works: [point('seed', 'Seed').work],
    groups: groups,
    points: points,
    completedPointIds: completed,
    createdAt: now,
    updatedAt: now,
  );
}

Future<void> pumpSubject(
  WidgetTester tester,
  PilgrimagePlan plan,
) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: PlanCompletionScreen(plan: plan),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders the headline ring and counts', (tester) async {
    await pumpSubject(
      tester,
      buildPlan(
        points: [point('p1', 'Spot One'), point('p2', 'Spot Two')],
        completed: {'p1'},
      ),
    );

    expect(find.text('Pilgrimage progress'), findsWidgets);
    expect(find.text('Chichibu pilgrimage'), findsOneWidget);
    expect(find.text('50%'), findsOneWidget);
    expect(find.text('1/2'), findsWidgets);
    expect(find.text('1 of 2 spots visited'), findsOneWidget);

    final ring = tester.widget<CircularProgressIndicator>(
      find.byType(CircularProgressIndicator),
    );
    expect(ring.value, closeTo(0.5, 0.001));
  });

  testWidgets('splits visited and remaining into sections', (tester) async {
    await pumpSubject(
      tester,
      buildPlan(
        points: [
          point('p1', 'Done Spot'),
          point('p2', 'Pending Spot'),
        ],
        completed: {'p1'},
      ),
    );

    expect(find.text('Visited'), findsOneWidget);
    expect(find.text('Still to visit'), findsOneWidget);
    expect(find.text('Done Spot'), findsOneWidget);
    expect(find.text('Pending Spot'), findsOneWidget);
    expect(find.text('Done Spot'), findsWidgets);
    // The remaining count badge uses the localized phrase.
    expect(find.text('1 spots left'), findsOneWidget);
  });

  testWidgets('celebrates a fully completed plan', (tester) async {
    await pumpSubject(
      tester,
      buildPlan(
        points: [point('p1', 'Spot One'), point('p2', 'Spot Two')],
        completed: {'p1', 'p2'},
      ),
    );

    expect(find.text('100%'), findsOneWidget);
    expect(find.text('2/2'), findsWidgets);
    expect(find.text('Every spot visited — you completed it!'), findsWidgets);
    expect(find.text('2 spots left'), findsNothing);
  });

  testWidgets('empty plan explains itself instead of showing 100%', (
    tester,
  ) async {
    await pumpSubject(tester, buildPlan(points: []));

    expect(find.text('0%'), findsOneWidget);
    expect(find.text('This plan has no spots yet.'), findsOneWidget);
    expect(find.text('Every spot visited — you completed it!'), findsNothing);
  });

  testWidgets('nothing checked in yet shows the empty visited note', (
    tester,
  ) async {
    await pumpSubject(
      tester,
      buildPlan(points: [point('p1', 'Spot One')]),
    );

    expect(find.text('Nothing checked in yet.'), findsOneWidget);
    expect(find.text('0/1'), findsWidgets);
  });

  testWidgets('renders per-group progress bars', (tester) async {
    final groups = [
      PilgrimagePlanGroup(
        id: 'g-a',
        name: 'Around Chichibu Station',
        orderIndex: 0,
        createdAt: DateTime.utc(2026, 1, 1),
      ),
      PilgrimagePlanGroup(
        id: 'g-b',
        name: 'Mitsumine',
        orderIndex: 1,
        createdAt: DateTime.utc(2026, 1, 1),
      ),
    ];
    await pumpSubject(
      tester,
      buildPlan(
        groups: groups,
        points: [
          point('a1', 'A One', groupId: 'g-a'),
          point('a2', 'A Two', groupId: 'g-a'),
          point('b1', 'B One', groupId: 'g-b'),
        ],
        completed: {'a1', 'b1'},
      ),
    );

    expect(find.text('By group'), findsOneWidget);
    expect(find.text('Around Chichibu Station'), findsOneWidget);
    expect(find.text('Mitsumine'), findsOneWidget);
    expect(find.text('1/2'), findsWidgets);
    expect(find.text('1/1'), findsOneWidget);

    final bars = tester
        .widgetList<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        )
        .map((bar) => bar.value)
        .toList();
    expect(bars, [closeTo(0.5, 0.001), closeTo(1.0, 0.001)]);
  });

  testWidgets('uses the localized label for ungrouped points', (tester) async {
    await pumpSubject(
      tester,
      buildPlan(points: [point('loose', 'Loose Spot', groupId: null)]),
    );

    expect(find.text('Ungrouped'), findsOneWidget);
    expect(find.text('0/1'), findsWidgets);
  });
}
