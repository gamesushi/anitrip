import 'package:flutter/foundation.dart';

import '../data/bangumi_api_client.dart';
import '../data/web_image_proxy.dart';
import '../data/web_posters.dart';

/// Resolves a work poster URL from a Bangumi subject id, deduping and caching
/// per id for the session so scrolling/rebuilds don't refetch. Returns null
/// when unavailable (offline, rate-limited, no cover) — cards then fall back to
/// the placeholder tile.
///
/// On the web platform, [kWebPosters] (compiled into the JS bundle) is used
/// as a zero-cost lookup before falling back to individual API calls.
class PosterResolver {
  PosterResolver({BangumiApiClient? bangumiClient})
    : _bangumi = bangumiClient ?? BangumiApiClient();

  final BangumiApiClient _bangumi;
  final Map<int, Future<String?>> _cache = {};

  Future<String?> resolve(int bangumiId) {
    return _cache.putIfAbsent(
      bangumiId,
      () => _resolveWithWebCache(bangumiId),
    );
  }

  Future<String?> _resolveWithWebCache(int bangumiId) async {
    String? url;
    // In web mode, prefer the compiled-in poster map — zero API cost.
    if (kIsWeb) {
      url = kWebPosters['$bangumiId'];
    }
    url ??= await _bangumi.fetchSubjectImageUrl(bangumiId);
    if (url == null || url.isEmpty) return null;
    // On web, route external cover URLs through a CORS proxy so CanvasKit can
    // display them (the CDN itself sends no Access-Control-Allow-Origin).
    return webImageProxy(url, width: 400);
  }
}
