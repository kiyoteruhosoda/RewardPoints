import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutterbase/shared/logging/app_logger.dart';
import 'package:flutterbase/shared/logging/log_entry.dart';
import 'package:flutterbase/shared/logging/log_level.dart';

/// [AppLogger] implementation that writes to the console and to rotating
/// log files under `<documents>/logs/`.
///
/// Register as a singleton in `app/di/service_locator.dart`:
/// ```dart
/// sl.registerSingleton<AppLogger>(PersistentAppLogger());
/// await sl<AppLogger>().init();
/// ```
final class PersistentAppLogger implements AppLogger {
  PersistentAppLogger() {
    _logger = Logger(
      filter: _PassThroughFilter(),
      printer: _PlainPrinter(),
      output: ConsoleOutput(),
      level: kDebugMode ? Level.trace : Level.info,
    );
  }

  static const int maxBufferEntries = 1000;
  static const int maxFiles = 5;
  static const int maxFileSizeBytes = 1024 * 1024; // 1 MB

  late final Logger _logger;
  final List<LogEntry> _buffer = [];
  IOSink? _fileSink;
  File? _currentFile;
  LogLevel _minLevel = LogLevel.debug;

  // ── Initialisation ────────────────────────────────────────────────────

  // ── AppLogger: min level ──────────────────────────────────────────────

  @override
  LogLevel get minLevel => _minLevel;

  @override
  void setMinLevel(LogLevel level) => _minLevel = level;

  // ── Initialisation ────────────────────────────────────────────────────

  /// Opens the initial log file and optionally restores [savedLevel].
  /// Call once after construction.
  Future<void> init({LogLevel? savedLevel}) async {
    if (savedLevel != null) _minLevel = savedLevel;
    try {
      await _openNewLogFile();
    } catch (e) {
      debugPrint('[PersistentAppLogger] Could not open log file: $e');
    }
  }

  // ── AppLogger interface ───────────────────────────────────────────────

  @override
  void verbose(String message, {Object? error, StackTrace? stackTrace}) =>
      _log(LogLevel.verbose, message, error: error, stackTrace: stackTrace);

  @override
  void debug(String message, {Object? error, StackTrace? stackTrace}) =>
      _log(LogLevel.debug, message, error: error, stackTrace: stackTrace);

  @override
  void info(String message, {Object? error, StackTrace? stackTrace}) =>
      _log(LogLevel.info, message, error: error, stackTrace: stackTrace);

  @override
  void warning(String message, {Object? error, StackTrace? stackTrace}) =>
      _log(LogLevel.warning, message, error: error, stackTrace: stackTrace);

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) =>
      _log(LogLevel.error, message, error: error, stackTrace: stackTrace);

  @override
  List<LogEntry> get entries => List.unmodifiable(_buffer);

  @override
  List<LogEntry> entriesForLevel(LogLevel? level) => level == null
      ? entries
      : entries.where((e) => e.level == level).toList();

  @override
  void clearBuffer() => _buffer.clear();

  @override
  Future<String?> exportLogs() async {
    try {
      final dir = await _logsDirectory();
      final file = File('${dir.path}/export_${_fileTimestamp()}.log');
      final sink = file.openWrite();
      for (final entry in _buffer) {
        sink.writeln(entry.toLogLine());
      }
      await sink.flush();
      await sink.close();
      return file.path;
    } catch (e) {
      debugPrint('[PersistentAppLogger] Export failed: $e');
      return null;
    }
  }

  @override
  Future<List<File>> logFiles() async {
    try {
      final dir = await _logsDirectory();
      return dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.log'))
          .toList()
        ..sort((a, b) => b.path.compareTo(a.path));
    } catch (_) {
      return [];
    }
  }

  // ── Internal ──────────────────────────────────────────────────────────

  void _log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (level.index < _minLevel.index) return;

    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      message: message,
      error: error,
      stackTrace: stackTrace,
    );

    _buffer.add(entry);
    if (_buffer.length > maxBufferEntries) _buffer.removeAt(0);

    switch (level) {
      case LogLevel.verbose:
        _logger.t(message, error: error, stackTrace: stackTrace);
      case LogLevel.debug:
        _logger.d(message, error: error, stackTrace: stackTrace);
      case LogLevel.info:
        _logger.i(message, error: error, stackTrace: stackTrace);
      case LogLevel.warning:
        _logger.w(message, error: error, stackTrace: stackTrace);
      case LogLevel.error:
        _logger.e(message, error: error, stackTrace: stackTrace);
    }

    _writeToFile(entry);
  }

  void _writeToFile(LogEntry entry) {
    if (_fileSink == null) return;
    try {
      _fileSink!.writeln(entry.toLogLine());
      _currentFile?.length().then((size) {
        if (size >= maxFileSizeBytes) _openNewLogFile();
      });
    } catch (_) {
      // Swallow file write errors — console logging continues.
    }
  }

  Future<void> _openNewLogFile() async {
    await _fileSink?.close();
    _fileSink = null;
    final dir = await _logsDirectory();
    _currentFile = File('${dir.path}/app_${_fileTimestamp()}.log');
    _fileSink = _currentFile!.openWrite(mode: FileMode.append);
    await _pruneOldFiles(dir);
  }

  Future<void> _pruneOldFiles(Directory dir) async {
    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.log'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    while (files.length > maxFiles) {
      await files.removeAt(0).delete();
    }
  }

  Future<Directory> _logsDirectory() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/logs');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  String _fileTimestamp() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}'
        '_${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}'
        '${now.second.toString().padLeft(2, '0')}';
  }
}

// ─── Logger internals ─────────────────────────────────────────────────────────

class _PassThroughFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) => true;
}

class _PlainPrinter extends LogPrinter {
  @override
  List<String> log(LogEvent event) {
    final level = event.level.name.toUpperCase().padRight(7);
    final lines = <String>['[$level] ${event.message}'];
    if (event.error != null) lines.add('  ERROR: ${event.error}');
    return lines;
  }
}
