import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../data/anitabi_client.dart';
import '../l10n/app_localizations.dart';
import '../plan/pilgrimage_models.dart';
import '../widgets/anitabi_network_image.dart';
import '../widgets/image_viewer_screen.dart';
import 'map_navigation_launcher.dart';
import 'nearby_radar_service.dart';

/// Marker shown on the map for a nearby anime spot found by the radar.
class NearbyRadarMarker extends StatelessWidget {
  const NearbyRadarMarker({
    required this.spot,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final NearbyRadarSpot spot;
  final bool selected;
  final VoidCallback onTap;

  static const Color radarColor = Color(0xFF00897B);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: selected ? 42 : 36,
            height: selected ? 42 : 36,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? AppColors.warning : radarColor,
                width: selected ? 3 : 2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.radar,
              size: selected ? 22 : 18,
              color: selected ? AppColors.warning : radarColor,
            ),
          ),
          if (spot.isImported)
            Positioned(
              right: -1,
              top: -1,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.green.shade600,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: const Icon(Icons.check, size: 9, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}

/// Floating status banner at top when radar is active.
class NearbyRadarBanner extends StatelessWidget {
  const NearbyRadarBanner({
    required this.count,
    required this.isScanning,
    required this.showRescan,
    required this.onRescan,
    required this.onClose,
    super.key,
  });

  final int count;
  final bool isScanning;
  final bool showRescan;
  final VoidCallback onRescan;
  final VoidCallback onClose;

  static const Color radarColor = Color(0xFF00897B);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: AppColors.surface.withValues(alpha: 0.95),
      elevation: 4,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: radarColor.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isScanning)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(radarColor),
                ),
              )
            else
              const Icon(Icons.radar, size: 18, color: radarColor),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                isScanning
                    ? l10n.radarScanning
                    : (count == 0
                        ? l10n.radarNoSpotsFound
                        : l10n.radarFoundCount(count)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (showRescan && !isScanning) ...[
              const SizedBox(width: 6),
              InkWell(
                onTap: onRescan,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: radarColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.refresh, size: 14, color: radarColor),
                      const SizedBox(width: 4),
                      Text(
                        l10n.radarRescanArea,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: radarColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.close, size: 16),
              tooltip: l10n.radarClose,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              onPressed: onClose,
            ),
          ],
        ),
      ),
    );
  }
}

/// Detailed bottom sheet for a radar spot.
class NearbyRadarSpotSheet extends StatefulWidget {
  const NearbyRadarSpotSheet({
    required this.spot,
    required this.anitabiClient,
    required this.navigationLauncher,
    required this.navigationApp,
    required this.onImportWork,
    this.onViewInPlan,
    super.key,
  });

  final NearbyRadarSpot spot;
  final AnitabiClient anitabiClient;
  final MapNavigationLauncher navigationLauncher;
  final NavigationApp navigationApp;
  final Future<void> Function(AnitabiMapWorkLite work) onImportWork;
  final VoidCallback? onViewInPlan;

  static Future<void> show(
    BuildContext context, {
    required NearbyRadarSpot spot,
    required AnitabiClient anitabiClient,
    required MapNavigationLauncher navigationLauncher,
    required NavigationApp navigationApp,
    required Future<void> Function(AnitabiMapWorkLite work) onImportWork,
    VoidCallback? onViewInPlan,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (_) => NearbyRadarSpotSheet(
        spot: spot,
        anitabiClient: anitabiClient,
        navigationLauncher: navigationLauncher,
        navigationApp: navigationApp,
        onImportWork: onImportWork,
        onViewInPlan: onViewInPlan,
      ),
    );
  }

  @override
  State<NearbyRadarSpotSheet> createState() => _NearbyRadarSpotSheetState();
}

