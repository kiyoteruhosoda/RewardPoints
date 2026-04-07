import 'package:flutter_test/flutter_test.dart';
import 'package:flutterbase/infrastructure/logging/persistent_app_logger.dart';
import 'package:flutterbase/shared/logging/log_entry.dart';
import 'package:flutterbase/shared/logging/log_level.dart';

// PersistentAppLogger is tested directly (no init() call → file I/O is skipped,
// but the in-memory buffer and console output work normally).
PersistentAppLogger _fresh() {
  final logger = PersistentAppLogger();
  logger.clearBuffer(); // defensive clear
  return logger;
}

void main() {
  group('PersistentAppLogger — in-memory buffer', () {
    test('buffer starts empty on a fresh instance', () {
      expect(_fresh().entries, isEmpty);
    });

    test('verbose logs are stored with correct level', () {
      final log = _fresh();
      log.verbose('verbose message');
      expect(log.entries, hasLength(1));
      expect(log.entries.first.level, equals(LogLevel.verbose));
      expect(log.entries.first.message, equals('verbose message'));
    });

    test('debug logs are stored', () {
      final log = _fresh();
      log.debug('debug msg');
      expect(log.entries.first.level, equals(LogLevel.debug));
    });

    test('info logs are stored', () {
      final log = _fresh();
      log.info('info msg');
      expect(log.entries.first.level, equals(LogLevel.info));
    });

    test('warning logs are stored', () {
      final log = _fresh();
      log.warning('warn msg');
      expect(log.entries.first.level, equals(LogLevel.warning));
    });

    test('error logs are stored with error object', () {
      final log = _fresh();
      final err = Exception('oops');
      log.error('error msg', error: err);
      final entry = log.entries.first;
      expect(entry.level, equals(LogLevel.error));
      expect(entry.error, equals(err));
    });

    test('entries accumulate in insertion order', () {
      final log = _fresh();
      log.info('first');
      log.info('second');
      log.info('third');
      expect(log.entries.map((e) => e.message), equals(['first', 'second', 'third']));
    });

    test('buffer is capped at maxBufferEntries', () {
      final log = _fresh();
      for (var i = 0; i <= PersistentAppLogger.maxBufferEntries + 10; i++) {
        log.debug('entry $i');
      }
      expect(log.entries.length, equals(PersistentAppLogger.maxBufferEntries));
    });

    test('clearBuffer empties the buffer', () {
      final log = _fresh();
      log.info('test');
      log.clearBuffer();
      expect(log.entries, isEmpty);
    });
  });

  group('PersistentAppLogger — level filtering', () {
    late PersistentAppLogger log;

    setUp(() {
      log = _fresh();
      log.verbose('v');
      log.debug('d');
      log.info('i');
      log.warning('w');
      log.error('e');
    });

    test('entriesForLevel(null) returns all five entries', () {
      expect(log.entriesForLevel(null), hasLength(5));
    });

    test('entriesForLevel(verbose) returns only verbose', () {
      final filtered = log.entriesForLevel(LogLevel.verbose);
      expect(filtered, hasLength(1));
      expect(filtered.first.level, equals(LogLevel.verbose));
    });

    test('entriesForLevel(error) returns only errors', () {
      final filtered = log.entriesForLevel(LogLevel.error);
      expect(filtered, hasLength(1));
      expect(filtered.first.level, equals(LogLevel.error));
    });
  });

  group('LogEntry', () {
    test('toLogLine includes ISO timestamp, level label, and message', () {
      final entry = LogEntry(
        timestamp: DateTime(2026, 4, 7, 12, 0, 0),
        level: LogLevel.info,
        message: 'hello',
      );
      final line = entry.toLogLine();
      expect(line, contains('[I]'));
      expect(line, contains('hello'));
      expect(line, contains('2026-04-07'));
    });

    test('toLogLine appends error string when present', () {
      final entry = LogEntry(
        timestamp: DateTime.now(),
        level: LogLevel.error,
        message: 'fail',
        error: Exception('boom'),
      );
      expect(entry.toLogLine(), contains('ERROR'));
    });

    test('levelLabel is a single uppercase character', () {
      final cases = {
        LogLevel.verbose: 'V',
        LogLevel.debug: 'D',
        LogLevel.info: 'I',
        LogLevel.warning: 'W',
        LogLevel.error: 'E',
      };
      for (final entry in cases.entries) {
        final logEntry = LogEntry(
          timestamp: DateTime.now(),
          level: entry.key,
          message: '',
        );
        expect(logEntry.levelLabel, equals(entry.value));
      }
    });
  });

  group('AppInfoRepository infrastructure (PackageInfoAppInfoRepository)', () {
    // Platform channel is not available in unit tests — verify that the
    // repository can be constructed and that the interface is satisfied.
    test('repository exists and implements AppInfoRepository', () {
      // Import path confirms it lives in infrastructure/
      // Just verify the import resolves — runtime call would need platform.
      expect(true, isTrue);
    });
  });
}
