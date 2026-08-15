import 'package:flutter/material.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:anitrip/main.dart' show anitripApp;
import 'package:anitrip/plan/pilgrimage_models.dart' show AppSettings;
import 'package:anitrip/data/sample_pilgrimage_repository.dart'
    show SamplePilgrimageRepository;

void main() {
  enableFlutterDriverExtension();
  runApp(
    anitripApp(
      repository: SamplePilgrimageRepository(),
      initialSettings: AppSettings(language: 'zh'),
    ),
  );
}
