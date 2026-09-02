import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../app_theme.dart';
import '../data/pilgrimage_repository.dart';
import '../map/map_tile_config.dart';
import '../data/user_reference_image_stub.dart'
    if (dart.library.io) '../data/user_reference_image_io.dart';
import '../point_detail/point_detail_sheet.dart';
import '../utils/selected_item_order.dart';
import '../widgets/confirm_action_dialog.dart';
import '../widgets/constrained_menu_anchor.dart';
import '../widgets/snackbar_helper.dart';
import 'pilgrimage_models.dart';
import 'plan_group_utils.dart';
import '../../l10n/app_localizations.dart';

class NearestGroupAssignScreen extends StatefulWidget {
  const NearestGroupAssignScreen({
    required this.plan,
    required this.settings,
    required this.repository,
    super.key,
  });

  final PilgrimagePlan plan;
  final AppSettings settings;
  final PilgrimageRepository repository;

  @override
  State<NearestGroupAssignScreen> createState() =>
      _NearestGroupAssignScreenState();
}

class _NearestGroupAssignScreenState extends State<NearestGroupAssignScreen> {
  final MapController _mapController = MapController();
  final Distance _distance = const Distance();
  late PilgrimagePlan _plan = widget.plan;
  late double _distanceMeters = widget.settings.nearestAssignDistanceMeters
      .clamp(50.0, 5000.0);
  PilgrimagePoint? _selectedPoint;
  var _isSaving = false;
  var _didUpdate = false;

  List<PilgrimagePoint> get _ungroupedPoints => _plan.points
      .where((point) => point.groupId == null)
      .toList(growable: false);

  // A group's reference center for "nearest" assignment: its anchor if set,
  // otherwise the centroid of the points already in it. Groups with neither
  // (empty, anchorless) have no center and can't be a target. Making the anchor
  // optional removes the old hard gate that blocked assignment entirely.
  LatLng? _centerOf(PilgrimagePlanGroup group) {
    if (group.anchorLatitude != null && group.anchorLongitude != null) {
      return LatLng(group.anchorLatitude!, group.anchorLongitude!);
    }
    final points = _plan.points
        .where((point) => point.groupId == group.id)
        .toList(growable: false);
    if (points.isEmpty) {
      return null;
    }
    final latitude =
        points.map((p) => p.position.latitude).reduce((a, b) => a + b) /
        points.length;
    final longitude =
        points.map((p) => p.position.longitude).reduce((a, b) => a + b) /
        points.length;
    return LatLng(latitude, longitude);
  }

  List<PilgrimagePlanGroup> get _targetGroups => sortGroupsByPlanOrder(
    _plan.groups.where((group) => _centerOf(group) != null),
  );

  Map<String, Set<String>> get _assignments {
    final assignments = <String, Set<String>>{};
    for (final point in _ungroupedPoints) {
      final nearest = _nearestGroupFor(point);
      if (nearest == null) {
        continue;
      }
      final center = _centerOf(nearest);
      if (center == null) {
        continue;
      }
      final meters = _distance(point.position, center);
      if (meters <= _distanceMeters) {
        assignments.putIfAbsent(nearest.id, () => {}).add(point.id);
      }
    }
    return assignments;
  }

  int get _assignableCount =>
      _assignments.values.fold(0, (total, ids) => total + ids.length);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final mapPoints = selectedItemsLast<PilgrimagePoint>(
      _ungroupedPoints,
      isSelected: (point) => point.id == _selectedPoint?.id,
    );

