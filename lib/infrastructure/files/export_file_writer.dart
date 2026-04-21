import 'dart:convert';
import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rewardpoints/shared/logging/app_logger.dart';
import 'package:share_plus/share_plus.dart';

abstract interface class ExportFileWriter {
  Future<String> shareJson({
    required String suggestedFileName,
    required String json,
  });
}

final class ExportShareUnavailableException implements Exception {
  const ExportShareUnavailableException(this.message);
  final String message;

  @override
  String toString() => message;
}

final class ExportJsonArtifact {
  const ExportJsonArtifact({
    required this.suggestedFileName,
    required this.json,
  });

  final String suggestedFileName;
  final String json;
}

final class ExportStoredFile {
  const ExportStoredFile({
    required this.file,
    required this.suggestedFileName,
  });

  final File file;
  final String suggestedFileName;
}

abstract interface class ExportArtifactStore {
  Future<ExportStoredFile> writeTemporary(ExportJsonArtifact artifact);
  Future<File> persistForFallback(ExportStoredFile file);
}

final class FileSystemExportArtifactStore implements ExportArtifactStore {
  @override
  Future<ExportStoredFile> writeTemporary(ExportJsonArtifact artifact) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/${artifact.suggestedFileName}');
    await file.writeAsString(artifact.json, encoding: utf8, flush: true);
    return ExportStoredFile(
      file: file,
      suggestedFileName: artifact.suggestedFileName,
    );
  }

  @override
  Future<File> persistForFallback(ExportStoredFile file) async {
    final documents = await getApplicationDocumentsDirectory();
    final saved = File('${documents.path}/${file.suggestedFileName}');
    return file.file.copy(saved.path);
  }
}


final class LoggedExportArtifactStore implements ExportArtifactStore {
  LoggedExportArtifactStore(this._delegate, this._logger);

  final ExportArtifactStore _delegate;
  final AppLogger _logger;

  @override
  Future<ExportStoredFile> writeTemporary(ExportJsonArtifact artifact) async {
    _logger.debug(
      '[ExportArtifactStore] writeTemporary start '
      '(fileName: ${artifact.suggestedFileName}, bytes: ${utf8.encode(artifact.json).length})',
    );
    try {
      final stored = await _delegate.writeTemporary(artifact);
      _logger.info(
        '[ExportArtifactStore] writeTemporary completed (path: ${stored.file.path})',
      );
      return stored;
    } catch (e, st) {
      _logger.error(
        '[ExportArtifactStore] writeTemporary failed',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  @override
  Future<File> persistForFallback(ExportStoredFile file) async {
    _logger.warning(
      '[ExportArtifactStore] persistForFallback start '
      '(from: ${file.file.path}, fileName: ${file.suggestedFileName})',
    );
    try {
      final saved = await _delegate.persistForFallback(file);
      _logger.info(
        '[ExportArtifactStore] persistForFallback completed (path: ${saved.path})',
      );
      return saved;
    } catch (e, st) {
      _logger.error(
        '[ExportArtifactStore] persistForFallback failed',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }
}
abstract interface class ExportShareGateway {
  Future<String> share(ExportStoredFile file);
}


final class LoggedExportShareGateway implements ExportShareGateway {
  LoggedExportShareGateway(this._delegate, this._logger);

  final ExportShareGateway _delegate;
  final AppLogger _logger;

  @override
  Future<String> share(ExportStoredFile file) async {
    _logger.debug(
      '[ExportShareGateway] share start '
      '(path: ${file.file.path}, fileName: ${file.suggestedFileName})',
    );
    try {
      final status = await _delegate.share(file);
      _logger.info('[ExportShareGateway] share completed (status: $status)');
      return status;
    } on ExportShareUnavailableException catch (e, st) {
      _logger.warning(
        '[ExportShareGateway] share unavailable',
        error: e,
        stackTrace: st,
      );
      rethrow;
    } catch (e, st) {
      _logger.error(
        '[ExportShareGateway] share failed',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }
}
final class SharePlusExportShareGateway implements ExportShareGateway {
  @override
  Future<String> share(ExportStoredFile file) async {
    final result = await Share.shareXFiles(
      [XFile(file.file.path, mimeType: 'application/json')],
      subject: 'RewardPoints Export',
      text: 'RewardPoints data export JSON',
    );

    if (result.status == ShareResultStatus.unavailable) {
      throw const ExportShareUnavailableException(
        'この端末では共有先アプリ選択が利用できません（share_plus status: unavailable）。',
      );
    }

    return result.status.name;
  }
}

final class PlatformExportFileWriter implements ExportFileWriter {
  PlatformExportFileWriter({
    ExportArtifactStore? artifactStore,
    ExportShareGateway? shareGateway,
  }) : _artifactStore = artifactStore ?? FileSystemExportArtifactStore(),
       _shareGateway = shareGateway ?? SharePlusExportShareGateway();

  final ExportArtifactStore _artifactStore;
  final ExportShareGateway _shareGateway;

  @override
  Future<String> shareJson({
    required String suggestedFileName,
    required String json,
  }) async {
    final artifact = ExportJsonArtifact(
      suggestedFileName: suggestedFileName,
      json: json,
    );
    final tempFile = await _artifactStore.writeTemporary(artifact);

    try {
      return await _shareGateway.share(tempFile);
    } on ExportShareUnavailableException {
      rethrow;
    } catch (_) {
      final savedFile = await _artifactStore.persistForFallback(tempFile);
      return 'saved_locally:${savedFile.path}';
    }
  }
}

final class LoggedExportFileWriter implements ExportFileWriter {
  LoggedExportFileWriter(this._delegate, this._logger);

  final ExportFileWriter _delegate;
  final AppLogger _logger;

  @override
  Future<String> shareJson({
    required String suggestedFileName,
    required String json,
  }) async {
    _logger.info(
      '[ExportFileWriter] shareJson start '
      '(fileName: $suggestedFileName, bytes: ${utf8.encode(json).length})',
    );
    try {
      final result = await _delegate.shareJson(
        suggestedFileName: suggestedFileName,
        json: json,
      );
      _logger.info(
        '[ExportFileWriter] shareJson completed (status: $result)',
      );
      return result;
    } on ExportShareUnavailableException catch (e, st) {
      _logger.warning(
        '[ExportFileWriter] shareJson unavailable',
        error: e,
        stackTrace: st,
      );
      rethrow;
    } catch (e, st) {
      _logger.error(
        '[ExportFileWriter] shareJson failed',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }
}
