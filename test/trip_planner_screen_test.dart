import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'package:anitrip/l10n/app_localizations.dart';
import 'package:anitrip/plan/pilgrimage_models.dart';
import 'package:anitrip/plan/trip_planner_screen.dart';

final _l10n = lookupAppLocalizations(const Locale('zh'));

PilgrimagePlan _plan({int pointCount = 4}) {
  final work = PilgrimageWork(
    id: 'w1',
    title: 'Work',
    subtitle: '',
    city: 'anime',
    source: WorkSource.manual,
  );
  final now = DateTime(2026);
  return PilgrimagePlan(
    id: 'plan-1',
    name: 'Chichibu',
    area: 'Saitama',
    works: [work],
    points: List<PilgrimagePoint>.generate(
      pointCount,
      (index) => PilgrimagePoint(
        id: 'p${index + 1}',
        work: work,
        name: 'Point ${index + 1}',
        subtitle: '',
        position: LatLng(35.0 + index * 0.01, 139.0),
        episodeLabel: '',
        referenceLabel: '',
      ),
    ),
    createdAt: now,
    updatedAt: now,
  );
}

Future<void> _pump(WidgetTester tester, PilgrimagePlan plan) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('zh'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: TripPlannerScreen(plan: plan),
    ),
  );
  await tester.pumpAndSettle();
}

/// 页面较长，ListView 视口外的子项不会构建，断言前先滚出来。
Future<void> _reveal(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the overview and a day timeline', (tester) async {
    await _pump(tester, _plan());

    expect(find.text(_l10n.tripPlannerOverview), findsOneWidget);
    expect(find.text(_l10n.tripPlannerDaysNeeded(1)), findsOneWidget);
    expect(find.text(_l10n.tripPlannerDayTitle(1)), findsOneWidget);
    expect(find.text('Point 1'), findsOneWidget);
    expect(find.text('Point 4'), findsOneWidget);

    await _reveal(tester, find.text(_l10n.tripPlannerNote));
    expect(find.text(_l10n.tripPlannerNote), findsOneWidget);
  });

  testWidgets('switching travel mode re-plans the trip', (tester) async {
    await _pump(tester, _plan());

    // 步行（默认）→ 公共交通：同一段路的耗时会变短，概览时长文案随之变化。
    final before = _l10n.tripPlannerTotalDuration(
      _durationOf(tester),
    );
    expect(find.text(before), findsOneWidget);

    await tester.tap(find.text(_l10n.tripPlannerModeTransit));
    await tester.pumpAndSettle();

    final after = _l10n.tripPlannerTotalDuration(_durationOf(tester));
    expect(after, isNot(before));
    expect(find.text(after), findsOneWidget);
  });

  testWidgets('tightening the daily budget splits the trip into more days',
      (tester) async {
    await _pump(tester, _plan());
    expect(find.text(_l10n.tripPlannerDaysNeeded(1)), findsOneWidget);

    // 每天 4 小时 + 每点停留 60 分钟：4 个点走不完，应切成多天。
    await tester.tap(find.text(_l10n.tripPlannerBudgetOption(4)));
    await tester.pumpAndSettle();
    await tester.tap(find.text(_l10n.tripPlannerSpotOption(60)));
    await tester.pumpAndSettle();

    // 概览在页面顶部，始终可见：4 个点在「4 小时/天 + 60 分钟/点」下装不进一天。
    expect(find.text(_l10n.tripPlannerDaysNeeded(2)), findsOneWidget);
    expect(find.text(_l10n.tripPlannerDaysNeeded(1)), findsNothing);

    await _reveal(tester, find.text(_l10n.tripPlannerDayTitle(2)));
    expect(find.text(_l10n.tripPlannerDayTitle(2)), findsOneWidget);
  });

  testWidgets('shows an empty state without spots', (tester) async {
    await _pump(tester, _plan(pointCount: 0));

    expect(find.text(_l10n.tripPlannerEmpty), findsOneWidget);
    expect(find.text(_l10n.tripPlannerOverview), findsNothing);
  });
}

/// 从概览里读出当前展示的总时长（避免依赖内部实现）。
String _durationOf(WidgetTester tester) {
  final text = tester
      .widgetList<Text>(find.byType(Text))
      .map((widget) => widget.data ?? '')
      .firstWhere(
        (value) => value.startsWith('合计约 '),
        orElse: () => '',
      );
  return text.replaceFirst('合计约 ', '');
}
