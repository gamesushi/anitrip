import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart' as file_selector;

import '../app_theme.dart';
import '../l10n/app_localizations.dart';
import '../data/pilgrimage_repository.dart';
import '../platform/platform_flags_stub.dart'
    if (dart.library.io) '../platform/platform_flags_io.dart';
import '../plan/pilgrimage_models.dart';
import '../widgets/snackbar_helper.dart';
import 'my_maps_csv_export.dart';
import 'plan_export_delivery.dart';
import 'plan_export_delivery_result.dart';
import 'plan_export_size_estimator.dart';
import 'plan_export_v2.dart';
import 'plan_import_package.dart';
import 'plan_import_preview_screen.dart';
import 'plan_package.dart' show seichiPlanFileExtension, seichiPlanMimeType;

class ImportExportScreen extends StatefulWidget {
  const ImportExportScreen({
    required this.plan,
    required this.repository,
    super.key,
  });

  final PilgrimagePlan plan;
  final PilgrimageRepository repository;

  @override
  State<ImportExportScreen> createState() => _ImportExportScreenState();
}

class _ImportExportScreenState extends State<ImportExportScreen> {
  var _mode = PlanExportV2Mode.planOnly;
  var _includeFullReferenceCache = false;
  var _exporting = false;
  var _importing = false;
  var _exportGeneration = 0;
  var _estimateGeneration = 0;
  PlanExportSizeEstimate? _sizeEstimate;
  var _estimatingSize = false;

  bool get _usesExternalIosImport => isIosPlatform;

  @override
  void initState() {
    super.initState();
    _refreshSizeEstimate();
  }

