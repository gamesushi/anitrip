import 'dart:math' as math;

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// 地图视口：可见范围 + 视图中心。
///
/// [center] 用于密集区缩略图的优先级排序——可见点位多于阈值时，
/// 保留离视线焦点最近的若干张，而不是整体关闭。
class MapThumbnailViewport {
  const MapThumbnailViewport({required this.bounds, required this.center});

  final LatLngBounds bounds;
  final LatLng center;
}

/// 从可见条目中挑选用于显示缩略图的 id。
///
/// 设计要点：地图缩略图有加载成本，[threshold] 是**性能上限**（最多同时
/// 加载多少张），而不是「超过就整体关闭」的开关。
///
/// 旧行为在密集区（可见条目多于阈值）会整体返回空集合，导致东京这类点位
/// 密集的城市里缩略图整片消失、只剩圆点。这里改为优雅降级：始终保留离
/// 视图中心最近的 [threshold] 个，其余退化为圆点——加载量上限不变，
/// 但用户视线焦点附近仍有预览。
///
/// [threshold] 小于等于 0 表示关闭缩略图，返回空集合。
Set<String> selectNearestThumbnailIds<T>({
  required Iterable<T> items,
  required LatLng Function(T) positionOf,
  required String Function(T) idOf,
  required LatLng center,
  required int threshold,
}) {
  if (threshold <= 0) {
    return const <String>{};
  }
  final candidates = items.toList(growable: false);
  if (candidates.isEmpty) {
    return const <String>{};
  }
  if (candidates.length <= threshold) {
    return candidates.map(idOf).toSet();
  }

  // 等距圆柱投影近似：同一视口内纬度跨度很小，按此排序足够精确；
  // 经度差乘 cos(lat) 修正高纬度收敛。比大圆距离更省，且无需额外依赖。
  final cosLat = math.cos(center.latitude * math.pi / 180.0);
  double squaredDistanceToCenter(T item) {
    final position = positionOf(item);
    final dLat = position.latitude - center.latitude;
    final dLng = (position.longitude - center.longitude) * cosLat;
    return dLat * dLat + dLng * dLng;
  }

  final ordered = candidates.toList()
    ..sort((a, b) {
      final byDistance = squaredDistanceToCenter(
        a,
      ).compareTo(squaredDistanceToCenter(b));
      // 距离相同时按 id 兜底，保证结果稳定可测。
      return byDistance != 0 ? byDistance : idOf(a).compareTo(idOf(b));
    });
  return ordered.take(threshold).map(idOf).toSet();
}
