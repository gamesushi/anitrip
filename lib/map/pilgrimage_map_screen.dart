import 'dart:async';

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../app_theme.dart';
import '../explore/widgets/explore_search_bar.dart';
import '../l10n/app_localizations.dart';
import '../widgets/snackbar_helper.dart';
import '../camera_reference/camerawesome_reference_screen.dart';
import '../data/pilgrimage_repository.dart';
import '../point_detail/point_detail_sheet.dart';
import '../plan/add_points_screen.dart';
import '../plan/plan_group_utils.dart';
import '../plan/pilgrimage_models.dart';
import '../plan/pilgrimage_plan_controller.dart';
import '../plan/reference_image_status.dart';
import '../records/point_visit_records_screen.dart';
import '../records/visit_record_detail_screen.dart';
import '../utils/selected_item_order.dart';
import '../widgets/copyable_text.dart';
import '../widgets/image_viewer_screen.dart';
import '../widgets/auto_caching_reference_thumbnail.dart';
import '../widgets/image_load_limiter.dart';
import '../widgets/map_thumbnail_marker.dart';
import '../data/anitabi_client.dart';
import '../explore/explore_work_item.dart';
import '../explore/work_importer.dart';
import 'map_navigation_launcher.dart';
import 'map_spots.dart';
import 'thumbnail_viewport_selection.dart';
import 'gps_fix_stream.dart';
import 'gps_track.dart';
import 'gps_track_recorder.dart';
import '../data/local/gps_track_repository.dart';
import '../data/local/sqlite_pilgrimage_repository.dart';
import 'map_tile_config.dart';
import 'map_work_widgets.dart';
import 'nearby_radar_service.dart';
import 'nearby_radar_widgets.dart';
import '../widgets/reference_thumbnail_stub.dart'
    if (dart.library.io) '../widgets/reference_thumbnail_io.dart';

class PilgrimageMapScreen extends StatefulWidget {
  const PilgrimageMapScreen({
    required this.controller,
    required this.settings,
    this.anitabiClient,
    this.onStartSearch,
    this.isActive = true,
    this.focusRequest,
    this.onActivatePlan,
    super.key,
  });

  final PilgrimagePlanController controller;
  final AppSettings settings;
  final AnitabiClient? anitabiClient;

  /// Opens the unified in-app search (on the Explore tab) from the top search
  /// bar. When null the search bar is hidden.
  final VoidCallback? onStartSearch;

  /// Whether the map tab is currently visible. The map lives in an
  /// [IndexedStack], so it uses this to reload the other plans' points when it
  /// comes back into view (e.g. after importing a work in Explore).
  final bool isActive;

  /// Isolates one work on the map (Explore → "我的作品" / "在地图查看").
  final ValueListenable<MapFocusRequest?>? focusRequest;

  /// Makes [planId] the active plan. The map shows points of *all* plans, but
  /// camera / complete / detail flows still operate on the active plan's
  /// controller, so acting on another plan's point switches to it first.
  final Future<void> Function(String planId)? onActivatePlan;

  @override
  State<PilgrimageMapScreen> createState() => _PilgrimageMapScreenState();
}

