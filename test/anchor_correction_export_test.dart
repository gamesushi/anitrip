import 'dart:convert';

import 'package:anitrip/data/pilgrimage_repository.dart';
import 'package:anitrip/point_detail/anchor_correction_export.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final createdAt = DateTime.utc(2026, 10, 23, 4, 30);

  AnchorCorrectionReport sample({String id = 'c1'}) {
    return AnchorCorrectionReport(
      id: id,
      pointId: 'p1',
      planId: 'plan1',
      workId: 'w1',
      workTitle: 'すずめの戸締まり',
      pointName: '神楽坂の階段',
      source: 'anitabi',
      sourceId: '12345',
      pointLatitude: 35.7012345678,
      pointLongitude: 139.7401234567,
      suggestedLatitude: 35.7019,
      suggestedLongitude: 139.7406,
      description: '实际位置在标注点以北约 50m',
      photoPath: '/tmp/photo.jpg',
      createdAt: createdAt,
    );
  }

  group('encodeAnchorCorrectionsJson', () {
    test('emits schema envelope and counts', () {
      final json = encodeAnchorCorrectionsJson(
        corrections: [sample(), sample(id: 'c2')],
        generatedAt: createdAt,
      );
      final decoded = jsonDecode(json) as Map<String, Object?>;

      expect(decoded['format'], anchorCorrectionFormat);
      expect(decoded['schemaVersion'], anchorCorrectionSchemaVersion);
      expect(decoded['generatedAt'], '2026-10-23T04:30:00.000Z');
      expect(decoded['count'], 2);
      expect((decoded['corrections'] as List<Object?>).length, 2);
      expect(decoded['appVersion'], isA<String>());
    });

    test('keeps both original and suggested coordinates at 1e-6 precision', () {
      final decoded = jsonDecode(
        encodeAnchorCorrectionsJson(
          corrections: [sample()],
          generatedAt: createdAt,
        ),
      ) as Map<String, Object?>;
      final entry = (decoded['corrections'] as List<Object?>).first
          as Map<String, Object?>;

      expect(entry['point'], {'latitude': 35.701235, 'longitude': 139.740123});
      expect(
        entry['suggested'],
        {'latitude': 35.7019, 'longitude': 139.7406},
      );
    });

    test('omits absent optional fields instead of writing nulls', () {
      final bare = AnchorCorrectionReport(
        id: 'c3',
        pointId: 'p3',
        pointLatitude: 35.0,
        pointLongitude: 139.0,
        createdAt: createdAt,
      );
      final decoded = jsonDecode(
        encodeAnchorCorrectionsJson(
          corrections: [bare],
          generatedAt: createdAt,
        ),
      ) as Map<String, Object?>;
      final entry = (decoded['corrections'] as List<Object?>).first
          as Map<String, Object?>;

      expect(entry.containsKey('suggested'), isFalse);
      expect(entry.containsKey('description'), isFalse);
      expect(entry.containsKey('photoPath'), isFalse);
      expect(entry.containsKey('workTitle'), isFalse);
    });

    test('drops whitespace-only descriptions', () {
      final item = AnchorCorrectionReport(
        id: 'c4',
        pointId: 'p4',
        pointLatitude: 35.0,
        pointLongitude: 139.0,
        description: '   \n  ',
        createdAt: createdAt,
      );
      final decoded = jsonDecode(
        encodeAnchorCorrectionsJson(
          corrections: [item],
          generatedAt: createdAt,
        ),
      ) as Map<String, Object?>;
      final entry = (decoded['corrections'] as List<Object?>).first
          as Map<String, Object?>;

      expect(entry.containsKey('description'), isFalse);
    });
  });

  group('decodeAnchorCorrectionsJson', () {
    test('round-trips a correction', () {
      final source = sample();
      final restored = decodeAnchorCorrectionsJson(
        encodeAnchorCorrectionsJson(
          corrections: [source],
          generatedAt: createdAt,
        ),
      );

      expect(restored, hasLength(1));
      final item = restored.first;
      expect(item.id, source.id);
      expect(item.pointId, source.pointId);
      expect(item.planId, source.planId);
      expect(item.workTitle, source.workTitle);
      expect(item.pointName, source.pointName);
      expect(item.source, source.source);
      expect(item.sourceId, source.sourceId);
      expect(item.pointLatitude, closeTo(source.pointLatitude, 1e-6));
      expect(item.pointLongitude, closeTo(source.pointLongitude, 1e-6));
      expect(item.suggestedLatitude, closeTo(source.suggestedLatitude!, 1e-6));
      expect(
        item.suggestedLongitude,
        closeTo(source.suggestedLongitude!, 1e-6),
      );
      expect(item.description, source.description);
      expect(item.photoPath, source.photoPath);
      expect(item.createdAt.isUtc, isTrue);
    });

    test('restores entries without a suggested coordinate', () {
      final bare = AnchorCorrectionReport(
        id: 'c5',
        pointId: 'p5',
        pointLatitude: 35.1,
        pointLongitude: 139.2,
        createdAt: createdAt,
      );
      final restored = decodeAnchorCorrectionsJson(
        encodeAnchorCorrectionsJson(
          corrections: [bare],
          generatedAt: createdAt,
        ),
      );

      expect(restored.first.hasSuggestedCoordinate, isFalse);
      expect(restored.first.suggestedLatitude, isNull);
    });

    test('rejects foreign or newer documents', () {
      expect(
        () => decodeAnchorCorrectionsJson('{"format":"something-else"}'),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => decodeAnchorCorrectionsJson(
          '{"format":"$anchorCorrectionFormat","schemaVersion":999,'
          '"corrections":[]}',
        ),
        throwsA(isA<FormatException>()),
      );
    });
  });

  test('suggestAnchorCorrectionFileName is filesystem-safe and stable', () {
    final name = suggestAnchorCorrectionFileName(createdAt);
    expect(name, 'anitrip-anchor-corrections-2026-10-23T04-30-00-000.json');
    expect(name, isNot(contains(':')));
    expect(name, isNot(contains(' ')));
  });
}
