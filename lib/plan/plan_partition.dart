import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

import 'pilgrimage_models.dart';

/// A cluster of points produced by [partitionByDistance] / [partitionByCount].
class PlanPartitionCluster {
  const PlanPartitionCluster({required this.pointIds, required this.centroid});

  final Set<String> pointIds;
  final LatLng centroid;

  int get size => pointIds.length;
}

/// A group to create plus the points to move into it, consumed by
/// [PilgrimageRepository.applyPlanPartition].
class PlanPartitionInput {
  const PlanPartitionInput({required this.group, required this.pointIds});

  final PilgrimagePlanGroup group;
  final Set<String> pointIds;
}

/// Default distance threshold (metres) for [partitionByDistance].
const double kDefaultPartitionThresholdMeters = 800;

/// Below this point count, splitting into areas just fragments a small plan, so
/// a single cluster is returned.
const int kMinPointsForPartition = 6;

/// Target number of points per area; oversized single-linkage clusters are
/// sub-split toward roughly this size.
const int kTargetAreaSize = 20;

/// Hard cap: any cluster larger than this is re-split regardless of dominance,
/// so no area is ever unwieldy (covers e.g. several equally-large city blobs).
const int kMaxAreaSize = 30;

/// A single-linkage cluster is also re-split when it dominates the plan (holds
/// more than this fraction of all points) — the classic chained-blob case.
const double kOversizedClusterFraction = 0.4;

/// Single-linkage clustering: points within [thresholdMeters] of each other are
/// merged into the same area (via union-find over pairwise distances). Isolated
/// points each form their own cluster. This matches the mental model that "an
/// area is a set of spots close to one another".
///
/// To avoid single-linkage "chaining" (dense city points chaining into one huge
/// area), any cluster that is bigger than [maxAreaSize] or dominates the plan
/// ([oversizedFraction]) is re-split with k-means into
/// `ceil(size / targetAreaSize)` walkable sub-areas.
///
/// Returns clusters sorted largest-first (stable) so area names are consistent.
List<PlanPartitionCluster> partitionByDistance(
  List<PilgrimagePoint> points, {
  double thresholdMeters = kDefaultPartitionThresholdMeters,
  int minPointsForSplit = kMinPointsForPartition,
  double oversizedFraction = kOversizedClusterFraction,
  int targetAreaSize = kTargetAreaSize,
  int maxAreaSize = kMaxAreaSize,
}) {
  if (points.isEmpty) {
    return const [];
  }
  if (points.length < minPointsForSplit) {
    return [
      PlanPartitionCluster(
        pointIds: points.map((p) => p.id).toSet(),
        centroid: _centroid(points),
      ),
    ];
  }

  final n = points.length;
  final parent = List<int>.generate(n, (i) => i);

  int find(int x) {
    var root = x;
    while (parent[root] != root) {
      root = parent[root];
    }
    // Path compression.
    var cursor = x;
    while (parent[cursor] != root) {
      final next = parent[cursor];
      parent[cursor] = root;
      cursor = next;
    }
    return root;
  }

  void union(int a, int b) {
    final ra = find(a);
    final rb = find(b);
    if (ra != rb) {
      parent[ra] = rb;
    }
  }

  const distance = Distance();
  for (var i = 0; i < n; i += 1) {
    for (var j = i + 1; j < n; j += 1) {
      if (distance(points[i].position, points[j].position) <= thresholdMeters) {
        union(i, j);
      }
    }
  }

  final grouped = <int, List<PilgrimagePoint>>{};
  for (var i = 0; i < n; i += 1) {
    grouped.putIfAbsent(find(i), () => []).add(points[i]);
  }

  // Re-split oversized (chained) clusters with k-means so no area dominates.
  final refined = <List<PilgrimagePoint>>[];
  for (final members in grouped.values) {
    final oversized =
        members.length > targetAreaSize &&
        (members.length > maxAreaSize || members.length > n * oversizedFraction);
    if (oversized) {
      final k = (members.length / targetAreaSize).ceil();
      for (final sub in partitionByCount(members, groupCount: k)) {
        final ids = sub.pointIds;
        refined.add(
          members.where((p) => ids.contains(p.id)).toList(growable: false),
        );
      }
    } else {
      refined.add(members);
    }
  }

  return _toClusters(refined);
}

