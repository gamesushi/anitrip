import '../data/anitabi_client.dart';
import '../plan/pilgrimage_models.dart';

/// Unified view-model for a work card on the Explore tab, so that both locally
/// imported works ([PilgrimageWork]) and anitabi catalog entries
/// ([AnitabiMapWorkLite]) render through the same [_WorkCard].
class ExploreWorkItem {
  const ExploreWorkItem({
    required this.title,
    this.subtitle,
    this.city,
    this.pointCount,
    this.bangumiId,
    this.imageUrl,
  });

  final String title;
  final String? subtitle;
  final String? city;

  /// Number of pilgrimage points for this work. `null` when unknown (kept out
  /// of the card so we never show a fabricated count).
  final int? pointCount;

  final int? bangumiId;

  /// Poster/cover URL. Currently always `null` (no work-level cover data
  /// source yet); the card falls back to a first-character tile. Reserved so a
  /// Bangumi subject poster can be wired in later without touching callers.
  final String? imageUrl;

  factory ExploreWorkItem.fromAnitabi(AnitabiMapWorkLite work) {
    return ExploreWorkItem(
      title: work.title,
      subtitle: work.subtitle.isEmpty ? null : work.subtitle,
      city: work.city,
      pointCount: work.points.length,
      bangumiId: work.bangumiId,
    );
  }

  factory ExploreWorkItem.fromLocal(
    PilgrimageWork work, {
    required int pointCount,
  }) {
    return ExploreWorkItem(
      title: work.title,
      subtitle: work.subtitle.isEmpty ? null : work.subtitle,
      city: work.city,
      pointCount: pointCount,
      bangumiId: work.bangumiId,
    );
  }
}
