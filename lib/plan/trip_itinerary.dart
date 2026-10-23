import '../map/gps_track.dart' show haversineDistanceMeters;
import 'pilgrimage_models.dart';

/// 出行方式。没有路网数据，只能用「直线距离 × 绕行系数 ÷ 平均速度」估算，
/// 因此这里的数值是经验值，不是导航结果。
enum TravelMode {
  walk,
  transit,
  drive;

  /// 直线距离 → 实际路程的放大系数（走路能抄近路，开车受单行/绕行影响最大）。
  double get detourFactor => switch (this) {
        TravelMode.walk => 1.35,
        TravelMode.transit => 1.5,
        TravelMode.drive => 1.65,
      };

  /// 平均移动速度（米/分钟）。公交已含停站与换乘的平均损耗。
  double get metersPerMinute => switch (this) {
        TravelMode.walk => 80, // ≈4.8 km/h
        TravelMode.transit => 250, // ≈15 km/h
        TravelMode.drive => 500, // ≈30 km/h（市区/山路）
      };

  /// 每次移动的固定开销（等车、找车位等）。
  int get overheadMinutes => switch (this) {
        TravelMode.walk => 0,
        TravelMode.transit => 6,
        TravelMode.drive => 4,
      };

  /// 短距离时开车/坐车反而不划算，统一按步行处理。
  double get walkFallbackMeters => switch (this) {
        TravelMode.walk => 0,
        TravelMode.transit => 400,
        TravelMode.drive => 300,
      };
}

/// 每个巡礼点的默认停留时长（分钟）与默认每天可用时长。
const int kDefaultSpotVisitMinutes = 30;
const int kDefaultDailyBudgetMinutes = 480; // 8 小时
const int kTripDefaultStartHour = 9;

/// 把巡礼点转成规划用的最小信息集。
ItineraryStop itineraryStopFromPoint(PilgrimagePoint point) {
  return ItineraryStop(
    id: point.id,
    name: point.name,
    workTitle: point.work.title,
    groupId: point.groupId,
    latitude: point.position.latitude,
    longitude: point.position.longitude,
  );
}

/// 整个计划的巡礼点转规划输入。
List<ItineraryStop> itineraryStopsFromPlan(PilgrimagePlan plan) {
  return plan.points.map(itineraryStopFromPoint).toList(growable: false);
}

