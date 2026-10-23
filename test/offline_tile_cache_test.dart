import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:anitrip/map/map_tile_config.dart';
import 'package:anitrip/map/offline_tile_cache.dart';
import 'package:anitrip/plan/pilgrimage_models.dart';

AppSettings _settings({
  required MapTileProvider provider,
  bool cacheTilesOffline = false,
}) =>
    AppSettings(mapTileProvider: provider, cacheTilesOffline: cacheTilesOffline);

void main() {
  group('offline caching ToS gating', () {
    test('only self-hosted Custom XYZ + opt-in may cache', () {
      // 允许：自定义 XYZ 且开启开关
      expect(
        offlineCachingAllowed(
          _settings(provider: MapTileProvider.customXyz, cacheTilesOffline: true),
        ),
        isTrue,
      );

      // 拒绝：自定义 XYZ 但未开启开关
      expect(
        offlineCachingAllowed(
          _settings(provider: MapTileProvider.customXyz, cacheTilesOffline: false),
        ),
        isFalse,
      );

      // 拒绝：所有第三方底图，即使开启了开关（版权红线）
      for (final provider in [
        MapTileProvider.openStreetMap,
        MapTileProvider.openFreeMap,
        MapTileProvider.customMapLibreStyle,
      ]) {
        expect(
          offlineCachingAllowed(
            _settings(provider: provider, cacheTilesOffline: true),
          ),
          isFalse,
          reason: '$provider must never be cached offline',
        );
      }
    });

    test('raster provider is disabled for third-party basemaps', () {
      final provider = rasterTileProvider(
        _settings(provider: MapTileProvider.openStreetMap),
      );
      expect(provider, isA<NetworkTileProvider>());
      final network = provider as NetworkTileProvider;
      // 第三方底图绝不挂载内置缓存
      expect(network.cachingProvider, isA<DisabledMapCachingProvider>());
    });

    test('raster provider is disabled when opt-in is off', () {
      final provider = rasterTileProvider(
        _settings(provider: MapTileProvider.customXyz, cacheTilesOffline: false),
      );
      expect(
        (provider as NetworkTileProvider).cachingProvider,
        isA<DisabledMapCachingProvider>(),
      );
    });

    test('signature changes when cache toggle flips', () {
      final a = mapTileConfigSignature(
        _settings(provider: MapTileProvider.customXyz, cacheTilesOffline: false),
      );
      final b = mapTileConfigSignature(
        _settings(provider: MapTileProvider.customXyz, cacheTilesOffline: true),
      );
      expect(a, isNot(equals(b)));
    });
  });

  group('formatCacheSize', () {
    test('formats bytes / KB / MB / GB', () {
      expect(formatCacheSize(0), '0 KB');
      expect(formatCacheSize(512), '512 B');
      expect(formatCacheSize(1536), '1.5 KB');
      expect(formatCacheSize(12 * 1024 * 1024), '12.0 MB');
      expect(formatCacheSize(1024 * 1024 * 1024), '1.0 GB');
    });
  });
}
