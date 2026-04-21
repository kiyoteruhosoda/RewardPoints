import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rewardpoints/infrastructure/files/export_file_writer.dart';
import 'package:rewardpoints/shared/logging/app_logger.dart';
import 'package:rewardpoints/shared/logging/log_entry.dart';
import 'package:rewardpoints/shared/logging/log_level.dart';

final class _InMemoryLogger implements AppLogger {
  final List<LogEntry> _entries = [];

  @override
  List<LogEntry> get entries => List.unmodifiable(_entries);

  @override
  LogLevel get minLevel => LogLevel.verbose;

  @override
  void clearBuffer() => _entries.clear();

  @override
  void debug(String message, {Object? error, StackTrace? stackTrace}) =>
      _add(LogLevel.debug, message, error: error, stackTrace: stackTrace);

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) =>
      _add(LogLevel.error, message, error: error, stackTrace: stackTrace);

  @override
  List<LogEntry> entriesForLevel(LogLevel? level) =>
      level == null ? entries : _entries.where((e) => e.level == level).toList();

  @override
  Future<String?> exportLogs() async => null;

  @override
  void info(String message, {Object? error, StackTrace? stackTrace}) =>
      _add(LogLevel.info, message, error: error, stackTrace: stackTrace);

  @override
  Future<List<File>> logFiles() async => const [];

  @override
  void setMinLevel(LogLevel level) {}

  @override
  void verbose(String message, {Object? error, StackTrace? stackTrace}) =>
      _add(LogLevel.verbose, message, error: error, stackTrace: stackTrace);

  @override
  void warning(String message, {Object? error, StackTrace? stackTrace}) =>
      _add(LogLevel.warning, message, error: error, stackTrace: stackTrace);

  void _add(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    _entries.add(
      LogEntry(
        timestamp: DateTime.now(),
        level: level,
        message: message,
        error: error,
        stackTrace: stackTrace,
      ),
    );
  }
}

final class _Store implements ExportArtifactStore {
  _Store(this.baseDir);

  final Directory baseDir;

  @override
  Future<File> persistForFallback(ExportStoredFile file) async {
    final saved = File('${baseDir.path}/saved_${file.suggestedFileName}');
    return file.file.copy(saved.path);
  }

  @override
  Future<ExportStoredFile> writeTemporary(ExportJsonArtifact artifact) async {
    final file = File('${baseDir.path}/${artifact.suggestedFileName}');
    await file.writeAsString(artifact.json);
    return ExportStoredFile(file: file, suggestedFileName: artifact.suggestedFileName);
  }
}

final class _FailingGateway implements ExportShareGateway {
  @override
  Future<String> share(ExportStoredFile file) async => throw StateError('share failed');
}

void main() {
  test('logs share failure and fallback persistence', () async {
    final dir = await Directory.systemTemp.createTemp('logged_export_');
    addTearDown(() => dir.delete(recursive: true));

    final logger = _InMemoryLogger();
    final writer = PlatformExportFileWriter(
      artifactStore: LoggedExportArtifactStore(_Store(dir), logger),
      shareGateway: LoggedExportShareGateway(_FailingGateway(), logger),
    );

    final result = await writer.shareJson(
      suggestedFileName: 'point_data.json',
      json: '{"users":[]}',
    );

    expect(result, startsWith('saved_locally:'));
    final messages = logger.entries.map((e) => e.message).join(' | ');
    expect(messages, contains('[ExportShareGateway] share failed'));
    expect(messages, contains('[ExportArtifactStore] persistForFallback completed'));
  });
}
