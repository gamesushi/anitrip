import 'dart:convert';

import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../l10n/app_localizations.dart';
import '../data/anitabi_image_source_scope.dart';
import '../color_grading/color_grading_params.dart';
import '../color_grading/color_grading_screen.dart';
import '../plan/pilgrimage_models.dart';
import '../plan/pilgrimage_plan_controller.dart';
import '../plan/reference_image_status.dart';
import '../point_detail/point_detail_sheet.dart';
import '../widgets/copyable_text.dart';
import '../widgets/anitabi_network_image.dart';
import '../widgets/image_viewer_screen.dart';
import '../widgets/reference_image_placeholder.dart';
import '../widgets/reference_image_source_stub.dart'
    if (dart.library.io) '../widgets/reference_image_source_io.dart';
import 'comparison_export_config.dart';
import 'comparison_export_sheet.dart';
import 'point_visit_records_screen.dart';
import 'visit_record_file_ops_stub.dart'
    if (dart.library.io) 'visit_record_file_ops_io.dart';
import 'visit_record_photo_stub.dart'
    if (dart.library.io) 'visit_record_photo_io.dart';

class VisitRecordDetailScreen extends StatefulWidget {
  const VisitRecordDetailScreen({
    required this.record,
    required this.point,
    required this.controller,
    required this.settings,
    required this.onDelete,
    super.key,
  });

  final PilgrimageVisitRecord record;
  final PilgrimagePoint? point;
  final PilgrimagePlanController controller;
  final AppSettings settings;
  final Future<void> Function() onDelete;

  @override
  State<VisitRecordDetailScreen> createState() =>
      _VisitRecordDetailScreenState();
}

