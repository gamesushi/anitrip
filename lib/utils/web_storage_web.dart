import 'package:web/web.dart' as web;
import 'dart:convert';
import '../plan/pilgrimage_models.dart';

void saveWebSettings(AppSettings settings) {
  try {
    final map = {
      'uiScale': settings.uiScale,
      'fontScale': settings.fontScale,
      'themeMode': settings.themeMode.name,
      'cameraCaptureAspectRatio': settings.cameraCaptureAspectRatio.name,
      'cameraFallbackAspectRatio': settings.cameraFallbackAspectRatio.name,
      'cameraMinZoom': settings.cameraMinZoom,
      'cameraMaxZoom': settings.cameraMaxZoom,
      'referenceImageScale': settings.referenceImageScale,
      'nearestAssignDistanceMeters': settings.nearestAssignDistanceMeters,
      'themePalette': settings.themePalette.name,
      'mapTileProvider': settings.mapTileProvider.name,
      'openFreeMapStyle': settings.openFreeMapStyle.name,
      'anitabiImageSource': settings.anitabiImageSource.name,
      'navigationApp': settings.navigationApp.name,
      'customXyzTileUrl': settings.customXyzTileUrl,
      'customMapLibreStyleUrl': settings.customMapLibreStyleUrl,
      'saveVisitPhotoToGallery': settings.saveVisitPhotoToGallery,
      'autoSaveComparisonToGallery': settings.autoSaveComparisonToGallery,
      'comparisonShowPilgrimName': settings.comparisonShowPilgrimName,
      'comparisonPilgrimName': settings.comparisonPilgrimName,
      'customThemeColorName': settings.customThemeColorName,
      'customThemeColorValue': settings.customThemeColorValue,
      'customThemeColors': settings.customThemeColors.map((c) => {
        'name': c.name,
        'value': c.value,
      }).toList(),
      'customCameraAspectRatioWidth': settings.customCameraAspectRatioWidth,
      'customCameraAspectRatioHeight': settings.customCameraAspectRatioHeight,
      'mapThumbnailVisibleThreshold': settings.mapThumbnailVisibleThreshold,
      'mapThumbnailConcurrentLoads': settings.mapThumbnailConcurrentLoads,
      'language': settings.language,
    };
    web.window.localStorage.setItem('miriago_web_settings', json.encode(map));
  } catch (_) {}
}

AppSettings loadWebSettings(AppSettings defaultValue) {
  try {
    final jsonStr = web.window.localStorage.getItem('miriago_web_settings');
    if (jsonStr == null) return defaultValue;
    final map = json.decode(jsonStr) as Map<String, dynamic>;
    
    T parseEnum<T extends Enum>(List<T> values, String name, T fallback) {
      return values.firstWhere((e) => e.name == name, orElse: () => fallback);
    }

    return AppSettings(
      uiScale: (map['uiScale'] as num?)?.toDouble() ?? defaultValue.uiScale,
      fontScale: (map['fontScale'] as num?)?.toDouble() ?? defaultValue.fontScale,
      themeMode: parseEnum(AppThemeMode.values, map['themeMode'] as String? ?? '', defaultValue.themeMode),
      cameraCaptureAspectRatio: parseEnum(CameraPhotoAspectRatio.values, map['cameraCaptureAspectRatio'] as String? ?? '', defaultValue.cameraCaptureAspectRatio),
      cameraFallbackAspectRatio: parseEnum(CameraPhotoAspectRatio.values, map['cameraFallbackAspectRatio'] as String? ?? '', defaultValue.cameraFallbackAspectRatio),
      cameraMinZoom: (map['cameraMinZoom'] as num?)?.toDouble() ?? defaultValue.cameraMinZoom,
      cameraMaxZoom: (map['cameraMaxZoom'] as num?)?.toDouble() ?? defaultValue.cameraMaxZoom,
      referenceImageScale: (map['referenceImageScale'] as num?)?.toDouble() ?? defaultValue.referenceImageScale,
      nearestAssignDistanceMeters: (map['nearestAssignDistanceMeters'] as num?)?.toDouble() ?? defaultValue.nearestAssignDistanceMeters,
      themePalette: parseEnum(AppThemePalette.values, map['themePalette'] as String? ?? '', defaultValue.themePalette),
      mapTileProvider: parseEnum(MapTileProvider.values, map['mapTileProvider'] as String? ?? '', defaultValue.mapTileProvider),
      openFreeMapStyle: parseEnum(OpenFreeMapStyle.values, map['openFreeMapStyle'] as String? ?? '', defaultValue.openFreeMapStyle),
      anitabiImageSource: parseEnum(AnitabiImageSource.values, map['anitabiImageSource'] as String? ?? '', defaultValue.anitabiImageSource),
      navigationApp: parseEnum(NavigationApp.values, map['navigationApp'] as String? ?? '', defaultValue.navigationApp),
      customXyzTileUrl: map['customXyzTileUrl'] as String? ?? defaultValue.customXyzTileUrl,
      customMapLibreStyleUrl: map['customMapLibreStyleUrl'] as String? ?? defaultValue.customMapLibreStyleUrl,
      saveVisitPhotoToGallery: map['saveVisitPhotoToGallery'] as bool? ?? defaultValue.saveVisitPhotoToGallery,
      autoSaveComparisonToGallery: map['autoSaveComparisonToGallery'] as bool? ?? defaultValue.autoSaveComparisonToGallery,
      comparisonShowPilgrimName: map['comparisonShowPilgrimName'] as bool? ?? defaultValue.comparisonShowPilgrimName,
      comparisonPilgrimName: map['comparisonPilgrimName'] as String? ?? defaultValue.comparisonPilgrimName,
      customThemeColorName: map['customThemeColorName'] as String? ?? defaultValue.customThemeColorName,
      customThemeColorValue: map['customThemeColorValue'] as int? ?? defaultValue.customThemeColorValue,
      customThemeColors: (map['customThemeColors'] as List?)?.map((c) {
        final m = c as Map;
        return CustomThemeColor(
          name: m['name'] as String,
          value: m['value'] as int,
        );
      }).toList() ?? defaultValue.customThemeColors,
      customCameraAspectRatioWidth: (map['customCameraAspectRatioWidth'] as num?)?.toDouble() ?? defaultValue.customCameraAspectRatioWidth,
      customCameraAspectRatioHeight: (map['customCameraAspectRatioHeight'] as num?)?.toDouble() ?? defaultValue.customCameraAspectRatioHeight,
      mapThumbnailVisibleThreshold: map['mapThumbnailVisibleThreshold'] as int? ?? defaultValue.mapThumbnailVisibleThreshold,
      mapThumbnailConcurrentLoads: map['mapThumbnailConcurrentLoads'] as int? ?? defaultValue.mapThumbnailConcurrentLoads,
      language: map['language'] as String? ?? defaultValue.language,
    );
  } catch (_) {
    return defaultValue;
  }
}
