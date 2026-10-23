import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../l10n/app_localizations.dart';
import '../plan/pilgrimage_models.dart';
import '../plan/reference_image_status.dart';
import '../widgets/reference_thumbnail_stub.dart'
    if (dart.library.io) '../widgets/reference_thumbnail_io.dart';
import 'map_spots.dart';

/// Per-work aggregate shown in the work filter sheet.
class MapWorkSummary {
  const MapWorkSummary({
    required this.key,
    required this.work,
    required this.total,
    required this.done,
  });

  final String key;
  final PilgrimageWork work;
  final int total;
  final int done;

  Color get color => mapColorForWorkKey(key);
}

/// Pill under the search bar: "全部作品 (N)" / "作品 k/N", or — when exactly one
/// work is isolated — "仅显示：作品X" with a clear button.
class MapWorkFilterBar extends StatelessWidget {
  const MapWorkFilterBar({
    required this.label,
    required this.onTap,
    this.onClear,
    super.key,
  });

  final String label;
  final VoidCallback onTap;

  /// Shown when a single work is isolated; returns to "all works".
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: AppColors.surface.withValues(alpha: 0.94),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            children: [
              const Icon(Icons.movie_filter_outlined, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ),
              if (onClear != null)
                InkResponse(
                  onTap: onClear,
                  radius: 18,
                  child: Tooltip(
                    message: l10n.mapFocusClear,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(Icons.close, size: 18),
                    ),
                  ),
                )
              else
                const Icon(Icons.expand_more, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet to tick which works are shown/highlighted on the map. Edits
/// are pushed to the map live through [onChanged].
Future<void> showMapWorkFilterSheet(
  BuildContext context, {
  required List<MapWorkSummary> works,
  required Set<String> deselected,
  required bool hideUnselected,
  required void Function(Set<String> deselected, bool hideUnselected)
  onChanged,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.surface,
    builder: (context) => _MapWorkFilterSheet(
      works: works,
      deselected: deselected,
      hideUnselected: hideUnselected,
      onChanged: onChanged,
    ),
  );
}

class _MapWorkFilterSheet extends StatefulWidget {
  const _MapWorkFilterSheet({
    required this.works,
    required this.deselected,
    required this.hideUnselected,
    required this.onChanged,
  });

  final List<MapWorkSummary> works;
  final Set<String> deselected;
  final bool hideUnselected;
  final void Function(Set<String>, bool) onChanged;

  @override
  State<_MapWorkFilterSheet> createState() => _MapWorkFilterSheetState();
}

class _MapWorkFilterSheetState extends State<_MapWorkFilterSheet> {
  late final Set<String> _deselected = {...widget.deselected};
  late bool _hideUnselected = widget.hideUnselected;

  void _commit() {
    setState(() {});
    widget.onChanged({..._deselected}, _hideUnselected);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.72;
    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.mapWorkFilterTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _deselected.isEmpty
                        ? null
                        : () {
                            _deselected.clear();
                            _commit();
                          },
                    child: Text(l10n.mapWorkFilterSelectAll),
                  ),
                ],
              ),
            ),
            SwitchListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              title: Text(l10n.mapWorkFilterHideUnselected),
              value: _hideUnselected,
              onChanged: (value) {
                _hideUnselected = value;
                _commit();
              },
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.works.length,
                itemBuilder: (context, index) {
                  final summary = widget.works[index];
                  final selected = !_deselected.contains(summary.key);
                  return CheckboxListTile(
                    value: selected,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    secondary: CircleAvatar(
                      radius: 7,
                      backgroundColor: summary.color,
                    ),
                    title: Text(
                      summary.work.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                    ),
                    subtitle: Text(
                      l10n.mapWorkFilterProgress(summary.done, summary.total),
                    ),
                    onChanged: (value) {
                      if (value == true) {
                        _deselected.remove(summary.key);
                      } else {
                        _deselected.add(summary.key);
                      }
                      _commit();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One work's point at a shared location.
class MapSpotRow {
  const MapSpotRow({
    required this.entry,
    required this.status,
    required this.selected,
  });

  final MapPointEntry entry;
  final VisitStatus status;

  /// Whether the user ticked this work as "want to go".
  final bool selected;

  Color get color => mapColorForWorkKey(entry.workKey);
}

/// Bottom panel for a location shared by several works: lists every work with
/// a checkbox ("想去") plus per-work camera / detail shortcuts.
class MapSpotPanel extends StatelessWidget {
  const MapSpotPanel({
    required this.rows,
    required this.onToggleWork,
    required this.onNavigate,
    required this.onOpenDetail,
    required this.onOpenCamera,
    super.key,
  });

  final List<MapSpotRow> rows;
  final ValueChanged<String> onToggleWork;
  final VoidCallback onNavigate;
  final ValueChanged<MapPointEntry> onOpenDetail;
  final ValueChanged<MapPointEntry> onOpenCamera;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final maxListHeight = MediaQuery.sizeOf(context).height * 0.34;

    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomInset),
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 4, 0),
            child: Row(
              children: [
                Icon(Icons.layers_outlined, size: 18, color: AppColors.accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.mapSpotTitle(rows.length),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: onNavigate,
                  icon: const Icon(Icons.near_me_outlined, size: 18),
                  label: Text(l10n.btnNavigate),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
            child: Text(
              l10n.mapSpotHint,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                letterSpacing: 0,
              ),
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxListHeight),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: rows.length,
              itemBuilder: (context, index) => _MapSpotRowTile(
                row: rows[index],
                onToggle: () => onToggleWork(rows[index].entry.workKey),
                onOpenDetail: () => onOpenDetail(rows[index].entry),
                onOpenCamera: () => onOpenCamera(rows[index].entry),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapSpotRowTile extends StatelessWidget {
  const _MapSpotRowTile({
    required this.row,
    required this.onToggle,
    required this.onOpenDetail,
    required this.onOpenCamera,
  });

  final MapSpotRow row;
  final VoidCallback onToggle;
  final VoidCallback onOpenDetail;
  final VoidCallback onOpenCamera;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final point = row.entry.point;
    final remoteImageUrl = hasRemoteReferenceImage(point)
        ? point.referenceImageUrl
        : null;
    final episode = point.episodeLabel.trim();
    final detail = episode.isEmpty ? point.name : '${point.name} · $episode';
    final statusText = switch (row.status) {
      VisitStatus.current => l10n.labelStatusCurrent,
      VisitStatus.completed => l10n.labelStatusCompleted,
      VisitStatus.pending => l10n.labelStatusPending,
    };
    final statusColor = switch (row.status) {
      VisitStatus.current => AppColors.accent,
      VisitStatus.completed => AppColors.textSecondary,
      VisitStatus.pending => AppColors.warning,
    };

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Checkbox(
              value: row.selected,
              onChanged: (_) => onToggle(),
              visualDensity: VisualDensity.compact,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Container(
                width: 48,
                height: 48,
                color: AppColors.surfaceMuted,
                child: ReferenceThumbnail(
                  localPath: point.referenceThumbnailPath,
                  imageUrl: remoteImageUrl,
                  placeholder: Icon(
                    Icons.image_outlined,
                    color: AppColors.accentDark,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Opacity(
                opacity: row.selected ? 1 : 0.55,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(radius: 5, backgroundColor: row.color),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            point.work.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        letterSpacing: 0,
                      ),
                    ),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              tooltip: l10n.btnPointDetail,
              visualDensity: VisualDensity.compact,
              onPressed: onOpenDetail,
              icon: const Icon(Icons.info_outline, size: 22),
            ),
            IconButton(
              tooltip: l10n.btnCameraReference,
              visualDensity: VisualDensity.compact,
              onPressed: onOpenCamera,
              icon: const Icon(Icons.photo_camera_outlined, size: 22),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small count badge drawn on a marker that stands for several works.
class MapSpotCountBadge extends StatelessWidget {
  const MapSpotCountBadge({required this.count, super.key});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.warning,
        shape: count > 9 ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: count > 9 ? BorderRadius.circular(9) : null,
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          height: 1,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
