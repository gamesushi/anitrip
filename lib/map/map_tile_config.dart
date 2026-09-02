import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_maplibre/flutter_map_maplibre.dart';
import 'package:url_launcher/url_launcher.dart';

import '../plan/pilgrimage_models.dart';
import '../l10n/app_localizations.dart';

const openFreeMapStyleUrl = 'https://tiles.openfreemap.org/styles/liberty';
const openStreetMapTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
const mapUserAgentPackageName = 'app.anitrip.anitrip';

// 免费、无需 token 的 MapLibre/Mapbox v8 样式（CARTO 矢量底图，CORS 友好）
// 视觉上最接近 anitabi 的浅色简洁底图：Positron=极简灰阶，Voyager=清爽微彩，Dark=深色
const cartoPositronStyleUrl =
    'https://basemaps.cartocdn.com/gl/positron-gl-style/style.json';
const cartoVoyagerStyleUrl =
    'https://basemaps.cartocdn.com/gl/voyager-gl-style/style.json';
const cartoDarkStyleUrl =
    'https://basemaps.cartocdn.com/gl/dark-matter-gl-style/style.json';

class OpenFreeMapStyleOption {
  const OpenFreeMapStyleOption({
    required this.style,
    required this.label,
    required this.styleUrl,
  });

  final OpenFreeMapStyle style;
  final String label;
  final String styleUrl;
}

class MapTileProviderOption {
  const MapTileProviderOption({
    required this.provider,
    required this.label,
  });

  final MapTileProvider provider;
  final String label;
}

const openFreeMapStyleOptions = [
  OpenFreeMapStyleOption(
    style: OpenFreeMapStyle.liberty,
    label: 'Liberty',
    styleUrl: 'https://tiles.openfreemap.org/styles/liberty',
  ),
  OpenFreeMapStyleOption(
    style: OpenFreeMapStyle.bright,
    label: 'Bright',
    styleUrl: 'https://tiles.openfreemap.org/styles/bright',
  ),
  OpenFreeMapStyleOption(
    style: OpenFreeMapStyle.positron,
    label: 'Positron',
    styleUrl: 'https://tiles.openfreemap.org/styles/positron',
  ),
  OpenFreeMapStyleOption(
    style: OpenFreeMapStyle.dark,
    label: 'Dark',
    styleUrl: 'https://tiles.openfreemap.org/styles/dark',
  ),
  OpenFreeMapStyleOption(
    style: OpenFreeMapStyle.fiord,
    label: 'Fiord',
    styleUrl: 'https://tiles.openfreemap.org/styles/fiord',
  ),
];

const mapTileProviderOptions = [
  MapTileProviderOption(
    provider: MapTileProvider.openFreeMap,
    label: 'OpenFreeMap',
  ),
  MapTileProviderOption(
    provider: MapTileProvider.openStreetMap,
    label: 'OpenStreetMap',
  ),
  MapTileProviderOption(
    provider: MapTileProvider.customXyz,
    label: 'Custom XYZ',
  ),
  MapTileProviderOption(
    provider: MapTileProvider.customMapLibreStyle,
    label: 'Custom MapLibre',
  ),
];

OpenFreeMapStyleOption openFreeMapStyleOption(OpenFreeMapStyle style) {
  return openFreeMapStyleOptions.firstWhere(
    (option) => option.style == style,
    orElse: () => openFreeMapStyleOptions.first,
  );
}

MapTileProviderOption mapTileProviderOption(MapTileProvider provider) {
  return mapTileProviderOptions.firstWhere(
    (option) => option.provider == provider,
    orElse: () => mapTileProviderOptions.first,
  );
}

bool mapProviderUsesMapLibre(MapTileProvider provider) {
  return provider == MapTileProvider.openFreeMap ||
      provider == MapTileProvider.customMapLibreStyle;
}

