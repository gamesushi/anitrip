import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../data/pilgrimage_repository.dart';
import 'plan_import_asset_restore.dart';
import 'plan_import_package.dart';
import '../l10n/app_localizations.dart';

class PlanImportPreviewScreen extends StatefulWidget {
  const PlanImportPreviewScreen({
    required this.importPackage,
    required this.repository,
    super.key,
  });

  final PlanImportPackage importPackage;
  final PilgrimageRepository repository;

  @override
  State<PlanImportPreviewScreen> createState() =>
      _PlanImportPreviewScreenState();
}

class _PlanImportPreviewScreenState extends State<PlanImportPreviewScreen> {
  late var _includeRecords = widget.importPackage.hasVisitRecords;
  late var _includeAssets =
      widget.importPackage.hasRestorableAssets &&
      supportsPlanImportAssetRestore;
  var _importing = false;

  PlanImportPackage get _package => widget.importPackage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.importContent)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _PackageHeader(importPackage: _package),
          const SizedBox(height: 16),
          _StatsGrid(importPackage: _package),
          const SizedBox(height: 18),
          _SectionTitle(
            icon: Icons.fact_check_outlined,
            title: l10n.selectImportContent,
            subtitle: l10n.importingWillNotModifyCurrentData,
          ),
          const SizedBox(height: 10),
          _ImportOptionTile(
            icon: Icons.route_outlined,
            title: l10n.planStructure,
            subtitle: l10n.worksAreasPointsCompletionStatusAndCurrentGoals,
            value: true,
            enabled: false,
            onChanged: null,
          ),
          const SizedBox(height: 8),
          _ImportOptionTile(
            icon: Icons.collections_bookmark_outlined,
            title: l10n.captureRecords,
            subtitle: _package.isLegacyJson
                ? l10n.v1FilesDoNotIncludePhotoAssetsOnlyThePlanStructureIsImported
                : _package.hasVisitRecords
                ? l10n.recordsIncludingPhotoPathsAndColorGradingParameters((_package.visitRecordCount).toString())
                : l10n.thisPackageHasNoCaptureRecords,
            value: _includeRecords,
            enabled: !_importing && _package.hasVisitRecords,
            onChanged: (value) => setState(() => _includeRecords = value),
          ),
          const SizedBox(height: 8),
          _ImportOptionTile(
            icon: Icons.photo_library_outlined,
            title: l10n.imagesAndResourceFiles,
            subtitle: _assetImportSubtitle,
            value: _includeAssets,
            enabled:
                !_importing &&
                _package.hasRestorableAssets &&
                supportsPlanImportAssetRestore,
            onChanged: (value) => setState(() => _includeAssets = value),
          ),
          if (_package.warnings.isNotEmpty) ...[
            const SizedBox(height: 18),
            _SectionTitle(
              icon: Icons.warning_amber_outlined,
              title: l10n.notesInPackage,
              subtitle: l10n.missingOrCompatibilityNotesRecordedDuringExport,
            ),
            const SizedBox(height: 10),
            for (final warning in _package.warnings.take(6))
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  warning,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    letterSpacing: 0,
                  ),
                ),
              ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: FilledButton.icon(
            onPressed: _importing ? null : _importSelected,
            icon: _importing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download_done_outlined),
            label: Text(_importing ? l10n.importing : l10n.importSelectedContent),
          ),
        ),
      ),
    );
  }

  Future<void> _importSelected() async {
    setState(() => _importing = true);
    try {
      final l10n = AppLocalizations.of(context)!;
      final restoredPaths = _includeAssets
          ? await restorePlanImportAssets(_package)
          : const <String, String>{};
      final restored = applyRestoredAssetPaths(
        importPackage: _package,
        restoredPaths: restoredPaths,
        includeRecords: _includeRecords,
      );
      final importedPlan = await widget.repository.importPlanPackage(
        plan: restored.plan,
        visitRecords: restored.visitRecords,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            restored.warnings.isEmpty
                ? l10n.importedPlan2((importedPlan.name).toString())
                : l10n.importedPlanButSomeAssetsWereNotRestored2((importedPlan.name).toString()),
          ),
        ),
      );
      Navigator.of(context).pop(true);
    } catch (_) {
      final l10n = AppLocalizations.of(context)!;
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.importFailed)));
    } finally {
      if (mounted) {
        setState(() => _importing = false);
      }
    }
  }

  String get _assetImportSubtitle {
    final l10n = AppLocalizations.of(context)!;
    if (!_package.hasAssets) {
      return l10n.thisPackageHasNoRecoverableAssetFiles;
    }
    if (!_package.hasRestorableAssets) {
      return l10n.thePackageRecordedAssetsButThereAreNoRecoverableAssetFiles;
    }
    if (!supportsPlanImportAssetRestore) {
      return l10n.packageAssetsNoPlatformRestore((_package.totalAssetCount).toString());
    }
    return l10n.packageAssetsRestoreLocal((_package.totalAssetCount).toString());
  }
}

class _PackageHeader extends StatelessWidget {
  const _PackageHeader({required this.importPackage});

  final PlanImportPackage importPackage;

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
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              color: AppColors.accentDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  importPackage.package.plan.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${importPackage.versionLabel} / ${importPackage.sourceName}',
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
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.importPackage});

  final PlanImportPackage importPackage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final exportedAt = importPackage.exportedAt;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _StatChip(label: l10n.profileWorks, value: '${importPackage.workCount}'),
        _StatChip(label: l10n.labelArea, value: '${importPackage.groupCount}'),
        _StatChip(label: l10n.labelPoints, value: '${importPackage.pointCount}'),
        _StatChip(label: l10n.tabRecords, value: '${importPackage.visitRecordCount}'),
        _StatChip(label: l10n.assets, value: '${importPackage.totalAssetCount}'),
        if (importPackage.appVersion != null)
          _StatChip(label: l10n.version, value: importPackage.appVersion!),
        if (exportedAt != null)
          _StatChip(
            label: l10n.comparisonExport,
            value:
                '${exportedAt.year}-${exportedAt.month.toString().padLeft(2, '0')}-${exportedAt.day.toString().padLeft(2, '0')}',
          ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label $value',
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 12,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.accentDark, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
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
    );
  }
}

class _ImportOptionTile extends StatelessWidget {
  const _ImportOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: enabled ? AppColors.surface : AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: enabled ? AppColors.accentDark : AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          Checkbox(
            value: value,
            onChanged: enabled
                ? (checked) {
                    if (checked != null) {
                      onChanged?.call(checked);
                    }
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
