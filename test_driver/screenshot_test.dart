import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

const outDir =
    '/Users/hebeihang/DEV/sns/anitrip/docs/promo_screenshots/simulator';

void main() {
  group('anitrip screenshots', () {
    late FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      await driver.close();
    });

    Future<void> shot(String name) async {
      final bytes = await driver.screenshot();
      File('$outDir/$name.png').writeAsBytesSync(bytes);
      // ignore: avoid_print
      print('saved $outDir/$name.png');
    }

    test('capture main tabs', () async {
      await driver.waitFor(find.text('探索'));
      await Future.delayed(const Duration(seconds: 2));
      await shot('01-explore');

      await driver.tap(find.text('计划'));
      await Future.delayed(const Duration(seconds: 2));
      await shot('02-plan');

      await driver.tap(find.text('地图'));
      await Future.delayed(const Duration(seconds: 3));
      await shot('03-map');

      await driver.tap(find.text('我的'));
      await Future.delayed(const Duration(seconds: 2));
      await shot('04-profile');
    });
  });
}
