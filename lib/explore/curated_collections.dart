import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';
import 'explore_work_item.dart';

/// A hand-curated Explore collection. Matching is best-effort by title keyword
/// against the anitabi catalog — the reference app curates these editorially,
/// and pure tag/studio data can't reproduce them precisely. Keeping keywords
/// specific avoids over-matching. A section is hidden when nothing matches.
///
/// A more precise future version would pin explicit Bangumi subject ids per
/// collection instead of keyword matching.
class CuratedCollection {
  const CuratedCollection({
    required this.id,
    required this.title,
    required this.keywords,
  });

  /// Stable identifier used to resolve the localized title.
  final String id;

  /// Default (Chinese) title; also used as a fallback when no localization
  /// exists for the current locale.
  final String title;
  final List<String> keywords;

  /// Localized section header for this collection.
  String localizedTitle(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (id) {
      case 'kyoto_animation':
        return l10n.exploreCollectionKyotoAnimation;
      case 'makoto_shinkai':
        return l10n.exploreCollectionMakotoShinkai;
      default:
        return title;
    }
  }

  bool matches(ExploreWorkItem item) {
    // Match against the locale-independent name so curated sections stay
    // stable regardless of the UI language.
    final haystack = '${item.matchTitle} ${item.subtitle ?? ''}'.toLowerCase();
    for (final keyword in keywords) {
      if (haystack.contains(keyword.toLowerCase())) {
        return true;
      }
    }
    return false;
  }
}

const List<CuratedCollection> kCuratedCollections = [
  CuratedCollection(
    id: 'kyoto_animation',
    title: '京阿尼名作选',
    keywords: [
      '吹响吧',
      '上低音号',
      '轻音少女',
      '中二病也要谈恋爱',
      '玉子市场',
      '冰菓',
      '凉宫春日',
      '声之形',
      '紫罗兰永恒花园',
      '境界的彼方',
      '小林家的龙女仆',
      'Free!',
    ],
  ),
  CuratedCollection(
    id: 'makoto_shinkai',
    title: '新海诚剧场',
    keywords: [
      '你的名字',
      '天气之子',
      '铃芽之旅',
      '铃芽户缔',
      '言叶之庭',
      '秒速5厘米',
      '追逐繁星的孩子',
      '星之声',
      '云之彼端',
    ],
  ),
];
