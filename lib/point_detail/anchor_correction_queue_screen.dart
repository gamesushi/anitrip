import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../data/pilgrimage_repository.dart';
import '../l10n/app_localizations.dart';
import '../plan_transfer/plan_export_delivery.dart';
import '../plan_transfer/plan_export_delivery_result.dart';
import '../widgets/snackbar_helper.dart';
import 'anchor_correction_export.dart';

/// Review queue for user-reported anchor-coordinate errors.
///
/// [AnchorCorrectionSheet] only writes to a local queue; this screen is what
/// makes that queue useful — it lets the maintainer hand the reports off (as a
/// JSON document they can review offline) and then clears them.
class AnchorCorrectionQueueScreen extends StatefulWidget {
  const AnchorCorrectionQueueScreen({required this.repository, super.key});

  final PilgrimageRepository repository;

  @override
  State<AnchorCorrectionQueueScreen> createState() =>
      _AnchorCorrectionQueueScreenState();
}

class _AnchorCorrectionQueueScreenState
    extends State<AnchorCorrectionQueueScreen> {
  var _loading = true;
  var _exporting = false;
  var _generation = 0;
  List<AnchorCorrectionReport> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _generation++;
    super.dispose();
  }

  Future<void> _load() async {
    final generation = _generation;
    setState(() => _loading = true);
    final items = await widget.repository.loadAnchorCorrections();
    if (!mounted || generation != _generation) {
      return;
    }
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  Future<void> _export() async {
    if (_items.isEmpty || _exporting) {
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _exporting = true);
    try {
      final generatedAt = DateTime.now();
      final fileName = suggestAnchorCorrectionFileName(generatedAt);
      final payload = encodeAnchorCorrectionsJson(
        corrections: _items,
        generatedAt: generatedAt,
      );
      final bytes = Uint8List.fromList(utf8.encode(payload));

      final destination = await preparePlanExportDestination(
        context: context,
        fileName: fileName,
        mimeType: anchorCorrectionMimeType,
        extension: anchorCorrectionFileExtension,
      );
      if (!mounted) {
        return;
      }
      final result = await deliverPlanExport(
        context: context,
        bytes: bytes,
        fileName: fileName,
        mimeType: anchorCorrectionMimeType,
        shareSubject: l10n.correctionQueueTitle,
        shareText: l10n.correctionQueuePending(_items.length),
        extension: anchorCorrectionFileExtension,
        destination: destination,
      );
      if (result.action == PlanExportDeliveryAction.canceled) {
        return;
      }
      final ids = _items.map((item) => item.id).toList(growable: false);
      await widget.repository.markAnchorCorrectionsExported(ids);
      await _load();
      if (mounted) {
        messenger.showReplacingSnackBar(
          SnackBar(content: Text(l10n.correctionQueueExported(ids.length))),
        );
      }
    } on PlanExportCanceledException {
      // User dismissed the save dialog; nothing to report.
    } catch (error) {
      if (mounted) {
        messenger.showReplacingSnackBar(
          SnackBar(content: Text('$error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _exporting = false);
      }
    }
  }

  Future<void> _confirmDelete(AnchorCorrectionReport item) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(l10n.correctionQueueDeleteConfirm),
          content: Text(l10n.correctionQueueDeleteConfirmBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );
    if (confirmed != true) {
      return;
    }
    await widget.repository.deleteAnchorCorrection(item.id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(l10n.correctionQueueTitle),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _items.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(24),
                          child: Center(child: Text(l10n.correctionQueueEmpty)),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                          itemCount: _items.length,
                          itemBuilder: (context, index) {
                            return _CorrectionTile(
                              item: _items[index],
                              onDelete: () => _confirmDelete(_items[index]),
                            );
                          },
                        ),
            ),
            if (_items.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.correctionQueueExportHint,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.5,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _exporting ? null : _export,
                        icon: _exporting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.ios_share_outlined, size: 18),
                        label: Text(
                          _exporting
                              ? l10n.correctionQueueExport
                              : '${l10n.correctionQueueExport} · ${l10n.correctionQueuePending(_items.length)}',
                        ),
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

class _CorrectionTile extends StatelessWidget {
  const _CorrectionTile({required this.item, required this.onDelete});

  final AnchorCorrectionReport item;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final chips = <String>[
      if (item.hasSuggestedCoordinate)
        '${item.suggestedLatitude!.toStringAsFixed(5)}, ${item.suggestedLongitude!.toStringAsFixed(5)}'
      else
        l10n.correctionQueueNoSuggestion,
      if (item.photoPath != null) l10n.correctionQueueHasPhoto,
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.pointName ?? item.workTitle ?? item.pointId,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                iconSize: 18,
                tooltip: l10n.correctionQueueDelete,
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.textSecondary,
                ),
                onPressed: onDelete,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${l10n.correctionCurrentLocation}: ${item.pointLatitude.toStringAsFixed(5)}, ${item.pointLongitude.toStringAsFixed(5)}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: chips
                .map(
                  (chip) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      chip,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
          if (item.description != null && item.description!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              item.description!.trim(),
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                letterSpacing: 0,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
