import 'package:latlong2/latlong.dart';

import '../data/anitabi_client.dart';

/// Represents a nearby anime spot discovered by the radar.
class NearbyRadarSpot {
  const NearbyRadarSpot({
    required this.bangumiId,
    required this.pointId,
    required this.work,
    required this.position,
    required this.distanceMeters,
    required this.isImported,
  });

  final int bangumiId;
  final String pointId;
  final AnitabiMapWorkLite work;
  final LatLng position;
  final double distanceMeters;
  final bool isImported;
}

/// Formats distance into a clean human-readable string (e.g. "450 m" or "2.3 km").
String formatRadarDistance(double meters) {
  if (meters < 1000) {
    return '${meters.round()} m';
  }
  final km = meters / 1000.0;
  return '${km.toStringAsFixed(1)} km';
}

/// Scans the full Anitabi catalog for anime pilgrimage spots within a radius.
class NearbyRadarService {
  const NearbyRadarService();

  static const double defaultRadiusMeters = 5000.0; // 5 km
  static const int defaultMaxSpots = 60;

  List<NearbyRadarSpot> scanNearby({
    required LatLng center,
    required List<AnitabiMapWorkLite> catalogWorks,
    required Set<int> importedBangumiIds,
    double radiusMeters = defaultRadiusMeters,
    int maxSpots = defaultMaxSpots,
  }) {
    const distance = Distance();
    final results = <NearbyRadarSpot>[];

    for (final work in catalogWorks) {
      final isImported = importedBangumiIds.contains(work.bangumiId);
      for (final point in work.points.values) {
        final d = distance.as(LengthUnit.Meter, center, point.position);
        if (d <= radiusMeters) {
          results.add(
            NearbyRadarSpot(
              bangumiId: work.bangumiId,
              pointId: point.id,
              work: work,
              position: point.position,
              distanceMeters: d,
              isImported: isImported,
            ),
          );
        }
      }
    }

    results.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    if (results.length > maxSpots) {
      return results.sublist(0, maxSpots);
    }
    return results;
  }
}
