import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'package:anitrip/plan/pilgrimage_models.dart';
import 'package:anitrip/plan/trip_itinerary.dart';

/// 纬度每 0.01° ≈ 1112 m，用一列等距点构造可预测的路径。
ItineraryStop stop(String id, double lat) {
  return ItineraryStop(
    id: id,
    name: 'Stop $id',
    latitude: lat,
    longitude: 139.0,
  );
}

PilgrimagePoint _point(String id, String workId, double lat) {
  final work = PilgrimageWork(
    id: workId,
    title: 'Work $workId',
    subtitle: '',
    city: 'anime',
    source: WorkSource.manual,
  );
  return PilgrimagePoint(
    id: id,
    work: work,
    name: 'Point $id',
    subtitle: '',
    position: LatLng(lat, 139.0),
    episodeLabel: '',
    referenceLabel: '',
  );
}

void main() {
  group('estimateTravelMinutesForDistance', () {
    test('zero distance costs nothing', () {
      expect(estimateTravelMinutesForDistance(0), 0);
    });

    test('walk uses the detour factor and walking speed', () {
      // 1112 m × 1.35 = 1501 m ÷ 80 m/min = 18.76 → 19 分钟（步行无额外开销）
      final minutes = estimateTravelMinutesForDistance(1112);
      expect(minutes, 19);
    });

    test('short hops fall back to walking even in transit mode', () {
      // 200 m < 400 m 兜底 → 按步行算：270 m ÷ 80 = 3.4 → 4 分钟（不含等车 6 分钟）
      expect(estimateTravelMinutesForDistance(200, mode: TravelMode.transit), 4);
    });

    test('transit adds waiting overhead on longer hops', () {
      // 1112 m × 1.5 = 1668 m ÷ 250 = 6.7 → 7 + 6 = 13 分钟
      expect(estimateTravelMinutesForDistance(1112, mode: TravelMode.transit), 13);
    });

    test('driving is fastest over the same distance', () {
      final walk = estimateTravelMinutesForDistance(3000, mode: TravelMode.walk);
      final drive = estimateTravelMinutesForDistance(3000, mode: TravelMode.drive);
      expect(drive, lessThan(walk));
    });
  });

  group('buildTripItinerary', () {
    test('returns an empty itinerary without stops', () {
      final itinerary = buildTripItinerary(stops: const <ItineraryStop>[]);

      expect(itinerary.isEmpty, isTrue);
      expect(itinerary.dayCount, 0);
      expect(itinerary.pointCount, 0);
      expect(itinerary.totalDistanceMeters, 0);
    });

    test('a single stop becomes a one-day, zero-travel plan', () {
      final itinerary = buildTripItinerary(
        stops: [stop('a', 35.0)],
        spotVisitMinutes: 30,
      );

      expect(itinerary.dayCount, 1);
      expect(itinerary.days.single.pointCount, 1);
      expect(itinerary.days.single.distanceMeters, 0);
      expect(itinerary.days.single.travelMinutes, 0);
      expect(itinerary.days.single.visitMinutes, 30);
      expect(itinerary.days.single.stops.single.travelMinutes, 0);
    });

    test('walks the nearest neighbour and keeps a single day inside budget', () {
      final itinerary = buildTripItinerary(
        stops: [
          stop('a', 35.00),
          stop('b', 35.01),
          stop('c', 35.02),
          stop('d', 35.03),
        ],
        dailyBudgetMinutes: 480,
      );

      expect(itinerary.dayCount, 1);
      final day = itinerary.days.single;
      // 质心在 35.015，最远的 a 与 d 同距，按列表顺序取 a 起步，然后最近邻一路向北。
      expect(day.stops.map((s) => s.stop.id).toList(), ['a', 'b', 'c', 'd']);
      expect(day.pointCount, 4);
      expect(day.travelMinutes, 19 * 3);
      expect(day.visitMinutes, 120);
      expect(day.totalMinutes, 177);
      expect(itinerary.pointCount, 4);
    });

    test('splits into several days when the daily budget is tight', () {
      final itinerary = buildTripItinerary(
        stops: [
          stop('a', 35.00),
          stop('b', 35.01),
          stop('c', 35.02),
          stop('d', 35.03),
        ],
        dailyBudgetMinutes: 60,
        spotVisitMinutes: 30,
      );

      // 每天先花 30 分钟停留，再移动 19 分钟就超 60 分钟预算 → 一天一个点。
      expect(itinerary.dayCount, 4);
      expect(itinerary.days.map((d) => d.stops.single.stop.id).toList(),
          ['a', 'b', 'c', 'd']);
      for (final day in itinerary.days) {
        expect(day.pointCount, 1);
        expect(day.totalMinutes, 30);
      }
      // 天数按 1 起编号。
      expect(itinerary.days.map((d) => d.index).toList(), [1, 2, 3, 4]);
    });

    test('never loops when one spot already exceeds the budget', () {
      final itinerary = buildTripItinerary(
        stops: [stop('a', 35.00), stop('b', 35.01)],
        dailyBudgetMinutes: 10,
        spotVisitMinutes: 30,
      );

      expect(itinerary.dayCount, 2);
      expect(itinerary.pointCount, 2);
    });

    test('starts every day at the configured hour', () {
      final itinerary = buildTripItinerary(
        stops: [stop('a', 35.00), stop('b', 35.01)],
        startDate: DateTime(2026, 5, 1, 8, 30),
      );

      expect(itinerary.days.single.startAt, DateTime(2026, 5, 1, 8, 30));
      final second = itinerary.days.single.stops[1];
      expect(second.arrivalAt.isAfter(itinerary.days.single.startAt), isTrue);
    });

    test('totals add up across days', () {
      final itinerary = buildTripItinerary(
        stops: [
          stop('a', 35.00),
          stop('b', 35.01),
          stop('c', 35.02),
        ],
        dailyBudgetMinutes: 60,
      );

      final summedDistance = itinerary.days.fold<double>(
        0,
        (total, day) => total + day.distanceMeters,
      );
      final summedMinutes = itinerary.days.fold<int>(
        0,
        (total, day) => total + day.totalMinutes,
      );
      expect(itinerary.totalDistanceMeters, summedDistance);
      expect(itinerary.totalMinutes, summedMinutes);
    });
  });

  group('formatting helpers', () {
    test('distance switches to kilometres above 1000 m', () {
      expect(formatTripDistance(0), '0 m');
      expect(formatTripDistance(999), '999 m');
      expect(formatTripDistance(1500), '1.5 km');
    });

    test('duration switches to hours above 60 minutes', () {
      expect(formatTripDuration(45), '45 min');
      expect(formatTripDuration(60), '1h');
      expect(formatTripDuration(95), '1h 35m');
    });

    test('day load is a percentage of the daily budget', () {
      final itinerary = buildTripItinerary(
        stops: [stop('a', 35.00), stop('b', 35.01)],
        dailyBudgetMinutes: 480,
      );
      final percent = tripDayLoadPercent(itinerary.days.single, 480);

      // 79 分钟（2×30 停留 + 19 移动） / 480 ≈ 16%
      expect(itinerary.days.single.totalMinutes, 79);
      expect(percent, 16);
      expect(tripDayLoadPercent(itinerary.days.single, 0), 0);
    });
  });

  group('plan adapters', () {
    test('converts pilgrimage points into itinerary stops', () {
      final plan = PilgrimagePlan(
        id: 'p1',
        name: 'Chichibu',
        area: 'Saitama',
        works: const <PilgrimageWork>[],
        points: [_point('pt1', 'w1', 35.0), _point('pt2', 'w1', 35.01)],
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );
      final stops = itineraryStopsFromPlan(plan);

      expect(stops.length, 2);
      expect(stops.first.id, 'pt1');
      expect(stops.first.workTitle, 'Work w1');
      expect(stops.first.latitude, 35.0);
      expect(stops.first.longitude, 139.0);
    });
  });
}
