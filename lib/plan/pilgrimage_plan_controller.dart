import 'dart:async';

import 'package:flutter/widgets.dart';

import '../data/pilgrimage_repository.dart';
import 'pilgrimage_models.dart';
import 'plan_group_utils.dart';

class PilgrimagePlanController extends ChangeNotifier {
  PilgrimagePlanController({
    required PilgrimagePlan plan,
    PilgrimageRepository? visitRepository,
  }) : _repository = visitRepository,
       _plan = plan,
       _completedPointIds = {...plan.completedPointIds},
       _currentPointId = plan.currentPointId,
       _selectedPointId = plan.points.firstOrNull?.id {
    unawaited(loadVisitRecords());
  }

  PilgrimagePlan _plan;
  final PilgrimageRepository? _repository;
  Set<String> _completedPointIds;
  List<PilgrimageVisitRecord> _visitRecords = const [];

  String? _currentPointId;
  String? _selectedPointId;

  PilgrimagePlan get plan => _plan;

  List<PilgrimagePoint> get points => _plan.points;

  PilgrimageRepository? get repository => _repository;

  PilgrimagePoint? get currentPoint => _pointById(_currentPointId);

  PilgrimagePoint? get selectedPoint => _pointById(_selectedPointId);

  PilgrimagePoint? pointById(String id) => _pointById(id);

  void replacePlan(PilgrimagePlan plan) {
    _plan = plan;
    _completedPointIds = {...plan.completedPointIds};
    _currentPointId = plan.currentPointId;
    if (_selectedPointId != null && _pointById(_selectedPointId!) == null) {
      _selectedPointId = plan.points.firstOrNull?.id;
    }
    notifyListeners();
  }

  /// Swaps the underlying plan in place while keeping the controller identity
  /// stable. This avoids disposing and recreating the controller, which would
  /// force every listener (including the always-mounted map layers in the
  /// IndexedStack) to rebuild in the same frame — that can deactivate an
  /// inherited widget (e.g. the map's internal state provider) while it still
  /// has dependents and trigger framework assertions such as
  /// `_dependents.isEmpty`.
  ///
  /// The current/selected point is only reset when switching to a genuinely
  /// different plan, so a plain settings/records reload of the same plan does
  /// not lose the user's in-progress selection.
  void applyPlan(PilgrimagePlan plan) {
    final isSamePlan = _plan.id == plan.id;
    _plan = plan;
    _completedPointIds = {...plan.completedPointIds};
    if (!isSamePlan) {
      _currentPointId = plan.currentPointId;
      _selectedPointId = plan.points.firstOrNull?.id;
    } else if (_selectedPointId != null &&
        !plan.points.any((point) => point.id == _selectedPointId)) {
      _selectedPointId = plan.points.firstOrNull?.id;
    }
    notifyListeners();
    // Defer visit-record loading so its notifyListeners() fires in a
    // separate frame.  If it resolved synchronously (e.g. cached SQLite)
    // and notified in the same microtask as applyPlan's own notifyListeners,
    // listeners that own complex InheritedWidget subtrees (e.g. FlutterMap
    // inside an IndexedStack) could hit the framework assertion
    // `_dependents.isEmpty`.
    unawaited(_deferredLoadVisitRecords());
  }

  List<PilgrimagePoint> get completedPoints => points
      .where((point) => _completedPointIds.contains(point.id))
      .toList(growable: false);

  List<PilgrimageVisitRecord> get visitRecords => _visitRecords;

  Set<String> get completedPointIds => Set.unmodifiable(_completedPointIds);

  List<PilgrimageVisitRecord> recordsForPoint(String pointId) => _visitRecords
      .where((record) => record.pointId == pointId)
      .toList(growable: false);

  int get completedCount => _completedPointIds.length;

  int get totalCount => points.length;

  bool get isPlanComplete => completedCount == totalCount;

  bool get hasPoints => points.isNotEmpty;

