import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

import '../desktop/tauri_bridge.dart';
import 'anitabi_client.dart';
import 'anitabi_service_config.dart';

class AnitabiStaticDataReader {
  AnitabiStaticDataReader({http.Client? httpClient, this.serviceConfig})
    : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;
  final AnitabiServiceConfig? serviceConfig;

  Future<String> read(String fileName, {String? version}) async {
    _validateFileName(fileName);
    final config = serviceConfig ?? AnitabiServiceConfig.current;

    if (isTauriLauncherAvailable) {
      return fetchDesktopAnitabiStaticJson(
        fileName: fileName,
        version: version,
      );
    }

    if (kIsWeb) {
      // Try the bundled static asset first (served at site root in production
      // web builds), then fall back to the dev-server proxy used by
      // `flutter run -d chrome`.
      final assetUri = _withVersion(Uri.base.resolve('/$fileName'), version);
      try {
        return (await _checkedGet(assetUri)).body;
      } catch (_) {
        // Fall through to the proxy.
      }
      final proxyUri = _withVersion(
        Uri.base.resolve('/__anitabi_static__/$fileName'),
        version,
      );
      try {
        return (await _checkedGet(proxyUri)).body;
      } catch (error) {
        throw AnitabiStaticDataUnavailableException(error);
      }
    }

    // Mobile / desktop (iOS, Android, macOS, Windows, Linux): prefer the live
    // Anitabi static-data host (ww.anitabi.cn/d). If the network is
    // unreachable or the endpoint fails, fall back to the bundled snapshot
    // under web/ so the app stays usable offline.
    final primaryUri = config.staticDataUri(fileName, version: version);
    try {
      return (await _checkedGet(primaryUri)).body;
    } catch (_) {
      // Network failed; try the bundled asset as a resilient fallback.
    }

    try {
      return await _readLocalAsset(fileName);
    } catch (error) {
      throw AnitabiStaticDataUnavailableException(error);
    }
  }

  Future<String> _readLocalAsset(String fileName) async {
    return rootBundle.loadString('web/$fileName');
  }

  Uri _withVersion(Uri uri, String? version) {
    if (version == null || version.isEmpty) {
      return uri;
    }
    return uri.replace(queryParameters: {'v': version});
  }

  Future<http.Response> _checkedGet(Uri uri) async {
    final response = await _httpClient.get(uri);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AnitabiException(response.statusCode, response.body);
    }
    return response;
  }

  void _validateFileName(String fileName) {
    final valid = RegExp(r'^g\d*\.json$').hasMatch(fileName);
    if (!valid) {
      throw ArgumentError.value(fileName, 'fileName', 'Invalid Anitabi file');
    }
  }
}
