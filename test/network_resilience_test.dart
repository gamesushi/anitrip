import 'dart:async';

import 'package:anitrip/data/anitabi_client.dart';
import 'package:anitrip/data/anitabi_static_data_reader.dart';
import 'package:anitrip/data/bangumi_api_client.dart';
import 'package:anitrip/utils/network_timeout.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

/// Never answers: simulates the hung sockets that used to leave the Explore
/// tab and the add-work search spinning forever.
class _HangingHttpClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return Completer<http.StreamedResponse>().future;
  }
}

void main() {
  // Needed because the fallback path reads the bundled snapshot via rootBundle.
  TestWidgetsFlutterBinding.ensureInitialized();
  test('static reader falls back to the bundled snapshot when network hangs',
      () async {
    final reader = AnitabiStaticDataReader(
      httpClient: _HangingHttpClient(),
      requestTimeout: const Duration(milliseconds: 60),
    );

    final stopwatch = Stopwatch()..start();
    final body = await reader.read('g.json');
    stopwatch.stop();

    expect(body, isNotEmpty);
    // Without the timeout this request would never return.
    expect(stopwatch.elapsed, lessThan(const Duration(seconds: 5)));
  });

  test('listWorks still returns the catalog offline (bounded wait)', () async {
    final client = AnitabiClient(
      httpClient: _HangingHttpClient(),
      requestTimeout: const Duration(milliseconds: 60),
    );

    final works = await client
        .listWorks()
        .timeout(const Duration(seconds: 10), onTimeout: () => const []);
    expect(works, isNotEmpty);
  });

  test('bangumi search fails fast instead of hanging', () async {
    final client = BangumiApiClient(
      httpClient: _HangingHttpClient(),
      requestTimeout: const Duration(milliseconds: 60),
    );

    await expectLater(
      client.searchAnime('すずめ'),
      throwsA(isA<RequestTimeoutException>()),
    );
  });

  test('bangumi poster lookup degrades to null on timeout', () async {
    final client = BangumiApiClient(
      httpClient: _HangingHttpClient(),
      requestTimeout: const Duration(milliseconds: 60),
    );

    final url = await client.fetchSubjectImageUrl(1);
    expect(url, isNull);
  });
}