class _PilgrimageMapScreenState extends State<PilgrimageMapScreen>
    with WidgetsBindingObserver {
  static const Duration _thumbnailBoundsDebounceDuration = Duration(
    milliseconds: 180,
  );

  final MapController _mapController = MapController();
  final MapNavigationLauncher _navigationLauncher =
      const MapNavigationLauncher();

  LatLng? _currentLocation;
  bool _isLocating = false;
  bool _showThumbnailMarkers = false;
  bool _showRecommendedRoutes = false;
  int _selectedGroupIndex = 0;
  final ValueNotifier<MapThumbnailViewport?> _visibleBoundsNotifier =
      ValueNotifier(null);
  Timer? _thumbnailBoundsDebounce;
  late final ImageLoadLimiter _thumbnailLoadLimiter = ImageLoadLimiter(
    widget.settings.mapThumbnailConcurrentLoads,
  );

  late final GpsTrackRecorder _gpsRecorder;

  /// 当前暂停是否由「App 切到后台」触发。回到前台时只自动恢复这类暂停，
  /// 用户手动暂停的保持暂停状态。
  bool _gpsAutoPausedByLifecycle = false;

  /// 录制中的秒级计时器，用于刷新时长显示。
  Timer? _gpsTicker;

  PilgrimagePlanController get _controller => widget.controller;

  /// Tracks the plan currently framed by the map so we can recenter when the
  /// active plan changes (e.g. switching away from the sample Uji plan).
  String? _lastCenteredPlanId;

  // --- Multi-plan aggregation -------------------------------------------
  //
  // Imported works each live in their own plan, but the map shows every
  // plan's points at once. The active plan is always read live from the
  // controller; the other plans come from [_snapshotPlans].

  /// All plans as last loaded from the repository (null until first load).
  List<PilgrimagePlan>? _snapshotPlans;
  List<PilgrimagePlan> _plans = const [];
  Map<String, PilgrimagePlan> _plansById = const {};
  List<MapPointEntry> _entries = const [];
  List<MapSpot> _spots = const [];
  PilgrimagePlan? _aggregatedPlan;
  List<PilgrimagePlan>? _aggregatedSnapshot;

  /// Works the user un-ticked. Empty = every work is wanted (the default), so
  /// newly imported works show up automatically.
  Set<String> _deselectedWorkKeys = <String>{};

  /// When true, un-ticked works are hidden instead of dimmed.
  bool _hideUnselected = false;

  /// Point the user last tapped (any plan). Identifies the selected spot.
  String? _selectedPointId;

  /// Plan whose groups the (single-work) group filter currently refers to.
  String? _groupPlanId;

  // --- Nearby Anime Pilgrimage Radar -----------------------------------
  late final AnitabiClient _anitabiClient =
      widget.anitabiClient ?? AnitabiClient();
  final NearbyRadarService _radarService = const NearbyRadarService();
  bool _radarActive = false;
  bool _isRadarScanning = false;
  LatLng? _lastRadarScanCenter;
  List<NearbyRadarSpot> _radarSpots = const [];
  NearbyRadarSpot? _selectedRadarSpot;
  bool _showRadarRescan = false;

  @override
  void initState() {
    super.initState();
    _lastCenteredPlanId = _controller.plan.id;
    _controller.addListener(_handleControllerChanged);
    widget.focusRequest?.addListener(_handleFocusRequest);
    _gpsRecorder = GpsTrackRecorder(
      store: _createGpsTrackStore(),
      streamFactory: () => gpsFixStream(
        distanceFilterMeters: kGpsTrackMinDistanceMeters.round(),
      ),
    );
    WidgetsBinding.instance.addObserver(this);
    unawaited(_loadSnapshot());
    // A request published before the map mounted (cold jump from Explore).
    if (widget.focusRequest?.value != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _handleFocusRequest();
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant PilgrimageMapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings.mapThumbnailConcurrentLoads !=
        widget.settings.mapThumbnailConcurrentLoads) {
      _thumbnailLoadLimiter.maxConcurrent =
          widget.settings.mapThumbnailConcurrentLoads;
    }
    if (!identical(oldWidget.focusRequest, widget.focusRequest)) {
      oldWidget.focusRequest?.removeListener(_handleFocusRequest);
      widget.focusRequest?.addListener(_handleFocusRequest);
    }
    if (!identical(oldWidget.controller, widget.controller)) {
      oldWidget.controller.removeListener(_handleControllerChanged);
      widget.controller.addListener(_handleControllerChanged);
      _lastCenteredPlanId = widget.controller.plan.id;
      _selectedGroupIndex = 0;
      unawaited(_loadSnapshot());
    }
    if (widget.isActive && !oldWidget.isActive) {
      // Other plans may have changed (import / edit) while the tab was hidden.
      unawaited(_loadSnapshot());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.removeListener(_handleControllerChanged);
    widget.focusRequest?.removeListener(_handleFocusRequest);
    _thumbnailBoundsDebounce?.cancel();
    _visibleBoundsNotifier.dispose();
    _gpsTicker?.cancel();
    _gpsRecorder.dispose();
    super.dispose();
  }

  /// GPS 轨迹落到业务库；拿不到数据库连接的平台退化为内存存储。
  GpsTrackStore _createGpsTrackStore() {
    final repository = _controller.repository;
    if (repository is SqlitePilgrimageRepository) {
      return GpsTrackRepository(database: repository.database);
    }
    return InMemoryGpsTrackStore();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // 仅前台记录：切到后台时暂停定位，回到前台再自动续上。
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      if (_gpsRecorder.isRecording) {
        _gpsAutoPausedByLifecycle = true;
        unawaited(_gpsRecorder.pause());
      }
      return;
    }
    if (state == AppLifecycleState.resumed &&
        _gpsAutoPausedByLifecycle &&
        _gpsRecorder.isPaused) {
      _gpsAutoPausedByLifecycle = false;
      unawaited(_gpsRecorder.resume());
    }
  }

  Future<void> _toggleGpsTrack() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_gpsRecorder.isActive) {
      final denial = await ensureGpsTrackPermission();
      if (denial != null) {
        _showSnackBar(_gpsDenialMessage(l10n, denial));
        return;
      }
      await _gpsRecorder.start(
        planId: _controller.plan.id,
        title: _controller.plan.name,
      );
      _syncGpsTicker();
      return;
    }
    if (_gpsRecorder.isPaused) {
      await _gpsRecorder.resume();
    } else {
      await _gpsRecorder.pause();
    }
    _syncGpsTicker();
  }

  /// 结束录制并提示保存结果。
  Future<void> _stopGpsTrack() async {
    final finished = await _gpsRecorder.stop();
    _syncGpsTicker();
    if (finished == null) {
      return;
    }
    _showSnackBar(
      AppLocalizations.of(context)!.gpsTrackSaved(
        '${finished.pointCount}',
        _formatTrackDistance(finished.distanceMeters),
      ),
    );
  }

  /// 录制中每秒触发一次 [GpsTrackRecorder.tick]，让时长显示走字。
  void _syncGpsTicker() {
    final shouldRun = _gpsRecorder.isRecording;
    if (shouldRun && _gpsTicker == null) {
      _gpsTicker = Timer.periodic(
        const Duration(seconds: 1),
        (_) => _gpsRecorder.tick(),
      );
    } else if (!shouldRun && _gpsTicker != null) {
      _gpsTicker?.cancel();
      _gpsTicker = null;
    }
  }

  String _gpsDenialMessage(AppLocalizations l10n, String denialKey) {
    return switch (denialKey) {
      'gpsLocationServiceDisabled' => l10n.gpsLocationServiceDisabled,
      'gpsPermissionDeniedForever' => l10n.gpsPermissionDeniedForever,
      _ => l10n.gpsPermissionDenied,
    };
  }

  String _formatTrackDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    }
    return '${(meters / 1000).toStringAsFixed(2)} km';
  }

  String _formatTrackDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  /// The map no longer reframes when the active plan changes: every plan is
  /// already on screen, and acting on another plan's point switches the active
  /// plan as a side effect that must not move the camera. The other plans'
  /// snapshot is refreshed instead, so the plan we just left reflects any
  /// progress made while it was live.
  void _handleControllerChanged() {
    final currentPlanId = _controller.plan.id;
    if (currentPlanId == _lastCenteredPlanId) {
      return;
    }
    _lastCenteredPlanId = currentPlanId;
    _selectedGroupIndex = 0;
    unawaited(_loadSnapshot());
  }

  Future<void> _loadSnapshot() async {
    final repository = _controller.repository;
    if (repository == null) {
      return;
    }
    try {
      final plans = await repository.loadPlans();
      if (!mounted) {
        return;
      }
      setState(() => _snapshotPlans = plans);
      _frameInitialPoints();
    } catch (_) {
      // Keep whatever we had; the active plan is still shown from the
      // controller.
    }
  }

  bool _framedInitialPoints = false;

  /// First time we have data from several plans, fit the camera so the user
  /// sees all of their points rather than just the active plan's corner.
  void _frameInitialPoints() {
    _rebuildAggregateIfNeeded();
    if (_framedInitialPoints || _entries.length < 2) {
      return;
    }
    _framedInitialPoints = true;
    _fitToEntries(_entries);
  }

  void _fitToEntries(List<MapPointEntry> entries) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || entries.isEmpty) {
        return;
      }
      final positions = entries
          .map((entry) => entry.point.position)
          .toList(growable: false);
      try {
        if (positions.length == 1) {
          _mapController.move(positions.first, 15);
          return;
        }
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: LatLngBounds.fromPoints(positions),
            padding: const EdgeInsets.all(56),
            maxZoom: 16,
          ),
        );
      } catch (_) {
        // The map may not be attached yet.
      }
    });
  }

  /// Explore → "我的作品" / "在地图查看": isolate that work and frame it.
  void _handleFocusRequest() {
    final request = widget.focusRequest?.value;
    if (request == null) {
      return;
    }
    _rebuildAggregateIfNeeded();
    final workKeys = {for (final entry in _entries) entry.workKey};
    if (!workKeys.contains(request.workKey)) {
      // Not loaded yet (just imported): refresh, then retry once.
      unawaited(
        _loadSnapshot().then((_) {
          if (mounted && widget.focusRequest?.value == request) {
            _applyFocus(request.workKey);
          }
        }),
      );
      return;
    }
    _applyFocus(request.workKey);
  }

  void _applyFocus(String workKey) {
    _rebuildAggregateIfNeeded();
    final workEntries = _entries
        .where((entry) => entry.workKey == workKey)
        .toList(growable: false);
    if (workEntries.isEmpty) {
      return;
    }
    setState(() {
      _deselectedWorkKeys = {
        for (final entry in _entries)
          if (entry.workKey != workKey) entry.workKey,
      };
      _selectedPointId = null;
    });
    _fitToEntries(workEntries);
  }

  void _rebuildAggregateIfNeeded() {
    if (_aggregatedPlan != null &&
        identical(_aggregatedPlan, _controller.plan) &&
        identical(_aggregatedSnapshot, _snapshotPlans)) {
      return;
    }
    final active = _controller.plan;
    _plans = [
      active,
      for (final plan in _snapshotPlans ?? const <PilgrimagePlan>[])
        if (plan.id != active.id) plan,
    ];
    _plansById = {for (final plan in _plans) plan.id: plan};
    _entries = flattenPlanPoints(_plans);
    _spots = clusterSpots(_entries);
    _aggregatedPlan = active;
    _aggregatedSnapshot = _snapshotPlans;
  }

  VisitStatus _statusOf(MapPointEntry entry) {
    if (entry.planId == _controller.plan.id) {
      return _controller.statusFor(entry.point);
    }
    final plan = _plansById[entry.planId];
    if (plan == null) {
      return VisitStatus.pending;
    }
    if (plan.completedPointIds.contains(entry.point.id)) {
      return VisitStatus.completed;
    }
    if (plan.currentPointId == entry.point.id) {
      return VisitStatus.current;
    }
    return VisitStatus.pending;
  }

  Set<String> _completedIdsOf(PilgrimagePlan plan) {
    return plan.id == _controller.plan.id
        ? _controller.completedPointIds
        : plan.completedPointIds;
  }

  bool _isWorkSelected(String workKey) =>
      !_deselectedWorkKeys.contains(workKey);

  /// Ticks / un-ticks a work as "want to go".
  void _toggleWork(String workKey) {
    setState(() {
      if (!_deselectedWorkKeys.remove(workKey)) {
        _deselectedWorkKeys.add(workKey);
      }
    });
  }

  /// Makes sure [entry]'s plan is the controller's active plan before running
  /// a flow that is bound to the controller (camera, complete, detail…).
  Future<bool> _ensureActive(MapPointEntry entry) async {
    if (entry.planId == _controller.plan.id) {
      return true;
    }
    final activate = widget.onActivatePlan;
    if (activate == null) {
      return false;
    }
    await activate(entry.planId);
    if (!mounted || _controller.plan.id != entry.planId) {
      return false;
    }
    // Visit records are loaded lazily after a plan swap; make sure the detail
    // sheet / counters see them.
    await _controller.loadVisitRecords();
    return mounted && _controller.plan.id == entry.planId;
  }

  List<MapWorkSummary> _workSummaries() {
    final order = <String>[];
    final works = <String, PilgrimageWork>{};
    final totals = <String, int>{};
    final dones = <String, int>{};
    for (final entry in _entries) {
      final key = entry.workKey;
      if (!works.containsKey(key)) {
        order.add(key);
        works[key] = entry.point.work;
      }
      totals[key] = (totals[key] ?? 0) + 1;
      if (_statusOf(entry) == VisitStatus.completed) {
        dones[key] = (dones[key] ?? 0) + 1;
      }
    }
    return [
      for (final key in order)
        MapWorkSummary(
          key: key,
          work: works[key]!,
          total: totals[key]!,
          done: dones[key] ?? 0,
        ),
    ];
  }

  /// Builds one polyline per non-ungrouped group, connecting its points in
  /// [PilgrimagePoint.groupOrderIndex] order. Used to visualise a recommended
  /// (or manually arranged) route when [_showRecommendedRoutes] is on.
  List<Polyline> _routePolylines(List<PlanGroupBucket> groups) {
    final polylines = <Polyline>[];
    for (var index = 0; index < groups.length; index += 1) {
      final group = groups[index];
      if (group.isUngrouped || group.points.length < 2) {
        continue;
      }
      final ordered = sortPointsByPlanOrder(group.points);
      polylines.add(
        Polyline(
          points: ordered.map((point) => point.position).toList(growable: false),
          color: planGroupMapColorAt(index).withValues(alpha: 0.9),
          strokeWidth: 3.5,
          borderColor: Colors.white.withValues(alpha: 0.85),
          borderStrokeWidth: 1,
        ),
      );
    }
    return polylines;
  }

  /// Maps each point id to its 1-based position within its group's ordered
  /// route, so markers can render a sequence number badge.
  Map<String, int> _routeSequenceByPointId(List<PlanGroupBucket> groups) {
    final sequence = <String, int>{};
    for (final group in groups) {
      if (group.isUngrouped) {
        continue;
      }
      final ordered = sortPointsByPlanOrder(group.points);
      for (var index = 0; index < ordered.length; index += 1) {
        sequence[ordered[index].id] = index + 1;
      }
    }
    return sequence;
  }

  Future<void> _locateUser() async {
    setState(() {
      _isLocating = true;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        _showSnackBar(AppLocalizations.of(context)!.gpsDisabled);
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        _showSnackBar(AppLocalizations.of(context)!.gpsPermissionRequired);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );
      final location = LatLng(position.latitude, position.longitude);

      if (!mounted) {
        return;
      }

      setState(() {
        _currentLocation = location;
      });
      _mapController.move(location, 16);
    } on TimeoutException {
      if (!mounted) return;
      _showSnackBar(AppLocalizations.of(context)!.gpsTimeout);
    } catch (_) {
      if (!mounted) return;
      _showSnackBar(AppLocalizations.of(context)!.gpsFailed);
    } finally {
      if (mounted) {
        setState(() {
          _isLocating = false;
        });
      }
    }
  }

  Future<void> _openNavigation(PilgrimagePoint point) async {
    final app = widget.settings.navigationApp;
    final opened = await _navigationLauncher.openWalking(point, app);
    if (!opened) {
      if (!mounted) return;
      _showSnackBar(AppLocalizations.of(context)!.msgCannotOpenMapApp(app.label));
    }
  }

  /// Selects the tapped point (of any plan). The controller's own selection and
  /// the group filter are only synced when the point belongs to the active
  /// plan, since both are plan-scoped.
  void _selectEntry(MapPointEntry entry) {
    setState(() {
      _selectedPointId = entry.point.id;
      _selectedRadarSpot = null;
    });
    if (entry.planId == _controller.plan.id) {
      _selectPoint(entry.point);
    }
  }

  void _selectPoint(PilgrimagePoint point) {
    final groups = planGroupBuckets(
      context,
      _controller.plan,
      _controller.completedPointIds,
    );
    final groupIndex = groups.indexWhere((group) {
      if (point.groupId == null) {
        return group.isUngrouped;
      }
      return group.id == point.groupId;
    });
    setState(() {
      if (groupIndex >= 0) {
        _selectedGroupIndex = groupIndex;
      }
      _selectedPointId = point.id;
    });
    _controller.selectPoint(point);
  }

  void _centerPoint(PilgrimagePoint point) {
    _mapController.move(point.position, _mapController.camera.zoom);
  }

  void _setCurrentPoint(PilgrimagePoint point) {
    _controller.setCurrentPoint(point);
    _selectPoint(point);
    _centerPoint(point);
  }

  /// Taps on a marker: keep the current row when the spot is already
  /// selected, otherwise start at the spot's first visible work.
  void _selectSpot(List<MapPointEntry> visibleEntries) {
    final entry = visibleEntries.firstWhere(
      (candidate) => candidate.point.id == _selectedPointId,
      orElse: () => visibleEntries.first,
    );
    _selectEntry(entry);
  }

  void _selectGroup(int index, List<PlanGroupBucket> groups) {
    final nextIndex = index.clamp(0, groups.length - 1);
    final group = groups[nextIndex];
    setState(() {
      _selectedGroupIndex = nextIndex;
    });
    if (group.points.isNotEmpty) {
      _mapController.move(groupMapCenter(group), 15);
    }
  }

  void _handleMapEvent(MapEvent event) {
    if (_radarActive && _lastRadarScanCenter != null) {
      if (event is MapEventMoveEnd ||
          event is MapEventFlingAnimationEnd ||
          event is MapEventFlingAnimationNotStarted ||
          event is MapEventDoubleTapZoomEnd) {
        const distance = Distance();
        final center = event.camera.center;
        final d = distance.as(LengthUnit.Meter, _lastRadarScanCenter!, center);
        final shouldShowRescan = d > 1500;
        if (shouldShowRescan != _showRadarRescan) {
          setState(() => _showRadarRescan = shouldShowRescan);
        }
      }
    }

    if (!_showThumbnailMarkers) {
      return;
    }
    if (event is MapEventMoveStart ||
        event is MapEventFlingAnimationStart ||
        event is MapEventDoubleTapZoomStart) {
      _thumbnailBoundsDebounce?.cancel();
      return;
    }

    if (event is MapEventMoveEnd ||
        event is MapEventFlingAnimationEnd ||
        event is MapEventFlingAnimationNotStarted ||
        event is MapEventDoubleTapZoomEnd) {
      _setThumbnailVisibleBounds(event.camera);
      return;
    }

    if (event is MapEventMove && event.source == MapEventSource.mapController) {
      _scheduleThumbnailVisibleBoundsRefresh();
      return;
    }

    if (event is MapEventScrollWheelZoom) {
      _scheduleThumbnailVisibleBoundsRefresh();
    }
  }

  void _scheduleThumbnailVisibleBoundsRefresh() {
    _thumbnailBoundsDebounce?.cancel();
    _thumbnailBoundsDebounce = Timer(_thumbnailBoundsDebounceDuration, () {
      if (!mounted || !_showThumbnailMarkers) {
        return;
      }
      try {
        _setThumbnailVisibleBounds(_mapController.camera);
      } catch (_) {
        // The controller may briefly be unavailable while the map mounts.
      }
    });
  }

  void _setThumbnailVisibleBounds(MapCamera camera) {
    _thumbnailBoundsDebounce?.cancel();
    if (!mounted || !_showThumbnailMarkers) {
      return;
    }
    _visibleBoundsNotifier.value = MapThumbnailViewport(
      bounds: camera.visibleBounds,
      center: camera.center,
    );
  }

  Set<String> _thumbnailPointIdsForCurrentView(
    Iterable<PilgrimagePoint> points,
    MapThumbnailViewport? viewport,
  ) {
    if (!_showThumbnailMarkers) {
      return const <String>{};
    }
    final threshold = widget.settings.mapThumbnailVisibleThreshold.clamp(
      0,
      200,
    );
    if (threshold <= 0) {
      return const <String>{};
    }
    final visiblePoints = viewport == null
        ? points.toList(growable: false)
        : points
              .where((point) => viewport.bounds.contains(point.position))
              .toList(growable: false);
    if (viewport == null) {
      // 首个相机事件之前拿不到视图中心，退化为旧的「全有或全无」。
      return visiblePoints.length > threshold
          ? const <String>{}
          : visiblePoints.map((point) => point.id).toSet();
    }
    // 密集区不再整体关闭缩略图：按距视图中心由近到远保留 threshold 个。
    return selectNearestThumbnailIds(
      items: visiblePoints,
      positionOf: (point) => point.position,
      idOf: (point) => point.id,
      center: viewport.center,
      threshold: threshold,
    );
  }

  void _moveToCurrentTarget() {
    final currentPoint = _controller.currentPoint;
    if (currentPoint == null) {
      _showSnackBar(AppLocalizations.of(context)!.mapNoPointsSnackBar);
      return;
    }

    _selectPoint(currentPoint);
    _centerPoint(currentPoint);
  }

  Future<void> _openCameraForEntry(MapPointEntry entry) async {
    if (await _ensureActive(entry)) {
      _openCamera(entry.point);
    }
  }

  Future<void> _showPointDetailForEntry(MapPointEntry entry) async {
    if (await _ensureActive(entry)) {
      _showPointDetail(entry.point);
    }
  }

  Future<void> _toggleCompleteForEntry(MapPointEntry entry) async {
    if (!await _ensureActive(entry)) {
      return;
    }
    final point = entry.point;
    if (_controller.statusFor(point) == VisitStatus.completed) {
      _controller.reopenPoint(point);
    } else {
      _controller.completePoint(point);
    }
  }

  Future<void> _setCurrentForEntry(MapPointEntry entry) async {
    if (await _ensureActive(entry)) {
      _setCurrentPoint(entry.point);
    }
  }

  void _openCamera(PilgrimagePoint point) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CamerawesomeReferenceScreen(
          point: point,
          controller: _controller,
          settings: widget.settings,
        ),
      ),
    );
  }

  void _showPointDetail(PilgrimagePoint point) {
    PointDetailSheet.show(
      context,
      point: point,
      status: _controller.statusFor(point),
      onSetCurrent: () => _setCurrentPoint(point),
      onOpenCamera: () => _openCamera(point),
      onComplete: () => _controller.statusFor(point) == VisitStatus.completed
          ? _controller.reopenPoint(point)
          : _controller.completePoint(point),
      onReplaceReference: (point, image) => _controller.updatePoint(
        point.copyWith(
          referenceImageUrl: null,
          referenceThumbnailPath: image.thumbnailPath,
          referenceFullImagePath: image.fullImagePath,
        ),
      ),
      groups: _controller.plan.groups,
      onMoveToGroup: _controller.movePointToGroup,
      records: _controller.recordsForPoint(point.id),
      onOpenRecords: () => _openPointRecords(point),
      onOpenRecord: _openRecordDetail,
      onEditPoint: () => _editPoint(point),
      navigationApp: widget.settings.navigationApp,
      repository: _controller.repository,
      planId: _controller.plan.id,
    );
  }

  Future<void> _editPoint(PilgrimagePoint point) async {
    final repository = _controller.repository;
    if (repository == null) {
      _showSnackBar(AppLocalizations.of(context)!.labelEditPointNotSupported);
      return;
    }
    final updated = await EditPointScreen.open(
      context,
      plan: _controller.plan,
      repository: repository,
      point: point,
    );
    if (updated != true || !mounted) {
      return;
    }
    final updatedPlan = await repository.loadActivePlan();
    if (!mounted) {
      return;
    }
    _controller.replacePlan(updatedPlan);
  }

  void _openPointRecords(PilgrimagePoint point) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PointVisitRecordsScreen(
          point: point,
          controller: _controller,
          settings: widget.settings,
        ),
      ),
    );
  }

  void _openRecordDetail(PilgrimageVisitRecord record) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VisitRecordDetailScreen(
          record: record,
          point: _controller.pointById(record.pointId),
          controller: _controller,
          settings: widget.settings,
          onDelete: () => _controller.deleteVisitRecord(record),
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showReplacingSnackBar(SnackBar(content: Text(message)));
  }

  // --- Nearby Anime Pilgrimage Radar methods --------------------------

  LatLng _resolveCurrentMapCenter() {
    try {
      return _mapController.camera.center;
    } catch (_) {
      return _fallbackCenter;
    }
  }

  Future<void> _scanRadar(LatLng center) async {
    setState(() {
      _radarActive = true;
      _isRadarScanning = true;
      _lastRadarScanCenter = center;
      _showRadarRescan = false;
    });

    try {
      final catalogWorks = await _anitabiClient.listWorks();
      _rebuildAggregateIfNeeded();
      final importedBangumiIds = <int>{
        for (final plan in _plans)
          for (final point in plan.points)
            if (point.work.bangumiId != null) point.work.bangumiId!,
      };

      final spots = _radarService.scanNearby(
        center: center,
        catalogWorks: catalogWorks,
        importedBangumiIds: importedBangumiIds,
      );

      if (!mounted) return;
      setState(() {
        _isRadarScanning = false;
        _radarSpots = spots;
      });

      final l10n = AppLocalizations.of(context);
      if (l10n != null) {
        _showSnackBar(
          spots.isEmpty
              ? l10n.radarNoSpotsFound
              : l10n.radarFoundCount(spots.length),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isRadarScanning = false);
      }
    }
  }

  void _toggleRadar() {
    if (_radarActive) {
      setState(() {
        _radarActive = false;
        _radarSpots = const [];
        _selectedRadarSpot = null;
        _showRadarRescan = false;
      });
    } else {
      final center = _currentLocation ?? _resolveCurrentMapCenter();
      unawaited(_scanRadar(center));
    }
  }

  void _selectRadarSpot(NearbyRadarSpot spot) {
    setState(() {
      _selectedRadarSpot = spot;
      _selectedPointId = null;
    });
    NearbyRadarSpotSheet.show(
      context,
      spot: spot,
      anitabiClient: _anitabiClient,
      navigationLauncher: _navigationLauncher,
      navigationApp: widget.settings.navigationApp,
      onImportWork: _importRadarWork,
      onViewInPlan: () => _viewRadarSpotInPlan(spot),
    );
  }

  Future<void> _importRadarWork(AnitabiMapWorkLite work) async {
    final repository = _controller.repository;
    if (repository == null) {
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    final importer = WorkImporter(anitabiClient: _anitabiClient);
    final item = ExploreWorkItem.fromAnitabi(work);

    _showSnackBar(l10n.exploreImporting);

    try {
      final newPlan = await repository.createPlan(
        name: l10n.planNameForWork(item.title),
        area: item.city ?? '',
      );

      final result = await importer.importWork(
        repository: repository,
        planId: newPlan.id,
        currentPlan: newPlan,
        item: item,
        autoPartition: true,
        fallbackAreaName: (index) => l10n.partitionGroupName(index + 1),
      );

      if (!mounted) return;

      if (widget.onActivatePlan != null) {
        await widget.onActivatePlan!(newPlan.id);
      }
      await _loadSnapshot();

      if (_lastRadarScanCenter != null) {
        unawaited(_scanRadar(_lastRadarScanCenter!));
      }

      _showSnackBar(l10n.radarImportSuccess(result.addedPointCount));
    } catch (e) {
      if (mounted) {
        _showSnackBar(e.toString());
      }
    }
  }

  void _viewRadarSpotInPlan(NearbyRadarSpot spot) {
    _rebuildAggregateIfNeeded();
    final entry = _entries
        .where(
          (e) =>
              e.point.work.bangumiId == spot.bangumiId &&
              (e.point.id == spot.pointId ||
                  e.point.id.endsWith(spot.pointId) ||
                  e.point.id.contains(spot.pointId)),
        )
        .firstOrNull;

    if (entry != null) {
      _selectPoint(entry.point);
      _centerPoint(entry.point);
    } else {
      final workEntry = _entries
          .where((e) => e.point.work.bangumiId == spot.bangumiId)
          .firstOrNull;
      if (workEntry != null) {
        _selectPoint(workEntry.point);
        _centerPoint(workEntry.point);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _rebuildAggregateIfNeeded();
    final summaries = _workSummaries();
    final selectedWorkCount = summaries
        .where((summary) => _isWorkSelected(summary.key))
        .length;
    final showWorkFilter = summaries.length > 1;

    // One display spot per physical location. Un-ticked works are dimmed (or
    // hidden); the spot holding the current selection always stays so the user
    // can re-tick a work they just un-ticked.
    final displayedSpots = <_DisplaySpot>[];
    for (final spot in _spots) {
      final selectedEntries = [
        for (final entry in spot.entries)
          if (_isWorkSelected(entry.workKey)) entry,
      ];
      final visible = _hideUnselected ? selectedEntries : spot.entries;
      final containsSelection =
          _selectedPointId != null &&
          spot.entries.any((entry) => entry.point.id == _selectedPointId);
      if (visible.isEmpty && !containsSelection) {
        continue;
      }
      displayedSpots.add(
        _DisplaySpot(
          spot: spot,
          visible: visible,
          highlighted: selectedEntries.isNotEmpty,
          representative: selectedEntries.firstOrNull ??
              visible.firstOrNull ??
              spot.entries.first,
        ),
      );
    }

    (_DisplaySpot, MapPointEntry)? findSelected() {
      final selectedId = _selectedPointId;
      if (selectedId == null) {
        return null;
      }
      for (final displaySpot in displayedSpots) {
        for (final entry in displaySpot.spot.entries) {
          if (entry.point.id == selectedId) {
            return (displaySpot, entry);
          }
        }
      }
      return null;
    }

    final selected = findSelected();
    final selectedDisplay = selected?.$1;
    final selectedEntry = selected?.$2;
    final mapSpots = selectedItemsLast<_DisplaySpot>(
      displayedSpots,
      isSelected: (displaySpot) => identical(displaySpot, selectedDisplay),
    );

    // Plan-scoped overlays (areas, routes, group filter) only make sense while
    // everything highlighted belongs to a single plan — always true for users
    // with one plan, and for a single isolated work.
    final highlightedPlanIds = {
      for (final entry in _entries)
        if (_isWorkSelected(entry.workKey)) entry.planId,
    };
    final groupPlan = highlightedPlanIds.length == 1
        ? _plansById[highlightedPlanIds.first]
        : null;
    final groups = groupPlan == null
        ? const <PlanGroupBucket>[]
        : planGroupBuckets(context, groupPlan, _completedIdsOf(groupPlan));
    if (groupPlan != null && _groupPlanId != groupPlan.id) {
      _groupPlanId = groupPlan.id;
      _selectedGroupIndex = 0;
    }
    if (_selectedGroupIndex >= groups.length) {
      _selectedGroupIndex = groups.isEmpty ? 0 : groups.length - 1;
    }
    final selectedGroup = groups.isEmpty ? null : groups[_selectedGroupIndex];
    final currentPoint =
        _controller.points.any(
          (point) => point.id == _controller.currentPoint?.id,
        )
        ? _controller.currentPoint
        : null;
    final initialFocusPoint = currentPoint ?? _controller.points.firstOrNull;
    final initialCenter =
        initialFocusPoint?.position ??
        (selectedGroup == null
            ? _fallbackCenter
            : groupMapCenter(selectedGroup));
    final selectedGroupId = selectedGroup?.id ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: 15,
              minZoom: 4,
              maxZoom: 24,
              onMapEvent: _handleMapEvent,
              keepAlive: true,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
            ),
            children: [
              configuredMapTileLayer(widget.settings),
              PolygonLayer(
                polygons: groupAreaPolygons(
                  groups,
                  selectedGroupId: selectedGroupId,
                ),
              ),
              if (_showRecommendedRoutes)
                PolylineLayer(
                  polylines: _routePolylines(groups),
                ),
              ListenableBuilder(
                listenable: _gpsRecorder,
                builder: (context, _) {
                  final samples = _gpsRecorder.samples;
                  if (samples.length < 2) {
                    return const SizedBox.shrink();
                  }
                  return PolylineLayer(
                    polylines: [
                      Polyline(
                        points: [
                          for (final sample in samples)
                            LatLng(sample.latitude, sample.longitude),
                        ],
                        color: Theme.of(context).colorScheme.primary,
                        strokeWidth: 4,
                      ),
                    ],
                  );
                },
              ),
              ValueListenableBuilder<MapThumbnailViewport?>(
                valueListenable: _visibleBoundsNotifier,
                builder: (context, visibleBounds, _) {
                  final thumbnailPointIds = _thumbnailPointIdsForCurrentView(
                    displayedSpots.map((spot) => spot.representative.point),
                    visibleBounds,
                  );
                  final sequenceByPointId = _showRecommendedRoutes
                      ? _routeSequenceByPointId(groups)
                      : const <String, int>{};
                  return MarkerLayer(
                    markers: [
                      for (final displaySpot in mapSpots)
                        () {
                          final entry = displaySpot.representative;
                          final point = entry.point;
                          final isSelected = displaySpot.spot.entries.any(
                            (candidate) => candidate.point.id == _selectedPointId,
                          );
                          final showThumbnail =
                              _showThumbnailMarkers &&
                              (isSelected ||
                                  thumbnailPointIds.contains(point.id));
                          final status = _spotStatus(displaySpot.markerEntries);
                          final markerColor = _markerColorFor(
                            entry,
                            groups,
                            groupPlanId: groupPlan?.id,
                          );
                          final marker = _showThumbnailMarkers
                              ? MapThumbnailMarker(
                                  key: ValueKey(
                                    'plan-map-thumbnail-marker-${point.id}',
                                  ),
                                  selected: isSelected,
                                  imported: status == VisitStatus.completed,
                                  showThumbnail: showThumbnail,
                                  markerColor: markerColor,
                                  imageLoadLimiter: _thumbnailLoadLimiter,
                                  localPath: point.referenceThumbnailPath,
                                  imageUrl: hasRemoteReferenceImage(point)
                                      ? point.referenceImageUrl
                                      : null,
                                  imageSource:
                                      widget.settings.anitabiImageSource,
                                  onTap: () => _selectSpot(displaySpot.markerEntries),
                                )
                              : _PointMarker(
                                  selected: isSelected,
                                  status: status,
                                  sequenceNumber: sequenceByPointId[point.id],
                                  color: markerColor,
                                  onTap: () => _selectSpot(displaySpot.markerEntries),
                                );
                          final badgeCount = displaySpot.visible.length;
                          Widget child = marker;
                          if (badgeCount > 1) {
                            child = Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Positioned.fill(child: marker),
                                Positioned(
                                  top: 0,
                                  right: showThumbnail ? 4 : 0,
                                  child: IgnorePointer(
                                    child: MapSpotCountBadge(count: badgeCount),
                                  ),
                                ),
                              ],
                            );
                          }
                          if (!displaySpot.highlighted && !isSelected) {
                            child = Opacity(opacity: 0.4, child: child);
                          }
                          return Marker(
                            key: ValueKey('plan-map-marker-${point.id}'),
                            point: displaySpot.spot.center,
                            width: _showThumbnailMarkers
                                ? (showThumbnail ? 84 : 24)
                                : 44,
                            height: _showThumbnailMarkers
                                ? (showThumbnail ? 82 : 24)
                                : 44,
                            alignment: _showThumbnailMarkers
                                ? (showThumbnail
                                      ? Alignment.topCenter
                                      : Alignment.center)
                                : Alignment.center,
                            child: child,
                          );
                        }(),
                      if (_currentLocation != null)
                        Marker(
                          point: _currentLocation!,
                          width: 44,
                          height: 44,
                          child: const _CurrentLocationMarker(),
                        ),
                    ],
                  );
                },
              ),
              if (_radarActive && _radarSpots.isNotEmpty)
                MarkerLayer(
                  markers: [
                    for (final spot in _radarSpots)
                      Marker(
                        key: ValueKey(
                          'radar-marker-${spot.bangumiId}-${spot.pointId}',
                        ),
                        point: spot.position,
                        width: _selectedRadarSpot == spot ? 42 : 36,
                        height: _selectedRadarSpot == spot ? 42 : 36,
                        child: NearbyRadarMarker(
                          spot: spot,
                          selected: _selectedRadarSpot == spot,
                          onTap: () => _selectRadarSpot(spot),
                        ),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.onStartSearch != null)
                    ExploreSearchBar(
                      hintText: AppLocalizations.of(context)!.exploreSearchHint,
                      onTap: widget.onStartSearch!,
                      padding: EdgeInsets.zero,
                    ),
                  if (showWorkFilter) ...[
                    if (widget.onStartSearch != null) const SizedBox(height: 8),
                    MapWorkFilterBar(
                      label: _workFilterLabel(
                        context,
                        summaries,
                        selectedWorkCount,
                      ),
                      onTap: () => _showWorkFilter(context, summaries),
                      onClear: selectedWorkCount == 1 ? _clearWorkFocus : null,
                    ),
                  ],
                  if (selectedGroup != null) ...[
                    if (widget.onStartSearch != null || showWorkFilter)
                      const SizedBox(height: 8),
                    _MapGroupFilterBar(
                      group: selectedGroup,
                      onTap: () => _showGroupPicker(context, groups),
                    ),
                  ],
                  if (_radarActive) ...[
                    if (widget.onStartSearch != null ||
                        showWorkFilter ||
                        selectedGroup != null)
                      const SizedBox(height: 8),
                    NearbyRadarBanner(
                      count: _radarSpots.length,
                      isScanning: _isRadarScanning,
                      showRescan: _showRadarRescan,
                      onRescan: () => _scanRadar(_resolveCurrentMapCenter()),
                      onClose: _toggleRadar,
                    ),
                  ],
                ],
              ),
            ),
          ),
          Positioned(
            right: 12,
            top: (widget.onStartSearch != null ? 140 : 76) +
                (showWorkFilter ? 46 : 0) +
                (_radarActive ? 46 : 0),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  if (widget.settings.gpsTrackEnabled)
                    ListenableBuilder(
                      listenable: _gpsRecorder,
                      builder: (context, _) {
                        if (!_gpsRecorder.isActive) {
                          return const SizedBox.shrink();
                        }
                        final l10n = AppLocalizations.of(context)!;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _GpsTrackStatsCard(
                            durationLabel: l10n.gpsTrackDuration(
                              _formatTrackDuration(_gpsRecorder.elapsed),
                            ),
                            distanceLabel: l10n.gpsTrackDistance(
                              _formatTrackDistance(_gpsRecorder.distanceMeters),
                            ),
                            countLabel: l10n.gpsTrackPointCount(
                              '${_gpsRecorder.pointCount}',
                            ),
                            statusLabel: _gpsRecorder.isPaused
                                ? l10n.gpsTrackPaused
                                : l10n.gpsTrackRecording,
                            paused: _gpsRecorder.isPaused,
                          ),
                        );
                      },
                    ),
                  _MapFloatingIconButton(
                    tooltip: AppLocalizations.of(context)!.tooltipLocation,
                    onTap: _isLocating ? null : _locateUser,
                    child: _isLocating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location, size: 20),
                  ),
                  const SizedBox(height: 8),
                  _MapFloatingIconButton(
                    tooltip: AppLocalizations.of(context)!.radarTooltip,
                    selected: _radarActive,
                    onTap: _toggleRadar,
                    child: _isRadarScanning
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            _radarActive ? Icons.radar : Icons.radar_outlined,
                            size: 20,
                          ),
                  ),
                  const SizedBox(height: 8),
                  _MapFloatingIconButton(
                    tooltip: AppLocalizations.of(context)!.tooltipGoToTarget,
                    onTap: _moveToCurrentTarget,
                    child: const Icon(Icons.flag_outlined, size: 20),
                  ),
                  const SizedBox(height: 8),
                  _MapFloatingIconButton(
                    tooltip: _showThumbnailMarkers ? AppLocalizations.of(context)!.tooltipUseIconMarkers : AppLocalizations.of(context)!.tooltipShowThumbnailMarkers,
                    selected: _showThumbnailMarkers,
                    onTap: () {
                      setState(() {
                        _showThumbnailMarkers = !_showThumbnailMarkers;
                        if (!_showThumbnailMarkers) {
                          _thumbnailBoundsDebounce?.cancel();
                          _visibleBoundsNotifier.value = null;
                        } else {
                          try {
                            final camera = _mapController.camera;
                            _visibleBoundsNotifier.value = MapThumbnailViewport(
                              bounds: camera.visibleBounds,
                              center: camera.center,
                            );
                          } catch (_) {
                            _visibleBoundsNotifier.value = null;
                          }
                        }
                      });
                    },
                    child: Icon(
                      _showThumbnailMarkers
                          ? Icons.location_on_outlined
                          : Icons.image_outlined,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _MapFloatingIconButton(
                    tooltip: AppLocalizations.of(context)!
                        .tooltipShowRecommendedRoutes,
                    selected: _showRecommendedRoutes,
                    onTap: () {
                      setState(() {
                        _showRecommendedRoutes = !_showRecommendedRoutes;
                      });
                    },
                    child: Icon(
                      _showRecommendedRoutes
                          ? Icons.route
                          : Icons.route_outlined,
                      size: 20,
                    ),
                  ),
                  if (widget.settings.gpsTrackEnabled) ...[
                    const SizedBox(height: 8),
                    ListenableBuilder(
                      listenable: _gpsRecorder,
                      builder: (context, _) {
                        final l10n = AppLocalizations.of(context)!;
                        final active = _gpsRecorder.isActive;
                        final paused = _gpsRecorder.isPaused;
                        return _MapFloatingIconButton(
                          tooltip: !active
                              ? l10n.gpsTrackTooltipStart
                              : paused
                                    ? l10n.gpsTrackTooltipResume
                                    : l10n.gpsTrackTooltipPause,
                          selected: active,
                          onTap: _toggleGpsTrack,
                          child: Icon(
                            active && !paused ? Icons.pause : Icons.play_arrow,
                            size: 20,
                          ),
                        );
                      },
                    ),
                    ListenableBuilder(
                      listenable: _gpsRecorder,
                      builder: (context, _) {
                        if (!_gpsRecorder.isActive) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: _MapFloatingIconButton(
                            tooltip: AppLocalizations.of(context)!
                                .gpsTrackTooltipStop,
                            onTap: _stopGpsTrack,
                            child: const Icon(Icons.stop, size: 20),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _entries.isEmpty
                ? const _EmptyMapCard()
                : selectedDisplay == null || selectedEntry == null
                ? const SizedBox.shrink()
                : selectedDisplay.spot.isShared
                ? MapSpotPanel(
                    rows: [
                      for (final entry in selectedDisplay.spot.entries)
                        MapSpotRow(
                          entry: entry,
                          status: _statusOf(entry),
                          selected: _isWorkSelected(entry.workKey),
                        ),
                    ],
                    onToggleWork: _toggleWork,
                    onNavigate: () => _openNavigation(selectedEntry.point),
                    onOpenDetail: _showPointDetailForEntry,
                    onOpenCamera: _openCameraForEntry,
                  )
                : _PointCard(
                    planId: selectedEntry.planId,
                    repository: _controller.repository,
                    onPlanUpdated: _handleThumbnailPlanUpdated,
                    point: selectedEntry.point,
                    status: _statusOf(selectedEntry),
                    recordCount: selectedEntry.planId == _controller.plan.id
                        ? _controller
                              .recordsForPoint(selectedEntry.point.id)
                              .length
                        : 0,
                    onSetCurrent: () => _setCurrentForEntry(selectedEntry),
                    onOpenDetail: () => _showPointDetailForEntry(selectedEntry),
                    onOpenNavigation: () => _openNavigation(selectedEntry.point),
                    onOpenCamera: () => _openCameraForEntry(selectedEntry),
                    onComplete: () => _toggleCompleteForEntry(selectedEntry),
                  ),
          ),
        ],
      ),
    );
  }

  LatLng get _fallbackCenter {
    return const LatLng(34.9671, 135.7727);
  }

  /// Marker status for a location: completed only when every visible work is,
  /// "current" if any of them is the plan's current target.
  VisitStatus _spotStatus(List<MapPointEntry> entries) {
    var allCompleted = true;
    for (final entry in entries) {
      final status = _statusOf(entry);
      if (status == VisitStatus.current) {
        return VisitStatus.current;
      }
      if (status != VisitStatus.completed) {
        allCompleted = false;
      }
    }
    return allCompleted && entries.isNotEmpty
        ? VisitStatus.completed
        : VisitStatus.pending;
  }

  /// Group colour while a single plan is shown (as before), otherwise one
  /// colour per work so overlapping works can be told apart.
  Color _markerColorFor(
    MapPointEntry entry,
    List<PlanGroupBucket> groups, {
    required String? groupPlanId,
  }) {
    if (groupPlanId != null &&
        entry.planId == groupPlanId &&
        groups.isNotEmpty) {
      return mapColorForPoint(entry.point, groups);
    }
    return mapColorForWorkKey(entry.workKey);
  }

  String _workFilterLabel(
    BuildContext context,
    List<MapWorkSummary> summaries,
    int selectedCount,
  ) {
    final l10n = AppLocalizations.of(context)!;
    if (selectedCount == summaries.length) {
      return l10n.mapWorkFilterAllLabel(summaries.length);
    }
    if (selectedCount == 1) {
      final only = summaries.firstWhere(
        (summary) => _isWorkSelected(summary.key),
      );
      return l10n.mapFocusBanner(only.work.title);
    }
    return l10n.mapWorkFilterSelectedLabel(selectedCount, summaries.length);
  }

  void _showWorkFilter(BuildContext context, List<MapWorkSummary> summaries) {
    showMapWorkFilterSheet(
      context,
      works: summaries,
      deselected: _deselectedWorkKeys,
      hideUnselected: _hideUnselected,
      onChanged: (deselected, hideUnselected) {
        if (!mounted) {
          return;
        }
        setState(() {
          _deselectedWorkKeys = deselected;
          _hideUnselected = hideUnselected;
        });
      },
    );
  }

  /// Leaves single-work focus and frames everything again.
  void _clearWorkFocus() {
    setState(() => _deselectedWorkKeys = <String>{});
    _fitToEntries(_entries);
  }

  /// A reference thumbnail finished caching for [plan]. Only the active plan
  /// lives in the controller; for others just refresh the snapshot.
  void _handleThumbnailPlanUpdated(PilgrimagePlan plan) {
    if (plan.id == _controller.plan.id) {
      _controller.replacePlan(plan);
    } else {
      unawaited(_loadSnapshot());
    }
  }

  void _showGroupPicker(BuildContext context, List<PlanGroupBucket> groups) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            itemCount: groups.length,
            separatorBuilder: (_, _) => const SizedBox(height: 6),
            itemBuilder: (context, index) {
              final group = groups[index];
              return Material(
                color: Colors.transparent,
                child: ListTile(
                  selected: index == _selectedGroupIndex,
                  selectedTileColor: AppColors.accent.withValues(alpha: 0.12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  leading: Icon(
                    group.isUngrouped
                        ? Icons.inventory_2_outlined
                        : Icons.folder_outlined,
                  ),
                  title: Text(group.name),
                  subtitle: Text(group.anchorLabel(context)),
                  trailing: Text(
                    '${group.completedCount} / ${group.points.length}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _selectGroup(index, groups);
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// A [MapSpot] as currently shown: which of its works are visible, and which
/// one represents it on the map.
class _DisplaySpot {
  const _DisplaySpot({
    required this.spot,
    required this.visible,
    required this.highlighted,
    required this.representative,
  });

  final MapSpot spot;

  /// Works shown at this spot (all of them, or only the ticked ones when
  /// "hide unchecked" is on).
  final List<MapPointEntry> visible;

  /// Whether at least one work here is ticked ("want to go").
  final bool highlighted;

  final MapPointEntry representative;

  /// Entries a tap should choose from; falls back to every work when the spot
  /// is only on screen because it holds the current selection.
  List<MapPointEntry> get markerEntries =>
      visible.isEmpty ? spot.entries : visible;
}

class _MapGroupFilterBar extends StatelessWidget {
  const _MapGroupFilterBar({required this.group, required this.onTap});

  final PlanGroupBucket group;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
              const Icon(Icons.folder_outlined, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${group.name} · ${group.completedCount}/${group.points.length}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ),
              const Icon(Icons.expand_more, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapFloatingIconButton extends StatelessWidget {
  const _MapFloatingIconButton({
    required this.tooltip,
    required this.onTap,
    required this.child,
    this.selected = false,
  });

  final String tooltip;
  final VoidCallback? onTap;
  final Widget child;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: selected
            ? AppColors.accent.withValues(alpha: 0.95)
            : AppColors.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: IconTheme(
            data: IconThemeData(
              color: selected ? AppColors.onAccent : AppColors.textPrimary,
            ),
            child: SizedBox(width: 38, height: 38, child: Center(child: child)),
          ),
        ),
      ),
    );
  }
}

class _PointMarker extends StatelessWidget {
  const _PointMarker({
    required this.selected,
    required this.status,
    required this.onTap,
    this.sequenceNumber,
    this.color,
  });

  final bool selected;
  final VisitStatus status;
  final VoidCallback onTap;
  final int? sequenceNumber;

  /// Work colour used when several works share the map; null keeps the theme
  /// accent.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final markerColors = switch (status) {
      VisitStatus.current => (color ?? AppColors.accent, Colors.white),
      VisitStatus.completed => (
        AppColors.surfaceMuted,
        AppColors.textSecondary,
      ),
      VisitStatus.pending => (AppColors.surface, color ?? AppColors.accentDark),
    };

    if (sequenceNumber != null) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: markerColors.$1,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? AppColors.warning : Colors.white,
              width: selected ? 3 : 2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            '$sequenceNumber',
            style: TextStyle(
              color: markerColors.$2,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
    }

    return IconButton(
      tooltip: AppLocalizations.of(context)!.tooltipPoint,
      onPressed: onTap,
      style: IconButton.styleFrom(
        backgroundColor: markerColors.$1,
        foregroundColor: markerColors.$2,
        side: BorderSide(
          color: selected
              ? AppColors.warning
              : (status == VisitStatus.pending && color != null
                    ? color!
                    : AppColors.border),
          width: selected ? 2 : 1,
        ),
      ),
      icon: Icon(
        status == VisitStatus.completed ? Icons.check : Icons.place,
        size: 24,
      ),
    );
  }
}

class _CurrentLocationMarker extends StatelessWidget {
  const _CurrentLocationMarker();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: AppColors.accent,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
        ),
      ),
    );
  }
}

