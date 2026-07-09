import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../l10n/app_localizations.dart';
import '../data/bangumi_api_client.dart';
import '../data/pilgrimage_repository.dart';
import '../widgets/copyable_text.dart';
import '../widgets/snackbar_helper.dart';
import 'add_points_screen.dart';
import 'pilgrimage_models.dart';

class WorkManagerScreen extends StatefulWidget {
  WorkManagerScreen({
    required this.plan,
    required this.repository,
    BangumiApiClient? bangumiApiClient,
    super.key,
  }) : bangumiApiClient = bangumiApiClient ?? BangumiApiClient();

  final PilgrimagePlan plan;
  final PilgrimageRepository repository;
  final BangumiApiClient bangumiApiClient;

  @override
  State<WorkManagerScreen> createState() => _WorkManagerScreenState();
}

class _WorkManagerScreenState extends State<WorkManagerScreen> {
  late PilgrimagePlan _plan = widget.plan;
  var _didUpdate = false;
  var _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final works = _worksForPlan(_plan);

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
            tooltip: AppLocalizations.of(context)!.tooltipBack,
            onPressed: () => Navigator.of(context).pop(_didUpdate),
            icon: const Icon(Icons.arrow_back),
          ),
          title: Text(AppLocalizations.of(context)!.addPointsWorkManagerTitle),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _AddWorkPanel(
              onBangumi: _openBangumiSearch,
              onManual: _openManualWorkForm,
            ),
            const SizedBox(height: 12),
            if (works.isEmpty)
              const _EmptyWorkPanel()
            else
              for (final work in works) ...[
                _WorkManageCard(
                  work: work,
                  pointCount: _plan.points
                      .where((point) => point.work.id == work.id)
                      .length,
                  disabled: _isSaving,
                  onDelete: () => _confirmDeleteWork(work),
                ),
                const SizedBox(height: 8),
              ],
          ],
        ),
      ),
    );
  }

  Future<void> _openBangumiSearch() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => BangumiWorkSearchScreen(
          plan: _plan,
          repository: widget.repository,
          bangumiApiClient: widget.bangumiApiClient,
        ),
      ),
    );
    if (mounted) {
      await _reloadPlan();
    }
  }

  Future<void> _openManualWorkForm() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) =>
            ManualWorkFormScreen(plan: _plan, repository: widget.repository),
      ),
    );
    if (mounted) {
      await _reloadPlan();
    }
  }

  Future<void> _confirmDeleteWork(PilgrimageWork work) async {
    final pointCount = _plan.points
        .where((point) => point.work.id == work.id)
        .length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.dialogDeleteWorkTitle),
        content: Text(
          pointCount == 0
              ? AppLocalizations.of(context)!.dialogDeleteWorkConfirmSingle(work.title)
              : AppLocalizations.of(context)!.dialogDeleteWorkConfirmMultiple(work.title, pointCount),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.btnCancel),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.delete_outline, size: 18),
            label: Text(AppLocalizations.of(context)!.btnDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      final updatedPlan = await widget.repository.deleteWorkFromPlan(
        planId: _plan.id,
        workId: work.id,
      );
      if (!mounted) {
        return;
      }

      setState(() {
        _plan = updatedPlan;
        _didUpdate = true;
        _isSaving = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() => _isSaving = false);
      ScaffoldMessenger.of(
        context,
      ).showReplacingSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.msgDeleteWorkFailed)));
    }
  }

  Future<void> _reloadPlan() async {
    final plans = await widget.repository.loadPlans();
    final updatedPlan = plans.firstWhere((plan) => plan.id == _plan.id);
    if (!mounted) {
      return;
    }

    setState(() {
      _plan = updatedPlan;
      _didUpdate = true;
    });
  }

  List<PilgrimageWork> _worksForPlan(PilgrimagePlan plan) {
    final worksById = <String, PilgrimageWork>{};
    for (final work in plan.works) {
      worksById[work.id] = work;
    }
    for (final point in plan.points) {
      worksById[point.work.id] = point.work;
    }

    return worksById.values.toList(growable: false);
  }
}

class _AddWorkPanel extends StatelessWidget {
  const _AddWorkPanel({required this.onBangumi, required this.onManual});

  final VoidCallback onBangumi;
  final VoidCallback onManual;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: onBangumi,
              icon: const Icon(Icons.search, size: 18),
              label: Text(AppLocalizations.of(context)!.btnBangumiSearch),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onManual,
              icon: const Icon(Icons.edit_note, size: 18),
              label: Text(AppLocalizations.of(context)!.btnManualAdd),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkManageCard extends StatelessWidget {
  const _WorkManageCard({
    required this.work,
    required this.pointCount,
    required this.disabled,
    required this.onDelete,
  });

  final PilgrimageWork work;
  final int pointCount;
  final bool disabled;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final sourceText = work.bangumiId == null
        ? AppLocalizations.of(context)!.btnManualAdd
        : AppLocalizations.of(context)!.labelBangumiSource(work.bangumiId!);
    final typeText = work.displayBangumiSubjectType?.getName(context);
    final pointsCountText = AppLocalizations.of(context)!.labelPointsCount(pointCount);
    final infoText = [
      work.subtitle,
      typeText,
      sourceText,
      pointsCountText,
    ].whereType<String>().where((value) => value.trim().isNotEmpty).join(' / ');

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(Icons.movie_filter_outlined, color: AppColors.accentDark),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CopyableText(
                  text: work.title,
                  copyLabel: AppLocalizations.of(context)!.labelWorkTitleText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 3),
                CopyableText(
                  text: infoText,
                  copyText: [
                    work.title,
                    work.subtitle,
                    typeText,
                    sourceText,
                    pointsCountText,
                  ].whereType<String>().where((value) => value.trim().isNotEmpty).join('\n'),
                  copyLabel: AppLocalizations.of(context)!.labelWorkInfoText,
                  maxLines: 1,
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
          IconButton(
            tooltip: AppLocalizations.of(context)!.tooltipDeleteWork,
            onPressed: disabled ? null : onDelete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}

class _EmptyWorkPanel extends StatelessWidget {
  const _EmptyWorkPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        AppLocalizations.of(context)!.workManagerEmptyHelp,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
