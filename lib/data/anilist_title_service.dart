import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Resolves English (or romaji fallback) anime titles from AniList, keyed by
/// the Bangumi subject id we already have for each work.
///
/// Used so the Explore tab can show a localized title when the app locale is
/// not Chinese — the anitabi catalog only ever carries the Chinese name
/// ([AnitabiMapWorkLite.titleZh]) and the original name
/// ([AnitabiMapWorkLite.titleOriginal]); it has no English field.
///
/// Results are cached in memory and persisted to a JSON file under the app
/// support directory, so a work's English title is only fetched once.
class AnilistTitleService {
  AnilistTitleService._();

  static final AnilistTitleService instance = AnilistTitleService._();

  static const String _endpoint = 'https://graphql.anilist.co';
  static const int _maxConcurrent = 5;
  static const String _kQuery =
      r'query($s:String){Media(type:ANIME,search:$s){id title{romaji english native}}}';

  final Map<int, String?> _cache = {};
  final Map<int, Future<String?>> _inflight = {};
  final List<_Pending> _queue = [];
  int _running = 0;
  File? _cacheFile;
  Future<void>? _loadFuture;

  /// Synchronous peek — returns the cached English title, `null` when the work
  /// is unknown (never fetched) or known to have no English title.
  String? peekEnglishTitle(int bangumiId) => _cache[bangumiId];

  /// Returns the English (or romaji) title for [bangumiId], fetching it from
  /// AniList by [originalTitle] on a cache miss. Network/parse failures return
  /// `null` without caching, so the lookup can be retried later.
  Future<String?> resolveEnglishTitle({
    required int bangumiId,
    required String originalTitle,
  }) {
    if (_cache.containsKey(bangumiId)) {
      return Future.value(_cache[bangumiId]);
    }
    final existing = _inflight[bangumiId];
    if (existing != null) {
      return existing;
    }
    final completer = Completer<String?>();
    _inflight[bangumiId] = completer.future;
    _enqueue(_Pending(bangumiId, originalTitle, completer));
    return completer.future;
  }

  void _enqueue(_Pending pending) {
    _queue.add(pending);
    _pump();
  }

  void _pump() {
    while (_running < _maxConcurrent && _queue.isNotEmpty) {
      final pending = _queue.removeAt(0);
      _running++;
      // Intentionally not awaited: the loop continues on the microtask queue.
      _run(pending).whenComplete(() {
        _running--;
        _pump();
      });
    }
  }

  Future<void> _run(_Pending pending) async {
    String? result;
    try {
      await _ensureLoaded();
      if (pending.originalTitle.trim().isEmpty) {
        _cache[pending.bangumiId] = null;
        _inflight.remove(pending.bangumiId);
        pending.completer.complete(null);
        return;
      }
      final response = await http
          .post(
            Uri.parse(_endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'User-Agent': 'anitrip/1.1.5 (https://github.com/bilyhurington/anitrip)',
            },
            body: jsonEncode({
              'query': _kQuery,
              'variables': {'s': pending.originalTitle},
            }),
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final media = decoded['data']?['Media'] as Map<String, dynamic>?;
        if (media != null) {
          final title = media['title'] as Map<String, dynamic>?;
          result = (title?['english'] as String?) ?? (title?['romaji'] as String?);
        }
      }
    } catch (_) {
      // Leave uncached so it can be retried; don't poison the negative cache.
      _inflight.remove(pending.bangumiId);
      pending.completer.complete(null);
      return;
    }
    _cache[pending.bangumiId] = result;
    _inflight.remove(pending.bangumiId);
    _persist();
    pending.completer.complete(result);
  }

  Future<void> _ensureLoaded() {
    _loadFuture ??= _doLoad();
    return _loadFuture!;
  }

  Future<void> _doLoad() async {
    try {
      final dir = await getApplicationSupportDirectory();
      _cacheFile = File('${dir.path}/anilist_title_cache.json');
      if (await _cacheFile!.exists()) {
        final raw = await _cacheFile!.readAsString();
        final map = jsonDecode(raw) as Map<String, dynamic>;
        for (final entry in map.entries) {
          final value = entry.value;
          _cache[int.parse(entry.key)] =
              value == null ? null : (value['en'] as String?);
        }
      }
    } catch (_) {
      // Cache load is best-effort.
    }
  }

  void _persist() {
    try {
      if (_cacheFile == null) return;
      final map = <String, dynamic>{};
      for (final entry in _cache.entries) {
        map[entry.key.toString()] =
            entry.value == null ? null : {'en': entry.value};
      }
      _cacheFile!.writeAsStringSync(jsonEncode(map));
    } catch (_) {
      // Persist is best-effort.
    }
  }
}

class _Pending {
  _Pending(this.bangumiId, this.originalTitle, this.completer);

  final int bangumiId;
  final String originalTitle;
  final Completer<String?> completer;
}