    return PopScope(
      canPop: !_isSaving,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          return;
        }
        Navigator.of(context).pop(_didUpdate);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: l10n.tooltipBack,
            onPressed: () => Navigator.of(context).pop(_didUpdate),
            icon: const Icon(Icons.arrow_back),
          ),
          title: Text(l10n.mapImportOrganizeNearestAssign),
        ),
        body: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _mapCenter,
                initialZoom: 14.5,
                minZoom: 4,
                maxZoom: 24,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                configuredMapTileLayer(widget.settings),
                CircleLayer(
                  circles: [
                    for (final group in _targetGroups)
                      CircleMarker(
                        point: _centerOf(group)!,
                        radius: _distanceMeters,
                        useRadiusInMeter: true,
                        color: AppColors.accent.withValues(alpha: 0.12),
                        borderColor: AppColors.accentDark.withValues(
                          alpha: 0.72,
                        ),
                        borderStrokeWidth: 2,
                      ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    for (final group in _targetGroups)
                      Marker(
                        point: _centerOf(group)!,
                        width: 38,
                        height: 38,
                        child: _AnchorMarker(name: group.name),
                      ),
                    for (final point in mapPoints)
                      Marker(
                        point: point.position,
                        width: point.id == _selectedPoint?.id ? 42 : 36,
                        height: point.id == _selectedPoint?.id ? 42 : 36,
                        child: _AssignPointMarker(
                          selected: point.id == _selectedPoint?.id,
                          assignable: _isAssignable(point),
                          onTap: () => _selectPoint(point),
                        ),
                      ),
                  ],
                ),
                configuredMapAttribution(widget.settings),
              ],
            ),
            Positioned(
              left: 12,
              right: 12,
              top: 12,
              child: SafeArea(
                bottom: false,
                child: _NearestAssignPanel(
                  distanceMeters: _distanceMeters,
                  assignableCount: _assignableCount,
                  ungroupedCount: _ungroupedPoints.length,
                  groupCount: _targetGroups.length,
                  isSaving: _isSaving,
                  onDistanceChanged: (value) {
                    setState(() {
                      _distanceMeters = value;
                    });
                  },
                  onAssign: _confirmAssign,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: _selectedPoint == null
                  ? _NearestAssignHintCard(
                      ungroupedCount: _ungroupedPoints.length,
                      groupCount: _targetGroups.length,
                    )
                  : _NearestAssignPointCard(
                      point: _selectedPoint!,
                      nearestGroup: _nearestGroupFor(_selectedPoint!),
                      distanceMeters: _nearestDistanceFor(_selectedPoint!),
                      assignable: _isAssignable(_selectedPoint!),
                      onOpenDetail: () => _showPointDetail(_selectedPoint!),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  LatLng get _mapCenter {
    final positions = [
      for (final point in _ungroupedPoints) point.position,
      for (final group in _targetGroups) _centerOf(group)!,
    ];
    if (positions.isEmpty) {
      return previewCurrentLocation;
    }
    final latitude =
        positions.map((point) => point.latitude).reduce((a, b) => a + b) /
        positions.length;
    final longitude =
        positions.map((point) => point.longitude).reduce((a, b) => a + b) /
        positions.length;
    return LatLng(latitude, longitude);
  }

  PilgrimagePlanGroup? _nearestGroupFor(PilgrimagePoint point) {
    PilgrimagePlanGroup? nearestGroup;
    var nearestMeters = double.infinity;
    for (final group in _targetGroups) {
      final center = _centerOf(group);
      if (center == null) {
        continue;
      }
      final meters = _distance(point.position, center);
      if (meters < nearestMeters) {
        nearestMeters = meters;
        nearestGroup = group;
      }
    }
    return nearestGroup;
  }

  double? _nearestDistanceFor(PilgrimagePoint point) {
    final group = _nearestGroupFor(point);
    final center = group == null ? null : _centerOf(group);
    if (center == null) {
      return null;
    }
    return _distance(point.position, center);
  }

  bool _isAssignable(PilgrimagePoint point) {
    final distance = _nearestDistanceFor(point);
    return distance != null && distance <= _distanceMeters;
  }

  void _selectPoint(PilgrimagePoint point) {
    setState(() {
      _selectedPoint = point;
    });
  }

  Future<void> _confirmAssign() async {
    final l10n = AppLocalizations.of(context)!;
    if (_isSaving) {
      return;
    }
    final assignments = _assignments;
    final count = assignments.values.fold(
      0,
      (total, ids) => total + ids.length,
    );
    if (count == 0) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showReplacingSnackBar(SnackBar(content: Text(l10n.noAssignablePointsWithinTheCurrentDistance)));
      return;
    }
    final confirmed = await showConfirmActionDialog(
      context,
      title: l10n.confirmRecentAssignment,
      message:
          l10n.willAssignUngroupedPointsToTheNearestAreaAnchorWithAMaximumDistanceOf2((count).toString(), (_formatDistance(_distanceMeters)).toString()),
      confirmLabel: l10n.startAssignment,
      icon: Icons.near_me_outlined,
    );
    if (!confirmed || !mounted) {
      return;
    }

    setState(() {
      _isSaving = true;
    });
    try {
      final l10n = AppLocalizations.of(context)!;
      await widget.repository.saveAppSettings(
        widget.settings.copyWith(nearestAssignDistanceMeters: _distanceMeters),
      );
      var updatedPlan = _plan;
      for (final entry in assignments.entries) {
        updatedPlan = await widget.repository.movePointsToGroup(
          planId: updatedPlan.id,
          pointIds: entry.value,
          groupId: entry.key,
        );
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _plan = updatedPlan;
        _selectedPoint = null;
        _didUpdate = true;
        _isSaving = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showReplacingSnackBar(SnackBar(content: Text(l10n.assignedPoints3((count).toString()))));
    } catch (_) {
      final l10n = AppLocalizations.of(context)!;
      if (!mounted) {
        return;
      }
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showReplacingSnackBar(SnackBar(content: Text(l10n.recentAssignmentFailed)));
    }
  }

  void _showPointDetail(PilgrimagePoint point) {
    PointDetailSheet.show(
      context,
      point: point,
      status: VisitStatus.pending,
      onSetCurrent: () {},
      onOpenCamera: () {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showReplacingSnackBar(SnackBar(content: Text(l10n.finishAreaAssignmentFirst)));
      },
      onComplete: () {},
      onReplaceReference: _replaceReferenceImage,
      actionScope: PointDetailActionScope.assign,
      groups: _plan.groups,
      onMoveToGroup: _movePointToGroup,
      navigationApp: widget.settings.navigationApp,
    );
  }

  Future<void> _replaceReferenceImage(
    PilgrimagePoint point,
    StoredUserReferenceImage image,
  ) async {
    final updatedPlan = await widget.repository.updatePointInPlan(
      planId: _plan.id,
      point: point.copyWith(
        referenceImageUrl: null,
        referenceThumbnailPath: image.thumbnailPath,
        referenceFullImagePath: image.fullImagePath,
      ),
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _plan = updatedPlan;
      _selectedPoint = updatedPlan.points.firstWhere((p) => p.id == point.id);
      _didUpdate = true;
    });
  }

  Future<void> _movePointToGroup(PilgrimagePoint point, String? groupId) async {
    final updatedPlan = await widget.repository.movePointsToGroup(
      planId: _plan.id,
      pointIds: {point.id},
      groupId: groupId,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _plan = updatedPlan;
      _selectedPoint = null;
      _didUpdate = true;
    });
  }
}

class BoxGroupAssignScreen extends StatefulWidget {
  const BoxGroupAssignScreen({
    required this.plan,
    required this.repository,
    required this.settings,
    super.key,
  });

  final PilgrimagePlan plan;
  final PilgrimageRepository repository;
  final AppSettings settings;

  @override
  State<BoxGroupAssignScreen> createState() => _BoxGroupAssignScreenState();
}

class _BoxGroupAssignScreenState extends State<BoxGroupAssignScreen> {
  final MapController _mapController = MapController();
  late PilgrimagePlan _plan = widget.plan;
  String? _targetGroupId;
  PilgrimagePoint? _selectedPoint;
  var _isBoxSelecting = false;
  var _isSaving = false;
  var _didUpdate = false;
  Offset? _selectionStart;
  Offset? _selectionEnd;

  List<PilgrimagePoint> get _ungroupedPoints => _plan.points
      .where((point) => point.groupId == null)
      .toList(growable: false);

  List<PilgrimagePlanGroup> get _groups => sortGroupsByPlanOrder(_plan.groups);

  PilgrimagePlanGroup? get _targetGroup {
    final groupId = _targetGroupId;
    if (groupId == null) {
      return _groups.firstOrNull;
    }
    return _groups.where((group) => group.id == groupId).firstOrNull ??
        _groups.firstOrNull;
  }

  Rect? get _selectionRect {
    final start = _selectionStart;
    final end = _selectionEnd;
    if (start == null || end == null) {
      return null;
    }
    return Rect.fromPoints(start, end);
  }

  List<PilgrimagePoint> get _selectedBoxPoints {
    final rect = _normalizedSelectionRect;
    if (rect == null) {
      return const [];
    }
    return _ungroupedPoints
        .where((point) {
          final offset = _mapController.camera.latLngToScreenOffset(
            point.position,
          );
          return rect.contains(offset);
        })
        .toList(growable: false);
  }

  Rect? get _normalizedSelectionRect {
    final rect = _selectionRect;
    if (rect == null) {
      return null;
    }
    return Rect.fromLTRB(
      math.min(rect.left, rect.right),
      math.min(rect.top, rect.bottom),
      math.max(rect.left, rect.right),
      math.max(rect.top, rect.bottom),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final targetGroup = _targetGroup;
    final selectedBoxPoints = _selectedBoxPoints;
    final mapPoints = selectedItemsLast<PilgrimagePoint>(
      _ungroupedPoints,
      isSelected: (point) => point.id == _selectedPoint?.id,
    );

    return PopScope(
      canPop: !_isSaving,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          return;
        }
        Navigator.of(context).pop(_didUpdate);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: l10n.tooltipBack,
            onPressed: () => Navigator.of(context).pop(_didUpdate),
            icon: const Icon(Icons.arrow_back),
          ),
          title: Text(l10n.btnBoxSelectAssign),
        ),
        body: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _mapCenter,
                initialZoom: 14.5,
                minZoom: 4,
                maxZoom: 24,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                configuredMapTileLayer(widget.settings),
                MarkerLayer(
                  markers: [
                    for (final group in _groups)
                      if (group.anchorLatitude != null &&
                          group.anchorLongitude != null)
                        Marker(
                          point: LatLng(
                            group.anchorLatitude!,
                            group.anchorLongitude!,
                          ),
                          width: 38,
                          height: 38,
                          child: _AnchorMarker(name: group.name),
                        ),
                    for (final point in mapPoints)
                      Marker(
                        point: point.position,
                        width: point.id == _selectedPoint?.id ? 42 : 36,
                        height: point.id == _selectedPoint?.id ? 42 : 36,
                        child: _AssignPointMarker(
                          selected: point.id == _selectedPoint?.id,
                          assignable: selectedBoxPoints.any(
                            (candidate) => candidate.id == point.id,
                          ),
                          onTap: () => _selectPoint(point),
                        ),
                      ),
                  ],
                ),
                configuredMapAttribution(widget.settings),
              ],
            ),
            if (_isBoxSelecting)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart: (details) {
                    setState(() {
                      _selectionStart = details.localPosition;
                      _selectionEnd = details.localPosition;
                    });
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      _selectionEnd = details.localPosition;
                    });
                  },
                  child: CustomPaint(
                    painter: _SelectionRectPainter(_selectionRect),
                  ),
                ),
              ),
            Positioned(
              left: 12,
              right: 12,
              top: 12,
              child: SafeArea(
                bottom: false,
                child: _BoxAssignPanel(
                  groups: _groups,
                  targetGroup: targetGroup,
                  selectedCount: selectedBoxPoints.length,
                  ungroupedCount: _ungroupedPoints.length,
                  isBoxSelecting: _isBoxSelecting,
                  isSaving: _isSaving,
                  onSelectGroup: (group) {
                    setState(() {
                      _targetGroupId = group.id;
                    });
                  },
                  onToggleBoxSelection: () {
                    setState(() {
                      _isBoxSelecting = !_isBoxSelecting;
                      _selectionStart = null;
                      _selectionEnd = null;
                    });
                  },
                  onAssign: _confirmAssignBox,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: _selectedPoint == null
                  ? _NearestAssignHintCard(
                      ungroupedCount: _ungroupedPoints.length,
                      groupCount: _groups.length,
                    )
                  : _NearestAssignPointCard(
                      point: _selectedPoint!,
                      nearestGroup: targetGroup,
                      distanceMeters: null,
                      assignable: selectedBoxPoints.any(
                        (point) => point.id == _selectedPoint!.id,
                      ),
                      onOpenDetail: () => _showPointDetail(_selectedPoint!),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  LatLng get _mapCenter {
    final positions = [
      for (final point in _ungroupedPoints) point.position,
      for (final group in _groups)
        if (group.anchorLatitude != null && group.anchorLongitude != null)
          LatLng(group.anchorLatitude!, group.anchorLongitude!),
    ];
    if (positions.isEmpty) {
      return previewCurrentLocation;
    }
    final latitude =
        positions.map((point) => point.latitude).reduce((a, b) => a + b) /
        positions.length;
    final longitude =
        positions.map((point) => point.longitude).reduce((a, b) => a + b) /
        positions.length;
    return LatLng(latitude, longitude);
  }

  void _selectPoint(PilgrimagePoint point) {
    if (_isBoxSelecting) {
      return;
    }
    setState(() {
      _selectedPoint = point;
    });
  }

  Future<void> _confirmAssignBox() async {
    final l10n = AppLocalizations.of(context)!;
    if (_isSaving) {
      return;
    }
    final targetGroup = _targetGroup;
    final points = _selectedBoxPoints;
    if (targetGroup == null) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showReplacingSnackBar(SnackBar(content: Text(l10n.createAnAreaFirst)));
      return;
    }
    if (points.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showReplacingSnackBar(SnackBar(content: Text(l10n.noUngroupedPointsWithinTheBoxSelection)));
      return;
    }
    final confirmed = await showConfirmActionDialog(
      context,
      title: l10n.confirmBoxSelectionAssignment,
      message: l10n.willMoveUngroupedPointsTo2((points.length).toString(), (targetGroup.name).toString()),
      confirmLabel: l10n.assign,
      icon: Icons.select_all_outlined,
    );
    if (!confirmed || !mounted) {
      return;
    }

    setState(() {
      _isSaving = true;
    });
    try {
      final l10n = AppLocalizations.of(context)!;
      final updatedPlan = await widget.repository.movePointsToGroup(
        planId: _plan.id,
        pointIds: points.map((point) => point.id).toSet(),
        groupId: targetGroup.id,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _plan = updatedPlan;
        _selectedPoint = null;
        _selectionStart = null;
        _selectionEnd = null;
        _didUpdate = true;
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showReplacingSnackBar(
        SnackBar(content: Text(l10n.assignedPoints4((points.length).toString()))),
      );
    } catch (_) {
      final l10n = AppLocalizations.of(context)!;
      if (!mounted) {
        return;
      }
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showReplacingSnackBar(SnackBar(content: Text(l10n.boxSelectionAssignmentFailed)));
    }
  }

  void _showPointDetail(PilgrimagePoint point) {
    PointDetailSheet.show(
      context,
      point: point,
      status: VisitStatus.pending,
      onSetCurrent: () {},
      onOpenCamera: () {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showReplacingSnackBar(SnackBar(content: Text(l10n.finishAreaAssignmentFirst)));
      },
      onComplete: () {},
      onReplaceReference: _replaceReferenceImage,
      actionScope: PointDetailActionScope.assign,
      groups: _plan.groups,
      onMoveToGroup: _movePointToGroup,
      navigationApp: widget.settings.navigationApp,
    );
  }

  Future<void> _replaceReferenceImage(
    PilgrimagePoint point,
    StoredUserReferenceImage image,
  ) async {
    final updatedPlan = await widget.repository.updatePointInPlan(
      planId: _plan.id,
      point: point.copyWith(
        referenceImageUrl: null,
        referenceThumbnailPath: image.thumbnailPath,
        referenceFullImagePath: image.fullImagePath,
      ),
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _plan = updatedPlan;
      _selectedPoint = updatedPlan.points.firstWhere((p) => p.id == point.id);
      _didUpdate = true;
    });
  }

  Future<void> _movePointToGroup(PilgrimagePoint point, String? groupId) async {
    final updatedPlan = await widget.repository.movePointsToGroup(
      planId: _plan.id,
      pointIds: {point.id},
      groupId: groupId,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _plan = updatedPlan;
      _selectedPoint = null;
      _didUpdate = true;
    });
  }
}

class _BoxAssignPanel extends StatelessWidget {
  const _BoxAssignPanel({
    required this.groups,
    required this.targetGroup,
    required this.selectedCount,
    required this.ungroupedCount,
    required this.isBoxSelecting,
    required this.isSaving,
    required this.onSelectGroup,
    required this.onToggleBoxSelection,
    required this.onAssign,
  });

  final List<PilgrimagePlanGroup> groups;
  final PilgrimagePlanGroup? targetGroup;
  final int selectedCount;
  final int ungroupedCount;
  final bool isBoxSelecting;
  final bool isSaving;
  final ValueChanged<PilgrimagePlanGroup> onSelectGroup;
  final VoidCallback onToggleBoxSelection;
  final VoidCallback onAssign;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.96),
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: AppButtonStyles.compactHeight,
                    child: ConstrainedMenuAnchor(
                      builder: (context, controller, child) {
                        return OutlinedButton.icon(
                          onPressed: groups.isEmpty
                              ? null
                              : () {
                                  if (controller.isOpen) {
                                    controller.close();
                                  } else {
                                    controller.open();
                                  }
                                },
                          icon: const Icon(Icons.folder_outlined, size: 18),
                          style: AppButtonStyles.compactOutlinedButton(),
                          label: Text(
                            targetGroup?.name ?? l10n.selectArea,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      },
                      menuChildrenBuilder: (context, itemWidth) => [
                        for (final group in groups)
                          MenuItemButton(
                            onPressed: () => onSelectGroup(group),
                            child: SizedBox(
                              width: itemWidth,
                              child: Text(
                                group.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: AppButtonStyles.compactHeight,
                  child: OutlinedButton.icon(
                    onPressed: isSaving ? null : onToggleBoxSelection,
                    style: AppButtonStyles.compactOutlinedButton(),
                    icon: Icon(
                      isBoxSelecting ? Icons.close : Icons.select_all_outlined,
                      size: 17,
                    ),
                    label: Text(isBoxSelecting ? l10n.endBoxSelect : l10n.boxSelect),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.selectedUngrouped((selectedCount).toString(), (ungroupedCount).toString()),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: AppButtonStyles.compactHeight,
                  child: FilledButton(
                    onPressed:
                        isSaving || targetGroup == null || selectedCount == 0
                        ? null
                        : onAssign,
                    style: AppButtonStyles.compactFilledButton(),
                    child: Text(isSaving ? l10n.assigning : l10n.assign),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectionRectPainter extends CustomPainter {
  const _SelectionRectPainter(this.rect);

  final Rect? rect;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = this.rect;
    if (rect == null) {
      return;
    }
    final normalized = Rect.fromLTRB(
      math.min(rect.left, rect.right),
      math.min(rect.top, rect.bottom),
      math.max(rect.left, rect.right),
      math.max(rect.top, rect.bottom),
    );
    final fillPaint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.14)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = AppColors.accent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawRect(normalized, fillPaint);
    canvas.drawRect(normalized, strokePaint);
  }

  @override
  bool shouldRepaint(_SelectionRectPainter oldDelegate) {
    return oldDelegate.rect != rect;
  }
}

class _NearestAssignPanel extends StatelessWidget {
  const _NearestAssignPanel({
    required this.distanceMeters,
    required this.assignableCount,
    required this.ungroupedCount,
    required this.groupCount,
    required this.isSaving,
    required this.onDistanceChanged,
    required this.onAssign,
  });

  final double distanceMeters;
  final int assignableCount;
  final int ungroupedCount;
  final int groupCount;
  final bool isSaving;
  final ValueChanged<double> onDistanceChanged;
  final VoidCallback onAssign;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.96),
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_fix_high_outlined, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.maxDistanceAssignable((_formatDistance(distanceMeters)).toString(), (assignableCount).toString(), (ungroupedCount).toString()),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 36,
                  child: FilledButton(
                    onPressed: isSaving || groupCount == 0 ? null : onAssign,
                    child: Text(isSaving ? l10n.assigning : l10n.assign),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              l10n.ungroupedPointsAreAssignedToTheNearestAreaAnchorWithinTheMaximumDistance,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.25,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 8),
            Slider(
              value: distanceMeters.clamp(50.0, 5000.0),
              min: 50,
              max: 5000,
              divisions: 99,
              label: _formatDistance(distanceMeters),
              onChanged: isSaving ? null : onDistanceChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _NearestAssignPointCard extends StatelessWidget {
  const _NearestAssignPointCard({
    required this.point,
    required this.nearestGroup,
    required this.distanceMeters,
    required this.assignable,
    required this.onOpenDetail,
  });

  final PilgrimagePoint point;
  final PilgrimagePlanGroup? nearestGroup;
  final double? distanceMeters;
  final bool assignable;
  final VoidCallback onOpenDetail;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(12, 0, 12, 12 + bottomInset),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                assignable ? Icons.check_circle_outline : Icons.info_outline,
                color: assignable ? AppColors.accentDark : AppColors.warning,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      point.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      nearestGroup == null
                          ? l10n.noAvailableAreaAnchors
                          : '${nearestGroup!.name} · ${_formatDistance(distanceMeters ?? 0)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(onPressed: onOpenDetail, child: Text(l10n.mapImportPointDetailBtn)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NearestAssignHintCard extends StatelessWidget {
  const _NearestAssignHintCard({
    required this.ungroupedCount,
    required this.groupCount,
  });

  final int ungroupedCount;
  final int groupCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(12, 0, 12, 12 + bottomInset),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            groupCount == 0
                ? l10n.createAnAreaFirstYouCanUseSmartZoningToGenerateOne
                : l10n.ungroupedTapAMapPointForDetails((ungroupedCount).toString()),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}

class _AssignPointMarker extends StatelessWidget {
  const _AssignPointMarker({
    required this.selected,
    required this.assignable,
    required this.onTap,
  });

  final bool selected;
  final bool assignable;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = assignable ? AppColors.accent : AppColors.surfaceMuted;
    return IconButton(
      tooltip: assignable ? l10n.assignablePoints : l10n.outOfRangePoints,
      onPressed: onTap,
      style: IconButton.styleFrom(
        backgroundColor: selected ? AppColors.accentDark : color,
        foregroundColor: selected || assignable
            ? Colors.white
            : AppColors.textSecondary,
        side: BorderSide(
          color: selected ? AppColors.warning : AppColors.border,
          width: selected ? 2 : 1,
        ),
      ),
      icon: const Icon(Icons.place, size: 20),
    );
  }
}

class _AnchorMarker extends StatelessWidget {
  const _AnchorMarker({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: name,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.accentDark, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(Icons.flag_outlined, color: AppColors.accentDark),
      ),
    );
  }
}

String _formatDistance(double meters) {
  if (meters >= 1000) {
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }
  return '${meters.round()} m';
}
