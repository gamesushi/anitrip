import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../app_theme.dart';
import '../data/pilgrimage_repository.dart';
import '../l10n/app_localizations.dart';
import '../map/map_tile_config.dart';
import '../widgets/snackbar_helper.dart';
import 'pilgrimage_models.dart';
import 'plan_group_utils.dart';
import 'plan_partition.dart';

enum _PartitionMode { distance, count }

/// One-tap smart partition: clusters the plan's ungrouped points into areas and
/// creates them (with centroid anchors) in a single step, replacing the manual
/// "create group → set anchor → assign points" chain. See
/// miriago_plan_optimization_plan.md (P0).
class SmartPartitionScreen extends StatefulWidget {
  const SmartPartitionScreen({
    required this.plan,
    required this.repository,
    required this.settings,
    super.key,
  });

  final PilgrimagePlan plan;
  final PilgrimageRepository repository;
  final AppSettings settings;

  static Future<bool?> open(
    BuildContext context, {
    required PilgrimagePlan plan,
    required PilgrimageRepository repository,
    required AppSettings settings,
  }) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => SmartPartitionScreen(
          plan: plan,
          repository: repository,
          settings: settings,
        ),
      ),
    );
  }

  @override
  State<SmartPartitionScreen> createState() => _SmartPartitionScreenState();
}

class _SmartPartitionScreenState extends State<SmartPartitionScreen> {
  final MapController _mapController = MapController();

  _PartitionMode _mode = _PartitionMode.distance;
  double _thresholdMeters = kDefaultPartitionThresholdMeters;
  int _groupCount = 4;
  var _isSaving = false;

  List<PlanPartitionCluster> _clusters = const [];

  late final List<PilgrimagePoint> _ungrouped = widget.plan.points
      .where((point) => point.groupId == null)
      .toList(growable: false);

  late final Map<String, PilgrimagePoint> _pointById = {
    for (final point in _ungrouped) point.id: point,
  };

  @override
  void initState() {
    super.initState();
    _groupCount = _groupCount.clamp(1, _ungrouped.isEmpty ? 1 : _ungrouped.length);
    _recompute();
  }

  void _recompute() {
    setState(() {
      _clusters = _mode == _PartitionMode.distance
          ? partitionByDistance(_ungrouped, thresholdMeters: _thresholdMeters)
          : partitionByCount(_ungrouped, groupCount: _groupCount);
    });
  }

  /// pointId → cluster index, for coloring the preview markers.
  Map<String, int> get _pointCluster {
    final map = <String, int>{};
    for (var i = 0; i < _clusters.length; i += 1) {
      for (final id in _clusters[i].pointIds) {
        map[id] = i;
      }
    }
    return map;
  }

  LatLng get _mapCenter {
    if (_ungrouped.isEmpty) {
      return previewCurrentLocation;
    }
    final lat =
        _ungrouped.map((p) => p.position.latitude).reduce((a, b) => a + b) /
        _ungrouped.length;
    final lng =
        _ungrouped.map((p) => p.position.longitude).reduce((a, b) => a + b) /
        _ungrouped.length;
    return LatLng(lat, lng);
  }

  List<Polygon> _clusterPolygons() {
    final polygons = <Polygon>[];
    for (var i = 0; i < _clusters.length; i += 1) {
      final points = _clusters[i].pointIds
          .map((id) => _pointById[id])
          .whereType<PilgrimagePoint>()
          .toList(growable: false);
      final hull = roundedGroupHull(points);
      if (hull.length < 3) {
        continue;
      }
      final color = planGroupMapColorAt(i);
      polygons.add(
        Polygon(
          points: hull,
          color: color.withValues(alpha: 0.16),
          borderColor: color.withValues(alpha: 0.7),
          borderStrokeWidth: 2,
        ),
      );
    }
    return polygons;
  }

