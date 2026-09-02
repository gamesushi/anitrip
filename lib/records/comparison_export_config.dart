import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

import '../plan/pilgrimage_models.dart';

enum ComparisonOutputWidth { auto, w1080, w1920, w2560, w3840 }

enum ComparisonMetadataField {
  capturedAt,
  workTitle,
  pointName,
  coordinates,
  anitabiId,
  episodeLabel,
}

extension ComparisonOutputWidthValue on ComparisonOutputWidth {
  double? get px => switch (this) {
    ComparisonOutputWidth.auto => null,
    ComparisonOutputWidth.w1080 => 1080,
    ComparisonOutputWidth.w1920 => 1920,
    ComparisonOutputWidth.w2560 => 2560,
    ComparisonOutputWidth.w3840 => 3840,
  };

  String get label => switch (this) {
    ComparisonOutputWidth.auto => 'Auto',
    ComparisonOutputWidth.w1080 => '1080px',
    ComparisonOutputWidth.w1920 => '1920px',
    ComparisonOutputWidth.w2560 => '2560px',
    ComparisonOutputWidth.w3840 => '3840px',
  };

  String getLocalizedLabel(BuildContext context) => switch (this) {
    ComparisonOutputWidth.auto => AppLocalizations.of(context)!.comparisonWidthAuto,
    ComparisonOutputWidth.w1080 => '1080px',
    ComparisonOutputWidth.w1920 => '1920px',
    ComparisonOutputWidth.w2560 => '2560px',
    ComparisonOutputWidth.w3840 => '3840px',
  };
}

extension ComparisonMetadataFieldLabel on ComparisonMetadataField {
  String get label => switch (this) {
    ComparisonMetadataField.capturedAt => 'Time',
    ComparisonMetadataField.workTitle => 'Work',
    ComparisonMetadataField.pointName => 'Point',
    ComparisonMetadataField.coordinates => 'Coordinates',
    ComparisonMetadataField.anitabiId => 'Anitabi ID',
    ComparisonMetadataField.episodeLabel => 'Episode',
  };

  String getLocalizedLabel(BuildContext context) => switch (this) {
    ComparisonMetadataField.capturedAt => AppLocalizations.of(context)!.comparisonMetaCapturedAt,
    ComparisonMetadataField.workTitle => AppLocalizations.of(context)!.comparisonMetaWork,
    ComparisonMetadataField.pointName => AppLocalizations.of(context)!.comparisonMetaPoint,
    ComparisonMetadataField.coordinates => AppLocalizations.of(context)!.comparisonMetaCoordinates,
    ComparisonMetadataField.anitabiId => 'Anitabi ID',
    ComparisonMetadataField.episodeLabel => AppLocalizations.of(context)!.comparisonMetaEpisode,
  };
}

class ComparisonExportConfig {
  const ComparisonExportConfig({
    this.borderWidthPercent = 0.5,
    this.borderColor = Colors.white,
    this.outputWidth = ComparisonOutputWidth.auto,
    this.showLabels = false,
    this.showPilgrimName = false,
    this.pilgrimName = '',
    this.showColorGradingParams = false,
    this.metadataFields = const {
      ComparisonMetadataField.capturedAt,
      ComparisonMetadataField.workTitle,
      ComparisonMetadataField.pointName,
    },
  });

  final double borderWidthPercent;
  final Color borderColor;
  final ComparisonOutputWidth outputWidth;
  final bool showLabels;
  final bool showPilgrimName;
  final String pilgrimName;
  final bool showColorGradingParams;
  final Set<ComparisonMetadataField> metadataFields;

  static ComparisonExportConfig lastUsed = const ComparisonExportConfig();

  ComparisonExportConfig withSettings(AppSettings settings) {
    return copyWith(
      showPilgrimName: settings.comparisonShowPilgrimName,
      pilgrimName: settings.comparisonPilgrimName,
    );
  }

  AppSettings applyToSettings(AppSettings settings) {
    return settings.copyWith(
      comparisonShowPilgrimName: showPilgrimName,
      comparisonPilgrimName: pilgrimName,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'borderWidthPercent': borderWidthPercent,
      'borderColor': borderColor.toARGB32(),
      'outputWidth': outputWidth.name,
      'showLabels': showLabels,
      'showPilgrimName': showPilgrimName,
      'pilgrimName': pilgrimName,
      'showColorGradingParams': showColorGradingParams,
      'metadataFields': metadataFields.map((field) => field.name).toList(),
    };
  }

  factory ComparisonExportConfig.fromJson(Map<String, Object?> json) {
    T enumValue<T extends Enum>(List<T> values, Object? value, T fallback) {
      return values.firstWhere(
        (candidate) => candidate.name == value,
        orElse: () => fallback,
      );
    }

    final fields = json['metadataFields'];
    return ComparisonExportConfig(
      borderWidthPercent:
          (json['borderWidthPercent'] as num?)?.toDouble().clamp(0.0, 3.0) ??
          0.5,
      borderColor: Color((json['borderColor'] as num?)?.toInt() ?? 0xFFFFFFFF),
      outputWidth: enumValue(
        ComparisonOutputWidth.values,
        json['outputWidth'],
        ComparisonOutputWidth.auto,
      ),
      showLabels: json['showLabels'] as bool? ?? false,
      showPilgrimName: json['showPilgrimName'] as bool? ?? false,
      pilgrimName: json['pilgrimName'] as String? ?? '',
      showColorGradingParams: json['showColorGradingParams'] as bool? ?? false,
      metadataFields: fields is List
          ? fields
                .map(
                  (field) => enumValue(
                    ComparisonMetadataField.values,
                    field,
                    ComparisonMetadataField.capturedAt,
                  ),
                )
                .toSet()
          : const {
              ComparisonMetadataField.capturedAt,
              ComparisonMetadataField.workTitle,
              ComparisonMetadataField.pointName,
            },
    );
  }

  ComparisonExportConfig copyWith({
    double? borderWidthPercent,
    Color? borderColor,
    ComparisonOutputWidth? outputWidth,
    bool? showLabels,
    bool? showPilgrimName,
    String? pilgrimName,
    bool? showColorGradingParams,
    Set<ComparisonMetadataField>? metadataFields,
  }) {
    return ComparisonExportConfig(
      borderWidthPercent: borderWidthPercent ?? this.borderWidthPercent,
      borderColor: borderColor ?? this.borderColor,
      outputWidth: outputWidth ?? this.outputWidth,
      showLabels: showLabels ?? this.showLabels,
      showPilgrimName: showPilgrimName ?? this.showPilgrimName,
      pilgrimName: pilgrimName ?? this.pilgrimName,
      showColorGradingParams:
          showColorGradingParams ?? this.showColorGradingParams,
      metadataFields: metadataFields ?? this.metadataFields,
    );
  }
}