  VisitStatus statusFor(PilgrimagePoint point) {
    if (_completedPointIds.contains(point.id)) {
      return VisitStatus.completed;
    }

    if (point.id == _currentPointId) {
      return VisitStatus.current;
    }

    return VisitStatus.pending;
  }

  void selectPoint(PilgrimagePoint point) {
    _selectedPointId = point.id;
    notifyListeners();
  }

  void setCurrentPoint(PilgrimagePoint point) {
    if (_completedPointIds.contains(point.id)) {
      _completedPointIds.remove(point.id);
    }

    _currentPointId = point.id;
    _selectedPointId = point.id;
    _persistSetCurrent(point);
    notifyListeners();
  }

  void completePoint(PilgrimagePoint point) {
    _completedPointIds.add(point.id);

    if (point.id == _currentPointId) {
      final nextPoint = nextPendingPointAfterCompletion(
        points: points,
        completedPoint: point,
        completedPointIds: _completedPointIds,
      );
      _currentPointId = nextPoint?.id;
      _selectedPointId = nextPoint?.id ?? point.id;
    }

    _persistComplete(point);
    notifyListeners();
  }

  void reopenPoint(PilgrimagePoint point) {
    _completedPointIds.remove(point.id);
    _currentPointId = point.id;
    _selectedPointId = point.id;
    _persistReopen(point);
    notifyListeners();
  }

  Future<void> loadVisitRecords() async {
    final repository = _repository;
    if (repository == null) {
      return;
    }

    _visitRecords = await repository.loadVisitRecords(_plan.id);
    notifyListeners();
  }

