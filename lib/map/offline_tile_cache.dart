import 'dart:io';

import 'package:flutter_map/flutter_map.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// flutter_map 内置缓存提供方存放瓦片文件所用的子目录名
/// （见 flutter_map `BuiltInMapCachingProviderImpl` 实现）。
const String _cacheSubDir = 'fm_cache';

Future<String> _offlineCacheDirPath() async {
  final base = await getApplicationCacheDirectory();
  return p.join(base.absolute.path, _cacheSubDir);
}

/// 离线瓦片缓存当前占用的字节数。无法访问文件系统时（如测试环境）返回 0。
Future<int> offlineTileCacheSizeBytes() async {
  try {
    final dir = Directory(await _offlineCacheDirPath());
    if (!await dir.exists()) return 0;
    var total = 0;
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        total += await entity.length();
      }
    }
    return total;
  } catch (_) {
    return 0;
  }
}

/// 清除全部离线瓦片缓存（flutter_map 内置缓存目录 `fm_cache`）。
///
/// 通过 [BuiltInMapCachingProvider.destroy] 安全终止后台写入 worker 并删除目录；
/// 缓存目录不存在或平台不可用时静默忽略。
Future<void> clearOfflineTileCache() async {
  try {
    final dir = Directory(await _offlineCacheDirPath());
    if (!await dir.exists()) return;
    await BuiltInMapCachingProvider.getOrCreateInstance().destroy(
      deleteCache: true,
    );
  } catch (_) {
    // 无缓存目录或平台不可用时忽略。
  }
}

/// 将字节数格式化为人类可读的缓存大小，例如 "12.3 MB" / "0 KB"。
String formatCacheSize(int bytes) {
  if (bytes <= 0) return '0 KB';
  const units = ['B', 'KB', 'MB', 'GB'];
  var size = bytes.toDouble();
  var unit = 0;
  while (size >= 1024 && unit < units.length - 1) {
    size /= 1024;
    unit += 1;
  }
  final value = unit == 0 ? size.toStringAsFixed(0) : size.toStringAsFixed(1);
  return '$value ${units[unit]}';
}
