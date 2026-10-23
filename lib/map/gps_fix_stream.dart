import 'package:geolocator/geolocator.dart';

import 'gps_track.dart';

/// 把 geolocator 的定位流适配成录制器需要的 [GpsFix] 流。
///
/// 这是整条链路里唯一依赖定位插件的地方，录制器本身保持纯 Dart、可测试。
///
/// 精度字段的坑：本项目解析到的 geolocator platform interface 4.2.6 的
/// [Position] 没有 `hasAccuracy` 标志，未测得精度时给的是 **0.0 占位符**，
/// 与「误差为零」无法区分。真实的水平精度必然 > 0，因此这里把
/// `accuracy <= 0` 视为「未测得」转成 null，避免拿未测得的点当完美定位。
///
/// 海拔同理可能给 0.0 占位符，但它不参与过滤，直接透传存储。
Stream<GpsFix> gpsFixStream({
  int distanceFilterMeters = 10,
  LocationAccuracy accuracy = LocationAccuracy.best,
}) {
  return Geolocator.getPositionStream(
    locationSettings: LocationSettings(
      accuracy: accuracy,
      distanceFilter: distanceFilterMeters,
    ),
  ).map(
    (position) => GpsFix(
      latitude: position.latitude,
      longitude: position.longitude,
      timestamp: position.timestamp,
      accuracy: position.accuracy > 0 ? position.accuracy : null,
      altitude: position.altitude,
    ),
  );
}

/// 请求定位权限并检查定位服务是否可用。
///
/// 返回 null 表示可以开始录制；否则返回应当提示给用户的 i18n 键。
Future<String?> ensureGpsTrackPermission() async {
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return 'gpsLocationServiceDisabled';
  }
  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.denied) {
    return 'gpsPermissionDenied';
  }
  if (permission == LocationPermission.deniedForever) {
    return 'gpsPermissionDeniedForever';
  }
  return null;
}
