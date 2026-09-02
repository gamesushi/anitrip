import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'data/anitabi_image_source_scope.dart';
import 'data/pilgrimage_repository.dart';
import 'explore/explore_screen.dart';
import 'explore/explore_work_item.dart';
import 'map/pilgrimage_map_screen.dart';
import 'plan/add_points_screen.dart';
import 'plan/plan_manager_screen.dart';
import 'plan/pilgrimage_models.dart';
import 'plan/pilgrimage_plan_controller.dart';
import 'plan/plan_screen.dart';
import 'plan/point_manager_screen.dart';
import 'plan_transfer/import_export_screen.dart';
import 'plan_transfer/incoming_plan_file.dart';
import 'plan_transfer/plan_import_file_stub.dart'
    if (dart.library.io) 'plan_transfer/plan_import_file_io.dart';
import 'plan_transfer/plan_import_preview_screen.dart';
import 'l10n/app_localizations.dart';
import 'profile/profile_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    required this.repository,
    required this.settings,
    required this.onSettingsChanged,
    super.key,
  });

  final PilgrimageRepository repository;
  final AppSettings settings;
  final ValueChanged<AppSettings> onSettingsChanged;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  PilgrimagePlanController? _planController;
  AppSettings _settings = const AppSettings();
  Object? _loadError;
  int _selectedIndex = 0;
  final _incomingPlanFiles = const IncomingPlanFileChannel();

  /// Signals [ExploreScreen] to open its in-app search overlay. The map tab's
  /// search bar routes here so search is unified on the Explore tab rather
  /// than jumping to "add content".
  final ValueNotifier<bool> _exploreSearchRequest = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
    _incomingPlanFiles.listen(_importPlanFromPath);
    _initializeApp();
  }

  @override
  void didUpdateWidget(AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.settings != oldWidget.settings) {
      final languageChanged = widget.settings.language != oldWidget.settings.language;
      setState(() {
        _settings = widget.settings;
      });
      if (languageChanged) {
        _loadActivePlan();
      }
    }
  }

  @override
  void dispose() {
    _planController?.dispose();
    _exploreSearchRequest.dispose();
    super.dispose();
  }

  Future<void> _loadActivePlan() async {
    setState(() {
      _loadError = null;
    });

    try {
      final plan = await widget.repository.loadActivePlan();
      final settings = await widget.repository.loadAppSettings();
      if (!mounted) {
        return;
      }

      if (_planController == null) {
        _planController = PilgrimagePlanController(
          plan: plan,
          visitRepository: widget.repository,
        );
        // Reflect the freshly loaded plan at boot so the shell (with the
        // bottom navigation bar) replaces the no-plan manager scaffold.
        if (mounted) setState(() {});
      } else {
        // Swap the plan in place so the controller identity stays stable.
        // Disposing and recreating the controller forces every listener
        // (including the always-mounted map layers in the IndexedStack) to
        // rebuild in the same frame, which can deactivate an inherited widget
        // (e.g. the map's internal state provider) while it still has
        // dependents and trigger framework assertions such as
        // `_dependents.isEmpty`.
        _planController!.applyPlan(plan);
        // NOTE: Do NOT call setState here. applyPlan() already calls
        // notifyListeners(), which triggers the ListenableBuilder wrapping
        // the IndexedStack. Calling setState on top of that causes a redundant
        // rebuild of this State in the same frame — the always-mounted map tab
        // (FlutterMap) contains internal InheritedWidgets whose elements may
        // still have pending dependents when deactivated, triggering the
        // framework assertion `_dependents.isEmpty`.
      }
      widget.onSettingsChanged(settings);
    } on StateError catch (error) {
      // No plans available (e.g. fresh install without sample data) — not fatal.
      // Show the shell with a null controller; PlanScreen should handle it gracefully.
      debugPrint('No active plan ($error)');
      if (!mounted) return;
      _planController?.dispose();
      setState(() {
        _planController = null;
        _loadError = null;
      });
    } catch (error, stackTrace) {
      debugPrint('Failed to load active pilgrimage plan: $error');
      debugPrint(stackTrace.toString());
      if (!mounted) {
        return;
      }

      setState(() {
        _loadError = error;
      });
    }
  }

  Future<void> _initializeApp() async {
    await _loadActivePlan();
    await _loadInitialIncomingPlanFile();
  }

  void _openMap() {
    setState(() {
      // Index 2 since ExploreScreen was inserted at index 0.
      _selectedIndex = 2;
    });
  }

  /// Opens a tapped work on the map. Works live in per-work plans, so when the
  /// tapped work belongs to a plan other than the active one we switch the
  /// active plan first (and reload the controller) before jumping to the map.
  Future<void> _openWorkOnMap(ExploreWorkItem item) async {
    final planId = item.planId;
    if (planId != null && planId != _planController?.plan.id) {
      await widget.repository.setActivePlan(planId);
      await _loadActivePlan();
    }
    if (mounted) {
      _openMap();
    }
  }

  /// Tapping the map tab's search bar should open the unified in-app search
  /// on the Explore tab instead of jumping to "add content".
  void _openExploreSearch() {
    setState(() {
      _selectedIndex = 0;
    });
    _exploreSearchRequest.value = true;
  }

  /// Called after Explore creates a new per-work plan (already made active by
  /// the repository): reload it into the controller and show the Plan tab.
  Future<void> _reloadAndOpenPlan() async {
    await _loadActivePlan();
    if (mounted) {
      setState(() {
        _selectedIndex = 1;
      });
    }
  }

  Future<void> _openPlanManager() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PlanManagerScreen(repository: widget.repository),
      ),
    );
    await _loadActivePlan();
  }

  Future<void> _openAddPoints() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => AddPointsScreen(
          plan: _planController?.plan,
          repository: widget.repository,
        ),
      ),
    );
    if (mounted) {
      await _loadActivePlan();
    }
  }

  Future<void> _openPointManager() async {
    final plan = _planController?.plan;
    if (plan == null) {
      return;
    }

    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => PointManagerScreen(
          plan: plan,
          repository: widget.repository,
          settings: _settings,
        ),
      ),
    );
    if (mounted) {
      await _loadActivePlan();
    }
  }

  Future<void> _openImportExport() async {
    final plan = _planController?.plan;
    if (plan == null) {
      return;
    }
    final imported = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) =>
            ImportExportScreen(plan: plan, repository: widget.repository),
      ),
    );
    if (imported == true) {
      await _loadActivePlan();
      if (mounted) {
        setState(() {
          // Land on the Plan tab (index 1) to show the imported plan.
          _selectedIndex = 1;
        });
      }
    }
  }

  Future<void> _saveSettings(AppSettings settings) async {
    widget.onSettingsChanged(settings);
    await widget.repository.saveAppSettings(settings);
  }

  Future<void> _loadInitialIncomingPlanFile() async {
    final path = await _incomingPlanFiles.getInitialPath();
    if (path == null || path.isEmpty) {
      return;
    }
    await _importPlanFromPath(path);
  }

  Future<void> _importPlanFromPath(String path) async {
    try {
      final importPackage = await readPlanImportPackageFromPath(path);
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
      if (imported != true) {
        return;
      }
      await _loadActivePlan();
      if (!mounted) {
        return;
      }
      setState(() {
        // Land on the Plan tab (index 1) to show the imported plan.
        _selectedIndex = 1;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.appShellPlanFileImportFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _planController;
    AppColors.palette = _settings.themePalette;
    AppColors.customAccentValue = _settings.customThemeColorValue;

    if (controller == null) {
      if (_loadError != null) {
        return _PlanLoadState(error: _loadError, onRetry: _loadActivePlan);
      }
      // No plans yet — show plan manager so user can create one
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.planSwitch)),
        body: PlanManagerScreen(
          repository: widget.repository,
          onPlanActivated: _loadActivePlan,
        ),
      );
    }

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: appTextScaler(_settings.fontScale)),
          child: AnitabiImageSourceScope(
            source: _settings.anitabiImageSource,
            child: AppUiScaleView(
              scale: _settings.uiScale,
              child: Theme(
                data: AppTheme.light(
                  palette: _settings.themePalette,
                  customAccentValue: _settings.customThemeColorValue,
                ),
                child: Scaffold(
                  body: IndexedStack(
                    index: _selectedIndex,
                    children: [
                      ExploreScreen(
                        controller: controller,
                        onOpenSearch: _openAddPoints,
                        searchRequest: _exploreSearchRequest,
                        onOpenWork: _openWorkOnMap,
                        onPlanCreated: _reloadAndOpenPlan,
                        onPlanUpdated: _loadActivePlan,
                      ),
                      PlanScreen(
                        controller: controller,
                        settings: _settings,
                        repository: widget.repository,
                        onOpenMap: _openMap,
                        onOpenPlanManager: _openPlanManager,
                        onOpenAddPoints: _openAddPoints,
                        onOpenPointManager: _openPointManager,
                        onOpenImportExport: _openImportExport,
                      ),
                      PilgrimageMapScreen(
                        controller: controller,
                        settings: _settings,
                        onStartSearch: _openExploreSearch,
                      ),
                      ProfileScreen(
                        controller: controller,
                        settings: _settings,
                        repository: widget.repository,
                        onSettingsChanged: _saveSettings,
                      ),
                    ],
                  ),
                  bottomNavigationBar: NavigationBarTheme(
                    data: NavigationBarThemeData(
                      indicatorColor: AppColors.accent,
                      iconTheme: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return IconThemeData(color: AppColors.onAccent);
                        }

                        return const IconThemeData(
                          color: AppColors.textPrimary,
                        );
                      }),
                      labelTextStyle: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0,
                          );
                        }

                        return const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0,
                        );
                      }),
                    ),
                    child: NavigationBar(
                      selectedIndex: _selectedIndex,
                      backgroundColor: AppColors.surface,
                      onDestinationSelected: (index) {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                      destinations: [
                        NavigationDestination(
                          icon: const Icon(Icons.explore_outlined),
                          selectedIcon: const Icon(Icons.explore),
                          label: AppLocalizations.of(context)!.tabExplore,
                        ),
                        NavigationDestination(
                          icon: const Icon(Icons.checklist_outlined),
                          selectedIcon: const Icon(Icons.checklist),
                          label: AppLocalizations.of(context)!.tabPlan,
                        ),
                        NavigationDestination(
                          icon: const Icon(Icons.map_outlined),
                          selectedIcon: const Icon(Icons.map),
                          label: AppLocalizations.of(context)!.tabMap,
                        ),
                        NavigationDestination(
                          icon: const Icon(Icons.person_outline),
                          selectedIcon: const Icon(Icons.person),
                          label: AppLocalizations.of(context)!.tabProfile,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PlanLoadState extends StatelessWidget {
  const _PlanLoadState({required this.error, required this.onRetry});

  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final hasError = error != null;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                hasError ? Icons.error_outline : Icons.route_outlined,
                color: hasError ? AppColors.error : AppColors.accent,
                size: 40,
              ),
              const SizedBox(height: 12),
              Text(
                hasError ? l10n.appShellPlanLoadFailed : l10n.appShellPlanLoading,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                hasError ? l10n.appShellRetryHint : l10n.appShellLoadingHint,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  letterSpacing: 0,
                ),
              ),
              if (hasError && kDebugMode) ...[
                const SizedBox(height: 10),
                SelectableText(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 12,
                    letterSpacing: 0,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              if (hasError)
                OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(l10n.btnRetry),
                )
              else
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