/// 规划输入的最小信息集：只带坐标与展示用的名字，方便单测直接构造。
class ItineraryStop {
  const ItineraryStop({
    required this.id,
    required this.name,
    this.workTitle = '',
    this.groupId,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final String name;
  final String workTitle;
  final String? groupId;
  final double latitude;
  final double longitude;
}

/// 一天里的一站：到达时间 + 从上一站移动过来的耗时/距离。
class TripDayStop {
  const TripDayStop({
    required this.stop,
    required this.arrivalAt,
    required this.travelMinutes,
    required this.travelMeters,
  });

  final ItineraryStop stop;

  /// 当天出发后累计到该站的时刻。
  final DateTime arrivalAt;

  /// 从上一站移动过来的时间（每天第一站为 0）。
  final int travelMinutes;

  /// 从上一站移动过来的距离（米，每天第一站为 0）。
  final double travelMeters;
}

/// 一天的行程。
class TripDay {
  const TripDay({
    required this.index,
    required this.stops,
    required this.startAt,
    required this.endAt,
    required this.travelMinutes,
    required this.visitMinutes,
    required this.distanceMeters,
  });

  /// 第几天（从 1 开始）。
  final int index;
  final List<TripDayStop> stops;
  final DateTime startAt;
  final DateTime endAt;

  final int travelMinutes;
  final int visitMinutes;
  final double distanceMeters;

  int get totalMinutes => travelMinutes + visitMinutes;
  int get pointCount => stops.length;
}

/// 完整的多日行程建议。
class TripItinerary {
  const TripItinerary({
    required this.days,
    required this.mode,
    required this.spotVisitMinutes,
    required this.dailyBudgetMinutes,
  });

  final List<TripDay> days;
  final TravelMode mode;
  final int spotVisitMinutes;
  final int dailyBudgetMinutes;

  bool get isEmpty => days.isEmpty;

  int get dayCount => days.length;

  int get pointCount =>
      days.fold<int>(0, (total, day) => total + day.pointCount);

  double get totalDistanceMeters =>
      days.fold<double>(0, (total, day) => total + day.distanceMeters);

  int get totalMinutes =>
      days.fold<int>(0, (total, day) => total + day.totalMinutes);
}

/// 估算相邻两点的移动耗时（分钟）。
///
/// 距离小于该模式的「步行兜底距离」时按步行算，避免 200 米也报「坐车 6 分钟」。
int estimateTravelMinutes(
  ItineraryStop from,
  ItineraryStop to, {
  TravelMode mode = TravelMode.walk,
}) {
  final straight = haversineDistanceMeters(
    from.latitude,
    from.longitude,
    to.latitude,
    to.longitude,
  );
  return estimateTravelMinutesForDistance(straight, mode: mode);
}

/// 按直线距离（米）估算移动耗时（分钟）。
int estimateTravelMinutesForDistance(
  double straightMeters, {
  TravelMode mode = TravelMode.walk,
}) {
  if (straightMeters <= 0) {
    return 0;
  }
  final effectiveMode =
      straightMeters < mode.walkFallbackMeters ? TravelMode.walk : mode;
  final routeMeters = straightMeters * effectiveMode.detourFactor;
  final minutes = routeMeters / effectiveMode.metersPerMinute;
  return minutes.ceil() + effectiveMode.overheadMinutes;
}

/// 按出行方式估算两点间的实际路程（米）。
double estimateTravelMeters(
  ItineraryStop from,
  ItineraryStop to, {
  TravelMode mode = TravelMode.walk,
}) {
  final straight = haversineDistanceMeters(
    from.latitude,
    from.longitude,
    to.latitude,
    to.longitude,
  );
  if (straight <= 0) {
    return 0;
  }
  final effectiveMode =
      straight < mode.walkFallbackMeters ? TravelMode.walk : mode;
  return straight * effectiveMode.detourFactor;
}

/// 生成多日行程建议。
///
/// 策略：每天从**剩余点中离质心最远**的那个点出发（先扫外围），
/// 然后贪心走最近邻；一旦「移动 + 停留」超出当天预算就收工，
/// 次日再从剩余点的外围重新开始。这样每天大致是一个局部簇，
/// 且每天结束时离住宿/车站更近。
///
/// 纯函数、无 BuildContext，便于单测。
TripItinerary buildTripItinerary({
  required List<ItineraryStop> stops,
  TravelMode mode = TravelMode.walk,
  int spotVisitMinutes = kDefaultSpotVisitMinutes,
  int dailyBudgetMinutes = kDefaultDailyBudgetMinutes,
  DateTime? startDate,
}) {
  if (stops.isEmpty) {
    return TripItinerary(
      days: const <TripDay>[],
      mode: mode,
      spotVisitMinutes: spotVisitMinutes,
      dailyBudgetMinutes: dailyBudgetMinutes,
    );
  }

  final remaining = List<ItineraryStop>.of(stops);
  final days = <TripDay>[];
  var dayIndex = 0;

  while (remaining.isNotEmpty) {
    dayIndex++;
    final base = _dayStart(startDate, dayIndex - 1);
    var current = _farthestFromCentroid(remaining);
    remaining.remove(current);

    final dayStops = <TripDayStop>[
      TripDayStop(
        stop: current,
        arrivalAt: base,
        travelMinutes: 0,
        travelMeters: 0,
      ),
    ];
    var usedMinutes = spotVisitMinutes;
    var travelMinutes = 0;
    var distanceMeters = 0.0;
    var clock = base.add(Duration(minutes: spotVisitMinutes));

    while (remaining.isNotEmpty) {
      final next = _nearestStop(remaining, current);
      final legMinutes = estimateTravelMinutes(current, next, mode: mode);
      final legMeters = estimateTravelMeters(current, next, mode: mode);
      final cost = legMinutes + spotVisitMinutes;
      // 至少保证每天一个点，避免 spotVisitMinutes > budget 时死循环。
      if (dayStops.isNotEmpty && usedMinutes + cost > dailyBudgetMinutes) {
        break;
      }
      clock = clock.add(Duration(minutes: legMinutes));
      dayStops.add(
        TripDayStop(
          stop: next,
          arrivalAt: clock,
          travelMinutes: legMinutes,
          travelMeters: legMeters,
        ),
      );
      clock = clock.add(Duration(minutes: spotVisitMinutes));
      usedMinutes += cost;
      travelMinutes += legMinutes;
      distanceMeters += legMeters;
      remaining.remove(next);
      current = next;
    }

    days.add(
      TripDay(
        index: dayIndex,
        stops: dayStops,
        startAt: base,
        endAt: clock,
        travelMinutes: travelMinutes,
        visitMinutes: spotVisitMinutes * dayStops.length,
        distanceMeters: distanceMeters,
      ),
    );
  }

  return TripItinerary(
    days: days,
    mode: mode,
    spotVisitMinutes: spotVisitMinutes,
    dailyBudgetMinutes: dailyBudgetMinutes,
  );
}

/// 每天默认早上 [kTripDefaultStartHour] 点出发。
DateTime _dayStart(DateTime? startDate, int dayOffset) {
  final base = startDate ?? DateTime(2026, 1, 1);
  return DateTime(
    base.year,
    base.month,
    base.day + dayOffset,
    startDate == null ? kTripDefaultStartHour : base.hour,
    startDate == null ? 0 : base.minute,
  );
}

/// 离剩余点质心最远的那个点（先扫外围，往回收）。
ItineraryStop _farthestFromCentroid(List<ItineraryStop> stops) {
  if (stops.length == 1) {
    return stops.first;
  }
  var latSum = 0.0;
  var lngSum = 0.0;
  for (final stop in stops) {
    latSum += stop.latitude;
    lngSum += stop.longitude;
  }
  final centroidLat = latSum / stops.length;
  final centroidLng = lngSum / stops.length;

  ItineraryStop best = stops.first;
  var bestDistance = -1.0;
  for (final stop in stops) {
    final distance = haversineDistanceMeters(
      centroidLat,
      centroidLng,
      stop.latitude,
      stop.longitude,
    );
    if (distance > bestDistance) {
      bestDistance = distance;
      best = stop;
    }
  }
  return best;
}

/// 距 [from] 最近的点；距离相同时按 id 兜底，保证结果稳定可测。
ItineraryStop _nearestStop(List<ItineraryStop> stops, ItineraryStop from) {
  ItineraryStop best = stops.first;
  var bestDistance = double.infinity;
  for (final stop in stops) {
    final distance = haversineDistanceMeters(
      from.latitude,
      from.longitude,
      stop.latitude,
      stop.longitude,
    );
    if (distance < bestDistance ||
        (distance == bestDistance && stop.id.compareTo(best.id) < 0)) {
      bestDistance = distance;
      best = stop;
    }
  }
  return best;
}

/// 距离展示：<1000 m 用米，否则用公里。
String formatTripDistance(double meters) {
  if (meters >= 1000) {
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }
  return '${meters.round()} m';
}

/// 时长展示：不足 1 小时用分钟，否则「X 小时 Y 分」风格由调用方拼接，
/// 这里只给出「X.X h」的稳定格式，便于单测。
String formatTripDuration(int minutes) {
  if (minutes < 60) {
    return '$minutes min';
  }
  final hours = minutes ~/ 60;
  final rest = minutes % 60;
  if (rest == 0) {
    return '${hours}h';
  }
  return '${hours}h ${rest}m';
}

/// 当天占用预算的百分比（可能 >100，表示预算装不下这一天的实际耗时）。
int tripDayLoadPercent(TripDay day, int dailyBudgetMinutes) {
  if (dailyBudgetMinutes <= 0) {
    return 0;
  }
  return ((day.totalMinutes * 100) / dailyBudgetMinutes).round();
}
