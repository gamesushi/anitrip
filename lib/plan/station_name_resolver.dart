import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Resolves the nearest public-transit hub (railway station) to a coordinate
/// via the OpenStreetMap Overpass API, for naming auto-generated areas
/// (e.g. "宇治駅附近"). Returns null on any failure so callers fall back to a
/// generic name. Results are cached per rounded coordinate for the session.
class StationNameResolver {
  StationNameResolver({http.Client? httpClient})
    : _client = httpClient ?? http.Client();

  final http.Client _client;
  final Map<String, String> _cache = {};

  static final Uri _endpoint = Uri.parse(
    'https://overpass-api.de/api/interpreter',
  );

  Future<String?> nearestStation(
    LatLng center, {
    int radiusMeters = 3000,
  }) async {
    final key =
        '${center.latitude.toStringAsFixed(3)},${center.longitude.toStringAsFixed(3)}';
    final cached = _cache[key];
    if (cached != null) {
      return cached;
    }
    final name = await _query(center, radiusMeters);
    // Only cache successes so failures (504/timeout) can be retried.
    if (name != null) {
      _cache[key] = name;
    }
    return name;
  }

  Future<String?> _query(LatLng center, int radiusMeters) async {
    final overpass =
        '[out:json][timeout:8];'
        'node(around:$radiusMeters,${center.latitude},${center.longitude})'
        '[railway=station];out;';
    try {
      final response = await _client
          .post(
            _endpoint,
            // Overpass rejects the default Dart headers (406); it needs an
            // explicit User-Agent and a permissive Accept.
            headers: const {
              'User-Agent': 'MiriaGo/1.0 (anime pilgrimage app)',
              'Accept': '*/*',
            },
            body: {'data': overpass},
          )
          .timeout(const Duration(seconds: 9));
      if (response.statusCode != 200) {
        return null;
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, Object?>) {
        return null;
      }
      final elements = (decoded['elements'] as List?)
          ?.whereType<Map<String, Object?>>();
      if (elements == null) {
        return null;
      }

      const distance = Distance();
      String? bestName;
      var bestDistance = double.infinity;
      for (final element in elements) {
        final lat = (element['lat'] as num?)?.toDouble();
        final lon = (element['lon'] as num?)?.toDouble();
        if (lat == null || lon == null) {
          continue;
        }
        final tags = element['tags'];
        if (tags is! Map<String, Object?>) {
          continue;
        }
        final name = (tags['name:ja'] ?? tags['name'] ?? tags['name:en'])
            ?.toString();
        if (name == null || name.trim().isEmpty) {
          continue;
        }
        final d = distance(center, LatLng(lat, lon));
        if (d < bestDistance) {
          bestDistance = d;
          bestName = name.trim();
        }
      }
      return bestName;
    } catch (_) {
      return null;
    }
  }
}
