import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'package:anitrip/data/sample_pilgrimage_repository.dart';
import 'package:anitrip/l10n/app_localizations.dart';
import 'package:anitrip/plan/pilgrimage_models.dart';
import 'package:anitrip/plan_transfer/import_export_screen.dart';

final _l10n = lookupAppLocalizations(const Locale('zh'));

PilgrimagePlan _plan({int pointCount = 2, String area = 'Tokyo'}) {
  final work = PilgrimageWork(
    id: 'w1',
    title: 'Work',
    subtitle: '',
    city: 'anime',
    source: WorkSource.manual,
  );
  final now = DateTime(2026);
  final points = List<PilgrimagePoint>.generate(
    pointCount,
    (index) => PilgrimagePoint(
      id: 'p${index + 1}',
      work: work,
      name: 'Point ${index + 1}',
      subtitle: '',
      position: const LatLng(35.0, 139.0),
      episodeLabel: '',
      referenceLabel: '',
    ),
  );
  return PilgrimagePlan(
    id: 'plan-1',
    name: 'Kimi no Na wa',
    area: area,
    works: [work],
    points: points,
    createdAt: now,
    updatedAt: now,
    completedPointIds: pointCount > 0 ? {'p1'} : const <String>{},
  );
}

/// 分享段落在 ListView 靠下位置，默认视口外不会构建，需先滚动到可见。
Future<void> _reveal(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpScreen(WidgetTester tester, PilgrimagePlan plan) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('zh'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ImportExportScreen(
        plan: plan,
        repository: SamplePilgrimageRepository(
          plans: [plan],
          visitRecords: const <PilgrimageVisitRecord>[],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    // 真机上有平台实现；测试环境里 Clipboard.setData 走真实 channel 会挂住，
    // 这里用 mock 兜住（返回 true 即可满足 Clipboard.setData 的返回约定）。
    TestWidgetsFlutterBinding.ensureInitialized()
        .defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        return true;
      }
      return null;
    });
  });

  testWidgets('shows the share section with plan stats', (tester) async {
    await _pumpScreen(tester, _plan());
    await _reveal(tester, find.text(_l10n.planShareSection));

    expect(find.text(_l10n.planShareSection), findsOneWidget);
    expect(find.text(_l10n.planShareTitle('Kimi no Na wa')), findsOneWidget);
    expect(find.text(_l10n.planShareStats(1, 2)), findsOneWidget);
    expect(find.text(_l10n.planShareProgress(1, 2, 50)), findsOneWidget);
    expect(find.text(_l10n.planShareCopy), findsOneWidget);
    expect(find.text(_l10n.planShareFile), findsOneWidget);
  });

  testWidgets('copying the share text confirms with a snackbar', (tester) async {
    await _pumpScreen(tester, _plan());
    await _reveal(tester, find.text(_l10n.planShareCopy));

    await tester.tap(find.text(_l10n.planShareCopy));
    await tester.pumpAndSettle();

    expect(find.text(_l10n.planShareCopied), findsOneWidget);
  });

  testWidgets('warns instead of sharing an empty plan', (tester) async {
    await _pumpScreen(tester, _plan(pointCount: 0, area: ''));
    await _reveal(tester, find.text(_l10n.planShareEmpty));

    expect(find.text(_l10n.planShareEmpty), findsOneWidget);

    await tester.tap(find.text(_l10n.planShareCopy));
    await tester.pumpAndSettle();

    expect(find.text(_l10n.planShareEmpty), findsWidgets);
    expect(find.text(_l10n.planShareCopied), findsNothing);
  });
}
