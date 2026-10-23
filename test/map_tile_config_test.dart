import 'package:flutter_test/flutter_test.dart';
import 'package:anitrip/map/map_tile_config.dart';
import 'package:anitrip/plan/pilgrimage_models.dart';

void main() {
  test('uses CARTO Voyager as default MapLibre style', () {
    const settings = AppSettings();

    expect(settings.mapTileProvider, MapTileProvider.customMapLibreStyle);
    expect(settings.customMapLibreStyleUrl, cartoVoyagerStyleUrl);
    expect(mapProviderUsesMapLibre(settings.mapTileProvider), isTrue);
    expect(mapLibreStyleUrl(settings), cartoVoyagerStyleUrl);
    expect(validateMapTileSettings(null, settings), isNull);
  });

  test('selects OpenFreeMap style URLs', () {
    const settings = AppSettings(
      mapTileProvider: MapTileProvider.openFreeMap,
      openFreeMapStyle: OpenFreeMapStyle.positron,
    );

    expect(
      mapLibreStyleUrl(settings),
      'https://tiles.openfreemap.org/styles/positron',
    );
    expect(
      openFreeMapStyleOption(OpenFreeMapStyle.dark).styleUrl,
      'https://tiles.openfreemap.org/styles/dark',
    );
  });

  test('validates custom XYZ tile URLs', () {
    const valid = AppSettings(
      mapTileProvider: MapTileProvider.customXyz,
      customXyzTileUrl: 'https://example.com/tiles/{z}/{x}/{y}.png',
    );
    const invalid = AppSettings(
      mapTileProvider: MapTileProvider.customXyz,
      customXyzTileUrl: 'https://example.com/tiles.png',
    );

    expect(validateMapTileSettings(null, valid), isNull);
    expect(validateMapTileSettings(null, invalid), isNotNull);
    expect(xyzTileUrl(valid), 'https://example.com/tiles/{z}/{x}/{y}.png');
    expect(xyzTileUrl(invalid), openStreetMapTileUrl);
  });

  test('validates custom MapLibre style URLs', () {
    const valid = AppSettings(
      mapTileProvider: MapTileProvider.customMapLibreStyle,
      customMapLibreStyleUrl: 'https://example.com/style.json',
    );
    const invalid = AppSettings(
      mapTileProvider: MapTileProvider.customMapLibreStyle,
      customMapLibreStyleUrl: 'ftp://example.com/style.json',
    );

    expect(validateMapTileSettings(null, valid), isNull);
    expect(validateMapTileSettings(null, invalid), isNotNull);
    expect(mapLibreStyleUrl(valid), 'https://example.com/style.json');
    expect(mapLibreStyleUrl(invalid), openFreeMapStyleUrl);
  });

  test('map tile signature changes when active style changes', () {
    const liberty = AppSettings();
    const positron = AppSettings(openFreeMapStyle: OpenFreeMapStyle.positron);
    const custom = AppSettings(
      mapTileProvider: MapTileProvider.customXyz,
      customXyzTileUrl: 'https://example.com/{z}/{x}/{y}.png',
    );

    expect(
      mapTileConfigSignature(liberty),
      isNot(mapTileConfigSignature(positron)),
    );
    expect(
      mapTileConfigSignature(liberty),
      isNot(mapTileConfigSignature(custom)),
    );
  });
}
