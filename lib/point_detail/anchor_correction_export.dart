/// Exports collected anchor-location corrections into a review-friendly JSON
/// document.
///
/// The schema deliberately carries both the original coordinate and the
/// suggested one, plus the upstream identifiers (`source` / `sourceId`) so the
/// maintainer can trace each report back to its origin without querying user
/// devices again.
library;

import 'dart:convert';

import '../app_version.dart';
import '../data/pilgrimage_repository.dart';

const anchorCorrectionFileExtension = 'json';
const anchorCorrectionMimeType = 'application/json';
const anchorCorrectionFileExtensionLabel = 'anchor-corrections';
const anchorCorrectionFormat = 'anitrip-anchor-corrections';
const anchorCorrectionSchemaVersion = 1;

String suggestAnchorCorrectionFileName(DateTime exportedAt) {
  final iso = exportedAt.toUtc().toIso8601String();
  final compact = iso.replaceAll(RegExp(r'[:.]'), '-').replaceFirst('Z', '');
  return 'anitrip-$anchorCorrectionFileExtensionLabel-$compact.json';
}

/// Serializes [corrections] into the exchange document.
String encodeAnchorCorrectionsJson({
  required List<AnchorCorrectionReport> corrections,
  required DateTime generatedAt,
  String appVersion = anitripAppVersion,
}) {
  return const JsonEncoder.withIndent('  ').convert({
    'format': anchorCorrectionFormat,
    'schemaVersion': anchorCorrectionSchemaVersion,
    'generatedAt': generatedAt.toUtc().toIso8601String(),
    'appVersion': appVersion,
    'count': corrections.length,
    'corrections': corrections.map(_correctionToJson).toList(),
  });
}

/// Round-trips the exported document back into typed reports.
List<AnchorCorrectionReport> decodeAnchorCorrectionsJson(String source) {
  final decoded = jsonDecode(source);
  if (decoded is! Map<String, Object?>) {
    throw const FormatException('Invalid anchor-correction document root.');
  }
  if (decoded['format'] != anchorCorrectionFormat) {
    throw const FormatException('Unsupported anchor-correction format.');
  }
  if (decoded['schemaVersion'] != anchorCorrectionSchemaVersion) {
    throw const FormatException('Unsupported anchor-correction schema version.');
  }
  final items = decoded['corrections'];
  if (items is! List<Object?>) {
    throw const FormatException('Missing anchor-correction list.');
  }
  return items.map(_correctionFromJson).toList(growable: false);
}

Map<String, Object?> _correctionToJson(AnchorCorrectionReport item) {
  return <String, Object?>{
    'id': item.id,
    'createdAt': item.createdAt.toUtc().toIso8601String(),
    if (item.planId != null) 'planId': item.planId,
    'pointId': item.pointId,
    if (item.workId != null) 'workId': item.workId,
    if (item.workTitle != null) 'workTitle': item.workTitle,
    if (item.pointName != null) 'pointName': item.pointName,
    if (item.source != null) 'source': item.source,
    if (item.sourceId != null) 'sourceId': item.sourceId,
    'point': _coordinateToJson(
      latitude: item.pointLatitude,
      longitude: item.pointLongitude,
    ),
    if (item.hasSuggestedCoordinate)
      'suggested': _coordinateToJson(
        latitude: item.suggestedLatitude!,
        longitude: item.suggestedLongitude!,
      ),
    if (item.description != null && item.description!.trim().isNotEmpty)
      'description': item.description,
    if (item.photoPath != null) 'photoPath': item.photoPath,
  };
}

Map<String, Object?> _coordinateToJson({
  required double latitude,
  required double longitude,
}) {
  return <String, Object?>{
    'latitude': _roundTo6(latitude),
    'longitude': _roundTo6(longitude),
  };
}

/// Keeps coordinates at ~0.1m precision — well below the accuracy a phone GPS
/// can realistically deliver, so nothing meaningful is lost.
double _roundTo6(double value) => (value * 1e6).roundToDouble() / 1e6;

AnchorCorrectionReport _correctionFromJson(Object? raw) {
  if (raw is! Map<String, Object?>) {
    throw const FormatException('Invalid anchor-correction entry.');
  }
  final point = raw['point'];
  if (point is! Map<String, Object?>) {
    throw const FormatException('Missing anchor-correction point coordinate.');
  }
  final suggested = raw['suggested'];
  Map<String, Object?>? suggestedMap;
  if (suggested is Map<String, Object?>) {
    suggestedMap = suggested;
  }

  String requireId() {
    final value = raw['id'];
    if (value is! String) {
      throw const FormatException('Missing anchor-correction id.');
    }
    return value;
  }

  return AnchorCorrectionReport(
    id: requireId(),
    pointId: raw['pointId'] as String? ?? '',
    planId: raw['planId'] as String?,
    workId: raw['workId'] as String?,
    workTitle: raw['workTitle'] as String?,
    pointName: raw['pointName'] as String?,
    source: raw['source'] as String?,
    sourceId: raw['sourceId'] as String?,
    pointLatitude: (point['latitude'] as num).toDouble(),
    pointLongitude: (point['longitude'] as num).toDouble(),
    suggestedLatitude: (suggestedMap?['latitude'] as num?)?.toDouble(),
    suggestedLongitude: (suggestedMap?['longitude'] as num?)?.toDouble(),
    description: raw['description'] as String?,
    photoPath: raw['photoPath'] as String?,
    createdAt: _parseDate(raw['createdAt']),
  );
}

DateTime _parseDate(Object? raw) {
  if (raw is! String) {
    return DateTime.fromMicrosecondsSinceEpoch(0, isUtc: true);
  }
  final parsed = DateTime.tryParse(raw);
  return parsed ?? DateTime.fromMicrosecondsSinceEpoch(0, isUtc: true);
}
