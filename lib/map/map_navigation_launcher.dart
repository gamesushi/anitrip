import 'package:url_launcher/url_launcher.dart';

import '../plan/pilgrimage_models.dart';

class MapNavigationLauncher {
  const MapNavigationLauncher();

  Future<bool> openWalking(PilgrimagePoint point, NavigationApp app) {
    return launchUrl(
      walkingNavigationUri(point, app),
      mode: LaunchMode.externalApplication,
    );
  }

  /// Opens the whole route (ordered list of points) in the chosen map app as a
  /// walking direction with waypoints. For apps that only support an origin and
  /// a destination (Apple / Amap / Baidu) the route is reduced to the first and
  /// last point; Google Maps keeps the intermediate waypoints.
  Future<bool> openRoute(List<PilgrimagePoint> points, NavigationApp app) {
    if (points.isEmpty) {
      return Future.value(false);
    }
    return launchUrl(
      routeNavigationUri(points, app),
      mode: LaunchMode.externalApplication,
    );
  }
}

Uri walkingNavigationUri(PilgrimagePoint point, NavigationApp app) {
  final latitude = _coordinate(point.position.latitude);
  final longitude = _coordinate(point.position.longitude);
  final destination = '$latitude,$longitude';
  final destinationName = _destinationName(point);

  return switch (app) {
    NavigationApp.googleMaps => Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'destination': destination,
      'travelmode': 'walking',
    }),
    NavigationApp.appleMaps => Uri.https('maps.apple.com', '/', {
      'daddr': destination,
      'dirflg': 'w',
    }),
    NavigationApp.amap => Uri.https('uri.amap.com', '/navigation', {
      'to': '$longitude,$latitude,$destinationName',
      'mode': 'walk',
      'coordinate': 'wgs84',
      'callnative': '1',
      'src': 'anitrip',
    }),
    NavigationApp.baiduMaps => Uri.http('api.map.baidu.com', '/direction', {
      'destination': 'latlng:$latitude,$longitude|name:$destinationName',
      'mode': 'walking',
      'coord_type': 'wgs84',
      'output': 'html',
      'src': 'webapp.anitrip.anitrip',
    }),
  };
}

String _coordinate(double value) => value.toStringAsFixed(6);

String _destinationName(PilgrimagePoint point) {
  final name = point.name.trim();
  if (name.isNotEmpty) {
    return name;
  }
  final subtitle = point.subtitle.trim();
  if (subtitle.isNotEmpty) {
    return subtitle;
  }
  return point.work.title;
}

Uri routeNavigationUri(List<PilgrimagePoint> points, NavigationApp app) {
  if (points.length == 1) {
    return walkingNavigationUri(points.first, app);
  }

  final coords = <String>[];
  final names = <String>[];
  for (final point in points) {
    coords.add(
      '${_coordinate(point.position.latitude)},'
      '${_coordinate(point.position.longitude)}',
    );
    names.add(_destinationName(point));
  }
  final origin = coords.first;
  final destination = coords.last;
  final originName = names.first;
  final destinationName = names.last;
  // Intermediate waypoints (everything except the first and last).
  final waypoints = coords.sublist(1, coords.length - 1);

  return switch (app) {
    NavigationApp.googleMaps => Uri.https('www.google.com', '/maps/dir/', {
        'api': '1',
        'travelmode': 'walking',
        'origin': origin,
        'destination': destination,
        if (waypoints.isNotEmpty) 'waypoints': waypoints.join('|'),
      }),
    NavigationApp.appleMaps => Uri.https('maps.apple.com', '/', {
        'saddr': origin,
        'daddr': destination,
        'dirflg': 'w',
      }),
    NavigationApp.amap => Uri.https('uri.amap.com', '/navigation', {
        'from': '$origin,$originName',
        'to': '$destination,$destinationName',
        'mode': 'walk',
        'coordinate': 'wgs84',
        'callnative': '1',
        'src': 'anitrip',
      }),
    NavigationApp.baiduMaps => Uri.http('api.map.baidu.com', '/direction', {
        'origin': 'latlng:${points.first.position.latitude},'
            '${points.first.position.longitude}|name:$originName',
        'destination': 'latlng:${points.last.position.latitude},'
            '${points.last.position.longitude}|name:$destinationName',
        'mode': 'walking',
        'coord_type': 'wgs84',
        'output': 'html',
        'src': 'webapp.anitrip.anitrip',
      }),
  };
}
