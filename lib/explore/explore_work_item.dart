import '../data/anitabi_client.dart';
import '../plan/pilgrimage_models.dart';

/// Unified view-model for a work card on the Explore tab, so that both locally
/// imported works ([PilgrimageWork]) and anitabi catalog entries
/// ([AnitabiMapWorkLite]) render through the same [_WorkCard].
class ExploreWorkItem {
  const ExploreWorkItem({
    required this.title,
    this.titleZh,
    this.titleOriginal,
    this.subtitle,
    this.city,
    this.pointCount,
    this.bangumiId,
    this.imageUrl,
    this.planId,
  });

  /// Default display title (Chinese-preferred). Kept as a field so call sites
  /// without a locale context (e.g. plan naming) still work.
  final String title;

  /// Chinese name. `null` when unavailable (foreign/older works, or local
  /// works that only carry a single name).
  final String? titleZh;

  /// Original name (Japanese for anime, English/Latin for Western titles).
  final String? titleOriginal;

  final String? subtitle;
  final String? city;

  /// Number of pilgrimage points for this work. `null` when unknown (kept out
  /// of the card so we never show a fabricated count).
  final int? pointCount;

  final int? bangumiId;

  /// Poster/cover URL. Populated from the anitabi static index when available;
  /// otherwise the card falls back to resolving a Bangumi subject poster, and
  /// finally to a first-character tile.
  final String? imageUrl;

  /// Plan that owns this work. Non-null for locally imported works. When the
  /// card is tapped we switch the active plan to this id so the map/plan
  /// screens show the correct pilgrimage (works live in per-work plans).
  final String? planId;

  /// Locale-aware display title: Chinese locales show [titleZh]; all others
  /// show [titleOriginal]. Falls back to the other field when one is missing.
  String displayTitle([String? localeName]) {
    final isZh =
        localeName == null || localeName.toLowerCase().startsWith('zh');
    if (isZh) {
      return titleZh?.isNotEmpty == true ? titleZh! : title;
    }
    return titleOriginal?.isNotEmpty == true ? titleOriginal! : title;
  }

  /// Locale-independent name used for curated-collection matching and search.
  String get matchTitle => titleZh ?? titleOriginal ?? title;

  /// Combined searchable text across both name forms and subtitle.
  String get searchableText =>
      '${titleZh ?? ''} ${titleOriginal ?? ''} ${subtitle ?? ''}';

  factory ExploreWorkItem.fromAnitabi(AnitabiMapWorkLite work) {
    return ExploreWorkItem(
      title: work.title,
      titleZh: work.titleZh,
      titleOriginal: work.titleOriginal,
      subtitle: work.subtitle.isEmpty ? null : work.subtitle,
      city: work.city,
      pointCount: work.points.length,
      bangumiId: work.bangumiId,
      imageUrl: work.imageUrl,
    );
  }

  factory ExploreWorkItem.fromLocal(
    PilgrimageWork work, {
    required int pointCount,
    required String planId,
  }) {
    // Local works only carry a single (Chinese) name, so mirror it into
    // [titleZh] for consistent locale handling.
    return ExploreWorkItem(
      title: work.title,
      titleZh: work.title,
      subtitle: work.subtitle.isEmpty ? null : work.subtitle,
      city: work.city,
      pointCount: pointCount,
      bangumiId: work.bangumiId,
      planId: planId,
    );
  }
}
