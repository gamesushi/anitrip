import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../data/pilgrimage_repository.dart';
import '../l10n/app_localizations.dart';
import '../map/map_navigation_launcher.dart';
import '../widgets/snackbar_helper.dart';
import 'group_anchor_picker_screen.dart';
import 'pilgrimage_models.dart';
import 'route_optimizer.dart';

const Object _unsetGroupField = Object();

Widget _cleanReorderProxy(
  Widget child,
  int index,
  Animation<double> animation,
) {
  return AnimatedBuilder(
    animation: animation,
    builder: (context, child) {
      final elevation = Curves.easeOut.transform(animation.value) * 10;
      return Material(
        color: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.18),
        elevation: elevation,
        borderRadius: BorderRadius.circular(8),
        child: child,
      );
    },
    child: child,
  );
}

class PlanGroupManagerScreen extends StatefulWidget {
  const PlanGroupManagerScreen({
    required this.plan,
    required this.repository,
    super.key,
  });

  final PilgrimagePlan plan;
  final PilgrimageRepository repository;

  @override
  State<PlanGroupManagerScreen> createState() => _PlanGroupManagerScreenState();
}

class _PlanGroupManagerScreenState extends State<PlanGroupManagerScreen> {
  late PilgrimagePlan _plan = widget.plan;
  var _isSaving = false;
  var _didUpdate = false;

  List<PilgrimagePlanGroup> get _groups {
    return [..._plan.groups]
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  }