  @override
  void dispose() {
    _exportGeneration++;
    _estimateGeneration++;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_exporting,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          return;
        }
        _handleBack();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: AppLocalizations.of(context)!.tooltipBack,
            onPressed: _handleBack,
            icon: const Icon(Icons.arrow_back),
          ),
          title: Text(AppLocalizations.of(context)!.planImportExport),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _PlanExportSummary(plan: widget.plan),
            const SizedBox(height: 16),
            _SectionTitle(
              icon: Icons.import_export_outlined,
              title: AppLocalizations.of(context)!.importExportImportSection,
              subtitle: _usesExternalIosImport
                  ? AppLocalizations.of(context)!.importExportImportDescMobile
                  : AppLocalizations.of(context)!.importExportImportDescWeb,
            ),
            const SizedBox(height: 10),
            _ActionTile(
              icon: _importing
                  ? Icons.hourglass_empty_outlined
                  : _usesExternalIosImport
                  ? Icons.open_in_new_outlined
                  : Icons.import_export_outlined,
              title: _importing
                  ? AppLocalizations.of(context)!.importExportStatusReading
                  : _usesExternalIosImport
                  ? AppLocalizations.of(context)!.importExportOpenFromApp
                  : AppLocalizations.of(context)!.importExportImportFileTitle,
              subtitle: _usesExternalIosImport
                  ? AppLocalizations.of(context)!.importExportOpenFromAppDesc
                  : AppLocalizations.of(context)!.importExportImportFileDesc,
              enabled: !_exporting && !_importing,
              onTap: _usesExternalIosImport
                  ? _showExternalIosImportHelp
                  : _importFromFile,
            ),
            const SizedBox(height: 20),
            _SectionTitle(
              icon: Icons.inventory_2_outlined,
              title: AppLocalizations.of(context)!.importExportDataPackageHeader,
              subtitle: AppLocalizations.of(context)!.importExportZipDesc,
            ),
            const SizedBox(height: 10),
            _BackupOptions(
              mode: _mode,
              includeFullReferenceCache: _includeFullReferenceCache,
              sizeEstimate: _sizeEstimate,
              estimatingSize: _estimatingSize,
              exporting: _exporting || _importing,
              onModeChanged: (mode) {
                setState(() => _mode = mode);
                _refreshSizeEstimate();
              },
              onFullReferenceChanged: (value) {
                setState(() => _includeFullReferenceCache = value);
                _refreshSizeEstimate();
              },
              onExport: _exportV2,
            ),
            const SizedBox(height: 20),
            _SectionTitle(
              icon: Icons.map_outlined,
              title: 'Google My Maps',
              subtitle: AppLocalizations.of(context)!.importExportMyMapsDesc,
            ),
            const SizedBox(height: 10),
            _ActionTile(
              icon: _exporting
                  ? Icons.hourglass_empty_outlined
                  : Icons.table_chart_outlined,
              title: AppLocalizations.of(context)!.importExportMyMapsTitle,
              subtitle: AppLocalizations.of(context)!.importExportMyMapsDetails,
              enabled: !_exporting && !_importing,
              onTap: _exportMyMapsCsv,
            ),
          ],
        ),
      ),
    );
  }

  void _handleBack() {
    final messenger = ScaffoldMessenger.of(context);
    if (_exporting) {
      _exportGeneration++;
      setState(() => _exporting = false);
      messenger.showReplacingSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.msgExportCancelled)));
    }
    Navigator.of(context).pop();
  }

  Future<void> _importFromFile() async {
    if (_usesExternalIosImport) {
      _showExternalIosImportHelp();
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _importing = true);
    try {
      final file = await file_selector.openFile(
        acceptedTypeGroups: const [
          file_selector.XTypeGroup(
            label: 'anitrip plan package',
            extensions: [seichiPlanFileExtension],
            mimeTypes: [
              anitripExportPackageMimeType,
              'application/zip',
              'application/x-zip-compressed',
              seichiPlanMimeType,
              'application/octet-stream',
              'application/json',
              'text/json',
              'text/plain',
            ],
          ),
        ],
      );
      if (file == null) {
        return;
      }
      final importPackage = readPlanImportPackageFromBytes(
        await file.readAsBytes(),
        sourceName: file.name,
      );
      if (!mounted) {
        return;
      }
      final imported = await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) => PlanImportPreviewScreen(
            importPackage: importPackage,
            repository: widget.repository,
          ),
        ),
      );
      if (imported == true && mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      messenger.showReplacingSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.msgImportReadFailed)),
      );
    } finally {
      if (mounted) {
        setState(() => _importing = false);
      }
    }
  }

  Future<void> _showExternalIosImportHelp() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.dialogOpenFromAppTitle),
        content: Text(
          AppLocalizations.of(context)!.dialogOpenFromAppMessage,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.btnGotIt),
          ),
        ],
      ),
    );
  }

  Future<void> _exportV2() async {
    await _runExport((generation) async {
      final exportedAt = DateTime.now();
      final options = PlanExportV2Options(
        mode: _mode,
        includeFullReferenceCache: _includeFullReferenceCache,
      );
      final records = await widget.repository.loadVisitRecords(widget.plan.id);
      if (!_isCurrentExport(generation)) {
        throw const _ExportAbortedException();
      }
      final shouldContinue = await _confirmExportResourceRisks(
        records: records,
        options: options,
      );
      if (!_isCurrentExport(generation)) {
        throw const _ExportAbortedException();
      }
      if (!shouldContinue) {
        throw const PlanExportCanceledException();
      }
      final fileName = suggestPlanExportV2FileName(
        plan: widget.plan,
        exportedAt: exportedAt,
      );
      final destination = await preparePlanExportDestination(
        fileName: fileName,
        mimeType: anitripExportPackageMimeType,
        extension: seichiPlanFileExtension,
      );
      if (!_isCurrentExport(generation)) {
        throw const _ExportAbortedException();
      }
      final package = await buildPlanExportV2Package(
        plan: widget.plan,
        visitRecords: records,
        options: options,
        exportedAt: exportedAt,
      );
      if (!_isCurrentExport(generation)) {
        throw const _ExportAbortedException();
      }
      final result = await deliverPlanExport(
        bytes: package.bytes,
        fileName: package.fileName,
        mimeType: anitripExportPackageMimeType,
        shareSubject: widget.plan.name,
        shareText: AppLocalizations.of(context)!.exportShareLabel(widget.plan.name),
        extension: seichiPlanFileExtension,
        destination: destination,
      );
      return _PlanExportRunResult(
        result,
        package.warnings,
        package.warningCounts,
      );
    }, successMessage: AppLocalizations.of(context)!.msgExportSuccess);
  }

  Future<bool> _confirmExportResourceRisks({
    required List<PilgrimageVisitRecord> records,
    required PlanExportV2Options options,
  }) async {
    final estimate = await estimatePlanExportV2Size(
      plan: widget.plan,
      visitRecords: records,
      options: options,
    );
    if (mounted) {
      setState(() => _sizeEstimate = estimate);
    }
    if (!estimate.hasMissingCriticalAssets || !mounted) {
      return true;
    }

    final messages = <String>[];
    if (estimate.missingUserReferenceCount > 0) {
      messages.add(AppLocalizations.of(context)!.estimateUserReferenceMissing(estimate.missingUserReferenceCount));
    }
    if (estimate.missingVisitPhotoCount > 0) {
      messages.add(AppLocalizations.of(context)!.estimateVisitPhotoMissing(estimate.missingVisitPhotoCount));
    }
    if (estimate.missingGradedPhotoCount > 0) {
      messages.add(AppLocalizations.of(context)!.estimateGradedPhotoMissing(estimate.missingGradedPhotoCount));
    }
    final shouldExport = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.dialogMissingResourcesTitle),
        content: Text([...messages, AppLocalizations.of(context)!.dialogMissingResourcesMessage].join('\n')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.btnCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context)!.btnContinueExport),
          ),
        ],
      ),
    );
    return shouldExport == true;
  }

  Future<void> _refreshSizeEstimate() async {
    final generation = ++_estimateGeneration;
    setState(() {
      _estimatingSize = true;
    });
    try {
      final records = _mode == PlanExportV2Mode.planWithRecords
          ? await widget.repository.loadVisitRecords(widget.plan.id)
          : const <PilgrimageVisitRecord>[];
      final estimate = await estimatePlanExportV2Size(
        plan: widget.plan,
        visitRecords: records,
        options: PlanExportV2Options(
          mode: _mode,
          includeFullReferenceCache: _includeFullReferenceCache,
        ),
      );
      if (!mounted || generation != _estimateGeneration) {
        return;
      }
      setState(() {
        _sizeEstimate = estimate;
        _estimatingSize = false;
      });
    } catch (_) {
      if (!mounted || generation != _estimateGeneration) {
        return;
      }
      setState(() {
        _sizeEstimate = null;
        _estimatingSize = false;
      });
    }
  }

  Future<void> _exportMyMapsCsv() async {
    await _runExport((generation) async {
      final export = buildMyMapsCsvExport(plan: widget.plan);
      if (!_isCurrentExport(generation)) {
        throw const _ExportAbortedException();
      }
      final destination = await preparePlanExportDestination(
        fileName: export.fileName,
        mimeType: export.mimeType,
        extension: myMapsCsvExtension,
      );
      if (!_isCurrentExport(generation)) {
        throw const _ExportAbortedException();
      }
      final result = await deliverPlanExport(
        bytes: export.bytes,
        fileName: export.fileName,
        mimeType: export.mimeType,
        shareSubject: widget.plan.name,
        shareText: 'anitrip My Maps CSV：${widget.plan.name}',
        extension: myMapsCsvExtension,
        destination: destination,
      );
      return _PlanExportRunResult(result);
    }, successMessage: AppLocalizations.of(context)!.msgExportMyMapsSuccess);
  }

  Future<void> _runExport(
    Future<_PlanExportRunResult> Function(int generation) action, {
    required String successMessage,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final generation = ++_exportGeneration;
    setState(() => _exporting = true);
    messenger.showReplacingSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.msgExporting)));
    try {
      final result = await action(generation);
      if (!_isCurrentExport(generation)) {
        return;
      }
      if (result.delivery.action == PlanExportDeliveryAction.canceled) {
        messenger.showReplacingSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.msgExportCancelled)));
        return;
      }
      messenger.showReplacingSnackBar(
        SnackBar(content: Text(result.successMessage(context, successMessage))),
      );
    } on PlanExportCanceledException {
      if (!_isCurrentExport(generation)) {
        return;
      }
      messenger.showReplacingSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.msgExportCancelled)));
    } on _ExportAbortedException {
      return;
    } catch (error, stackTrace) {
      debugPrint('Plan export failed: $error');
      debugPrint(stackTrace.toString());
      if (!_isCurrentExport(generation)) {
        return;
      }
      messenger.showReplacingSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.msgExportFailed)));
    } finally {
      if (_isCurrentExport(generation)) {
        setState(() => _exporting = false);
      }
    }
  }

  bool _isCurrentExport(int generation) {
    return mounted && generation == _exportGeneration;
  }
}

