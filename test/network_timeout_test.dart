import 'dart:async';

import 'package:anitrip/utils/network_timeout.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('withRequestTimeout', () {
    test('returns the value when the task finishes in time', () async {
      final result = await withRequestTimeout(
        Future<String>.delayed(
          const Duration(milliseconds: 50),
          () => 'ok',
        ),
        timeout: const Duration(seconds: 1),
      );
      expect(result, 'ok');
    });

    test('passes through errors thrown before the budget expires', () async {
      expect(
        () => withRequestTimeout<int>(
          Future<int>.error(StateError('boom')),
          timeout: const Duration(seconds: 1),
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('throws RequestTimeoutException when the task hangs', () async {
      expect(
        () => withRequestTimeout<void>(
          Completer<void>().future,
          timeout: const Duration(milliseconds: 20),
          label: 'GET example.com/g.json',
        ),
        throwsA(isA<RequestTimeoutException>()),
      );
    });

    test('keeps the budget and label on the thrown exception', () async {
      Object? error;
      try {
        await withRequestTimeout<void>(
          Completer<void>().future,
          timeout: const Duration(milliseconds: 10),
          label: 'GET static index',
        );
      } catch (caught) {
        error = caught;
      }

      expect(error, isA<RequestTimeoutException>());
      final timeout = error! as RequestTimeoutException;
      expect(timeout.timeout.inMilliseconds, 10);
      expect(timeout.label, 'GET static index');
      expect(
        timeout.toString(),
        'Request timed out after 10ms (GET static index)',
      );
    });

    test('omits the label when none is provided', () async {
      Object? error;
      try {
        await withRequestTimeout<void>(
          Completer<void>().future,
          timeout: const Duration(milliseconds: 10),
        );
      } catch (caught) {
        error = caught;
      }
      expect(error.toString(), 'Request timed out after 10ms');
    });

    test('disables the guard for a non-positive budget', () {
      // A never-completing future stays pending instead of throwing.
      final future = withRequestTimeout<void>(
        Completer<void>().future,
        timeout: Duration.zero,
      );
      expect(future, isNotNull);
    });
  });

  group('isRequestTimeout', () {
    test('recognises timeout failures only', () {
      expect(
        isRequestTimeout(
          const RequestTimeoutException(Duration(seconds: 1)),
        ),
        isTrue,
      );
      expect(isRequestTimeout(StateError('x')), isFalse);
      expect(isRequestTimeout(null), isFalse);
    });
  });

  group('defaults', () {
    test('ships bounded budgets rather than unbounded waits', () {
      expect(kDefaultRequestTimeout, const Duration(seconds: 15));
      expect(kFallbackableRequestTimeout, kDefaultRequestTimeout);
    });
  });
}