class _NearbyRadarSpotSheetState extends State<NearbyRadarSpotSheet> {
  late Future<AnitabiPointLookupResult?> _pointFuture;
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    _loadPoint();
  }

  @override
  void didUpdateWidget(covariant NearbyRadarSpotSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.spot.bangumiId != widget.spot.bangumiId ||
        oldWidget.spot.pointId != widget.spot.pointId) {
      _loadPoint();
    }
  }

  void _loadPoint() {
    _pointFuture = widget.anitabiClient.findPointInBangumi(
      bangumiId: widget.spot.bangumiId,
      pointId: widget.spot.pointId,
    );
  }

  Future<void> _handleImport() async {
    if (_isImporting) {
      return;
    }
    setState(() => _isImporting = true);
    try {
      await widget.onImportWork(widget.spot.work);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeName = Localizations.localeOf(context).toString();
    final work = widget.spot.work;
    final workTitle = work.displayTitle(localeName);
    final distanceText = l10n.radarDistance(
      formatRadarDistance(widget.spot.distanceMeters),
    );

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Work header card
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (work.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 52,
                      height: 52,
                      child: AnitabiNetworkImage(
                        url: work.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_) => Container(
                          color: AppColors.surfaceMuted,
                          child: const Icon(
                            Icons.movie_outlined,
                            size: 24,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.movie_outlined,
                      size: 24,
                      color: AppColors.textSecondary,
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (work.city.isNotEmpty) ...[
                            Text(
                              work.city,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '•',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            distanceText,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF00897B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // Dynamic Point Details
            FutureBuilder<AnitabiPointLookupResult?>(
              future: _pointFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          l10n.radarLoadingPoint,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final point = snapshot.data?.point;
                if (point == null) {
                  return const SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      point.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (point.episodeLabel.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        point.episodeLabel,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    if (point.referenceImageUrl != null &&
                        point.referenceImageUrl!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: GestureDetector(
                          onTap: () {
                            ImageViewerScreen.show(
                              context,
                              imageUrl: point.referenceImageUrl,
                            );
                          },
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: AnitabiNetworkImage(
                              url: point.referenceImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_) => Container(
                                color: AppColors.surfaceMuted,
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.broken_image_outlined,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (point.origin.isNotEmpty || (point.note?.isNotEmpty ?? false)) ...[
                      const SizedBox(height: 10),
                      Text(
                        point.origin.isNotEmpty ? point.origin : (point.note ?? ''),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),

            const SizedBox(height: 20),

            // Actions row
            Row(
              children: [
                Expanded(
                  child: widget.spot.isImported
                      ? Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green.shade300),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: 16,
                                    color: Colors.green.shade700,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    l10n.radarAlreadyInPlan,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (widget.onViewInPlan != null) ...[
                              const SizedBox(width: 8),
                              OutlinedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  widget.onViewInPlan?.call();
                                },
                                child: Text(l10n.radarViewInPlan),
                              ),
                            ],
                          ],
                        )
                      : FilledButton.icon(
                          onPressed: _isImporting ? null : _handleImport,
                          icon: _isImporting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.playlist_add),
                          label: Text(l10n.radarAddToPlan),
                        ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    final tempWork = PilgrimageWork(
                      id: 'bangumi-${widget.spot.bangumiId}',
                      bangumiId: widget.spot.bangumiId,
                      title: workTitle,
                      subtitle: work.subtitle,
                      city: work.city,
                      source: WorkSource.bangumi,
                    );
                    final tempPoint = PilgrimagePoint(
                      id: 'radar-${widget.spot.bangumiId}-${widget.spot.pointId}',
                      work: tempWork,
                      name: workTitle,
                      subtitle: '',
                      position: widget.spot.position,
                      episodeLabel: '',
                      referenceLabel: '',
                      source: PointSource.anitabi,
                    );
                    widget.navigationLauncher.openWalking(
                      tempPoint,
                      widget.navigationApp,
                    );
                  },
                  icon: const Icon(Icons.navigation_outlined, size: 18),
                  label: Text(l10n.btnNavigate),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
