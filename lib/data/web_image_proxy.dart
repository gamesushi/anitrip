import 'package:flutter/foundation.dart';

/// CORS-enabled image proxy used on the web platform.
///
/// Flutter's web renderer (CanvasKit — the only renderer since Flutter 3.22)
/// requests cross-origin images with `crossOrigin = 'anonymous'`, so the remote
/// host must send `Access-Control-Allow-Origin`. Bangumi's CDN (lain.bgm.tv)
/// and anitabi's image hosts do NOT, so direct loads fail on web even though
/// the same URLs work fine on native builds (which don't enforce CORS).
///
/// Routing the URL through this proxy — which adds the CORS header and can even
/// resize on the fly — restores image display without bundling every image
/// into the build. Swap [kWebImageProxyBase] if you prefer a self-hosted proxy.
const String kWebImageProxyBase = 'https://wsrv.nl/';

/// Rewrites an external image [url] so it can be loaded by Flutter web's
/// CanvasKit renderer. On non-web platforms (or for already same-origin /
/// already-proxied urls) the original [url] is returned unchanged.
///
/// [width] optionally constrains the proxied image width (aspect ratio is
/// preserved) which also shrinks payloads for thumbnails.
String webImageProxy(String url, {int? width}) {
  if (!kIsWeb) return url;

  // Same-origin asset, or already going through the proxy — leave untouched.
  if (url.startsWith('/') || url.toLowerCase().contains('wsrv.nl')) {
    return url;
  }
  // Only http(s) external urls need proxying.
  if (!url.startsWith('http://') && !url.startsWith('https://')) {
    return url;
  }

  final encoded = Uri.encodeComponent(url);
  if (width != null) {
    return '$kWebImageProxyBase?url=$encoded&w=$width&output=jpg';
  }
  return '$kWebImageProxyBase?url=$encoded';
}
