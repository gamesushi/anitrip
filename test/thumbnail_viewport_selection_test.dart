import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'package:anitrip/map/thumbnail_viewport_selection.dart';

/// 轻量替身：只关心 id 与坐标，避免为纯排序逻辑构造完整 PilgrimagePoint。
class _Item {
  const _Item(this.id, this.position);

  final String id;
  final LatLng position;
}

void main() {
  final center = LatLng(35.0, 139.0);

  /// 沿纬度递增排开的一串点位，p0 最近（就在中心上），pN 最远。
  List<_Item> ladder(int count) => [
    for (var i = 0; i < count; i++) _Item('p$i', LatLng(35.0 + i * 0.01, 139.0)),
  ];

  Set<String> select(
    Iterable<_Item> items,
    LatLng at,
    int threshold,
  ) => selectNearestThumbnailIds(
    items: items,
    positionOf: (item) => item.position,
    idOf: (item) => item.id,
    center: at,
    threshold: threshold,
  );

  test('可见点数不超过阈值时全部显示', () {
    final ids = select(ladder(5), center, 40);
    expect(ids, {'p0', 'p1', 'p2', 'p3', 'p4'});
  });

  test('点数恰好等于阈值时全部显示', () {
    final ids = select(ladder(10), center, 10);
    expect(ids.length, 10);
  });

  test('密集区只保留距视图中心最近的 N 个，而不是整体关闭', () {
    final ids = select(ladder(50), center, 10);

    expect(ids.length, 10, reason: '应保留 10 张，而不是返回空集合');
    expect(ids, {
      'p0',
      'p1',
      'p2',
      'p3',
      'p4',
      'p5',
      'p6',
      'p7',
      'p8',
      'p9',
    });
    // 远处的点位退化为圆点，不加载缩略图。
    expect(ids.contains('p49'), isFalse);
  });

  test('阈值为 0 或负数时关闭缩略图', () {
    expect(select(ladder(5), center, 0), isEmpty);
    expect(select(ladder(5), center, -1), isEmpty);
  });

  test('没有点位时返回空集合', () {
    expect(select(const <_Item>[], center, 10), isEmpty);
  });

  test('距离相同时按 id 稳定排序', () {
    const items = [
      _Item('b', LatLng(35.01, 139.0)),
      _Item('a', LatLng(35.01, 139.0)),
    ];

    expect(select(items, center, 1), {'a'});
  });

  test('经度差按纬度收敛修正（高纬度不放大经度距离）', () {
    // 同样 1 度的经度差，在高纬度对应的实际距离更短，
    // 因此高纬度点应比低纬度点更靠近中心。
    const highLat = _Item('high', LatLng(60.0, 140.0));
    const lowLat = _Item('low', LatLng(5.0, 140.0));
    final atHighLat = LatLng(60.0, 139.0);

    final ids = select([lowLat, highLat], atHighLat, 1);
    expect(ids, {'high'});
  });
}
