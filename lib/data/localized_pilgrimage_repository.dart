import '../plan/pilgrimage_models.dart';
import '../utils/translation_service.dart';
import 'pilgrimage_repository.dart';

class LocalizedPilgrimageRepository implements PilgrimageRepository {
  LocalizedPilgrimageRepository(this.delegate);

  final PilgrimageRepository delegate;

  Future<PilgrimagePlan> _translate(PilgrimagePlan plan) async {
    final settings = await delegate.loadAppSettings();
    final resolvedLang = TranslationService.resolveLanguage(settings.language);
    return TranslationService.translatePlan(plan, resolvedLang);
  }

  Future<List<PilgrimagePlan>> _translateList(List<PilgrimagePlan> plans) async {
    final settings = await delegate.loadAppSettings();
    final resolvedLang = TranslationService.resolveLanguage(settings.language);
    return plans
        .map((p) => TranslationService.translatePlan(p, resolvedLang))
        .toList();
  }

  @override
  Future<List<PilgrimagePlan>> loadPlans() async {
    final plans = await delegate.loadPlans();
    return _translateList(plans);
  }

  @override
  Future<PilgrimagePlan> loadActivePlan() async {
    final plan = await delegate.loadActivePlan();
    return _translate(plan);
  }

  @override
  Future<AppSettings> loadAppSettings() {
    return delegate.loadAppSettings();
  }

  @override
  Future<List<PilgrimageVisitRecord>> loadVisitRecords(String planId) {
    return delegate.loadVisitRecords(planId);
  }

  @override
  Future<void> setActivePlan(String id) {
    return delegate.setActivePlan(id);
  }

  @override
  Future<PilgrimagePlan> createPlan({
    required String name,
    required String area,
  }) async {
    final plan = await delegate.createPlan(name: name, area: area);
    return _translate(plan);
  }

  @override
  Future<PilgrimagePlan> importPlanPackage({
    required PilgrimagePlan plan,
    required List<PilgrimageVisitRecord> visitRecords,
  }) async {
    final importedPlan = await delegate.importPlanPackage(
      plan: plan,
      visitRecords: visitRecords,
    );
    return _translate(importedPlan);
  }

  @override
  Future<PilgrimagePlan> renamePlan({
    required String planId,
    required String name,
  }) async {
    final plan = await delegate.renamePlan(planId: planId, name: name);
    return _translate(plan);
  }

  @override
  Future<PilgrimagePlan> updatePlanInfo({
    required String planId,
    required String name,
    required String area,
  }) async {
    final plan = await delegate.updatePlanInfo(
      planId: planId,
      name: name,
      area: area,
    );
    return _translate(plan);
  }

  @override
  Future<PilgrimagePlan> updatePlanMemo({
    required String planId,
    required String memo,
  }) async {
    final plan = await delegate.updatePlanMemo(planId: planId, memo: memo);
    return _translate(plan);
  }

  @override
  Future<PilgrimagePlan> addPointToPlan({
    required String planId,
    required PilgrimagePoint point,
  }) async {
    final plan = await delegate.addPointToPlan(planId: planId, point: point);
    return _translate(plan);
  }

  @override
  Future<PilgrimagePlan> addPointsToPlan({
    required String planId,
    required List<PilgrimagePoint> points,
  }) async {
    final plan = await delegate.addPointsToPlan(planId: planId, points: points);
    return _translate(plan);
  }

  @override
  Future<PilgrimagePlan> updatePointInPlan({
    required String planId,
    required PilgrimagePoint point,
  }) async {
    final plan = await delegate.updatePointInPlan(planId: planId, point: point);
    return _translate(plan);
  }

  @override
  Future<PilgrimagePlan> updatePointImageCache({
    required String planId,
    required String pointId,
    String? referenceThumbnailPath,
    String? referenceFullImagePath,
  }) async {
    final plan = await delegate.updatePointImageCache(
      planId: planId,
      pointId: pointId,
      referenceThumbnailPath: referenceThumbnailPath,
      referenceFullImagePath: referenceFullImagePath,
    );
    return _translate(plan);
  }

  @override
  Future<PilgrimagePlan> updatePointImageCaches({
    required String planId,
    required Map<String, PointImageCacheUpdate> updatesByPointId,
  }) async {
    final plan = await delegate.updatePointImageCaches(
      planId: planId,
      updatesByPointId: updatesByPointId,
    );
    return _translate(plan);
  }

  @override
  Future<PilgrimagePlan> addWorkToPlan({
    required String planId,
    required PilgrimageWork work,
  }) async {
    final plan = await delegate.addWorkToPlan(planId: planId, work: work);
    return _translate(plan);
  }

  @override
  Future<PilgrimagePlan> createPlanGroup({
    required String planId,
    required PilgrimagePlanGroup group,
  }) async {
    final plan = await delegate.createPlanGroup(planId: planId, group: group);
    return _translate(plan);
  }

  @override
  Future<PilgrimagePlan> renamePlanGroup({
    required String planId,
    required String groupId,
    required String name,
  }) async {
    final plan = await delegate.renamePlanGroup(
      planId: planId,
      groupId: groupId,
      name: name,
    );
    return _translate(plan);
  }

