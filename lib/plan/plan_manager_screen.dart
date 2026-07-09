import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../l10n/app_localizations.dart';
import '../data/pilgrimage_repository.dart';
import '../plan_transfer/import_export_screen.dart';
import '../widgets/confirm_action_dialog.dart';
import '../widgets/copyable_text.dart';
import 'pilgrimage_models.dart';

class PlanManagerScreen extends StatefulWidget {
  const PlanManagerScreen({required this.repository, super.key});

  final PilgrimageRepository repository;

  @override
  State<PlanManagerScreen> createState() => _PlanManagerScreenState();
}

class _PlanManagerScreenState extends State<PlanManagerScreen> {
  List<PilgrimagePlan>? _plans;
  PilgrimagePlan? _activePlan;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    setState(() {
      _error = null;
    });

    try {
      final plans = await widget.repository.loadPlans();
      final activePlan = await widget.repository.loadActivePlan();
      if (!mounted) {
        return;
      }

      setState(() {
        _plans = plans;
        _activePlan = activePlan;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = error;
      });
    }
  }

  Future<void> _switchPlan(PilgrimagePlan plan) async {
    await widget.repository.setActivePlan(plan.id);
    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
  }

  Future<void> _createEmptyPlan() async {
    final planNumber = (_plans?.length ?? 0) + 1;
    await widget.repository.createPlan(
      name: AppLocalizations.of(context)!.planDefaultNewName(planNumber),
      area: AppLocalizations.of(context)!.planDefaultArea,
    );
    await _loadPlans();
  }

  Future<void> _deletePlan(PilgrimagePlan plan) async {
    final plans = _plans;
    if (plans == null || plans.length <= 1) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.msgDeletePlanAtLeastOne)));
      return;
    }

    final confirmed = await showConfirmActionDialog(
      context,
      title: AppLocalizations.of(context)!.dialogDeletePlanTitle,
      message: AppLocalizations.of(context)!.dialogDeletePlanMessage(plan.name),
      confirmLabel: AppLocalizations.of(context)!.btnDelete,
      icon: Icons.delete_outline,
      destructive: true,
    );
    if (!confirmed || !mounted) {
      return;
    }

    await widget.repository.deletePlan(plan.id);
    await _loadPlans();
  }

  Future<void> _editPlanInfo(PilgrimagePlan plan) async {
    final nameController = TextEditingController(text: plan.name);
    final areaController = TextEditingController(text: plan.area);
    final result = await showDialog<_PlanInfoFormResult>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.dialogEditPlanTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.labelPlanName),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: areaController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.labelPlanArea),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => Navigator.of(context).pop(
                _PlanInfoFormResult(
                  name: nameController.text.trim(),
                  area: areaController.text.trim(),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.btnCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(
              _PlanInfoFormResult(
                name: nameController.text.trim(),
                area: areaController.text.trim(),
              ),
            ),
            child: Text(AppLocalizations.of(context)!.btnSave),
          ),
        ],
      ),
    );
    nameController.dispose();
    areaController.dispose();
    if (result == null || result.name.isEmpty) {
      return;
    }

    final area = result.area.isEmpty ? AppLocalizations.of(context)!.planDefaultArea : result.area;
    if (result.name == plan.name && area == plan.area) {
      return;
    }

    await widget.repository.updatePlanInfo(
      planId: plan.id,
      name: result.name,
      area: area,
    );
    await _loadPlans();
  }

  Future<void> _openImportExport(PilgrimagePlan plan) async {
    final imported = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) =>
            ImportExportScreen(plan: plan, repository: widget.repository),
      ),
    );
    if (imported == true) {
      await _loadPlans();
    }
  }

  @override
  Widget build(BuildContext context) {
    final plans = _plans;

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.planSwitch)),
      body: Builder(
        builder: (context) {
          if (_error != null) {
            return _ErrorState(onRetry: _loadPlans);
          }

          if (plans == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _CreatePlanButton(onPressed: _createEmptyPlan);
              }

              final plan = plans[index - 1];
              return _PlanCard(
                plan: plan,
                selected: plan.id == _activePlan?.id,
                canDelete: plans.length > 1,
                onSwitch: () => _switchPlan(plan),
                onRename: () => _editPlanInfo(plan),
                onExport: () => _openImportExport(plan),
                onDelete: () => _deletePlan(plan),
              );
            },
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemCount: plans.length + 1,
          );
        },
      ),
    );
  }
}

class _PlanInfoFormResult {
  const _PlanInfoFormResult({required this.name, required this.area});

  final String name;
  final String area;
}

class _CreatePlanButton extends StatelessWidget {
  const _CreatePlanButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.add, size: 18),
      label: Text(AppLocalizations.of(context)!.btnNewPlan),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.selected,
    required this.canDelete,
    required this.onSwitch,
    required this.onRename,
    required this.onExport,
    required this.onDelete,
  });

  final PilgrimagePlan plan;
  final bool selected;
  final bool canDelete;
  final VoidCallback onSwitch;
  final VoidCallback onRename;
  final VoidCallback onExport;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final statusText = selected ? AppLocalizations.of(context)!.statusTextCurrentPlan : AppLocalizations.of(context)!.statusTextSwitchable;
    final statusColor = selected ? AppColors.accent : AppColors.textSecondary;
    final summaryText =
        AppLocalizations.of(context)!.planHeaderStats(plan.area, plan.points.length, _workCountText(context, plan));

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: selected ? AppColors.accent : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 42),
                child: CopyableText(
                  text: plan.name,
                  copyLabel: AppLocalizations.of(context)!.labelPlanName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.25,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: -5,
                child: _CompactPlanButton(
                  tooltip: AppLocalizations.of(context)!.planImportExport,
                  onPressed: onExport,
                  icon: const Icon(Icons.import_export_outlined, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          CopyableText(
            text: summaryText,
            copyText:
                AppLocalizations.of(context)!.planInfoCopyContent(plan.name, plan.area, plan.points.length, _workCountText(context, plan)),
            copyLabel: AppLocalizations.of(context)!.labelPlanInfo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 32,
            child: Row(
              children: [
                Icon(
                  selected ? Icons.check_circle : Icons.route_outlined,
                  color: statusColor,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
                const Spacer(),
                if (!selected)
                  TextButton(
                    style: TextButton.styleFrom(
                      minimumSize: const Size(44, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: onSwitch,
                    child: Text(AppLocalizations.of(context)!.btnSwitch),
                  ),
                _CompactPlanButton(
                  tooltip: AppLocalizations.of(context)!.dialogEditPlanTitle,
                  onPressed: onRename,
                  icon: const Icon(Icons.edit_outlined, size: 22),
                ),
                if (canDelete)
                  _CompactPlanButton(
                    tooltip: AppLocalizations.of(context)!.dialogDeletePlanTitle,
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, size: 22),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _workCountText(BuildContext context, PilgrimagePlan plan) {
    final count = plan.works.isNotEmpty
        ? plan.works.length
        : plan.points.map((point) => point.work.id).toSet().length;
    return AppLocalizations.of(context)!.planWorksCount(count);
  }
}

class _CompactPlanButton extends StatelessWidget {
  const _CompactPlanButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final Widget icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints.tightFor(width: 36, height: 32),
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      icon: icon,
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: OutlinedButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh),
        label: Text(AppLocalizations.of(context)!.btnReloadPlan),
      ),
    );
  }
}
