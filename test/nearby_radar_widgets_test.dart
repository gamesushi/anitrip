import 'package:anitrip/data/anitabi_client.dart';
import 'package:anitrip/l10n/app_localizations.dart';
import 'package:anitrip/map/nearby_radar_service.dart';
import 'package:anitrip/map/nearby_radar_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

Widget _wrap(Widget child, [Locale locale = const Locale('zh')]) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: locale,
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  final testWork = AnitabiMapWorkLite(
    bangumiId: 101,
    titleZh: '吹响吧！上低音号',
    titleOriginal: '響け！ユーフォニアム',
    subtitle: '',
    city: '宇治',
    center: const LatLng(34.89, 135.81),
    zoom: 14,
    points: const {},
  );

  testWidgets('NearbyRadarMarker renders and responds to tap', (tester) async {
    var tapped = false;
    final spot = NearbyRadarSpot(
      bangumiId: 101,
      pointId: 'p1',
      work: testWork,
      position: const LatLng(34.89, 135.81),
      distanceMeters: 450,
      isImported: true,
    );

    await tester.pumpWidget(
      _wrap(
        NearbyRadarMarker(
          spot: spot,
          selected: false,
          onTap: () => tapped = true,
        ),
      ),
    );

    expect(find.byIcon(Icons.radar), findsOneWidget);
    // Spot is imported, so check icon is rendered
    expect(find.byIcon(Icons.check), findsOneWidget);

    await tester.tap(find.byIcon(Icons.radar));
    expect(tapped, isTrue);
  });

  testWidgets('NearbyRadarBanner displays found count and rescan in zh', (tester) async {
    var rescanned = false;
    var closed = false;

    await tester.pumpWidget(
      _wrap(
        NearbyRadarBanner(
          count: 12,
          isScanning: false,
          showRescan: true,
          onRescan: () => rescanned = true,
          onClose: () => closed = true,
        ),
      ),
    );

    expect(find.text('附近发现 12 处动漫圣地'), findsOneWidget);
    expect(find.text('在此区域扫描'), findsOneWidget);

    await tester.tap(find.text('在此区域扫描'));
    expect(rescanned, isTrue);

    await tester.tap(find.byIcon(Icons.close));
    expect(closed, isTrue);
  });

  testWidgets('NearbyRadarBanner displays found count and rescan in en', (tester) async {
    await tester.pumpWidget(
      _wrap(
        NearbyRadarBanner(
          count: 5,
          isScanning: false,
          showRescan: true,
          onRescan: () {},
          onClose: () {},
        ),
        const Locale('en'),
      ),
    );

    expect(find.text('Found 5 anime spots nearby'), findsOneWidget);
    expect(find.text('Scan this area'), findsOneWidget);
  });

  testWidgets('NearbyRadarBanner displays scanning state and no spots found', (tester) async {
    await tester.pumpWidget(
      _wrap(
        NearbyRadarBanner(
          count: 0,
          isScanning: true,
          showRescan: false,
          onRescan: () {},
          onClose: () {},
        ),
      ),
    );

    expect(find.text('正在扫描周边圣地...'), findsOneWidget);

    await tester.pumpWidget(
      _wrap(
        NearbyRadarBanner(
          count: 0,
          isScanning: false,
          showRescan: false,
          onRescan: () {},
          onClose: () {},
        ),
      ),
    );

    expect(find.text('周边 5km 内未收录动漫圣地'), findsOneWidget);
  });
}
