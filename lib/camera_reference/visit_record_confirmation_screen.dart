import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../l10n/app_localizations.dart';
import '../data/anitabi_image_source_scope.dart';
import '../widgets/snackbar_helper.dart';
import '../records/gallery_saver_stub.dart'
    if (dart.library.io) '../records/gallery_saver_io.dart';
import '../plan/pilgrimage_models.dart';
import '../plan/pilgrimage_plan_controller.dart';
import '../records/visit_record_photo_stub.dart'
    if (dart.library.io) '../records/visit_record_photo_io.dart';
import '../widgets/image_viewer_screen.dart';
import '../widgets/anitabi_network_image.dart';
import '../widgets/reference_image_placeholder.dart';
import '../widgets/reference_image_source_stub.dart'
    if (dart.library.io) '../widgets/reference_image_source_io.dart';
import '../widgets/reference_thumbnail_stub.dart'
    if (dart.library.io) '../widgets/reference_thumbnail_io.dart';
import 'auto_comparison_gallery_backup.dart';
import 'camera_storage_stub.dart'
    if (dart.library.io) 'camera_storage_io.dart'
    as camera_storage;

class VisitRecordConfirmationScreen extends StatefulWidget {
  const VisitRecordConfirmationScreen({
    required this.point,
    required this.controller,
    required this.photoPath,
    required this.referenceMode,
    this.referenceBytes,
    this.referenceImagePath,
    this.referenceImageUrl,
    this.capturedAtOverride,
    this.settings = const AppSettings(),
    this.saveVisitPhotoToGallery = false,
    this.autoSaveComparisonToGallery = false,
    super.key,
  });

  final PilgrimagePoint point;
  final PilgrimagePlanController? controller;
  final String photoPath;
  final String referenceMode;
  final Uint8List? referenceBytes;
  final String? referenceImagePath;
  final String? referenceImageUrl;
  final DateTime? capturedAtOverride;
  final AppSettings settings;
  final bool saveVisitPhotoToGallery;
  final bool autoSaveComparisonToGallery;

  @override
  State<VisitRecordConfirmationScreen> createState() =>
      _VisitRecordConfirmationScreenState();
}

