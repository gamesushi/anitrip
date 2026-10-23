import 'dart:math' as math;
import 'dart:ui' show Color;

import 'package:latlong2/latlong.dart';

import '../plan/pilgrimage_models.dart';

/// Distance (meters) within which points of *different* works are treated as
/// the same physical location on the map.
const double kMapSpotMergeMeters = 30;

/// Stable key identifying a work across plans. The same work imported into
/// several plans collapses to one key (Bangumi id when known).
String workKeyOf(PilgrimageWork work) =>
    work.bangumiId?.toString() ?? work.id;

/// One pilgrimage point together with the plan that owns it.
class MapPointEntry {
  const MapPointEntry({required this.planId, required this.point});

  final String planId;
  final PilgrimagePoint point;

  String get workKey => workKeyOf(point.work);
}

/// A physical location on the map. Holds every work's point found there.
class MapSpot {
  const MapSpot({required this.center, required this.entries});

  final LatLng center;
  final List<MapPointEntry> entries;

  bool get isShared => entries.length > 1;

  /// Stable identity for marker keys / selection (ids are globally unique).
  String get id => entries.map((entry) => entry.point.id).join('|');
}

/// Flattens [plans] into entries, dropping duplicates of the same work's point
/// (same work imported into several plans). Earlier plans win, so callers
/// should list the active plan first.
List<MapPointEntry> flattenPlanPoints(Iterable<PilgrimagePlan> plans) {
  final seen = <String>{};
  final entries = <MapPointEntry>[];
  for (final plan in plans) {
    for (final point in plan.points) {
      final workKey = workKeyOf(point.work);
      final sourceId = point.sourceId;
      final dedupeKey = (sourceId != null && sourceId.isNotEmpty)
          ? '$workKey#$sourceId'
          : '$workKey@${point.position.latitude.toStringAsFixed(5)},'
                '${point.position.longitude.toStringAsFixed(5)}';
      if (!seen.add(dedupeKey)) {
        continue;
      }
      entries.add(MapPointEntry(planId: plan.id, point: point));
    }
  }
  return entries;
}

/// Groups [entries] into [MapSpot]s: points within [thresholdMeters] of a spot's
/// anchor join it, except that a spot never holds two points of the same work
/// (a work's own neighbouring points stay separate and individually tappable).
///
/// Uses a latitude-band grid so it stays O(n) for thousands of points.
List<MapSpot> clusterSpots(
  List<MapPointEntry> entries, {
  double thresholdMeters = kMapSpotMergeMeters,
}) {
  const metersPerDegree = 111320.0;
  const distance = Distance();
  final latStep = thresholdMeters / metersPerDegree;

  double lonStepAt(int latCell) {
    final centerLat = (latCell + 0.5) * latStep;
    final cosLat = math.cos(centerLat * math.pi / 180).abs();
    return thresholdMeters / (metersPerDegree * math.max(cosLat, 0.01));
  }

  final anchors = <LatLng>[];
  final members = <List<MapPointEntry>>[];
  final workKeys = <Set<String>>[];
  final grid = <(int, int), List<int>>{};

  for (final entry in entries) {
    final position = entry.point.position;
    final latCell = (position.latitude / latStep).floor();

    int? best;
    var bestDistance = double.infinity;
    for (var dLat = -1; dLat <= 1; dLat += 1) {
      final cellLat = latCell + dLat;
      final lonStep = lonStepAt(cellLat);
      final lonCell = (position.longitude / lonStep).floor();
      for (var dLon = -1; dLon <= 1; dLon += 1) {
        final spotIndexes = grid[(cellLat, lonCell + dLon)];
        if (spotIndexes == null) {
          continue;
        }
        for (final index in spotIndexes) {
          if (workKeys[index].contains(entry.workKey)) {
            continue;
          }
          final meters = distance(anchors[index], position);
          if (meters <= thresholdMeters && meters < bestDistance) {
            best = index;
            bestDistance = meters;
          }
        }
      }
    }

    if (best != null) {
      members[best].add(entry);
      workKeys[best].add(entry.workKey);
      continue;
    }

    final index = anchors.length;
    anchors.add(position);
    members.add([entry]);
    workKeys.add({entry.workKey});
    final lonCell = (position.longitude / lonStepAt(latCell)).floor();
    grid.putIfAbsent((latCell, lonCell), () => []).add(index);
  }

  return [
    for (var i = 0; i < members.length; i += 1)
      MapSpot(center: _meanPosition(members[i]), entries: members[i]),
  ];
}

LatLng _meanPosition(List<MapPointEntry> entries) {
  if (entries.length == 1) {
    return entries.first.point.position;
  }
  var lat = 0.0;
  var lon = 0.0;
  for (final entry in entries) {
    lat += entry.point.position.latitude;
    lon += entry.point.position.longitude;
  }
  return LatLng(lat / entries.length, lon / entries.length);
}

/// Palette used to tell works apart when several are shown at once.
const List<Color> mapWorkColors = [
  Color(0xFF0F8B8D),
  Color(0xFFE11D48),
  Color(0xFF2563EB),
  Color(0xFFF59E0B),
  Color(0xFF7C3AED),
  Color(0xFF16A34A),
  Color(0xFFEA580C),
  Color(0xFFDB2777),
];

/// Deterministic per-work color (stable across launches, unlike hashCode).
Color mapColorForWorkKey(String workKey) {
  var hash = 0;
  for (final unit in workKey.codeUnits) {
    hash = (hash * 31 + unit) & 0x7fffffff;
  }
  return mapWorkColors[hash % mapWorkColors.length];
}

/// Asks the map to isolate a single work (e.g. tapped in Explore → "我的作品").
/// A fresh instance is published for every request so repeated taps on the
/// same work still re-trigger.
class MapFocusRequest {
  const MapFocusRequest(this.workKey);

  final String workKey;
}