  int get _ungroupedCount {
    return _plan.points.where((point) => point.groupId == null).length;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final groups = _groups;

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
          title: Text(l10n.mapImportOrganizeGroupManager),
          actions: [
            if (_isSaving)
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _isSaving ? null : _createGroup,
          icon: const Icon(Icons.add),
          label: Text(l10n.newArea),
        ),
        body: ReorderableListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          header: _PlanGroupManagerHeader(
            plan: _plan,
            groupCount: groups.length,
          ),
          itemCount: groups.length + 1,
          buildDefaultDragHandles: false,
          proxyDecorator: _cleanReorderProxy,
          onReorderItem: _reorderGroups,
          itemBuilder: (context, index) {
            if (index == groups.length) {
              return Padding(
                key: const ValueKey('ungrouped'),
                padding: const EdgeInsets.only(bottom: 8),
                child: _UngroupedGroupCard(pointCount: _ungroupedCount),
              );
            }

            final group = groups[index];
            final pointCount = _plan.points
                .where((point) => point.groupId == group.id)
                .length;
            return Padding(
              key: ValueKey(group.id),
              padding: const EdgeInsets.only(bottom: 8),
              child: _PlanGroupCard(
                index: index,
                group: group,
                pointCount: pointCount,
                isBusy: _isSaving,
                onRename: () => _renameGroup(group),
                onSetAnchor: () => _setGroupAnchor(group),
                onToggleOrderMode: () => _toggleOrderMode(group),
                onGenerateRoute: () => _generateRoute(group),
                onExportRoute: () => _exportRoute(group),
                onDelete: () => _confirmDeleteGroup(group, pointCount),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _createGroup() async {
    final l10n = AppLocalizations.of(context)!;
    final name = await showDialog<String>(
      context: context,
      builder: (context) => const _CreatePlanGroupDialog(),
    );
    final trimmedName = name?.trim();
    if (trimmedName == null || trimmedName.isEmpty || !mounted) {
      return;
    }

    final nextOrderIndex = _groups.isEmpty
        ? 0
        : _groups
                  .map((group) => group.orderIndex)
                  .reduce((a, b) => a > b ? a : b) +
              1;
    final now = DateTime.now();
    await _savePlanChange(
      action: () => widget.repository.createPlanGroup(
        planId: _plan.id,
        group: PilgrimagePlanGroup(
          id: 'group-${now.microsecondsSinceEpoch}',
          name: trimmedName,
          orderIndex: nextOrderIndex,
          createdAt: now,
        ),
      ),
      failureMessage: l10n.areaCreationFailed,
    );
  }

  Future<void> _renameGroup(PilgrimagePlanGroup group) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: group.name);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.renameArea),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: l10n.areaName),
          textInputAction: TextInputAction.done,
          onSubmitted: (value) => Navigator.of(context).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.btnCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: Text(l10n.btnSave),
          ),
        ],
      ),
    );
    controller.dispose();
    final trimmedName = name?.trim();
    if (trimmedName == null ||
        trimmedName.isEmpty ||
        trimmedName == group.name ||
        !mounted) {
      return;
    }

    await _savePlanChange(
      action: () => widget.repository.renamePlanGroup(
        planId: _plan.id,
        groupId: group.id,
        name: trimmedName,
      ),
      failureMessage: l10n.areaRenameFailed,
    );
  }

  Future<void> _toggleOrderMode(PilgrimagePlanGroup group) {
    final l10n = AppLocalizations.of(context)!;
    final nextMode = group.orderMode == PlanGroupOrderMode.manual
        ? PlanGroupOrderMode.unordered
        : PlanGroupOrderMode.manual;
    return _savePlanChange(
      action: () => widget.repository.updatePlanGroup(
        planId: _plan.id,
        group: _copyGroup(group, orderMode: nextMode),
      ),
      failureMessage: l10n.sortOrderSaveFailed,
    );
  }

  Future<void> _generateRoute(PilgrimagePlanGroup group) async {
    final l10n = AppLocalizations.of(context)!;
    final route = recommendedRouteForGroup(group, _plan.points);
    if (route.orderedPoints.length < 2) {
      if (mounted) {
        ScaffoldMessenger.of(context).showReplacingSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.routeTooFewPoints),
          ),
        );
      }
      return;
    }

    final updated = await _savePlanChange(
      action: () async {
        var updatedPlan = _plan;
        for (var index = 0;
            index < route.orderedPoints.length;
            index += 1) {
          final point = route.orderedPoints[index];
          updatedPlan = await widget.repository.updatePointInPlan(
            planId: updatedPlan.id,
            point: point.copyWith(groupOrderIndex: index),
          );
        }
        return widget.repository.updatePlanGroup(
          planId: updatedPlan.id,
          group: _copyGroup(group, orderMode: PlanGroupOrderMode.manual),
        );
      },
      failureMessage: l10n.recommendedRouteGenerationFailed,
    );

    if (updated != null && mounted) {
      final l10n = AppLocalizations.of(context)!;
      final summary =
          l10n.pointsAbout2((route.orderedPoints.length).toString()) +
          l10n.onFoot2((formatRouteDistance(route.totalDistanceMeters)).toString());
      ScaffoldMessenger.of(context).showReplacingSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.routeGenerated(summary)),
        ),
      );
    }
  }

  Future<void> _exportRoute(PilgrimagePlanGroup group) async {
    final ordered = group.orderMode == PlanGroupOrderMode.manual
        ? orderedPointsForGroup(group, _plan.points)
        : recommendedRouteForGroup(group, _plan.points).orderedPoints;
    if (ordered.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showReplacingSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.routeTooFewPoints),
          ),
        );
      }
      return;
    }

    final settings = await widget.repository.loadAppSettings();
    if (!mounted) {
      return;
    }
    final opened = await const MapNavigationLauncher().openRoute(
      ordered,
      settings.navigationApp,
    );
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showReplacingSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.routeExportFailed),
        ),
      );
    }
  }

  Future<void> _setGroupAnchor(PilgrimagePlanGroup group) async {
    final l10n = AppLocalizations.of(context)!;
    final settings = await widget.repository.loadAppSettings();
    if (!mounted) {
      return;
    }
    final selection = await Navigator.of(context).push<GroupAnchorSelection>(
      MaterialPageRoute(
        builder: (_) => GroupAnchorPickerScreen(
          group: group,
          points: _plan.points,
          groupNameForPoint: _groupNameForPoint,
          settings: settings,
        ),
      ),
    );
    if (selection == null || !mounted) {
      return;
    }
    await _savePlanChange(
      action: () => widget.repository.updatePlanGroup(
        planId: _plan.id,
        group: _copyGroup(
          group,
          anchorName: selection.name,
          anchorLatitude: selection.position?.latitude,
          anchorLongitude: selection.position?.longitude,
          anchorPointId: selection.pointId,
        ),
      ),
      failureMessage: l10n.anchorSaveFailed,
    );
  }

  Future<void> _confirmDeleteGroup(
    PilgrimagePlanGroup group,
    int pointCount,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteArea),
        content: Text(l10n.deletePointsWillBeMovedToUngroupedPoints2((group.name).toString(), (pointCount).toString())),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.btnCancel),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.delete_outline, size: 18),
            label: Text(l10n.btnDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }

    await _savePlanChange(
      action: () => widget.repository.deletePlanGroup(
        planId: _plan.id,
        groupId: group.id,
      ),
      failureMessage: l10n.areaDeletionFailed,
    );
  }

  Future<void> _reorderGroups(int oldIndex, int newIndex) async {
    final l10n = AppLocalizations.of(context)!;
    final groups = _groups;
    if (_isSaving || oldIndex >= groups.length || newIndex > groups.length) {
      return;
    }
    final group = groups.removeAt(oldIndex);
    groups.insert(newIndex, group);

    await _savePlanChange(
      action: () async {
        var updatedPlan = _plan;
        for (var index = 0; index < groups.length; index += 1) {
          final group = groups[index];
          updatedPlan = await widget.repository.updatePlanGroup(
            planId: updatedPlan.id,
            group: _copyGroup(group, orderIndex: index),
          );
        }
        return updatedPlan;
      },
      failureMessage: l10n.areaOrderSaveFailed,
    );
  }

  Future<PilgrimagePlan?> _savePlanChange({
    required Future<PilgrimagePlan> Function() action,
    required String failureMessage,
  }) async {
    if (_isSaving) {
      return null;
    }
    setState(() {
      _isSaving = true;
    });
    try {
      final updatedPlan = await action();
      if (!mounted) {
        return null;
      }
      setState(() {
        _plan = updatedPlan;
        _didUpdate = true;
        _isSaving = false;
      });
      return updatedPlan;
    } catch (_) {
      if (!mounted) {
        return null;
      }
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showReplacingSnackBar(SnackBar(content: Text(failureMessage)));
      return null;
    }
  }

  PilgrimagePlanGroup _copyGroup(
    PilgrimagePlanGroup group, {
    String? name,
    int? orderIndex,
    PlanGroupOrderMode? orderMode,
    Object? anchorName = _unsetGroupField,
    Object? anchorLatitude = _unsetGroupField,
    Object? anchorLongitude = _unsetGroupField,
    Object? anchorPointId = _unsetGroupField,
  }) {
    return PilgrimagePlanGroup(
      id: group.id,
      name: name ?? group.name,
      orderIndex: orderIndex ?? group.orderIndex,
      orderMode: orderMode ?? group.orderMode,
      anchorName: anchorName == _unsetGroupField
          ? group.anchorName
          : anchorName as String?,
      anchorLatitude: anchorLatitude == _unsetGroupField
          ? group.anchorLatitude
          : anchorLatitude as double?,
      anchorLongitude: anchorLongitude == _unsetGroupField
          ? group.anchorLongitude
          : anchorLongitude as double?,
      anchorPointId: anchorPointId == _unsetGroupField
          ? group.anchorPointId
          : anchorPointId as String?,
      note: group.note,
      createdAt: group.createdAt,
    );
  }

  String _groupNameForPoint(PilgrimagePoint point) {
    final l10n = AppLocalizations.of(context)!;
    final groupId = point.groupId;
    if (groupId == null) {
      final l10n = AppLocalizations.of(context)!;
      return l10n.ungroupedPoints;
    }
    return _plan.groups
        .firstWhere(
          (group) => group.id == groupId,
          orElse: () => PilgrimagePlanGroup(
            id: groupId,
            name: l10n.labelUnknownArea,
            orderIndex: 0,
            createdAt: DateTime.fromMillisecondsSinceEpoch(0),
          ),
        )
        .name;
  }
}