class _VisitRecordConfirmationScreenState
    extends State<VisitRecordConfirmationScreen> {
  bool _saving = false;
  String? _savingStage;

  Future<void> _save({required bool completePoint}) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = widget.controller;
    if (controller == null || _saving) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _saving = true;
      _savingStage = l10n.savingRecordStage;
    });

    String? referenceImagePath;
    final referenceBytes = widget.referenceBytes;
    if (referenceBytes != null) {
      referenceImagePath = await camera_storage.saveRecordImageBytes(
        bytes: referenceBytes,
        prefix: 'reference',
      );
    }
    final fallbackReferencePath =
        referenceImageLocalPathCanDisplay(widget.referenceImagePath)
        ? widget.referenceImagePath
        : null;

    final record = await controller.createVisitRecord(
      point: widget.point,
      photoPath: widget.photoPath,
      referenceImagePath: referenceImagePath ?? fallbackReferencePath,
      referenceImageUrl:
          referenceImagePath == null && fallbackReferencePath == null
          ? widget.referenceImageUrl
          : null,
      referenceMode: widget.referenceMode,
      capturedAt: widget.capturedAtOverride,
    );

    var attemptedGalleryBackup = false;
    var galleryBackupSucceeded = false;
    if (widget.saveVisitPhotoToGallery) {
      if (mounted) {
        setState(() => _savingStage = l10n.backingUpPilgrimagePhotoStage);
      }
      attemptedGalleryBackup = true;
      galleryBackupSucceeded = await saveImageToGallery(widget.photoPath);
    }

    AutoComparisonGalleryResult? comparisonBackupResult;
    if (record != null && widget.autoSaveComparisonToGallery) {
      if (mounted) {
        setState(() => _savingStage = l10n.generatingComparisonImageStage);
      }
      comparisonBackupResult = await autoSaveComparisonImageToGallery(
        record: record,
        point: widget.point,
        settings: widget.settings,
        pointReferenceFullImagePath: widget.referenceImagePath,
        pointReferenceImageUrl: widget.referenceImageUrl,
        labelReference: AppLocalizations.of(context)!.comparisonLabelReference,
        labelCaptured: AppLocalizations.of(context)!.comparisonLabelCaptured,
        labelPilgrim: AppLocalizations.of(context)!.comparisonLabelPilgrim,
      );
    }

    String? nextPointName;
    if (completePoint) {
      if (mounted) {
        setState(() => _savingStage = l10n.updatingPointStatusStage);
      }
      controller.completePoint(widget.point);
      nextPointName = controller.currentPoint?.name;
    }

    if (!mounted) {
      return;
    }
    setState(() {
      _saving = false;
      _savingStage = null;
    });
    final message = _saveSuccessMessage(context,
      completePoint: completePoint,
      nextPointName: nextPointName,
      attemptedGalleryBackup: attemptedGalleryBackup,
      galleryBackupSucceeded: galleryBackupSucceeded,
      comparisonBackupResult: comparisonBackupResult,
    );
    ScaffoldMessenger.of(
      context,
    ).showReplacingSnackBar(SnackBar(content: Text(message)));
    if (completePoint) {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopScope(
      canPop: !_saving,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _saving) {
          ScaffoldMessenger.of(
            context,
          ).showReplacingSnackBar(SnackBar(content: Text(l10n.savingRecordPleaseWait)));
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.confirmRecordTitle)),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Text(
              widget.point.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.point.work.title} / ${widget.point.displayEpisodeLabel}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 16),
            _ComparisonPanel(
              photoPath: widget.photoPath,
              referenceBytes: widget.referenceBytes,
              referenceImagePath: widget.referenceImagePath,
              referenceImageUrl: widget.referenceImageUrl,
            ),
            const SizedBox(height: 16),
            _InfoPanel(referenceMode: widget.referenceMode),
            if (_savingStage != null) ...[
              const SizedBox(height: 12),
              _SavingProgressPanel(label: _savingStage!),
            ],
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _saving ? null : () => _save(completePoint: false),
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined, size: 18),
              label: Text(_saving ? l10n.saving2 : l10n.saveRecord),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _saving ? null : () => _save(completePoint: true),
              icon: const Icon(Icons.check_circle_outline, size: 18),
              label: Text(l10n.saveAndMarkComplete),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _saving ? null : () => Navigator.of(context).pop(),
              child: Text(l10n.btnCancel),
            ),
          ],
        ),
      ),
    );
  }
}

bool shouldAutoSaveVisitPhotoToGallery(AppSettings settings) {
  if (!settings.saveVisitPhotoToGallery || kIsWeb) {
    return false;
  }
  return defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
}

String _saveSuccessMessage(
  BuildContext context, {
  required bool completePoint,
  required String? nextPointName,
  required bool attemptedGalleryBackup,
  required bool galleryBackupSucceeded,
  required AutoComparisonGalleryResult? comparisonBackupResult,
}) {
  final l10n = AppLocalizations.of(context)!;
  final base = completePoint
      ? l10n.savedAndMarkedComplete
      : l10n.recordSaved;
  final backupText = attemptedGalleryBackup
      ? (galleryBackupSucceeded
          ? l10n.backupSavedToAlbumSuffix
          : l10n.albumBackupFailedSuffix)
      : '';
  final comparisonText = _comparisonBackupMessage(context, comparisonBackupResult);
  final nextText = completePoint && nextPointName != null
      ? l10n.nextPointNameSuffix(nextPointName)
      : '';
  return '$base$backupText$comparisonText$nextText';
}

String _comparisonBackupMessage(
  BuildContext context,
  AutoComparisonGalleryResult? result,
) {
  if (result == null) {
    return '';
  }
  final l10n = AppLocalizations.of(context)!;
  return switch (result.status) {
    AutoComparisonGalleryStatus.saved => l10n.comparisonSavedToAlbumSuffix,
    AutoComparisonGalleryStatus.referenceUnavailable =>
      l10n.referenceUnavailableComparisonSuffix,
    AutoComparisonGalleryStatus.capturedPhotoUnavailable =>
      l10n.capturedUnavailableComparisonSuffix,
    AutoComparisonGalleryStatus.galleryFailed =>
      l10n.comparisonGalleryFailedSuffix,
    AutoComparisonGalleryStatus.renderFailed => l10n.comparisonRenderFailedSuffix,
  };
}

