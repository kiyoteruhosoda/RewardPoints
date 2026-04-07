import 'dart:io';

import 'package:flutterbase/shared/logging/log_entry.dart';
import 'package:flutterbase/shared/logging/log_level.dart';

export 'log_entry.dart';
export 'log_level.dart';

/// Cross-cutting logging contract.
///
/// The concrete implementation lives in `infrastructure/logging/`.
/// Access via the service locator: `sl<AppLogger>()`.
abstract interface class AppLogger {
  void verbose(String message, {Object? error, StackTrace? stackTrace});
  void debug(String message, {Object? error, StackTrace? stackTrace});
  void info(String message, {Object? error, StackTrace? stackTrace});
  void warning(String message, {Object? error, StackTrace? stackTrace});
  void error(String message, {Object? error, StackTrace? stackTrace});

  /// All entries currently in the in-memory buffer (oldest first).
  List<LogEntry> get entries;

  /// Entries filtered by [level]; null returns all.
  List<LogEntry> entriesForLevel(LogLevel? level);

  /// Current minimum log level. Messages below this level are silently dropped.
  LogLevel get minLevel;

  /// Changes the minimum log level at runtime.
  void setMinLevel(LogLevel level);

  /// Clears the in-memory buffer. Persistent files are unaffected.
  void clearBuffer();

  /// Exports the buffer to a new file and returns its path, or null on failure.
  Future<String?> exportLogs();

  /// Returns all persisted log file paths (newest first).
  Future<List<File>> logFiles();
}
