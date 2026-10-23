/// Pure-Dart roll-up of how much of a pilgrimage plan has been checked in.
///
/// Kept free of BuildContext (and of any l10n lookup) so it can be unit tested
/// directly; the screen supplies the localized labels.
library;

import 'plan_group_utils.dart';
import 'pilgrimage_models.dart';

/// Per-group roll-up. [isUngrouped] marks the synthetic bucket holding points
/// that were never assigned to a group.
class PlanGroupCompletion {
  const PlanGroupCompletion({
    required this.id,
    required this.name,
    required this.points,
    required this.completedPoints,
    this.isUngrouped = false,
  });

  final String id;
  final String name;
  final bool isUngrouped;
  final List<PilgrimagePoint> points;
  final List<PilgrimagePoint> completedPoints;

  int get total => points.length;

  int get completed => completedPoints.length;

  int get remaining => total - completed;

  bool get isComplete => total > 0 && remaining == 0;

  /// Rounded percentage, clamped to 0..100. Empty groups report 0 rather than
  /// 100, which would otherwise read as "done".
  int get percent {
    if (total == 0) {
      return 0;
    }
    return ((completed / total) * 100).round().clamp(0, 100);
  }
}

class PlanCompletionSummary {
  const PlanCompletionSummary({
    required this.total,
    required this.completed,
    required this.groups,
    required this.visitedPoints,
    required this.remainingPoints,
  });

  factory PlanCompletionSummary.of(PilgrimagePlan plan) {
    final completedIds = plan.completedPointIds;

    // Only count ids that still exist as points — a plan can keep stale ids
    // after its points were edited or re-imported.
    final visited = <PilgrimagePoint>[];
    final remaining = <PilgrimagePoint>[];
    for (final point in plan.points) {
      if (completedIds.contains(point.id)) {
        visited.add(point);
      } else {
        remaining.add(point);
      }
    }

    final planGroups = {
      for (final group in sortGroupsByPlanOrder(plan.groups)) group.id: group,
    };
    final buckets = <PlanGroupCompletion>[];
    for (final group in planGroups.values) {
      final ordered = sortPointsByPlanOrder(
        plan.points.where((point) => point.groupId == group.id),
      );
      // Groups with no points would only render 0/0 noise rows.
      if (ordered.isEmpty) {
        continue;
      }
      buckets.add(
        PlanGroupCompletion(
          id: group.id,
          name: group.name,
          points: ordered,
          completedPoints: ordered
              .where((point) => completedIds.contains(point.id))
              .toList(growable: false),
        ),
      );
    }

    final ungroupedPoints = sortPointsByPlanOrder(
      plan.points.where(
        (point) => point.groupId == null || !planGroups.containsKey(point.groupId),
      ),
    );
    if (ungroupedPoints.isNotEmpty) {
      buckets.add(
        PlanGroupCompletion(
          id: 'ungrouped',
          name: '',
          isUngrouped: true,
          points: ungroupedPoints,
          completedPoints: ungroupedPoints
              .where((point) => completedIds.contains(point.id))
              .toList(growable: false),
        ),
      );
    }

    return PlanCompletionSummary(
      total: plan.points.length,
      completed: visited.length,
      groups: buckets,
      visitedPoints: visited,
      remainingPoints: remaining,
    );
  }

  final int total;
  final int completed;

  final List<PlanGroupCompletion> groups;

  /// Checked-in points, in plan order.
  final List<PilgrimagePoint> visitedPoints;

  /// Points still to walk, in plan order.
  final List<PilgrimagePoint> remainingPoints;

  int get remaining => total - completed;

  bool get isEmpty => total == 0;

  bool get isComplete => total > 0 && remaining == 0;

  /// Rounded percentage, clamped to 0..100. An empty plan reports 0 so we never
  /// render a misleading full ring.
  int get percent {
    if (total == 0) {
      return 0;
    }
    return ((completed / total) * 100).round().clamp(0, 100);
  }

  /// 0..1 ring value, or 0 for an empty plan.
  double get ratio => total == 0 ? 0.0 : (completed / total).clamp(0.0, 1.0);
}
