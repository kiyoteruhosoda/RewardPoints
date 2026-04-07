import 'package:flutterbase/shared/logging/log_level.dart';

/// A single immutable log entry.
final class LogEntry {
  const LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.error,
    this.stackTrace,
  });

  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final Object? error;
  final StackTrace? stackTrace;

  String get levelLabel => switch (level) {
        LogLevel.verbose => 'V',
        LogLevel.debug => 'D',
        LogLevel.info => 'I',
        LogLevel.warning => 'W',
        LogLevel.error => 'E',
      };

  String toLogLine() {
    final ts = timestamp.toIso8601String();
    final base = '[$ts][$levelLabel] $message';
    if (error != null) return '$base\n  ERROR: $error';
    return base;
  }
}