class _VisitRecordDetailScreenState extends State<VisitRecordDetailScreen> {
  late PilgrimageVisitRecord _record = widget.record;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final resolvedPoint = widget.point;
    final referenceImagePath = _resolvedReferenceImagePath(resolvedPoint);
    final referenceImageUrl = _resolvedReferenceImageUrl(resolvedPoint);
    final group = _groupFor(resolvedPoint);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.recordDetailTitle),
        actions: [
          IconButton(
            tooltip: l10n.recordDetailAutoGrading,
            onPressed: () => _openColorGrading(context),
            icon: const Icon(Icons.auto_fix_high_outlined),
          ),
          IconButton(
            tooltip: l10n.comparisonExportTitle,
            onPressed: () => _exportComparison(context, resolvedPoint),
            icon: const Icon(Icons.ios_share_outlined),
          ),
          IconButton(
            tooltip: l10n.recordDetailDelete,
            onPressed: () => _confirmDelete(context),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _RecordComparisonPanel(
            record: _record,
            referenceImagePath: referenceImagePath,
            referenceImageUrl: referenceImageUrl,
          ),
          const SizedBox(height: 16),
          Text(
            resolvedPoint?.name ?? _record.displayPointNameSnapshot,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            resolvedPoint == null
                ? _recordSnapshotSubtitle(_record)
                : '${resolvedPoint.work.title} / ${resolvedPoint.subtitle}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 16),
          if (resolvedPoint == null) ...[
            const _OrphanRecordNotice(),
            const SizedBox(height: 12),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showPointDetail(resolvedPoint),
                icon: const Icon(Icons.place_outlined, size: 18),
                label: Text(l10n.recordDetailViewPoint),
              ),
            ),
            const SizedBox(height: 12),
          ],
          _DetailSection(
            children: [
              _DetailRow(
                icon: Icons.schedule,
                  label: l10n.comparisonMetaCapturedAt,
                value: _formatDateTime(_record.capturedAt),
              ),
              if (resolvedPoint != null) ...[
                _DetailRow(
                  icon: Icons.grid_view_outlined,
                  label: l10n.labelArea,
                  value: _groupName(resolvedPoint, group, l10n),
                ),
                _DetailRow(
                  icon: Icons.local_movies_outlined,
                  label: l10n.comparisonMetaEpisode,
                  value: resolvedPoint.displayEpisodeLabel,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showPointDetail(PilgrimagePoint point) {
    PointDetailSheet.show(
      context,
      point: point,
      status: widget.controller.statusFor(point),
      onSetCurrent: () => widget.controller.setCurrentPoint(point),
      onOpenCamera: null,
      onComplete: () =>
          widget.controller.statusFor(point) == VisitStatus.completed
          ? widget.controller.reopenPoint(point)
          : widget.controller.completePoint(point),
      onReplaceReference: (point, image) => widget.controller.updatePoint(
        point.copyWith(
          referenceImageUrl: null,
          referenceThumbnailPath: image.thumbnailPath,
          referenceFullImagePath: image.fullImagePath,
        ),
      ),
      actionScope: PointDetailActionScope.manage,
      groups: widget.controller.plan.groups,
      onMoveToGroup: widget.controller.movePointToGroup,
      records: widget.controller.recordsForPoint(point.id),
      onOpenRecords: () => _openPointRecords(point),
      onOpenRecord: _openRelatedRecord,
      navigationApp: widget.settings.navigationApp,
    );
  }

  void _openPointRecords(PilgrimagePoint point) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PointVisitRecordsScreen(
          point: point,
          controller: widget.controller,
          settings: widget.settings,
        ),
      ),
    );
  }

  void _openRelatedRecord(PilgrimageVisitRecord record) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VisitRecordDetailScreen(
          record: record,
          point: widget.controller.pointById(record.pointId),
          controller: widget.controller,
          settings: widget.settings,
          onDelete: () => widget.controller.deleteVisitRecord(record),
        ),
      ),
    );
  }

  Future<void> _openColorGrading(BuildContext context) async {
    final resolvedPoint = widget.point;
    final updated = await Navigator.of(context).push<PilgrimageVisitRecord>(
      MaterialPageRoute<PilgrimageVisitRecord>(
        builder: (_) => ColorGradingScreen(
          record: _record,
          controller: widget.controller,
          fallbackReferenceImagePath: _resolvedReferenceImagePath(
            resolvedPoint,
          ),
          fallbackReferenceImageUrl: _resolvedReferenceImageUrl(resolvedPoint),
        ),
      ),
    );
    if (updated == null || !mounted) {
      return;
    }
    setState(() => _record = updated);
  }

  Future<void> _confirmDelete(BuildContext context) async {
    var deleteFiles = false;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.recordDetailDelete),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.recordDetailDeleteConfirmBody),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Checkbox(
                        value: deleteFiles,
                        onChanged: (v) =>
                            setState(() => deleteFiles = v ?? false),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                      Text(l10n.recordDetailDeletePhotoFile),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(l10n.btnCancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(l10n.btnDelete),
                ),
              ],
            );
          },
        );
      },
    );
    if (shouldDelete != true || !context.mounted) {
      return;
    }

    if (deleteFiles) {
      for (final path in {
        _record.photoPath,
        _record.originalPhotoPath,
        _record.gradedPhotoPath,
      }.whereType<String>()) {
        deleteVisitRecordLocalFile(path);
      }
      final refPath = _record.referenceImagePath;
      if (refPath != null) {
        deleteVisitRecordLocalFile(refPath);
      }
    }

    await widget.onDelete();
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).pop();
  }

  void _exportComparison(BuildContext context, PilgrimagePoint? resolvedPoint) {
    final l10n = AppLocalizations.of(context)!;
    final capturedPath = resolveVisitRecordDisplayPhotoPath(_record);
    if (capturedPath == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.comparisonErrCapturedUnavailable)));
      return;
    }

    final meta = <ComparisonMetadataField, String>{
      ComparisonMetadataField.capturedAt: _formatDateTime(_record.capturedAt),
    };

    if (resolvedPoint != null) {
      meta[ComparisonMetadataField.pointName] = resolvedPoint.name;
      meta[ComparisonMetadataField.workTitle] = resolvedPoint.work.title;
      meta[ComparisonMetadataField.episodeLabel] =
          resolvedPoint.displayEpisodeLabel;
      meta[ComparisonMetadataField.coordinates] =
          '${resolvedPoint.position.latitude.toStringAsFixed(5)}, '
          '${resolvedPoint.position.longitude.toStringAsFixed(5)}';
      if (resolvedPoint.sourceId != null) {
        meta[ComparisonMetadataField.anitabiId] = resolvedPoint.sourceId!;
      }
    } else {
      meta[ComparisonMetadataField.pointName] =
          _record.displayPointNameSnapshot;
      meta[ComparisonMetadataField.workTitle] =
          _record.displayWorkTitleSnapshot;
    }

    final repository = widget.controller.repository;
    if (repository == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.recordDetailExportPrefUnsupported)));
      return;
    }

    ComparisonExportSheet.show(
      context,
      referenceImagePath: _resolvedReferenceImagePath(resolvedPoint),
      referenceImageUrl: _resolvedReferenceImageUrl(resolvedPoint),
      capturedPath: capturedPath,
      metadata: meta,
      colorGradingSummary: _colorGradingSummary(l10n),
      repository: repository,
    );
  }

  String? _resolvedReferenceImagePath(PilgrimagePoint? resolvedPoint) {
    for (final path in [
      _record.referenceImagePath,
      resolvedPoint?.referenceFullImagePath,
    ].whereType<String>()) {
      if (visitRecordLocalFileExists(path)) {
        return path;
      }
    }
    return null;
  }

  String? _resolvedReferenceImageUrl(PilgrimagePoint? resolvedPoint) {
    if (_record.referenceImageUrl != null) {
      return _record.referenceImageUrl;
    }
    if (resolvedPoint == null || !hasRemoteReferenceImage(resolvedPoint)) {
      return null;
    }
    return resolvedPoint.referenceImageUrl;
  }

  PilgrimagePlanGroup? _groupFor(PilgrimagePoint? point) {
    final groupId = point?.groupId;
    if (groupId == null) {
      return null;
    }
    return widget.controller.plan.groups
        .where((group) => group.id == groupId)
        .firstOrNull;
  }

  String _groupName(
    PilgrimagePoint point,
    PilgrimagePlanGroup? group,
    AppLocalizations l10n,
  ) {
    if (point.groupId == null) {
      return l10n.labelUngrouped;
    }
    return group?.name ?? l10n.labelUnknownGroup;
  }

  String? _colorGradingSummary(AppLocalizations l10n) {
    final paramsJson = _record.colorGradingParamsJson;
    if (paramsJson == null || paramsJson.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(paramsJson);
      if (decoded is! Map) {
        return null;
      }
      final targetParams = ColorGradingParams.fromJson(
        Map<String, Object?>.from(decoded),
      );
      final intensity = (_record.colorGradingIntensity ?? 1).clamp(0.0, 1.0);
      final params = ColorGradingParams.lerp(
        ColorGradingParams.defaults,
        targetParams,
        intensity,
      );
      const threshold = 0.005;
      final defaults = ColorGradingParams.defaults;
      final parts = <String>[];

      String signed(double value) =>
          '${value >= 0 ? '+' : ''}${value.toStringAsFixed(2)}';
      bool changed(double value, double fallback) =>
          (value - fallback).abs() >= threshold;
      void addZeroBased(String label, double value, double fallback) {
        if (changed(value, fallback)) {
          parts.add('$label ${signed(value)}');
        }
      }

      addZeroBased(l10n.gradingBrightness, params.brightness, defaults.brightness);
      addZeroBased(l10n.gradingExposure, params.exposure, defaults.exposure);
      addZeroBased(l10n.gradingContrast, params.contrast, defaults.contrast);
      addZeroBased(l10n.gradingSaturation, params.saturation, defaults.saturation);
      addZeroBased(l10n.gradingTemperature, params.temperature, defaults.temperature);
      addZeroBased(l10n.gradingTint, params.tint, defaults.tint);
      addZeroBased(l10n.gradingHighlights, params.highlights, defaults.highlights);
      addZeroBased(l10n.gradingShadows, params.shadows, defaults.shadows);
      addZeroBased(l10n.gradingRedShadow, params.redShadowCurve, defaults.redShadowCurve);
      addZeroBased(l10n.gradingRedMid, params.redMidCurve, defaults.redMidCurve);
      addZeroBased(l10n.gradingRedHighlight, params.redHighlightCurve, defaults.redHighlightCurve);
      addZeroBased(l10n.gradingGreenShadow, params.greenShadowCurve, defaults.greenShadowCurve);
      addZeroBased(l10n.gradingGreenMid, params.greenMidCurve, defaults.greenMidCurve);
      addZeroBased(
        l10n.gradingGreenHighlight,
        params.greenHighlightCurve,
        defaults.greenHighlightCurve,
      );
      addZeroBased(l10n.gradingBlueShadow, params.blueShadowCurve, defaults.blueShadowCurve);
      addZeroBased(l10n.gradingBlueMid, params.blueMidCurve, defaults.blueMidCurve);
      addZeroBased(
        l10n.gradingBlueHighlight,
        params.blueHighlightCurve,
        defaults.blueHighlightCurve,
      );

      if (parts.isEmpty) {
        return null;
      }
      return parts.join('  ');
    } catch (_) {
      return null;
    }
  }
}

