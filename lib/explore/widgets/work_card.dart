import 'package:flutter/material.dart';

import '../../app_theme.dart';
import '../explore_work_item.dart';
import '../poster_resolver.dart';
import '../../data/anilist_title_service.dart';
import '../../widgets/anitabi_network_image.dart';
import '../../widgets/image_load_limiter.dart';
import 'localized_title.dart';

/// Single work card on the Explore tab: 2:3 poster area + title + a secondary
/// line (point count, else city). When [ExploreWorkItem.imageUrl] is null the
/// poster falls back to a Bangumi subject resolver and finally to a
/// deterministic gradient tile with the work's first character.
class WorkCard extends StatelessWidget {
  const WorkCard({
    required this.item,
    required this.onTap,
    this.pointLabel,
    this.posterResolver,
    this.imageLoadLimiter,
    super.key,
  });

  final ExploreWorkItem item;

  /// Pre-formatted "N 个地点" string, or null to fall back to city.
  final String? pointLabel;

  /// Resolves a Bangumi poster when [ExploreWorkItem.imageUrl] is null. When
  /// null too, the card shows the placeholder tile.
  final PosterResolver? posterResolver;

  /// Caps simultaneous cover downloads so the connection pool / CDN don't drop
  /// requests (leaving some covers stuck on the placeholder tile).
  final ImageLoadLimiter? imageLoadLimiter;

  final VoidCallback onTap;

  static const double width = 140;

  @override
  Widget build(BuildContext context) {
    final secondary = pointLabel ?? item.city;
    return SizedBox(
      width: width,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AspectRatio(
                aspectRatio: 2 / 3,
                child: _Poster(
                  item: item,
                  posterResolver: posterResolver,
                  imageLoadLimiter: imageLoadLimiter,
                ),
              ),
            ),
            const SizedBox(height: 8),
            LocalizedTitle(
              item: item,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
              ),
            ),
            if (secondary != null && secondary.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                secondary,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  letterSpacing: 0,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Poster extends StatelessWidget {
  const _Poster({
    required this.item,
    this.posterResolver,
    this.imageLoadLimiter,
  });

  final ExploreWorkItem item;
  final PosterResolver? posterResolver;
  final ImageLoadLimiter? imageLoadLimiter;

  Widget _network(String url) {
    // AnitabiNetworkImage retries across candidate hosts (image.anitabi.cn →
    // img-tc.anitabi.cn mirror) and honours the shared load limiter, so a
    // transient drop no longer strands a cover on the placeholder tile.
    return AnitabiNetworkImage(
      url: url,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      loadLimiter: imageLoadLimiter,
      loadingBuilder: (_) => _FallbackTile(item: item),
      errorBuilder: (_) => _FallbackTile(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    final url = item.imageUrl;
    if (url != null && url.isNotEmpty) {
      return _network(url);
    }

    final resolver = posterResolver;
    final bangumiId = item.bangumiId;
    if (resolver != null && bangumiId != null) {
      return FutureBuilder<String?>(
        future: resolver.resolve(bangumiId),
        builder: (context, snapshot) {
          final resolved = snapshot.data;
          if (resolved != null && resolved.isNotEmpty) {
            return _network(resolved);
          }
          return _FallbackTile(item: item);
        },
      );
    }

    return _FallbackTile(item: item);
  }
}

class _FallbackTile extends StatelessWidget {
  const _FallbackTile({required this.item});

  final ExploreWorkItem item;

  static const List<List<Color>> _palettes = [
    [Color(0xFFF45B9A), Color(0xFFB72665)],
    [Color(0xFF8753C7), Color(0xFF5D3495)],
    [Color(0xFF1C2B78), Color(0xFF111B52)],
    [Color(0xFF0F8B8D), Color(0xFF0B6F72)],
    [Color(0xFF16C6A8), Color(0xFF0A7E83)],
  ];

  @override
  Widget build(BuildContext context) {
    final localeName = Localizations.localeOf(context).languageCode;
    final title = localeName.startsWith('zh')
        ? ((item.titleZh?.isNotEmpty ?? false)
            ? item.titleZh!
            : (item.titleOriginal ?? ''))
        : (AnilistTitleService.instance.peekEnglishTitle(
                  item.bangumiId ?? -1,
                ) ??
                (item.titleOriginal ?? ''));
    final glyph = title.runes.isEmpty
        ? '?'
        : String.fromCharCode(title.runes.first);
    final palette = _palettes[title.hashCode.abs() % _palettes.length];
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: palette,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        glyph,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 44,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