  @override
  Future<PilgrimagePlan> updatePlanGroup({
    required String planId,
    required PilgrimagePlanGroup group,
  }) async {
    final plan = await delegate.updatePlanGroup(planId: planId, group: group);
    return _translate(plan);
  }

  @override
  Future<PilgrimagePlan> deletePlanGroup({
    required String planId,
    required String groupId,
  }) async {
    final plan = await delegate.deletePlanGroup(
      planId: planId,
      groupId: groupId,
    );
    return _translate(plan);
  }

  @override
  Future<PilgrimagePlan> movePointsToGroup({
    required String planId,
    required Set<String> pointIds,
    required String? groupId,
  }) async {
    final plan = await delegate.movePointsToGroup(
      planId: planId,
      pointIds: pointIds,
      groupId: groupId,
    );
    return _translate(plan);
  }

  @override
  Future<PilgrimagePlan> deleteWorkFromPlan({
    required String planId,
    required String workId,
  }) async {
    final plan = await delegate.deleteWorkFromPlan(
      planId: planId,
      workId: workId,
    );
    return _translate(plan);
  }

  @override
  Future<PilgrimagePlan> deletePointFromPlan({
    required String planId,
    required String pointId,
  }) async {
    final plan = await delegate.deletePointFromPlan(
      planId: planId,
      pointId: pointId,
    );
    return _translate(plan);
  }

  @override
  Future<PilgrimagePlan> deletePointsFromPlan({
    required String planId,
    required Set<String> pointIds,
  }) async {
    final plan = await delegate.deletePointsFromPlan(
      planId: planId,
      pointIds: pointIds,
    );
    return _translate(plan);
  }

  @override
  Future<PilgrimagePlan> reorderPoints({
    required String planId,
    required List<String> pointIds,
  }) async {
    final plan = await delegate.reorderPoints(planId: planId, pointIds: pointIds);
    return _translate(plan);
  }

  @override
  Future<PilgrimagePlan> reorderGroupPoints({
    required String planId,
    required String groupId,
    required List<String> pointIds,
  }) async {
    final plan = await delegate.reorderGroupPoints(
      planId: planId,
      groupId: groupId,
      pointIds: pointIds,
    );
    return _translate(plan);
  }

  @override
  Future<void> setCurrentPoint({
    required String planId,
    required String pointId,
  }) {
    return delegate.setCurrentPoint(planId: planId, pointId: pointId);
  }

  @override
  Future<void> completePoint({
    required String planId,
    required String pointId,
    required String? nextCurrentPointId,
  }) {
    return delegate.completePoint(
      planId: planId,
      pointId: pointId,
      nextCurrentPointId: nextCurrentPointId,
    );
  }

  @override
  Future<void> completePoints({
    required String planId,
    required Set<String> pointIds,
  }) {
    return delegate.completePoints(planId: planId, pointIds: pointIds);
  }

  @override
  Future<void> reopenPoint({required String planId, required String pointId}) {
    return delegate.reopenPoint(planId: planId, pointId: pointId);
  }

  @override
  Future<void> reopenPoints({
    required String planId,
    required Set<String> pointIds,
  }) {
    return delegate.reopenPoints(planId: planId, pointIds: pointIds);
  }

  @override
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
  }) {
    return delegate.createVisitRecord(
      planId: planId,
      pointId: pointId,
      workId: workId,
      workTitle: workTitle,
      workSubtitle: workSubtitle,
      pointName: pointName,
      pointSubtitle: pointSubtitle,
      photoPath: photoPath,
      referenceImagePath: referenceImagePath,
      referenceImageUrl: referenceImageUrl,
      referenceMode: referenceMode,
      capturedAt: capturedAt,
    );
  }

  @override
  Future<PilgrimageVisitRecord> updateVisitRecordColorGrading({
    required String planId,
    required String recordId,
    required String originalPhotoPath,
    required String gradedPhotoPath,
    required String colorGradingMode,
    required String colorGradingParamsJson,
    required double colorGradingIntensity,
  }) {
    return delegate.updateVisitRecordColorGrading(
      planId: planId,
      recordId: recordId,
      originalPhotoPath: originalPhotoPath,
      gradedPhotoPath: gradedPhotoPath,
      colorGradingMode: colorGradingMode,
      colorGradingParamsJson: colorGradingParamsJson,
      colorGradingIntensity: colorGradingIntensity,
    );
  }

  @override
  Future<PilgrimageVisitRecord> clearVisitRecordColorGrading({
    required String planId,
    required String recordId,
  }) {
    return delegate.clearVisitRecordColorGrading(
      planId: planId,
      recordId: recordId,
    );
  }

  @override
  Future<void> deleteVisitRecord({
    required String planId,
    required String recordId,
  }) {
    return delegate.deleteVisitRecord(planId: planId, recordId: recordId);
  }

  @override
  Future<void> deletePlan(String id) {
    return delegate.deletePlan(id);
  }

  @override
  Future<void> saveAppSettings(AppSettings settings) {
    return delegate.saveAppSettings(settings);
  }
}
