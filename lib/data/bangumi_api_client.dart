import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/bangumi_config.dart';
import '../plan/pilgrimage_models.dart';

class BangumiApiClient {
  BangumiApiClient({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  Future<List<PilgrimageWork>> searchSubjects(
    String keyword, {
    required Set<BangumiSubjectType> types,
  }) async {
    final query = keyword.trim();
    if (query.isEmpty) {
      return const [];
    }

    final uri = Uri.parse(
      '${BangumiConfig.apiBaseUrl}/v0/search/subjects',
    ).replace(queryParameters: const {'limit': '12'});
    final response = await _httpClient.post(
      uri,
      headers: {
        'Authorization': 'Bearer ${BangumiConfig.apiToken}',
        'Content-Type': 'application/json',
        if (!kIsWeb) 'User-Agent': BangumiConfig.userAgent,
      },
      body: jsonEncode({
        'keyword': query,
        'sort': 'match',
        if (types.isNotEmpty)
          'filter': {
            'type': types.map((type) => type.code).toList(growable: false),
          },
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw BangumiApiException(response.statusCode, response.body);
    }

    final decoded = jsonDecode(response.body) as Map<String, Object?>;
    final data = decoded['data'];
    if (data is! List) {
      return const [];
    }

    return data
        .whereType<Map<String, Object?>>()
        .map(_workFromSubject)
        .toList(growable: false);
  }

  Future<List<PilgrimageWork>> searchAnime(String keyword) {
    return searchSubjects(keyword, types: const {BangumiSubjectType.anime});
  }

  /// Fetches a subject's poster URL (`images.large`, falling back to smaller
  /// sizes) for the Explore work cards. Returns null on any failure so callers
  /// fall back to the placeholder tile. Bangumi work covers are not available
  /// from the anitabi catalog, so this is the poster source keyed by bangumiId.
  Future<String?> fetchSubjectImageUrl(int bangumiId) async {
    final uri = Uri.parse('${BangumiConfig.apiBaseUrl}/v0/subjects/$bangumiId');
    final http.Response response;
    try {
      response = await _httpClient.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${BangumiConfig.apiToken}',
          if (!kIsWeb) 'User-Agent': BangumiConfig.userAgent,
        },
      );
    } catch (_) {
      return null;
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return null;
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, Object?>) {
      return null;
    }
    final images = decoded['images'];
    if (images is! Map<String, Object?>) {
      return null;
    }
    for (final size in const ['large', 'common', 'medium', 'grid', 'small']) {
      final url = images[size];
      if (url is String && url.isNotEmpty) {
        return url;
      }
    }
    return null;
  }

  PilgrimageWork _workFromSubject(Map<String, Object?> subject) {
    final bangumiId = subject['id'] as int;
    final subjectType = BangumiSubjectType.fromCode(subject['type'] as int?);
    final name = subject['name'] as String? ?? 'Bangumi #$bangumiId';
    final nameCn = subject['name_cn'] as String? ?? '';
    final date = subject['date'] as String? ?? '';
    final title = nameCn.isEmpty ? name : nameCn;
    final subtitle = nameCn.isEmpty ? 'Bangumi #$bangumiId' : name;

    // Persist the subject type in `city` using a language-neutral token
    // (`subjectType.name`, e.g. "anime") rather than the localized `label`, so the
    // type survives a language switch. `bangumiSubjectType` is NOT a DB column, so
    // `displayBangumiSubjectType` recovers it from `city`. The UI always renders the
    // type via getName(context), keeping it localized.
    final metaParts = [
      if (subjectType != null) subjectType.name,
      if (date.isNotEmpty) date,
    ];

    return PilgrimageWork(
      id: 'bangumi-$bangumiId',
      bangumiId: bangumiId,
      bangumiSubjectType: subjectType,
      title: title,
      subtitle: subtitle,
      city: metaParts.isEmpty ? '未设置地区' : metaParts.join(' / '),
      source: WorkSource.bangumi,
    );
  }
}

class BangumiApiException implements Exception {
  const BangumiApiException(this.statusCode, this.body);

  final int statusCode;
  final String body;

  @override
  String toString() {
    return 'BangumiApiException($statusCode): $body';
  }
}
