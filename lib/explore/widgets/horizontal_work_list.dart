import 'package:flutter/material.dart';

import '../explore_work_item.dart';
import '../poster_resolver.dart';
import 'work_card.dart';

/// Horizontally scrolling row of [WorkCard]s under a section header.
class HorizontalWorkList extends StatelessWidget {
  const HorizontalWorkList({
    required this.items,
    required this.onWorkTap,
    this.pointLabelBuilder,
    this.posterResolver,
    super.key,
  });

  final List<ExploreWorkItem> items;
  final ValueChanged<ExploreWorkItem> onWorkTap;

  /// Builds the "N 个地点" label for an item (localized by the screen). Return
  /// null to fall back to the item's city.
  final String? Function(ExploreWorkItem item)? pointLabelBuilder;

  final PosterResolver? posterResolver;

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
            onTap: () => onWorkTap(item),
          );
        },
      ),
    );
  }
}