class _ExportAbortedException implements Exception {
  const _ExportAbortedException();
}

class _PlanExportRunResult {
  const _PlanExportRunResult(
    this.delivery, [
    this.warnings = const <String>[],
    this.warningCounts = const <String, int>{},
  ]);

  final PlanExportDeliveryResult delivery;
  final List<String> warnings;
  final Map<String, int> warningCounts;

  String successMessage(BuildContext context, String fallback) {
    if (warnings.isEmpty) {
      return fallback;
    }
    final summary = _warningSummary(context, warningCounts);
    if (summary.isEmpty) {
      return AppLocalizations.of(context)!.warningMissingPart(fallback);
    }
    return '$fallback，$summary';
  }
}

String _warningSummary(BuildContext context, Map<String, int> counts) {
  final parts = <String>[];

  void add(PlanExportWarningType type, String label) {
    final count = counts[type.key] ?? 0;
    if (count > 0) {
      parts.add(label);
    }
  }

  add(PlanExportWarningType.userReferenceMissing, AppLocalizations.of(context)!.warningUserReferenceMissing(counts[PlanExportWarningType.userReferenceMissing.key] ?? 0));
  add(PlanExportWarningType.thumbnailMissing, AppLocalizations.of(context)!.warningThumbnailMissing(counts[PlanExportWarningType.thumbnailMissing.key] ?? 0));
  add(PlanExportWarningType.fullReferenceDownloadFailed, AppLocalizations.of(context)!.warningFullReferenceDownloadFailed(counts[PlanExportWarningType.fullReferenceDownloadFailed.key] ?? 0));
  add(PlanExportWarningType.fullReferenceMissing, AppLocalizations.of(context)!.warningFullReferenceMissing(counts[PlanExportWarningType.fullReferenceMissing.key] ?? 0));
  add(PlanExportWarningType.visitPhotoMissing, AppLocalizations.of(context)!.warningVisitPhotoMissing(counts[PlanExportWarningType.visitPhotoMissing.key] ?? 0));
  add(PlanExportWarningType.gradedPhotoMissing, AppLocalizations.of(context)!.warningGradedPhotoMissing(counts[PlanExportWarningType.gradedPhotoMissing.key] ?? 0));

  return parts.isEmpty ? '' : parts.join('，');
}