Future<void> _showGallerySaveSheet(
  BuildContext context,
  String photoPath,
) async {
  final l10n = AppLocalizations.of(context)!;
  final action = await showModalBottomSheet<String>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.save_alt_outlined),
            title: Text(l10n.saveToAlbum),
            onTap: () => Navigator.of(context).pop('save'),
          ),
          const SizedBox(height: 12),
        ],
      ),
    ),
  );

  if (action != 'save' || !context.mounted) return;

  final success = await saveImageToGallery(photoPath);
  if (!context.mounted) return;

  ScaffoldMessenger.of(context).showReplacingSnackBar(
    SnackBar(content: Text(success ? l10n.savedToAlbum : l10n.saveFailedRetry)),
  );
}

class _ComparisonPanel extends StatelessWidget {
  const _ComparisonPanel({
    required this.photoPath,
    required this.referenceBytes,
    required this.referenceImagePath,
    required this.referenceImageUrl,
  });

  final String photoPath;
  final Uint8List? referenceBytes;
  final String? referenceImagePath;
  final String? referenceImageUrl;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ImageCompareTile(
          label: l10n.reference2,
          child: _ReferencePreview(
            bytes: referenceBytes,
            imagePath: referenceImagePath,
            imageUrl: referenceImageUrl,
          ),
          onTap: () => ImageViewerScreen.show(
            context,
            bytes: referenceBytes,
            filePath: referenceImagePath,
            imageUrl: referenceImageUrl,
          ),
        ),
        const SizedBox(height: 12),
        _ImageCompareTile(
          label: l10n.recordDetailCapturedPhoto,
          child: VisitRecordPhoto(path: photoPath, fit: BoxFit.contain),
          onTap: () => ImageViewerScreen.show(context, filePath: photoPath),
          onLongPress: () => _showGallerySaveSheet(context, photoPath),
        ),
      ],
    );
  }
}

class _ImageCompareTile extends StatelessWidget {
  const _ImageCompareTile({
    required this.label,
    required this.child,
    this.onTap,
    this.onLongPress,
  });

  final String label;
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: InkWell(
              onTap: onTap,
              onLongPress: onLongPress,
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

class _ReferencePreview extends StatelessWidget {
  const _ReferencePreview({
    required this.bytes,
    required this.imagePath,
    required this.imageUrl,
  });

  final Uint8List? bytes;
  final String? imagePath;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final localBytes = bytes;
    if (localBytes != null) {
      return Image.memory(localBytes, fit: BoxFit.contain);
    }

    final localPath = imagePath;
    if (referenceImageLocalPathCanDisplay(localPath)) {
      return ReferenceThumbnail(
        localPath: localPath,
        imageUrl: null,
        placeholder: const _ReferencePlaceholder(),
        fit: BoxFit.contain,
      );
    }

    final url = imageUrl;
    if (url != null) {
      return AnitabiNetworkImage(
        url: url,
        imageSource: AnitabiImageSourceScope.of(context),
        fit: BoxFit.contain,
        loadingBuilder: (_) {
          return const _ReferencePlaceholder(
            state: ReferenceImagePlaceholderState.loading,
          );
        },
        errorBuilder: (_) {
          return const _ReferencePlaceholder();
        },
      );
    }

    return const _ReferencePlaceholder();
  }
}

class _ReferencePlaceholder extends StatelessWidget {
  const _ReferencePlaceholder({
    this.state = ReferenceImagePlaceholderState.unavailable,
  });

  final ReferenceImagePlaceholderState state;

  @override
  Widget build(BuildContext context) {
    return ReferenceImagePlaceholder(state: state);
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.referenceMode});

  final String referenceMode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.layers_outlined, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(
            l10n.referenceModeLabel,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
          const Spacer(),
          Text(
            referenceMode,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _SavingProgressPanel extends StatelessWidget {
  const _SavingProgressPanel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 10),
          Expanded(
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
        ],
      ),
    );
  }
}
