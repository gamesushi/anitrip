import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:anitrip/data/local/app_database.dart';
import 'package:anitrip/data/local/sqlite_pilgrimage_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('persists cacheTilesOffline setting round-trip', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final repository = SqlitePilgrimageRepository(database: database);

    // 默认关闭
    expect((await repository.loadAppSettings()).cacheTilesOffline, isFalse);

    // 开启后写回再读回
    final toggled =
        (await repository.loadAppSettings()).copyWith(cacheTilesOffline: true);
    await repository.saveAppSettings(toggled);
    expect((await repository.loadAppSettings()).cacheTilesOffline, isTrue);

    // 再次关闭
    await repository.saveAppSettings(
      toggled.copyWith(cacheTilesOffline: false),
    );
    expect((await repository.loadAppSettings()).cacheTilesOffline, isFalse);
  });
}