class _PlanExportSummary extends StatelessWidget {
  const _PlanExportSummary({required this.plan});

  final PilgrimagePlan plan;

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
            child: Icon(Icons.archive_outlined, color: AppColors.accentDark),
          ),
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
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  AppLocalizations.of(context)!.importExportStats(plan.groups.length, plan.points.length),
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

class _BackupOptions extends StatelessWidget {
  const _BackupOptions({
    required this.mode,
    required this.includeFullReferenceCache,
    required this.sizeEstimate,
    required this.estimatingSize,
    required this.exporting,
    required this.onModeChanged,
    required this.onFullReferenceChanged,
    required this.onExport,
  });

  final PlanExportV2Mode mode;
  final bool includeFullReferenceCache;
  final PlanExportSizeEstimate? sizeEstimate;
  final bool estimatingSize;
  final bool exporting;
  final ValueChanged<PlanExportV2Mode> onModeChanged;
  final ValueChanged<bool> onFullReferenceChanged;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<PlanExportV2Mode>(
            segments: [
              ButtonSegment(
                value: PlanExportV2Mode.planOnly,
                icon: const Icon(Icons.route_outlined),
                label: Text(AppLocalizations.of(context)!.btnPlanOnly),
              ),
              ButtonSegment(
                value: PlanExportV2Mode.planWithRecords,
                icon: const Icon(Icons.collections_bookmark_outlined),
                label: Text(AppLocalizations.of(context)!.btnPlanAndRecords),
              ),
            ],
            selected: {mode},
            onSelectionChanged: exporting
                ? null
                : (values) => onModeChanged(values.first),
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              AppLocalizations.of(context)!.importExportIncludeCache,
              style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0),
            ),
            subtitle: Text(AppLocalizations.of(context)!.importExportIncludeCacheDesc),
            value: includeFullReferenceCache,
            onChanged: exporting ? null : onFullReferenceChanged,
          ),
          const SizedBox(height: 2),
          _ExportSizeEstimateRow(
            estimate: sizeEstimate,
            estimating: estimatingSize,
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: exporting ? null : onExport,
            icon: exporting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.ios_share_outlined, size: 18),
            label: Text(exporting ? AppLocalizations.of(context)!.btnExportingDataPackage : AppLocalizations.of(context)!.btnExportDataPackage),
          ),
        ],
      ),
    );
  }
}

class _ExportSizeEstimateRow extends StatelessWidget {
  const _ExportSizeEstimateRow({
    required this.estimate,
    required this.estimating,
  });

  final PlanExportSizeEstimate? estimate;
  final bool estimating;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (estimating)
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else
          Icon(
            Icons.inventory_2_outlined,
            size: 18,
            color: AppColors.textSecondary,
          ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            estimating ? AppLocalizations.of(context)!.importExportEstimateEstimating : (estimate != null ? estimate!.label(context) : AppLocalizations.of(context)!.importExportEstimateFailed),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? AppColors.surface : AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
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
                      style: TextStyle(
                        color: enabled
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
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
              Icon(
                Icons.chevron_right,
                color: enabled ? AppColors.textSecondary : AppColors.border,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
