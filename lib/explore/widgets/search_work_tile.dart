import 'package:flutter/material.dart';

import '../../app_theme.dart';
import '../explore_work_item.dart';
import '../poster_resolver.dart';

/// A single search-result row for the Explore in-app search: poster thumbnail
/// on the left, title + metadata on the right — similar to anitabi.cn's search
/// result layout but adapted to the app's card style and colour system.
class SearchWorkTile extends StatelessWidget {
  const SearchWorkTile({
    required this.item,
    required this.onTap,
    this.posterResolver,
    super.key,
  });

  final ExploreWorkItem item;
  final VoidCallback onTap;
  final PosterResolver? posterResolver;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // Poster thumbnail (square)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 56,
                height: 56,
                child: _Poster(item: item, posterResolver: posterResolver),
              ),
            ),
            const SizedBox(width: 12),
            // Title + metadata
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _MetadataRow(item: item),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Status indicator dot (same palette as WorkCard fallback tile)
            _StatusDot(item: item),
          ],
        ),
      ),
    );
  }
}

class _MetadataRow extends StatelessWidget {
  const _MetadataRow({required this.item});

  final ExploreWorkItem item;

  @override
  Widget build(BuildContext context) {
    final parts = <String>[
      if (item.city != null && item.city!.isNotEmpty) item.city!,
      if (item.pointCount != null) '${item.pointCount} 地标',
      if (item.pointCount != null) '${item.pointCount} 截图',
    ];
    return Text(
      parts.join(' · '),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 13,
        letterSpacing: 0,
      ),
    );
  }
}

class _Poster extends StatelessWidget {
  const _Poster({required this.item, this.posterResolver});

  final ExploreWorkItem item;
  final PosterResolver? posterResolver;

  Widget _network(String url) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) return child;
        return _FallbackTile(item: item);
      },
      errorBuilder: (context, error, stackTrace) => _FallbackTile(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    final url = item.imageUrl;
    if (url != null && url.isNotEmpty) return _network(url);

    final resolver = posterResolver;
    final bangumiId = item.bangumiId;
    if (resolver != null && bangumiId != null) {
      return FutureBuilder<String?>(
        future: resolver.resolve(bangumiId),
        builder: (context, snapshot) {
          final resolved = snapshot.data;
          if (resolved != null && resolved.isNotEmpty) return _network(resolved);
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
    final title = item.title.trim();
    final glyph =
        title.runes.isEmpty ? '?' : String.fromCharCode(title.runes.first);
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
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

/// Small coloured status dot matching WorkCard's fallback-tile palette so the
/// list row feels visually connected to the horizontal card grid.
class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.item});

  final ExploreWorkItem item;

  static const List<Color> _dotColors = [
    Color(0xFFF45B9A),
    Color(0xFF8753C7),
    Color(0xFF1C2B78),
    Color(0xFF0F8B8D),
    Color(0xFF16C6A8),
    Color(0xFFFF9800),
  ];

  @override
  Widget build(BuildContext context) {
    final color = _dotColors[item.title.hashCode.abs() % _dotColors.length];
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
