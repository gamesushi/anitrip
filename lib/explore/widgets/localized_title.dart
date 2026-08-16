import 'package:flutter/material.dart';

import '../explore_work_item.dart';
import '../../data/anilist_title_service.dart';

/// Renders a work's title in the current locale.
///
/// - Chinese locales show the Chinese name ([ExploreWorkItem.titleZh],
///   falling back to the original name).
/// - Non-Chinese locales show the English (or romaji) title resolved from
///   AniList when available; until that resolves (or if it has no English
///   title) the original name is shown. The English lookup is fired lazily and
///   updates the text in place once it returns, so switching the app language
///   re-localizes every visible title.
class LocalizedTitle extends StatefulWidget {
  const LocalizedTitle({
    required this.item,
    this.style,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    super.key,
  });

  final ExploreWorkItem item;
  final TextStyle? style;
  final int maxLines;
  final TextOverflow overflow;

  @override
  State<LocalizedTitle> createState() => _LocalizedTitleState();
}

class _LocalizedTitleState extends State<LocalizedTitle> {
  late String _text;
  bool _resolveStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _recompute();
  }

  void _recompute() {
    final locale = Localizations.localeOf(context);
    final isZh = locale.languageCode == 'zh';
    final original = widget.item.titleOriginal ?? '';
    if (isZh) {
      // Allow re-resolving if the user flips back to a non-Chinese locale.
      _resolveStarted = false;
      _text = widget.item.displayTitle(locale.languageCode);
      return;
    }

    final bangumiId = widget.item.bangumiId;
    if (bangumiId == null) {
      _text = original;
      return;
    }

    final cached = AnilistTitleService.instance.peekEnglishTitle(bangumiId);
    if (cached != null && cached.isNotEmpty) {
      _text = cached;
      return;
    }

    // Fall back to the original name while the English title resolves.
    _text = original;
    if (!_resolveStarted) {
      _resolveStarted = true;
      _resolve(bangumiId);
    }
  }

  Future<void> _resolve(int bangumiId) async {
    final english = await AnilistTitleService.instance.resolveEnglishTitle(
      bangumiId: bangumiId,
      originalTitle: widget.item.titleOriginal ?? '',
    );
    if (!mounted) return;
    if (Localizations.localeOf(context).languageCode == 'zh') return;
    if (english != null && english.isNotEmpty && english != _text) {
      setState(() => _text = english);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _text,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
      style: widget.style,
    );
  }
}