class _RecordComparisonPanel extends StatelessWidget {
  const _RecordComparisonPanel({
    required this.record,
    required this.referenceImagePath,
    required this.referenceImageUrl,
  });

  final PilgrimageVisitRecord record;
  final String? referenceImagePath;
  final String? referenceImageUrl;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final photoPath = resolveVisitRecordDisplayPhotoPath(record);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _RecordImageTile(
          label: l10n.labelReference,
          child: _RecordReferencePhoto(
            path: referenceImagePath,
            url: referenceImageUrl,
          ),
          onTap: () => ImageViewerScreen.show(
            context,
            filePath: referenceImagePath,
            imageUrl: referenceImageUrl,
          ),
        ),
        const SizedBox(height: 12),
        _RecordImageTile(
          label: l10n.recordDetailCapturedPhoto,
          child: VisitRecordPhoto(path: photoPath, fit: BoxFit.contain),
          onTap: () => ImageViewerScreen.show(context, filePath: photoPath),
        ),
      ],
    );
  }
}

class _RecordImageTile extends StatelessWidget {
  const _RecordImageTile({
    required this.label,
    required this.child,
    this.onTap,
  });

  final String label;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              child: child,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _RecordReferencePhoto extends StatelessWidget {
  const _RecordReferencePhoto({required this.path, required this.url});

  final String? path;
  final String? url;

  @override
  Widget build(BuildContext context) {
    final localPath = path;
    if (referenceImageLocalPathCanDisplay(localPath)) {
      return VisitRecordPhoto(path: localPath!, fit: BoxFit.contain);
    }

    final imageUrl = url;
    if (imageUrl != null) {
      return AnitabiNetworkImage(
        url: imageUrl,
        imageSource: AnitabiImageSourceScope.of(context),
        fit: BoxFit.contain,
        loadingBuilder: (_) {
          return const _RecordReferencePlaceholder(
            state: ReferenceImagePlaceholderState.loading,
          );
        },
        errorBuilder: (_) {
          return const _RecordReferencePlaceholder();
        },
      );
    }

    return const _RecordReferencePlaceholder();
  }
}

class _RecordReferencePlaceholder extends StatelessWidget {
  const _RecordReferencePlaceholder({
    this.state = ReferenceImagePlaceholderState.unavailable,
  });

  final ReferenceImagePlaceholderState state;

  @override
  Widget build(BuildContext context) {
    return ReferenceImagePlaceholder(state: state);
  }
}

class _OrphanRecordNotice extends StatelessWidget {
  const _OrphanRecordNotice();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(Icons.link_off_outlined, color: AppColors.warning, size: 19),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.recordDetailPointMissing,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (var index = 0; index < children.length; index += 1) ...[
            if (index > 0) const Divider(height: 18),
            children[index],
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 19),
        const SizedBox(width: 8),
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: CopyableText(
            text: value,
            copyLabel: label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}

String _formatDateTime(DateTime value) {
  final year = value.year.toString();
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$year-$month-$day $hour:$minute';
}

String _recordSnapshotSubtitle(PilgrimageVisitRecord record) {
  final workTitle = record.displayWorkTitleSnapshot;
  final pointSubtitle = record.displayPointSubtitleSnapshot;
  if (pointSubtitle.isEmpty) {
    return workTitle;
  }
  return '$workTitle / $pointSubtitle';
}