String mapLibreStyleUrl(AppSettings settings) {
  if (settings.mapTileProvider == MapTileProvider.customMapLibreStyle) {
    final custom = settings.customMapLibreStyleUrl.trim();
    if (_isHttpUrl(custom)) {
      return custom;
    }
  }
  return openFreeMapStyleOption(settings.openFreeMapStyle).styleUrl;
}

String xyzTileUrl(AppSettings settings) {
  if (settings.mapTileProvider == MapTileProvider.customXyz) {
    final custom = settings.customXyzTileUrl.trim();
    if (isValidXyzTileUrl(custom)) {
      return custom;
    }
  }
  return openStreetMapTileUrl;
}

Widget configuredMapTileLayer(AppSettings settings) {
  final layerKey = ValueKey(mapTileConfigSignature(settings));
  if (mapProviderUsesMapLibre(settings.mapTileProvider) &&
      !_isFlutterWidgetTest) {
    return MapLibreLayer(key: layerKey, initStyle: mapLibreStyleUrl(settings));
  }
  return configuredRasterTileLayer(settings, key: layerKey);
}

TileLayer configuredRasterTileLayer(AppSettings settings, {Key? key}) {
  return TileLayer(
    key: key,
    urlTemplate: xyzTileUrl(settings),
    userAgentPackageName: mapUserAgentPackageName,
  );
}

String mapTileConfigSignature(AppSettings settings) {
  return [
    settings.mapTileProvider.name,
    settings.openFreeMapStyle.name,
    settings.customXyzTileUrl.trim(),
    settings.customMapLibreStyleUrl.trim(),
  ].join('|');
}

RichAttributionWidget configuredMapAttribution(AppSettings settings) {
  final provider = settings.mapTileProvider;
  if (mapProviderUsesMapLibre(provider)) {
    final styleUrl = mapLibreStyleUrl(settings);
    if (styleUrl.contains('cartocdn.com')) {
      return RichAttributionWidget(
        attributions: [
          TextSourceAttribution(
            '© CARTO © OpenStreetMap contributors',
            onTap: () {
              launchUrl(
                Uri.parse('https://carto.com/attributions'),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
        ],
      );
    }
    if (styleUrl.contains('openfreemap.org')) {
      return RichAttributionWidget(
        attributions: [
          TextSourceAttribution(
            'OpenFreeMap / OpenMapTiles contributors',
            onTap: () {
              launchUrl(
                Uri.parse('https://openfreemap.org/'),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
        ],
      );
    }
    return RichAttributionWidget(
      attributions: [
        TextSourceAttribution(
          'MapLibre style',
          onTap: () {
            launchUrl(
              Uri.parse('https://maplibre.org/'),
              mode: LaunchMode.externalApplication,
            );
          },
        ),
      ],
    );
  }
  return RichAttributionWidget(
    attributions: [
      TextSourceAttribution(
        'OpenStreetMap contributors',
        onTap: () {
          launchUrl(
            Uri.parse('https://www.openstreetmap.org/copyright'),
            mode: LaunchMode.externalApplication,
          );
        },
      ),
    ],
  );
}

String? validateMapTileSettings(BuildContext context, AppSettings settings) {
  final l10n = AppLocalizations.of(context)!;
  return switch (settings.mapTileProvider) {
    MapTileProvider.customXyz =>
      isValidXyzTileUrl(settings.customXyzTileUrl.trim())
          ? null
          : l10n.mapCustomXyzUrlInvalid,
    MapTileProvider.customMapLibreStyle =>
      _isHttpUrl(settings.customMapLibreStyleUrl.trim())
          ? null
          : l10n.mapMapLibreUrlRequireHttp,
    _ => null,
  };
}

bool isValidXyzTileUrl(String value) {
  return _isHttpUrl(value) &&
      value.contains('{z}') &&
      value.contains('{x}') &&
      value.contains('{y}');
}

bool _isHttpUrl(String value) {
  final uri = Uri.tryParse(value);
  return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
}

bool get _isFlutterWidgetTest {
  return WidgetsBinding.instance.runtimeType.toString().contains('TestWidgets');
}
