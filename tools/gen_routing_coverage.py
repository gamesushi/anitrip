#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
生成 anitrip 的 iOS「路线 App 覆盖地区文件」(Routing App Coverage File)。

Apple 要求:
- 格式: GeoJSON, type 必须是 "MultiPolygon" 或 "Polygon"
- 坐标顺序: [经度 lon, 纬度 lat]  (注意不是 lat, lon)
- 每个多边形环必须闭合 (首尾坐标相同)
- 不允许有 holes (GeoJSON 的 inner rings 不被 Apple Maps 支持)
- 环不能自相交
- 文件 < 5MB (Apple 建议), 上限 20MB
- WGS84

用法:
  # 生成默认的「日本四大岛 + 冲绳」覆盖文件
  python3 tools/gen_routing_coverage.py

  # 用真实巡礼点位生成 (传入经纬度 csv: lon,lat 每行一个)
  python3 tools/gen_routing_coverage.py --points spots.csv --out ios/Runner/routing_coverage.geojson

输出: ios/Runner/routing_coverage.geojson
然后在 App Store Connect 的 App 信息页 "Routing App Coverage File" 处上传此文件;
并在 Xcode scheme (Run -> Options -> Routing App Coverage File) 选它做本地测试。
"""
import argparse
import json
import os

# ---------------------------------------------------------------------------
# 默认覆盖区: 日本本土 (北海道/本州/九州/四国) + 冲绳, 简化轮廓。
# 坐标 [lon, lat]。这些只是粗略多边形, 足以覆盖 anitrip 巡礼点所在的日本范围。
# 若要更精确, 用 --points 传入真实点位让其算凸包/并集。
# ---------------------------------------------------------------------------
DEFAULT_ISLANDS = {
    "Hokkaido": [
        [141.5, 45.5], [145.5, 44.0], [145.0, 41.8], [140.8, 41.3],
        [140.0, 42.5], [141.5, 45.5],
    ],
    "Honshu": [
        [140.0, 39.5], [141.5, 38.3], [140.9, 37.2], [139.7, 35.7],
        [138.0, 34.5], [135.0, 34.0], [130.5, 33.5], [131.0, 34.5],
        [133.0, 35.5], [136.0, 36.0], [138.3, 37.0], [140.0, 39.5],
    ],
    "Kyushu": [
        [130.5, 33.5], [131.8, 33.0], [130.5, 31.0], [129.7, 32.0],
        [130.5, 33.5],
    ],
    "Shikoku": [
        [132.5, 34.6], [134.6, 34.0], [134.2, 33.4], [132.4, 33.4],
        [132.5, 34.6],
    ],
    "Okinawa": [
        [127.0, 26.2], [128.0, 26.2], [128.0, 26.7], [127.0, 26.7],
        [127.0, 26.2],
    ],
}


def _close_ring(ring):
    if ring and ring[0] != ring[-1]:
        ring = ring + [ring[0]]
    return ring


def build_from_islands(islands):
    polygons = [[_close_ring(list(r)) for r in islands.values()]]
    return polygons


def build_from_points(points):
    """用一组 [lon,lat] 点位生成覆盖多边形: 先按经度/纬度求凸包近似。

    这里用最简单的「最小包围盒」(bounding box) 作为兜底; 如果你想要贴合海岸线,
    请直接用 --islands 默认或手动提供更精确轮廓。bbox 会包含一些海洋, 但合法。
    """
    lons = [p[0] for p in points]
    lats = [p[1] for p in points]
    min_lon, max_lon = min(lons), max(lons)
    min_lat, max_lat = min(lats), max(lats)
    # 留 0.5 度余量, 避免边界点正好落在边上
    pad = 0.5
    ring = [
        [min_lon - pad, min_lat - pad],
        [max_lon + pad, min_lat - pad],
        [max_lon + pad, max_lat + pad],
        [min_lon - pad, max_lat + pad],
        [min_lon - pad, min_lat - pad],
    ]
    return [[ring]]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--points", help="可选: 经纬度 csv (每行 lon,lat), 用于按点位生成")
    ap.add_argument("--out", default="ios/Runner/routing_coverage.geojson")
    args = ap.parse_args()

    if args.points:
        pts = []
        with open(args.points, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith("#"):
                    continue
                a, b = line.split(",")[:2]
                pts.append([float(a), float(b)])
        polygons = build_from_points(pts)
        print(f"从 {len(pts)} 个点生成包围盒覆盖多边形")
    else:
        polygons = build_from_islands(DEFAULT_ISLANDS)
        print(f"使用默认日本轮廓 ({len(DEFAULT_ISLANDS)} 个岛块)")

    geojson = {
        "type": "MultiPolygon",
        "coordinates": polygons,
    }

    out_path = args.out
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(geojson, f, ensure_ascii=False, indent=2)
    print(f"已写出: {out_path}")
    # 校验
    assert geojson["type"] == "MultiPolygon"
    for poly in polygons:
        for ring in poly:
            assert ring[0] == ring[-1], "环未闭合!"
            assert len(ring) >= 4, "环顶点不足!"
    size = os.path.getsize(out_path)
    print(f"校验通过 (环闭合/顶点数OK). 文件大小 {size} 字节 (< 5MB: {size < 5*1024*1024})")


if __name__ == "__main__":
    main()
