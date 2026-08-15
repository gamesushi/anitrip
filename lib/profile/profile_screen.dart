import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../data/pilgrimage_repository.dart';
import '../l10n/app_localizations.dart';
import '../plan/pilgrimage_models.dart';
import '../plan/pilgrimage_plan_controller.dart';
import '../records/records_screen.dart';
import '../records/visit_record_detail_screen.dart';
import '../settings/settings_screen.dart';
import '../records/visit_record_photo_stub.dart'
    if (dart.library.io) '../records/visit_record_photo_io.dart';

/// "我的" tab: profile header + 足迹/作品/城市 stats (backed by real check-in
/// records) + entries for the full records manager and settings. See
/// ANIMAP_REDESIGN_PLAN.md Phase 3. Favorites is out of scope this round and
/// shown as a "敬请期待" placeholder.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    required this.controller,
    required this.settings,
    required this.repository,
    required this.onSettingsChanged,
    super.key,
  });

  final PilgrimagePlanController controller;
  final AppSettings settings;
  final PilgrimageRepository repository;
  final ValueChanged<AppSettings> onSettingsChanged;

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SettingsScreen(
          settings: settings,
          repository: repository,
          onChanged: onSettingsChanged,
        ),
      ),
    );
  }

  void _openRecordsManager(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            RecordsScreen(controller: controller, settings: settings),
      ),
    );
  }

  void _openRecordDetail(BuildContext context, PilgrimageVisitRecord record) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VisitRecordDetailScreen(
          record: record,
          point: controller.pointById(record.pointId),
          controller: controller,
          settings: settings,
          onDelete: () => controller.deleteVisitRecord(record),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final records = controller.visitRecords;
    final worksById = {for (final w in controller.plan.works) w.id: w};

    final workIds = records.map((r) => r.workId).toSet();
    final cityCounts = <String, int>{};
    for (final record in records) {
      final city = _cityForWork(worksById[record.workId]);
      if (city != null) {
        cityCounts.update(city, (v) => v + 1, ifAbsent: () => 1);
      }
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _ProfileHeader(
                checkins: records.length,
                works: workIds.length,
                cities: cityCounts.length,
                onOpenSettings: () => _openSettings(context),
              ),
              _FavoritesPlaceholderTile(
                title: l10n.profileFavorites,
                subtitle: l10n.profileFavoritesSoon,
              ),
              TabBar(
                labelColor: AppColors.accent,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.accent,
                indicatorSize: TabBarIndicatorSize.label,
                labelStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
                tabs: [
                  Tab(text: l10n.profileFootprints),
                  Tab(text: l10n.profileWorks),
                  Tab(text: l10n.profileCities),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _FootprintsTab(
                      records: records,
                      onManage: () => _openRecordsManager(context),
                      onOpenRecord: (record) =>
                          _openRecordDetail(context, record),
                    ),
                    _WorksTab(records: records, worksById: worksById),
                    _CitiesTab(cityCounts: cityCounts),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Works with check-in records are always anitabi-sourced (points come from
  /// anitabi), so `city` holds a real place. Guard against the compound meta
  /// that Bangumi-only works store in `city` by taking the first segment.
  static String? _cityForWork(PilgrimageWork? work) {
    final raw = work?.city.split('/').first.trim();
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return raw;
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.checkins,
    required this.works,
    required this.cities,
    required this.onOpenSettings,
  });

  final int checkins;
  final int works;
  final int cities;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              tooltip: l10n.tabSettings,
              onPressed: onOpenSettings,
              icon: const Icon(Icons.settings_outlined),
            ),
          ),
          Row(
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: AppColors.surfaceMuted,
                child: Icon(
                  Icons.person_outline,
                  size: 38,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.profileTitle,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _Stat(value: checkins, label: l10n.profileStatCheckins),
                        _StatDivider(),
                        _Stat(value: works, label: l10n.profileWorks),
                        _StatDivider(),
                        _Stat(value: cities, label: l10n.profileCities),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          '$value',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Text(
        '·',
        style: TextStyle(color: AppColors.textSecondary, letterSpacing: 0),
      ),
    );
  }
}

class _FavoritesPlaceholderTile extends StatelessWidget {
  const _FavoritesPlaceholderTile({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(Icons.favorite_border, color: AppColors.accent, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
            ),
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
    );
  }
}

class _FootprintsTab extends StatelessWidget {
  const _FootprintsTab({
    required this.records,
    required this.onManage,
    required this.onOpenRecord,
  });

  final List<PilgrimageVisitRecord> records;
  final VoidCallback onManage;
  final ValueChanged<PilgrimageVisitRecord> onOpenRecord;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (records.isEmpty) {
      return _EmptyState(
        icon: Icons.directions_walk,
        message: l10n.profileEmptyFootprints,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: records.length + 1,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onManage,
              icon: const Icon(Icons.tune, size: 18),
              label: Text(l10n.profileManageRecords),
            ),
          );
        }
        final record = records[index - 1];
        return _RecordRow(
          record: record,
          onTap: () => onOpenRecord(record),
        );
      },
    );
  }
}

class _RecordRow extends StatelessWidget {
  const _RecordRow({required this.record, required this.onTap});

  final PilgrimageVisitRecord record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final photoPath = resolveVisitRecordDisplayPhotoPath(record);
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            SizedBox(
              width: 68,
              height: 68,
              child: VisitRecordPhoto(path: photoPath),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.displayPointNameSnapshot,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    record.displayWorkTitleSnapshot,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _formatTime(record.capturedAt),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime t) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${t.year}/${two(t.month)}/${two(t.day)} ${two(t.hour)}:${two(t.minute)}';
  }
}

class _WorksTab extends StatelessWidget {
  const _WorksTab({required this.records, required this.worksById});

  final List<PilgrimageVisitRecord> records;
  final Map<String, PilgrimageWork> worksById;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final counts = <String, int>{};
    final titles = <String, String>{};
    for (final record in records) {
      counts.update(record.workId, (v) => v + 1, ifAbsent: () => 1);
      titles[record.workId] =
          worksById[record.workId]?.title ?? record.displayWorkTitleSnapshot;
    }
    if (counts.isEmpty) {
      return _EmptyState(
        icon: Icons.movie_outlined,
        message: l10n.profileEmptyWorks,
      );
    }
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      itemCount: entries.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _CountRow(
          icon: Icons.movie_outlined,
          title: titles[entry.key] ?? entry.key,
          countLabel: l10n.profileCheckinTimes(entry.value),
        );
      },
    );
  }
}

class _CitiesTab extends StatelessWidget {
  const _CitiesTab({required this.cityCounts});

  final Map<String, int> cityCounts;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (cityCounts.isEmpty) {
      return _EmptyState(
        icon: Icons.location_city_outlined,
        message: l10n.profileEmptyCities,
      );
    }
    final entries = cityCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      itemCount: entries.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _CountRow(
          icon: Icons.location_city_outlined,
          title: entry.key,
          countLabel: l10n.profileCheckinTimes(entry.value),
        );
      },
    );
  }
}

class _CountRow extends StatelessWidget {
  const _CountRow({
    required this.icon,
    required this.title,
    required this.countLabel,
  });

  final IconData icon;
  final String title;
  final String countLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ),
          Text(
            countLabel,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 44, color: AppColors.accent),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}
