import 'dart:async';

import 'package:anitrip/data/anitabi_client.dart';
import 'package:anitrip/explore/explore_screen.dart';
import 'package:anitrip/explore/widgets/explore_search_bar.dart';
import 'package:anitrip/l10n/app_localizations.dart';
import 'package:anitrip/plan/pilgrimage_models.dart';
import 'package:anitrip/plan/pilgrimage_plan_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Catalog never resolves → exercises the skeleton loading state.
class _HangingAnitabiClient extends AnitabiClient {
  _HangingAnitabiClient() : super();

  @override
  Future<List<AnitabiMapWorkLite>> listWorks() =>
      Completer<List<AnitabiMapWorkLite>>().future;
}

/// Catalog always fails → exercises the error + retry path (both the catalog
/// section and search mode).
class _FailingAnitabiClient extends AnitabiClient {
  _FailingAnitabiClient() : super();

  @override
  Future<List<AnitabiMapWorkLite>> listWorks() async =>
      throw Exception('catalog unavailable');
}

PilgrimagePlan _emptyPlan() => PilgrimagePlan(
      id: 'test-plan',
      name: 'Test',
      area: 'Tokyo',
      works: const [],
      points: const [],
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

Widget _buildScreen(AnitabiClient client) => MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ExploreScreen(
        controller: PilgrimagePlanController(plan: _emptyPlan()),
        onOpenSearch: () {},
        onOpenWork: (_) async {},
        onPlanCreated: () async {},
        onPlanUpdated: () async {},
        anitabiClient: client,
      ),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows skeleton while the catalog is loading', (tester) async {
    await tester.pumpWidget(_buildScreen(_HangingAnitabiClient()));
    // A couple of frames so the future's pending state renders the skeleton.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byKey(const Key('catalog_skeleton')), findsOneWidget);
  });

  testWidgets('catalog failure shows the error message and a retry button',
      (tester) async {
    await tester.pumpWidget(_buildScreen(_FailingAnitabiClient()));
    await tester.pumpAndSettle();

    // The deferred error surfaces via the existing catalog error widget.
    expect(find.text('Failed to load works. Check your network and retry.'),
        findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Retry'), findsOneWidget);
  });

  testWidgets(
      'search mode distinguishes a catalog failure from no results and offers '
      'a retry', (tester) async {
    await tester.pumpWidget(_buildScreen(_FailingAnitabiClient()));
    await tester.pumpAndSettle();

    // Open the in-app search by tapping the collapsed search bar.
    await tester.tap(find.byType(ExploreSearchBar));
    await tester.pumpAndSettle();

    // Type a query; the debounced search awaits the (failed) catalog.
    await tester.enterText(find.byType(TextField), 'evangelion');
    // Advance past the 300ms search debounce so _performSearch runs.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    // Instead of a silent "no results", search mode shows the catalog error
    // with a retry that reloads the catalog and re-runs the query.
    expect(find.text('Failed to load works. Check your network and retry.'),
        findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Retry'), findsOneWidget);

    // Tapping retry must not crash and must keep the failed state visible
    // (the injected client keeps failing).
    await tester.tap(find.widgetWithText(OutlinedButton, 'Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Failed to load works. Check your network and retry.'),
        findsOneWidget);
  });
}