class _CreatePlanGroupDialog extends StatefulWidget {
  const _CreatePlanGroupDialog();

  @override
  State<_CreatePlanGroupDialog> createState() => _CreatePlanGroupDialogState();
}

class _CreatePlanGroupDialogState extends State<_CreatePlanGroupDialog> {
  final _controller = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final trimmedName = _controller.text.trim();
    if (trimmedName.isEmpty) {
      setState(() {
        final l10n = AppLocalizations.of(context)!;
        _errorText = l10n.areaNameCannotBeEmpty;
      });
      return;
    }
    Navigator.of(context).pop(trimmedName);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.newArea),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(labelText: l10n.areaName, errorText: _errorText),
        textInputAction: TextInputAction.done,
        onChanged: (_) {
          if (_errorText == null) {
            return;
          }
          setState(() {
            _errorText = null;
          });
        },
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.btnCancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.create)),
      ],
    );
  }
}

class _PlanGroupManagerHeader extends StatelessWidget {
  const _PlanGroupManagerHeader({required this.plan, required this.groupCount});

  final PilgrimagePlan plan;
  final int groupCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(Icons.account_tree_outlined, color: AppColors.accent),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    l10n.areasPoints((groupCount).toString(), (plan.points.length).toString()),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanGroupCard extends StatelessWidget {
  const _PlanGroupCard({
    required this.index,
    required this.group,
    required this.pointCount,
    required this.isBusy,
    required this.onRename,
    required this.onSetAnchor,
    required this.onToggleOrderMode,
    required this.onGenerateRoute,
    required this.onExportRoute,
    required this.onDelete,
  });

  final int index;
  final PilgrimagePlanGroup group;
  final int pointCount;
  final bool isBusy;
  final VoidCallback onRename;
  final VoidCallback onSetAnchor;
  final VoidCallback onToggleOrderMode;
  final VoidCallback onGenerateRoute;
  final VoidCallback onExportRoute;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final orderLabel = group.orderMode == PlanGroupOrderMode.manual
        ? l10n.manualOrder
        : l10n.groupOrderModeNone;
    final anchorLabel = group.anchorName ?? l10n.labelNoAnchor;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 12, 6, 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            ReorderableDragStartListener(
              index: index,
              enabled: !isBusy,
              child: const SizedBox(
                width: 42,
                child: Icon(
                  Icons.drag_indicator,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    l10n.points((pointCount).toString(), (anchorLabel).toString(), (orderLabel).toString()),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              tooltip: l10n.areaActions,
              enabled: !isBusy,
              onSelected: (value) {
                switch (value) {
                  case 'rename':
                    onRename();
                  case 'anchor':
                    onSetAnchor();
                  case 'order':
                    onToggleOrderMode();
                  case 'route':
                    onGenerateRoute();
                  case 'export':
                    onExportRoute();
                  case 'delete':
                    onDelete();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 'rename', child: Text(l10n.rename)),
                PopupMenuItem(value: 'anchor', child: Text(l10n.setAnchor)),
                PopupMenuItem(
                  value: 'order',
                  child: Text(
                    group.orderMode == PlanGroupOrderMode.manual
                        ? l10n.switchToUnordered
                        : l10n.switchToManualOrder,
                  ),
                ),
                PopupMenuItem(
                  value: 'route',
                  child: Text(
                    AppLocalizations.of(context)!.generateRecommendedRoute,
                  ),
                ),
                PopupMenuItem(
                  value: 'export',
                  child: Text(
                    AppLocalizations.of(context)!.exportRouteToMap,
                  ),
                ),
                PopupMenuItem(value: 'delete', child: Text(l10n.deleteArea)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _UngroupedGroupCard extends StatelessWidget {
  const _UngroupedGroupCard({required this.pointCount});

  final int pointCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.inbox_outlined, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.ungroupedPoints,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.pointsAwaitingOrganization((pointCount).toString()),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