class _PointCard extends StatelessWidget {
  const _PointCard({
    required this.planId,
    required this.repository,
    required this.onPlanUpdated,
    required this.point,
    required this.status,
    required this.recordCount,
    required this.onSetCurrent,
    required this.onOpenDetail,
    required this.onOpenNavigation,
    required this.onOpenCamera,
    required this.onComplete,
  });

  final String planId;
  final PilgrimageRepository? repository;
  final ValueChanged<PilgrimagePlan> onPlanUpdated;
  final PilgrimagePoint point;
  final VisitStatus status;
  final int recordCount;
  final VoidCallback onSetCurrent;
  final VoidCallback onOpenDetail;
  final VoidCallback onOpenNavigation;
  final VoidCallback onOpenCamera;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomInset),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PointThumbnail(
                planId: planId,
                repository: repository,
                onPlanUpdated: onPlanUpdated,
                point: point,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _StatusBadge(status: status),
                        const SizedBox(width: 8),
                        Expanded(
                          child: CopyableText(
                            text: point.name,
                            copyLabel: AppLocalizations.of(context)!.copyLabelPointName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                        if (recordCount > 0) ...[
                          const SizedBox(width: 8),
                          _MapRecordBadge(count: recordCount),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    CopyableText(
                      text: _metaText,
                      copyText: _copySummary,
                      copyLabel: AppLocalizations.of(context)!.copyLabelPointInfo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onOpenNavigation,
                  icon: const Icon(Icons.near_me_outlined, size: 18),
                  label: Text(AppLocalizations.of(context)!.btnNavigate),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.outlined(
                tooltip: AppLocalizations.of(context)!.btnPointDetail,
                onPressed: onOpenDetail,
                icon: const Icon(Icons.info_outline),
              ),
              const SizedBox(width: 4),
              IconButton.outlined(
                tooltip: AppLocalizations.of(context)!.btnCameraReference,
                onPressed: onOpenCamera,
                icon: const Icon(Icons.photo_camera_outlined),
              ),
              const SizedBox(width: 4),
              if (status == VisitStatus.completed)
                IconButton.outlined(
                  tooltip: AppLocalizations.of(context)!.tooltipRevertCompleted,
                  onPressed: onComplete,
                  icon: const Icon(Icons.replay_outlined),
                )
              else
                IconButton.outlined(
                  tooltip: AppLocalizations.of(context)!.tooltipMarkCompleted,
                  onPressed: onComplete,
                  icon: const Icon(Icons.check_circle_outline),
                ),
              if (status != VisitStatus.current &&
                  status != VisitStatus.completed) ...[
                const SizedBox(width: 4),
                IconButton.outlined(
                  tooltip: AppLocalizations.of(context)!.tooltipSetTarget,
                  onPressed: onSetCurrent,
                  icon: const Icon(Icons.flag_outlined),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String get _metaText {
    final episodeLabel = point.episodeLabel.trim();
    if (episodeLabel.isEmpty) {
      return point.work.title;
    }
    return '${point.work.title} / $episodeLabel';
  }

  String get _copySummary {
    return [
      point.name,
      '${point.work.title} / ${point.work.subtitle}',
      point.subtitle,
      point.displayEpisodeLabel,
      '${point.position.latitude.toStringAsFixed(5)},${point.position.longitude.toStringAsFixed(5)}',
    ].where((value) => value.trim().isNotEmpty).join('\n');
  }
}

class _PointThumbnail extends StatelessWidget {
  const _PointThumbnail({
    required this.planId,
    required this.repository,
    required this.onPlanUpdated,
    required this.point,
  });

  final String planId;
  final PilgrimageRepository? repository;
  final ValueChanged<PilgrimagePlan> onPlanUpdated;
  final PilgrimagePoint point;

  @override
  Widget build(BuildContext context) {
    final repository = this.repository;
    final remoteImageUrl = hasRemoteReferenceImage(point)
        ? point.referenceImageUrl
        : null;
    return GestureDetector(
      onTap: () => ImageViewerScreen.show(
        context,
        filePath: point.referenceFullImagePath,
        imageUrl: remoteImageUrl,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 64,
          height: 64,
          color: AppColors.surfaceMuted,
          child: repository == null
              ? ReferenceThumbnail(
                  localPath: point.referenceThumbnailPath,
                  imageUrl: remoteImageUrl,
                  placeholder: Icon(
                    Icons.image_outlined,
                    color: AppColors.accentDark,
                  ),
                )
              : AutoCachingReferenceThumbnail(
                  planId: planId,
                  point: point,
                  repository: repository,
                  onPlanUpdated: onPlanUpdated,
                  placeholder: Icon(
                    Icons.image_outlined,
                    color: AppColors.accentDark,
                  ),
                ),
        ),
      ),
    );
  }
}

class _MapRecordBadge extends StatelessWidget {
  const _MapRecordBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 15,
            color: AppColors.accentDark,
          ),
          const SizedBox(width: 5),
          Text(
            AppLocalizations.of(context)!.visitPhotoCount(count),
            style: TextStyle(
              color: AppColors.accentDark,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyMapCard extends StatelessWidget {
  const _EmptyMapCard();

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomInset),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(Icons.map_outlined, color: AppColors.accent),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.mapNoPointsMessage,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final VisitStatus status;

  @override
  Widget build(BuildContext context) {
    final text = switch (status) {
      VisitStatus.current => AppLocalizations.of(context)!.labelStatusCurrent,
      VisitStatus.completed => AppLocalizations.of(context)!.labelStatusCompleted,
      VisitStatus.pending => AppLocalizations.of(context)!.labelStatusPending,
    };

    final color = switch (status) {
      VisitStatus.current => AppColors.accent,
      VisitStatus.completed => AppColors.textSecondary,
      VisitStatus.pending => AppColors.warning,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

/// 录制中的实时统计卡片（时长 / 距离 / 采样点数）。
class _GpsTrackStatsCard extends StatelessWidget {
  const _GpsTrackStatsCard({
    required this.durationLabel,
    required this.distanceLabel,
    required this.countLabel,
    required this.statusLabel,
    required this.paused,
  });

  final String durationLabel;
  final String distanceLabel;
  final String countLabel;
  final String statusLabel;
  final bool paused;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bodyStyle = TextStyle(
      fontSize: 11,
      color: theme.textTheme.bodySmall?.color,
    );
    return Container(
      width: 136,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                paused
                    ? Icons.pause_circle_outline
                    : Icons.fiber_manual_record,
                size: 12,
                color: paused ? Colors.grey : Colors.redAccent,
              ),
              const SizedBox(width: 4),
              Text(
                statusLabel,
                style: bodyStyle.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(durationLabel, style: bodyStyle),
          Text(distanceLabel, style: bodyStyle),
          Text(countLabel, style: bodyStyle),
        ],
      ),
    );
  }
}
