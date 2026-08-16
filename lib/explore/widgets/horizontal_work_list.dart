import 'package:flutter/material.dart';

import '../explore_work_item.dart';
import '../poster_resolver.dart';
import '../../widgets/image_load_limiter.dart';
import 'work_card.dart';

/// Horizontally scrolling row of [WorkCard]s under a section header.
class HorizontalWorkList extends StatelessWidget {
  const HorizontalWorkList({
    required this.items,
    required this.onWorkTap,
    this.pointLabelBuilder,
    this.posterResolver,
    this.imageLoadLimiter,
    super.key,
  });

  final List<ExploreWorkItem> items;
  final ValueChanged<ExploreWorkItem> onWorkTap;

  /// Builds the "N 个地点" label for an item (localized by the screen). Return
  /// null to fall back to the item's city.
  final String? Function(ExploreWorkItem item)? pointLabelBuilder;

  final PosterResolver? posterResolver;

  /// Caps simultaneous cover downloads so iOS's connection pool and the image
  /// CDN don't drop requests (which leaves some covers on the placeholder).
  final ImageLoadLimiter? imageLoadLimiter;

  @override
  Widget build(BuildContext context) {
    // Card height: poster (width * 3/2) + text block.
    const cardHeight = WorkCard.width * 3 / 2 + 52;
    return SizedBox(
      height: cardHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return WorkCard(
            item: item,
            pointLabel: pointLabelBuilder?.call(item),
            posterResolver: posterResolver,
            imageLoadLimiter: imageLoadLimiter,
            onTap: () => onWorkTap(item),
          );
        },
      ),
    );
  }
}