  /// Loads visit records and defers the resulting [notifyListeners()] to the
  /// next frame so it never collides with a synchronous notification that is
  /// already in progress (e.g. from [applyPlan]).
  Future<void> _deferredLoadVisitRecords() async {
    final repository = _repository;
    if (repository == null) {
      return;
    }
    _visitRecords = await repository.loadVisitRecords(_plan.id);
    // Schedule notification for the next frame so it never overlaps
    // with applyPlan's synchronous notifyListeners.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (hasListeners) notifyListeners();
    });
  }

  Future<PilgrimageVisitRecord?> createVisitRecord({
    required PilgrimagePoint point,
    required String photoPath,
    String? referenceImagePath,
    String? referenceImageUrl,
    required String referenceMode,
    DateTime? capturedAt,
  }) async {
    final repository = _repository;
    if (repository == null) {
      return null;
    }

    final record = await repository.createVisitRecord(
      planId: _plan.id,
      pointId: point.id,
      workId: point.work.id,
      workTitle: point.work.title,
      workSubtitle: point.work.subtitle,
      pointName: point.name,
      pointSubtitle: point.subtitle,
      photoPath: photoPath,
      referenceImagePath: referenceImagePath,
      referenceImageUrl: referenceImageUrl,
      referenceMode: referenceMode,
      capturedAt: capturedAt,
    );
    _visitRecords = [record, ..._visitRecords];
    notifyListeners();
    return record;
  }

  Future<void> updatePointImageCache(
    PilgrimagePoint point, {
    String? referenceThumbnailPath,
    String? referenceFullImagePath,
  }) async {
    final repository = _repository;
    if (repository == null) {
      return;
    }

    final updatedPlan = await repository.updatePointImageCache(
      planId: _plan.id,
      pointId: point.id,
      referenceThumbnailPath: referenceThumbnailPath,
      referenceFullImagePath: referenceFullImagePath,
    );
    _replacePlanState(updatedPlan);
  }

  Future<void> updatePointImageCaches(
    Map<String, PointImageCacheUpdate> updatesByPointId,
  ) async {
    final repository = _repository;
    if (repository == null || updatesByPointId.isEmpty) {
      return;
    }

    final updatedPlan = await repository.updatePointImageCaches(
      planId: _plan.id,
      updatesByPointId: updatesByPointId,
    );
    _replacePlanState(updatedPlan);
  }

  Future<void> updatePoint(PilgrimagePoint point) async {
    final repository = _repository;
    if (repository == null) {
      return;
    }

    final updatedPlan = await repository.updatePointInPlan(
      planId: _plan.id,
      point: point,
    );
    _replacePlanState(updatedPlan);
  }

  Future<void> updatePlanMemo(String memo) async {
    final repository = _repository;
    if (repository == null) {
      return;
    }

    final updatedPlan = await repository.updatePlanMemo(
      planId: _plan.id,
      memo: memo,
    );
    _replacePlanState(updatedPlan);
  }

  Future<void> movePointToGroup(PilgrimagePoint point, String? groupId) async {
    final repository = _repository;
    if (repository == null || point.groupId == groupId) {
      return;
    }

    final updatedPlan = await repository.movePointsToGroup(
      planId: _plan.id,
      pointIds: {point.id},
      groupId: groupId,
    );
    _replacePlanState(updatedPlan);
  }

  Future<void> deleteVisitRecord(PilgrimageVisitRecord record) async {
    final repository = _repository;
    if (repository == null) {
      return;
    }

    await repository.deleteVisitRecord(planId: _plan.id, recordId: record.id);
    _visitRecords = _visitRecords
        .where((candidate) => candidate.id != record.id)
        .toList(growable: false);
    notifyListeners();
  }

  Future<PilgrimageVisitRecord?> updateVisitRecordColorGrading({
    required PilgrimageVisitRecord record,
    required String originalPhotoPath,
    required String gradedPhotoPath,
    required String colorGradingMode,
    required String colorGradingParamsJson,
    required double colorGradingIntensity,
  }) async {
    final repository = _repository;
    if (repository == null) {
      return null;
    }

    final updated = await repository.updateVisitRecordColorGrading(
      planId: _plan.id,
      recordId: record.id,
      originalPhotoPath: originalPhotoPath,
      gradedPhotoPath: gradedPhotoPath,
      colorGradingMode: colorGradingMode,
      colorGradingParamsJson: colorGradingParamsJson,
      colorGradingIntensity: colorGradingIntensity,
    );
    _visitRecords = [
      for (final candidate in _visitRecords)
        candidate.id == updated.id ? updated : candidate,
    ];
    notifyListeners();
    return updated;
  }

  Future<PilgrimageVisitRecord?> clearVisitRecordColorGrading({
    required PilgrimageVisitRecord record,
  }) async {
    final repository = _repository;
    if (repository == null) {
      return null;
    }

    final updated = await repository.clearVisitRecordColorGrading(
      planId: _plan.id,
      recordId: record.id,
    );
    _visitRecords = [
      for (final candidate in _visitRecords)
        candidate.id == updated.id ? updated : candidate,
    ];
    notifyListeners();
    return updated;
  }

  void _persistSetCurrent(PilgrimagePoint point) {
    final repository = _repository;
    if (repository == null) {
      return;
    }

    unawaited(repository.setCurrentPoint(planId: _plan.id, pointId: point.id));
  }

  void _persistComplete(PilgrimagePoint point) {
    final repository = _repository;
    if (repository == null) {
      return;
    }

    unawaited(
      repository.completePoint(
        planId: _plan.id,
        pointId: point.id,
        nextCurrentPointId: _currentPointId,
      ),
    );
  }

  void _persistReopen(PilgrimagePoint point) {
    final repository = _repository;
    if (repository == null) {
      return;
    }

    unawaited(repository.reopenPoint(planId: _plan.id, pointId: point.id));
  }

  PilgrimagePoint? _pointById(String? id) {
    if (id == null || points.isEmpty) {
      return null;
    }

    return points.firstWhere(
      (point) => point.id == id,
      orElse: () => points.first,
    );
  }

  void _replacePlanState(PilgrimagePlan updatedPlan) {
    _plan = updatedPlan;
    _completedPointIds = {...updatedPlan.completedPointIds};
    _currentPointId = updatedPlan.currentPointId;
    _selectedPointId =
        updatedPlan.points.any((point) => point.id == _selectedPointId)
        ? _selectedPointId
        : updatedPlan.currentPointId;
    notifyListeners();
  }
}
