import 'package:anitrip/app_theme.dart';
import 'package:anitrip/data/pilgrimage_repository.dart';
import 'package:anitrip/data/sample_pilgrimage_repository.dart';
import 'package:anitrip/l10n/app_localizations.dart';
import 'package:anitrip/point_detail/anchor_correction_queue_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpSubject(
    WidgetTester tester,
    PilgrimageRepository repository,
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
        home: AnchorCorrectionQueueScreen(repository: repository),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> submit(
    PilgrimageRepository repository,
    String id, {
    double? suggestedLatitude,
    double? suggestedLongitude,
    String? description,
  }) async {
    await repository.submitAnchorCorrection(
      AnchorCorrectionInput(
        planId: 'plan1',
        pointId: id,
        workId: 'work1',
        workTitle: 'Suzume',
        pointName: 'Kagurazaka Stairs',
        source: 'anitabi',
        sourceId: id,
        pointLatitude: 35.7012,
        pointLongitude: 139.7401,
        suggestedLatitude: suggestedLatitude,
        suggestedLongitude: suggestedLongitude,
        description: description,
      ),
    );
  }

  testWidgets('shows empty state when nothing has been reported', (
    tester,
  ) async {
    await pumpSubject(tester, SamplePilgrimageRepository());

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.textContaining('No pending corrections yet'), findsOneWidget);
    expect(find.byWidgetPredicate((widget) => widget is FilledButton), findsNothing);
  });

  testWidgets('lists submitted corrections with their details', (
    tester,
  ) async {
    final repository = SamplePilgrimageRepository();
    await submit(
      repository,
      'point-a',
      suggestedLatitude: 35.7019,
      suggestedLongitude: 139.7406,
      description: 'The actual spot is about 50m north of the pin.',
    );

    await pumpSubject(tester, repository);

    expect(find.text('Kagurazaka Stairs'), findsOneWidget);
    expect(
      find.text('Current location: 35.70120, 139.74010'),
      findsOneWidget,
    );
    expect(find.text('35.70190, 139.74060'), findsOneWidget);
    expect(
      find.text('The actual spot is about 50m north of the pin.'),
      findsOneWidget,
    );
    expect(find.textContaining('1 pending'), findsWidgets);
  });

  testWidgets('falls back to work title when the point has no name', (
    tester,
  ) async {
    final repository = SamplePilgrimageRepository();
    await repository.submitAnchorCorrection(
      const AnchorCorrectionInput(
        pointId: 'point-b',
        workTitle: '5 Centimeters per Second',
        pointLatitude: 35.0,
        pointLongitude: 139.0,
      ),
    );

    await pumpSubject(tester, repository);

    expect(find.text('5 Centimeters per Second'), findsOneWidget);
    expect(find.text('No suggested coordinate'), findsOneWidget);
  });

  testWidgets('deleting a report removes it from the queue', (tester) async {
    final repository = SamplePilgrimageRepository();
    await submit(repository, 'point-c', description: 'first report');
    await submit(repository, 'point-d', description: 'second report');

    await pumpSubject(tester, repository);
    expect(find.text('first report'), findsOneWidget);
    expect(find.text('second report'), findsOneWidget);

    // Reports are newest-first, so the first delete button targets the
    // most recent submission.
    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();
    expect(find.text('Delete this correction report?'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(find.text('second report'), findsNothing);
    expect(find.text('first report'), findsOneWidget);
    expect(await repository.loadAnchorCorrections(), hasLength(1));
  });

  testWidgets('canceling the delete dialog keeps the report', (tester) async {
    final repository = SamplePilgrimageRepository();
    await submit(repository, 'point-e', description: 'keep me');

    await pumpSubject(tester, repository);
    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('keep me'), findsOneWidget);
    expect(await repository.loadAnchorCorrections(), hasLength(1));
  });

  testWidgets('exported reports leave the pending queue', (tester) async {
    final repository = SamplePilgrimageRepository();
    await submit(repository, 'point-f', description: 'handled');

    await pumpSubject(tester, repository);
    expect(find.text('handled'), findsOneWidget);

    final pending = await repository.loadAnchorCorrections();
    await repository.markAnchorCorrectionsExported(
      pending.map((item) => item.id).toList(growable: false),
    );

    // Unmount first: Flutter would otherwise preserve the previous State.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await pumpSubject(tester, repository);
    expect(find.text('handled'), findsNothing);
    expect(find.textContaining('No pending corrections yet'), findsOneWidget);
    // The report itself is retained (soft delete-by-export), only hidden.
    expect(await repository.loadAnchorCorrections(onlyPending: false), hasLength(1));
  });
}
