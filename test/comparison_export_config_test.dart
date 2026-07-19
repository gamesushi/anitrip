import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:anitrip/l10n/app_localizations.dart';
import 'package:anitrip/plan/pilgrimage_models.dart';
import 'package:anitrip/records/comparison_export_config.dart';
import 'package:anitrip/records/comparison_export_config_editor.dart';

void main() {
  test('serializes comparison export config for global reuse', () {
    const config = ComparisonExportConfig(
      borderWidthPercent: 1.5,
      borderColor: Colors.black,
      outputWidth: ComparisonOutputWidth.w1920,
      showLabels: true,
      showPilgrimName: true,
      pilgrimName: 'BilyHurington',
      showColorGradingParams: true,
      metadataFields: {
        ComparisonMetadataField.pointName,
        ComparisonMetadataField.episodeLabel,
      },
    );

    final restored = ComparisonExportConfig.fromJson(config.toJson());

    expect(restored.borderWidthPercent, 1.5);
    expect(restored.borderColor, Colors.black);
    expect(restored.outputWidth, ComparisonOutputWidth.w1920);
    expect(restored.showLabels, isTrue);
    expect(restored.showPilgrimName, isTrue);
    expect(restored.pilgrimName, 'BilyHurington');
    expect(restored.showColorGradingParams, isTrue);
    expect(restored.metadataFields, {
      ComparisonMetadataField.pointName,
      ComparisonMetadataField.episodeLabel,
    });
  });

  test('applies pilgrim identity to app settings', () {
    const config = ComparisonExportConfig(
      showPilgrimName: true,
      pilgrimName: '巡礼者',
    );

    final settings = config.applyToSettings(const AppSettings());
    final restored = const ComparisonExportConfig().withSettings(settings);

    expect(settings.comparisonShowPilgrimName, isTrue);
    expect(settings.comparisonPilgrimName, '巡礼者');
    expect(restored.showPilgrimName, isTrue);
    expect(restored.pilgrimName, '巡礼者');
  });

  testWidgets('summarizes default comparison export config', (WidgetTester tester) async {
    const config = ComparisonExportConfig(
      outputWidth: ComparisonOutputWidth.w1920,
      borderWidthPercent: 1,
      showLabels: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (BuildContext context) {
            final localizations = AppLocalizations.of(context)!;
            final expected = [
              localizations.comparisonWidthLabel('1920px'),
              localizations.comparisonBorderPercent('1.0'),
              localizations.comparisonShowLabels,
            ].join(' / ');
            expect(comparisonExportConfigSummary(context, config), expected);
            return const Placeholder();
          },
        ),
      ),
    );
  });
}
