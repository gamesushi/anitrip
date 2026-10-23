import 'package:anitrip/l10n/app_localizations.dart';
import 'package:anitrip/map/map_spots.dart';
import 'package:anitrip/map/map_work_widgets.dart';
import 'package:anitrip/plan/pilgrimage_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('zh'),
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('MapSpotCountBadge renders count number', (tester) async {
    await tester.pumpWidget(_wrap(const MapSpotCountBadge(count: 3)));
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('MapWorkFilterBar displays label and responds to taps', (tester) async {
    var tapped = false;
    var cleared = false;

    await tester.pumpWidget(
      _wrap(
        MapWorkFilterBar(
          label: '全部作品 (5)',
          onTap: () => tapped = true,
          onClear: () => cleared = true,
        ),
      ),
    );

    expect(find.text('全部作品 (5)'), findsOneWidget);
    await tester.tap(find.text('全部作品 (5)'));
    expect(tapped, isTrue);

    await tester.tap(find.byIcon(Icons.close));
    expect(cleared, isTrue);
  });

  testWidgets('MapSpotPanel displays works list and checkboxes', (tester) async {
    final workA = PilgrimageWork(
      id: 'w1',
      title: '吹响吧！上低音号',
      subtitle: '',
      city: '宇治',
      source: WorkSource.bangumi,
    );
    final workB = PilgrimageWork(
      id: 'w2',
      title: '利兹与青鸟',
      subtitle: '',
      city: '宇治',
      source: WorkSource.bangumi,
    );
    final pointA = PilgrimagePoint(
      id: 'p1',
      work: workA,
      name: '大吉山登山口',
      subtitle: '',
      position: const LatLng(34.89, 135.81),
      episodeLabel: '第8话',
      referenceLabel: '',
    );
    final pointB = PilgrimagePoint(
      id: 'p2',
      work: workB,
      name: '宇治桥',
      subtitle: '',
      position: const LatLng(34.89, 135.81),
      episodeLabel: '第1话',
      referenceLabel: '',
    );

    final rows = [
      MapSpotRow(
        entry: MapPointEntry(planId: 'plan1', point: pointA),
        status: VisitStatus.pending,
        selected: true,
      ),
      MapSpotRow(
        entry: MapPointEntry(planId: 'plan2', point: pointB),
        status: VisitStatus.completed,
        selected: false,
      ),
    ];

    String? toggledKey;

    await tester.pumpWidget(
      _wrap(
        MapSpotPanel(
          rows: rows,
          onToggleWork: (key) => toggledKey = key,
          onNavigate: () {},
          onOpenDetail: (_) {},
          onOpenCamera: (_) {},
        ),
      ),
    );

    expect(find.text('该地点有 2 部作品'), findsOneWidget);
    expect(find.text('吹响吧！上低音号'), findsOneWidget);
    expect(find.text('利兹与青鸟'), findsOneWidget);

    // Tap on second work to toggle
    await tester.tap(find.text('利兹与青鸟'));
    expect(toggledKey, 'w2');
  });
}