  Future<void> _generate() async {
    if (_isSaving || _clusters.isEmpty) {
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isSaving = true);

    final now = DateTime.now();
    final baseOrder = widget.plan.groups.isEmpty
        ? 0
        : widget.plan.groups
                  .map((g) => g.orderIndex)
                  .reduce((a, b) => a > b ? a : b) +
              1;
    final inputs = <PlanPartitionInput>[
      for (var i = 0; i < _clusters.length; i += 1)
        PlanPartitionInput(
          group: PilgrimagePlanGroup(
            id: 'group-${now.microsecondsSinceEpoch}-$i',
            name: l10n.partitionGroupName(i + 1),
            orderIndex: baseOrder + i,
            anchorName: l10n.partitionGroupName(i + 1),
            anchorLatitude: _clusters[i].centroid.latitude,
            anchorLongitude: _clusters[i].centroid.longitude,
            createdAt: now,
          ),
          pointIds: _clusters[i].pointIds,
        ),
    ];

    try {
      await widget.repository.applyPlanPartition(
        planId: widget.plan.id,
        groups: inputs,
      );
      if (!mounted) {
        return;
      }
      messenger.showReplacingSnackBar(
        SnackBar(content: Text(l10n.partitionSuccess(inputs.length))),
      );
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _isSaving = false);
      messenger.showReplacingSnackBar(
        SnackBar(content: Text(l10n.partitionFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pointCluster = _pointCluster;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.smartPartition)),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _mapCenter,
              initialZoom: 13.5,
              minZoom: 4,
              maxZoom: 24,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
            ),
            children: [
              configuredMapTileLayer(widget.settings),
              PolygonLayer(polygons: _clusterPolygons()),
              MarkerLayer(
                markers: [
                  for (final point in _ungrouped)
                    Marker(
                      point: point.position,
                      width: 22,
                      height: 22,
                      child: _ClusterDot(
                        color: planGroupMapColorAt(pointCluster[point.id] ?? 0),
                      ),
                    ),
                  for (final cluster in _clusters)
                    Marker(
                      point: cluster.centroid,
                      width: 30,
                      height: 30,
                      child: const _CentroidMarker(),
                    ),
                ],
              ),
              configuredMapAttribution(widget.settings),
            ],
          ),
          Positioned(
            left: 12,
            right: 12,
            top: 12,
            child: SafeArea(
              bottom: false,
              child: _PartitionPanel(
                mode: _mode,
                thresholdMeters: _thresholdMeters,
                groupCount: _groupCount,
                maxGroupCount: _ungrouped.isEmpty ? 1 : _ungrouped.length,
                onModeChanged: (mode) {
                  _mode = mode;
                  _recompute();
                },
                onThresholdChanged: (value) {
                  _thresholdMeters = value;
                  _recompute();
                },
                onGroupCountChanged: (value) {
                  _groupCount = value;
                  _recompute();
                },
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _PartitionActionBar(
              clusterCount: _clusters.length,
              pointCount: _ungrouped.length,
              isSaving: _isSaving,
              onGenerate: _generate,
            ),
          ),
        ],
      ),
    );
  }
}

class _PartitionPanel extends StatelessWidget {
  const _PartitionPanel({
    required this.mode,
    required this.thresholdMeters,
    required this.groupCount,
    required this.maxGroupCount,
    required this.onModeChanged,
    required this.onThresholdChanged,
    required this.onGroupCountChanged,
  });

  final _PartitionMode mode;
  final double thresholdMeters;
  final int groupCount;
  final int maxGroupCount;
  final ValueChanged<_PartitionMode> onModeChanged;
  final ValueChanged<double> onThresholdChanged;
  final ValueChanged<int> onGroupCountChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.96),
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<_PartitionMode>(
              segments: [
                ButtonSegment(
                  value: _PartitionMode.distance,
                  icon: const Icon(Icons.social_distance_outlined, size: 18),
                  label: Text(l10n.partitionByDistance),
                ),
                ButtonSegment(
                  value: _PartitionMode.count,
                  icon: const Icon(Icons.grid_view_outlined, size: 18),
                  label: Text(l10n.partitionByCount),
                ),
              ],
              selected: {mode},
              onSelectionChanged: (set) => onModeChanged(set.first),
            ),
            const SizedBox(height: 6),
            if (mode == _PartitionMode.distance) ...[
              Text(
                '${l10n.partitionThreshold} · ${_formatDistance(thresholdMeters)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: 0,
                ),
              ),
              Slider(
                value: thresholdMeters.clamp(200, 3000),
                min: 200,
                max: 3000,
                divisions: 56,
                label: _formatDistance(thresholdMeters),
                onChanged: onThresholdChanged,
              ),
            ] else ...[
              Text(
                '${l10n.partitionGroups} · $groupCount',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: 0,
                ),
              ),
              Slider(
                value: groupCount.toDouble().clamp(
                  1,
                  maxGroupCount.toDouble(),
                ),
                min: 1,
                max: maxGroupCount.clamp(2, 20).toDouble(),
                divisions: (maxGroupCount.clamp(2, 20) - 1).clamp(1, 19),
                label: '$groupCount',
                onChanged: (value) => onGroupCountChanged(value.round()),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PartitionActionBar extends StatelessWidget {
  const _PartitionActionBar({
    required this.clusterCount,
    required this.pointCount,
    required this.isSaving,
    required this.onGenerate,
  });

  final int clusterCount;
  final int pointCount;
  final bool isSaving;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(12, 0, 12, 12 + bottomInset),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.partitionSummary(clusterCount, pointCount),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 40,
                child: FilledButton.icon(
                  onPressed: isSaving || clusterCount == 0 || pointCount == 0
                      ? null
                      : onGenerate,
                  icon: isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome_mosaic_outlined, size: 18),
                  label: Text(
                    isSaving ? l10n.partitionGenerating : l10n.partitionGenerate,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClusterDot extends StatelessWidget {
  const _ClusterDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }
}

class _CentroidMarker extends StatelessWidget {
  const _CentroidMarker();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.accentDark, width: 2),
      ),
      child: Icon(Icons.flag_outlined, size: 18, color: AppColors.accentDark),
    );
  }
}

String _formatDistance(double meters) {
  if (meters >= 1000) {
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }
  return '${meters.round()} m';
}
