import '../plan/pilgrimage_models.dart';
import '../plan/plan_partition.dart';

abstract interface class PilgrimageRepository {
  Future<List<PilgrimagePlan>> loadPlans();

  Future<PilgrimagePlan> loadActivePlan();

  Future<AppSettings> loadAppSettings();

  Future<List<PilgrimageVisitRecord>> loadVisitRecords(String planId);

  Future<void> setActivePlan(String id);

  Future<PilgrimagePlan> createPlan({
    required String name,
    required String area,
  });

  Future<PilgrimagePlan> importPlanPackage({
    required PilgrimagePlan plan,
    required List<PilgrimageVisitRecord> visitRecords,
  });

  Future<PilgrimagePlan> renamePlan({
    required String planId,
    required String name,
  });

  Future<PilgrimagePlan> updatePlanInfo({
    required String planId,
    required String name,
    required String area,
  });

  Future<PilgrimagePlan> updatePlanMemo({
    required String planId,
    required String memo,
  });

  Future<PilgrimagePlan> addPointToPlan({
    required String planId,
    required PilgrimagePoint point,
  });

  Future<PilgrimagePlan> addPointsToPlan({
    required String planId,
    required List<PilgrimagePoint> points,
  });

  Future<PilgrimagePlan> updatePointInPlan({
    required String planId,
    required PilgrimagePoint point,
  });

  Future<PilgrimagePlan> updatePointImageCache({
    required String planId,
    required String pointId,
    String? referenceThumbnailPath,
    String? referenceFullImagePath,
  });

  Future<PilgrimagePlan> updatePointImageCaches({
    required String planId,
    required Map<String, PointImageCacheUpdate> updatesByPointId,
  });

  Future<PilgrimagePlan> addWorkToPlan({
    required String planId,
    required PilgrimageWork work,
  });

  Future<PilgrimagePlan> createPlanGroup({
    required String planId,
    required PilgrimagePlanGroup group,
  });

  Future<PilgrimagePlan> renamePlanGroup({
    required String planId,
    required String groupId,
    required String name,
  });

  Future<PilgrimagePlan> updatePlanGroup({
    required String planId,
    required PilgrimagePlanGroup group,
  });

  Future<PilgrimagePlan> deletePlanGroup({
    required String planId,
    required String groupId,
  });

  Future<PilgrimagePlan> movePointsToGroup({
    required String planId,
    required Set<String> pointIds,
    required String? groupId,
  });

  /// Atomically creates [groups] (each with its centroid anchor) and moves the
  /// associated points into them, in one commit. Powers Explore's one-tap smart
  /// partition. Existing groups/points are untouched.
  Future<PilgrimagePlan> applyPlanPartition({
    required String planId,
    required List<PlanPartitionInput> groups,
  });

  Future<PilgrimagePlan> deleteWorkFromPlan({
    required String planId,
    required String workId,
  });

  Future<PilgrimagePlan> deletePointFromPlan({
    required String planId,
    required String pointId,
  });

  Future<PilgrimagePlan> deletePointsFromPlan({
    required String planId,
    required Set<String> pointIds,
  });

  Future<PilgrimagePlan> reorderPoints({
    required String planId,
    required List<String> pointIds,
  });

  Future<PilgrimagePlan> reorderGroupPoints({
    required String planId,
    required String groupId,
    required List<String> pointIds,
  });

  Future<void> setCurrentPoint({
    required String planId,
    required String pointId,
  });

  Future<void> completePoint({
    required String planId,
    required String pointId,
    required String? nextCurrentPointId,
  });

  Future<void> completePoints({
    required String planId,
    required Set<String> pointIds,
  });

  Future<void> reopenPoint({required String planId, required String pointId});

  Future<void> reopenPoints({
    required String planId,
    required Set<String> pointIds,
  });

  Future<PilgrimageVisitRecord> createVisitRecord({
    required String planId,
    required String pointId,
    required String workId,
    String? workTitle,
    String? workSubtitle,
    String? pointName,
    String? pointSubtitle,
    required String photoPath,
    String? referenceImagePath,
    String? referenceImageUrl,
    required String referenceMode,
    DateTime? capturedAt,
  });

  Future<PilgrimageVisitRecord> updateVisitRecordColorGrading({
    required String planId,
    required String recordId,
    required String originalPhotoPath,
    required String gradedPhotoPath,
    required String colorGradingMode,
    required String colorGradingParamsJson,
    required double colorGradingIntensity,
  });

  Future<PilgrimageVisitRecord> clearVisitRecordColorGrading({
    required String planId,
    required String recordId,
  });

  Future<void> deleteVisitRecord({
    required String planId,
    required String recordId,
  });

  Future<void> deletePlan(String id);

  Future<void> saveAppSettings(AppSettings settings);

  /// Submits a user-reported anchor-location correction (the "报告位置错误"
  /// flow). Stored locally so it survives without a backend; the developer can
  /// later export/forward the queue to the upstream data source.
  Future<void> submitAnchorCorrection(AnchorCorrectionInput correction);

  /// Returns collected corrections, newest first.
  Future<List<AnchorCorrectionReport>> loadAnchorCorrections({
    bool onlyPending = true,
  });

  /// Flags [ids] as already handed off, so they stop showing up as pending.
  Future<void> markAnchorCorrectionsExported(List<String> ids);

  Future<void> deleteAnchorCorrection(String id);
}

class AnchorCorrectionInput {
  const AnchorCorrectionInput({
    this.planId,
    required this.pointId,
    this.workId,
    this.workTitle,
    this.pointName,
    this.source,
    this.sourceId,
    required this.pointLatitude,
    required this.pointLongitude,
    this.suggestedLatitude,
    this.suggestedLongitude,
    this.description,
    this.photoPath,
  });

  final String? planId;
  final String pointId;
  final String? workId;
  final String? workTitle;
  final String? pointName;
  final String? source;
  final String? sourceId;
  final double pointLatitude;
  final double pointLongitude;
  final double? suggestedLatitude;
  final double? suggestedLongitude;
  final String? description;
  final String? photoPath;
}

/// A persisted anchor-location correction awaiting review/export.
///
/// Named `...Report` to avoid colliding with the drift-generated row class of
/// the same name (`AnchorCorrection`).
class AnchorCorrectionReport {
  const AnchorCorrectionReport({
    required this.id,
    required this.pointId,
    required this.pointLatitude,
    required this.pointLongitude,
    required this.createdAt,
    this.planId,
    this.workId,
    this.workTitle,
    this.pointName,
    this.source,
    this.sourceId,
    this.suggestedLatitude,
    this.suggestedLongitude,
    this.description,
    this.photoPath,
    this.status = 'submitted',
    this.exportedAt,
  });

  final String id;
  final String? planId;
  final String pointId;
  final String? workId;
  final String? workTitle;
  final String? pointName;
  final String? source;
  final String? sourceId;
  final double pointLatitude;
  final double pointLongitude;
  final double? suggestedLatitude;
  final double? suggestedLongitude;
  final String? description;
  final String? photoPath;
  final String status;
  final DateTime createdAt;
  final DateTime? exportedAt;

  bool get hasSuggestedCoordinate =>
      suggestedLatitude != null && suggestedLongitude != null;
}

class PointImageCacheUpdate {
  const PointImageCacheUpdate({
    this.referenceThumbnailPath,
    this.referenceFullImagePath,
  });

  final String? referenceThumbnailPath;
  final String? referenceFullImagePath;
}
