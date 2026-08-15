import 'package:latlong2/latlong.dart';

import '../data/anitabi_client.dart';
import '../data/pilgrimage_repository.dart';
import '../plan/pilgrimage_models.dart';
import '../plan/plan_partition.dart';
import 'explore_work_item.dart';

/// An auto-created area (partition group), returned so the caller can name it
/// after the fact (e.g. resolve a nearby transit hub in the background).
class ImportedArea {
  const ImportedArea({required this.groupId, required this.centroid});

  final String groupId;
  final LatLng centroid;
}

/// Result of a one-tap work import from the Explore tab.
class WorkImportResult {
  const WorkImportResult({
    required this.plan,
    required this.addedPointCount,
    this.areaCount = 0,
    this.createdAreas = const [],
  });

  final PilgrimagePlan plan;
  final int addedPointCount;

  /// Number of areas auto-created by [WorkImporter.importWork] (0 when
  /// auto-partition was off or produced nothing).
  final int areaCount;

  /// The created areas, for background station naming.
  final List<ImportedArea> createdAreas;
}

/// Provides the initial fallback name for the [index]-th area (e.g. "片区 1").
typedef FallbackAreaName = String Function(int index);

/// Imports a whole anime work (its anitabi pilgrimage points) into the active
/// plan in one step, replacing the original "add work, then add points"
/// two-step flow. Points come from anitabi; the work is auto-upserted by
/// [PilgrimageRepository.addPointsToPlan] via each point's `work`.
class WorkImporter {
  WorkImporter({AnitabiClient? anitabiClient})
    : _anitabi = anitabiClient ?? AnitabiClient();

  final AnitabiClient _anitabi;

  /// Whether [item] can be one-tap imported (needs a Bangumi id to resolve
  /// anitabi points).
  static bool canImport(ExploreWorkItem item) => item.bangumiId != null;

  PilgrimageWork _workFor(ExploreWorkItem item, int bangumiId) {
    return PilgrimageWork(
      id: 'bangumi-$bangumiId',
      bangumiId: bangumiId,
      title: item.title,
      subtitle: item.subtitle ?? '',
      city: item.city ?? '',
      source: WorkSource.bangumi,
    );
  }

  /// Fetches the work's anitabi points and adds any that aren't already in the
  /// plan. Returns the updated plan and how many new points were added (0 when
  /// the work has no points or all were already present). Throws on
  /// network/data failure so the caller can surface an error.
  Future<WorkImportResult> importWork({
    required PilgrimageRepository repository,
    required String planId,
    required PilgrimagePlan currentPlan,
    required ExploreWorkItem item,
    bool autoPartition = false,
    FallbackAreaName? fallbackAreaName,
  }) async {
    final bangumiId = item.bangumiId;
    if (bangumiId == null) {
      throw StateError('Work has no bangumiId');
    }
    final work = _workFor(item, bangumiId);

    final List<AnitabiPoint> anitabiPoints;
    try {
      anitabiPoints = await _anitabi.fetchPoints(bangumiId);
    } on AnitabiNoPointsException {
      final plan = await repository.addWorkToPlan(planId: planId, work: work);
      return WorkImportResult(plan: plan, addedPointCount: 0);
    }

    final existingIds = currentPlan.points.map((p) => p.id).toSet();
    final points = anitabiPoints
        .map((p) => p.toPilgrimagePoint(work))
        .where((p) => !existingIds.contains(p.id))
        .toList(growable: false);

    if (points.isEmpty) {
      final plan = await repository.addWorkToPlan(planId: planId, work: work);
      return WorkImportResult(plan: plan, addedPointCount: 0);
    }

    var plan = await repository.addPointsToPlan(planId: planId, points: points);

    // Auto-organize the freshly imported points into areas so the user skips
    // the manual "create group → assign points" chain entirely. Areas get a
    // fast fallback name ("片区 N"); transit-hub names are resolved afterwards
    // in the background so the import never blocks on Overpass.
    var areaCount = 0;
    var createdAreas = const <ImportedArea>[];
    if (autoPartition && fallbackAreaName != null) {
      final inputs = _buildPartitionInputs(
        points: points,
        existingGroups: currentPlan.groups,
        fallbackAreaName: fallbackAreaName,
      );
      if (inputs.isNotEmpty) {
        plan = await repository.applyPlanPartition(
          planId: planId,
          groups: inputs,
        );
        areaCount = inputs.length;
        createdAreas = [
          for (final input in inputs)
            ImportedArea(
              groupId: input.group.id,
              centroid: LatLng(
                input.group.anchorLatitude!,
                input.group.anchorLongitude!,
              ),
            ),
        ];
      }
    }

    return WorkImportResult(
      plan: plan,
      addedPointCount: points.length,
      areaCount: areaCount,
      createdAreas: createdAreas,
    );
  }

  List<PlanPartitionInput> _buildPartitionInputs({
    required List<PilgrimagePoint> points,
    required List<PilgrimagePlanGroup> existingGroups,
    required FallbackAreaName fallbackAreaName,
  }) {
    final clusters = partitionByDistance(points);
    if (clusters.isEmpty) {
      return const [];
    }
    final now = DateTime.now();
    final baseOrder = existingGroups.isEmpty
        ? 0
        : existingGroups.map((g) => g.orderIndex).reduce((a, b) => a > b ? a : b) +
              1;
    final inputs = <PlanPartitionInput>[];
    for (var i = 0; i < clusters.length; i += 1) {
      final centroid = clusters[i].centroid;
      final name = fallbackAreaName(i);
      inputs.add(
        PlanPartitionInput(
          group: PilgrimagePlanGroup(
            id: 'group-${now.microsecondsSinceEpoch}-$i',
            name: name,
            orderIndex: baseOrder + i,
            anchorName: name,
            anchorLatitude: centroid.latitude,
            anchorLongitude: centroid.longitude,
            createdAt: now,
          ),
          pointIds: clusters[i].pointIds,
        ),
      );
    }
    return inputs;
  }
}