/// k-means partition into a fixed [groupCount] areas (k-means++ init, fixed
/// iterations). Suited to many, evenly spread points where the user wants a
/// specific number of areas rather than a distance rule. Deterministic via a
/// fixed seed so previews and tests are stable.
List<PlanPartitionCluster> partitionByCount(
  List<PilgrimagePoint> points, {
  required int groupCount,
  int iterations = 20,
  int seed = 7,
}) {
  if (points.isEmpty) {
    return const [];
  }
  final k = groupCount.clamp(1, points.length);
  if (k == 1) {
    return [
      PlanPartitionCluster(
        pointIds: points.map((p) => p.id).toSet(),
        centroid: _centroid(points),
      ),
    ];
  }

  final random = math.Random(seed);
  const distance = Distance();
  final coords = points.map((p) => p.position).toList(growable: false);

  // k-means++ seeding.
  final centers = <LatLng>[coords[random.nextInt(coords.length)]];
  while (centers.length < k) {
    final weights = coords.map((c) {
      var nearest = double.infinity;
      for (final center in centers) {
        final d = distance(c, center);
        if (d < nearest) {
          nearest = d;
        }
      }
      return nearest * nearest;
    }).toList(growable: false);
    final total = weights.fold<double>(0, (a, b) => a + b);
    if (total <= 0) {
      centers.add(coords[random.nextInt(coords.length)]);
      continue;
    }
    var target = random.nextDouble() * total;
    var chosen = coords.length - 1;
    for (var i = 0; i < weights.length; i += 1) {
      target -= weights[i];
      if (target <= 0) {
        chosen = i;
        break;
      }
    }
    centers.add(coords[chosen]);
  }

  final assignment = List<int>.filled(points.length, 0);
  for (var iter = 0; iter < iterations; iter += 1) {
    var changed = false;
    for (var i = 0; i < coords.length; i += 1) {
      var best = 0;
      var bestDistance = double.infinity;
      for (var c = 0; c < centers.length; c += 1) {
        final d = distance(coords[i], centers[c]);
        if (d < bestDistance) {
          bestDistance = d;
          best = c;
        }
      }
      if (assignment[i] != best) {
        assignment[i] = best;
        changed = true;
      }
    }
    for (var c = 0; c < centers.length; c += 1) {
      final members = <PilgrimagePoint>[
        for (var i = 0; i < points.length; i += 1)
          if (assignment[i] == c) points[i],
      ];
      if (members.isNotEmpty) {
        centers[c] = _centroid(members);
      }
    }
    if (!changed && iter > 0) {
      break;
    }
  }

  final grouped = <int, List<PilgrimagePoint>>{};
  for (var i = 0; i < points.length; i += 1) {
    grouped.putIfAbsent(assignment[i], () => []).add(points[i]);
  }
  return _toClusters(grouped.values);
}

List<PlanPartitionCluster> _toClusters(Iterable<List<PilgrimagePoint>> groups) {
  final clusters = groups
      .where((pts) => pts.isNotEmpty)
      .map(
        (pts) => PlanPartitionCluster(
          pointIds: pts.map((p) => p.id).toSet(),
          centroid: _centroid(pts),
        ),
      )
      .toList();
  clusters.sort((a, b) {
    final bySize = b.size.compareTo(a.size);
    if (bySize != 0) {
      return bySize;
    }
    // Stable tie-break by smallest point id.
    final aMin = a.pointIds.reduce((x, y) => x.compareTo(y) <= 0 ? x : y);
    final bMin = b.pointIds.reduce((x, y) => x.compareTo(y) <= 0 ? x : y);
    return aMin.compareTo(bMin);
  });
  return clusters;
}

LatLng _centroid(List<PilgrimagePoint> points) {
  final lat =
      points.map((p) => p.position.latitude).reduce((a, b) => a + b) /
      points.length;
  final lng =
      points.map((p) => p.position.longitude).reduce((a, b) => a + b) /
      points.length;
  return LatLng(lat, lng);
}
