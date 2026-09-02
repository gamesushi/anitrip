import 'package:latlong2/latlong.dart';

import 'pilgrimage_models.dart';

/// Result of computing a recommended visiting order for a plan group.
class RouteResult {
  const RouteResult(this.orderedPoints, this.totalDistanceMeters);

  /// Points in the suggested visiting order (start first, end last).
  final List<PilgrimagePoint> orderedPoints;

  /// Sum of straight-line segment distances between consecutive points, in
  /// meters. This is a heuristic lower bound, not a real road distance.
  final double totalDistanceMeters;
}

/// Builds a recommended visiting order for the points belonging to [group].
///
/// The route starts from the group's anchor (either the anchored point or the
/// point nearest the anchored coordinate) and then greedily visits the nearest
/// unvisited point at each step (nearest-neighbour heuristic). This keeps the
/// total walking distance short without the cost of an exact TSP solve.
///
/// Returns the points in order plus the summed segment distance. For groups
/// with 0 or 1 point the order is trivial and the distance is 0.
RouteResult recommendedRouteForGroup(
  PilgrimagePlanGroup group,
  List<PilgrimagePoint> allPoints,
) {
  final groupPoints = allPoints.where((point) => point.groupId == group.id);
  final points = [...groupPoints];
  if (points.length <= 1) {
    return RouteResult(points, 0);
  }

  final distance = Distance();

  PilgrimagePoint pickStart() {
    if (group.anchorPointId != null) {
      final anchored = points.where(
        (point) => point.id == group.anchorPointId,
      );
      if (anchored.isNotEmpty) {
        return anchored.first;
      }
    }
    if (group.anchorLatitude != null && group.anchorLongitude != null) {
      final anchor = LatLng(group.anchorLatitude!, group.anchorLongitude!);
      var best = points.first;
      var bestDistance = distance(anchor, best.position);
      for (final point in points.skip(1)) {
        final d = distance(anchor, point.position);
        if (d < bestDistance) {
          bestDistance = d;
          best = point;
        }
      }
      return best;
    }
    return points.first;
  }

  final ordered = <PilgrimagePoint>[];
  final remaining = [...points];
  var current = pickStart();
  ordered.add(current);
  remaining.remove(current);

  var total = 0.0;
  while (remaining.isNotEmpty) {
    var best = remaining.first;
    var bestDistance = distance(current.position, best.position);
    for (final candidate in remaining.skip(1)) {
      final d = distance(current.position, candidate.position);
      if (d < bestDistance) {
        bestDistance = d;
        best = candidate;
      }
    }
    ordered.add(best);
    total += bestDistance;
    remaining.remove(best);
    current = best;
  }

  return RouteResult(ordered, total);
}

/// Orders a group's points by their explicit [PilgrimagePoint.groupOrderIndex].
///
/// Falls back to the given order when indices are missing. Used to read back a
/// previously generated (or manually arranged) route for display / export.
List<PilgrimagePoint> orderedPointsForGroup(
  PilgrimagePlanGroup group,
  List<PilgrimagePoint> allPoints,
) {
  final points = allPoints
      .where((point) => point.groupId == group.id)
      .toList(growable: false);
  points.sort((a, b) {
    final orderA = a.groupOrderIndex ?? 1 << 30;
    final orderB = b.groupOrderIndex ?? 1 << 30;
    final compare = orderA.compareTo(orderB);
    return compare != 0 ? compare : a.name.compareTo(b.name);
  });
  return points;
}

/// Formats a meter distance as a short, localized-friendly walking estimate.
String formatRouteDistance(double meters) {
  if (meters >= 1000) {
    final km = meters / 1000;
    return '${km.toStringAsFixed(km >= 10 ? 0 : 1)} km';
  }
  return '${meters.round()} m';
}
