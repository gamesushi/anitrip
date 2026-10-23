import 'package:anitrip/data/anitabi_client.dart';
import 'package:anitrip/map/nearby_radar_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

void main() {
  group('formatRadarDistance', () {
    test('formats meters under 1km', () {
      expect(formatRadarDistance(0), '0 m');
      expect(formatRadarDistance(250), '250 m');
      expect(formatRadarDistance(999.4), '999 m');
    });

    test('formats kilometers for 1km and above', () {
      expect(formatRadarDistance(1000), '1.0 km');
      expect(formatRadarDistance(1500), '1.5 km');
      expect(formatRadarDistance(5230), '5.2 km');
    });
  });

  group('NearbyRadarService.scanNearby', () {
    const service = NearbyRadarService();
    const center = LatLng(35.0, 135.0);

    final work1 = AnitabiMapWorkLite(
      bangumiId: 101,
      titleZh: '作品一',
      titleOriginal: 'Work 1',
      subtitle: '',
      city: '京都',
      center: center,
      zoom: 14,
      points: {
        // Very close (~0m)
        'p1': const AnitabiMapLitePoint(
          id: 'p1',
          position: LatLng(35.0, 135.0),
        ),
        // ~1.1 km north
        'p2': const AnitabiMapLitePoint(
          id: 'p2',
          position: LatLng(35.01, 135.0),
        ),
        // Far away (~220 km)
        'p3': const AnitabiMapLitePoint(
          id: 'p3',
          position: LatLng(37.0, 135.0),
        ),
      },
    );

    final work2 = AnitabiMapWorkLite(
      bangumiId: 102,
      titleZh: '作品二',
      titleOriginal: 'Work 2',
      subtitle: '',
      city: '宇治',
      center: center,
      zoom: 14,
      points: {
        // ~500m north
        'p4': const AnitabiMapLitePoint(
          id: 'p4',
          position: LatLng(35.0045, 135.0),
        ),
      },
    );

    test('filters out points farther than radiusMeters', () {
      final results = service.scanNearby(
        center: center,
        catalogWorks: [work1],
        importedBangumiIds: const {},
        radiusMeters: 2000,
      );

      // p1 (~0m) and p2 (~1.1km) should be included, p3 (~220km) excluded
      expect(results.length, 2);
      expect(results.map((r) => r.pointId).toList(), ['p1', 'p2']);
    });

    test('sorts spots ascending by distance', () {
      final results = service.scanNearby(
        center: center,
        catalogWorks: [work1, work2],
        importedBangumiIds: const {},
        radiusMeters: 5000,
      );

      expect(results.length, 3);
      // p1 is closest (~0m), then p4 (~500m), then p2 (~1.1km)
      expect(results[0].pointId, 'p1');
      expect(results[1].pointId, 'p4');
      expect(results[2].pointId, 'p2');
      expect(results[0].distanceMeters <= results[1].distanceMeters, isTrue);
      expect(results[1].distanceMeters <= results[2].distanceMeters, isTrue);
    });

    test('marks isImported correctly according to importedBangumiIds', () {
      final results = service.scanNearby(
        center: center,
        catalogWorks: [work1, work2],
        importedBangumiIds: {102},
        radiusMeters: 5000,
      );

      final p1 = results.firstWhere((r) => r.pointId == 'p1');
      final p4 = results.firstWhere((r) => r.pointId == 'p4');

      expect(p1.isImported, isFalse);
      expect(p4.isImported, isTrue);
    });

    test('respects maxSpots limit', () {
      final results = service.scanNearby(
        center: center,
        catalogWorks: [work1, work2],
        importedBangumiIds: const {},
        radiusMeters: 5000,
        maxSpots: 2,
      );

      expect(results.length, 2);
      expect(results[0].pointId, 'p1');
      expect(results[1].pointId, 'p4');
    });
  });
}
