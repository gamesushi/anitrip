import 'dart:async';

/// Wall-clock budget for a single outbound request (Anitabi, Bangumi, …).
///
/// Without a budget the default `http.Client` keeps a socket open until the OS
/// gives up, which is what made the Explore tab and the "add work" search spin
/// forever on a flaky network ("一直在加载" in the Animap user group). Every
/// request now fails fast so the UI can show a retry (or fall back to the
/// bundled snapshot).
const Duration kDefaultRequestTimeout = Duration(seconds: 15);

/// Budget used when a request has a local fallback that can take over quickly
/// (e.g. the bundled `web/g*.json` snapshot served offline). Kept close to
/// [kDefaultRequestTimeout] because the static index is a multi-MB download —
/// a tighter budget would push users with a slow-but-working connection onto
/// the stale snapshot. It still bounds genuinely hung sockets, which is what
/// used to leave the loading spinner running forever.
const Duration kFallbackableRequestTimeout = kDefaultRequestTimeout;

/// Thrown when a request exceeds its budget.
///
/// [timeout] and [label] are kept so debug UIs and logs can tell "the network
/// hung" apart from "the server answered 500".
class RequestTimeoutException implements Exception {
  const RequestTimeoutException(this.timeout, {this.label});

  final Duration timeout;
  final String? label;

  @override
  String toString() {
    final suffix = label == null ? '' : ' ($label)';
    return 'Request timed out after ${timeout.inMilliseconds}ms$suffix';
  }
}

/// True when [error] was caused by [withRequestTimeout] giving up.
bool isRequestTimeout(Object? error) => error is RequestTimeoutException;

/// Runs [task] and fails with [RequestTimeoutException] if it takes longer than
/// [timeout].
///
/// A `timeout <= 0` disables the guard (kept for tests and for callers that
/// already manage their own budget). Cancellation propagates: when the timeout
/// fires, the wrapped future's own errors are ignored rather than surfacing as
/// unhandled.
Future<T> withRequestTimeout<T>(
  Future<T> task, {
  Duration timeout = kDefaultRequestTimeout,
  String? label,
}) {
  if (timeout <= Duration.zero) {
    return task;
  }
  return task.timeout(
    timeout,
    onTimeout: () => throw RequestTimeoutException(timeout, label: label),
  );
}
