import 'explore_work_item.dart';

/// A hand-curated Explore collection. Matching is best-effort by title keyword
/// against the anitabi catalog — the reference app curates these editorially,
/// and pure tag/studio data can't reproduce them precisely. Keeping keywords
/// specific avoids over-matching. A section is hidden when nothing matches.
///
/// A more precise future version would pin explicit Bangumi subject ids per
/// collection instead of keyword matching.
class CuratedCollection {
  const CuratedCollection({required this.title, required this.keywords});

  final String title;
  final List<String> keywords;

  bool matches(ExploreWorkItem item) {
    final haystack = '${item.title} ${item.subtitle ?? ''}'.toLowerCase();
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
