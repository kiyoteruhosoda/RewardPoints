import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rewardpoints/infrastructure/files/export_file_writer.dart';

final class _InMemoryStore implements ExportArtifactStore {
  _InMemoryStore(this.baseDir);

  final Directory baseDir;
  File? lastFallback;

  @override
  Future<File> persistForFallback(ExportStoredFile file) async {
    final fallback = File('${baseDir.path}/fallback_${file.suggestedFileName}');
    await fallback.writeAsString(await file.file.readAsString());
    lastFallback = fallback;
    return fallback;
  }

  @override
  Future<ExportStoredFile> writeTemporary(ExportJsonArtifact artifact) async {
    final file = File('${baseDir.path}/${artifact.suggestedFileName}');
    await file.writeAsString(artifact.json);
    return ExportStoredFile(
      file: file,
      suggestedFileName: artifact.suggestedFileName,
    );
  }
}

final class _SuccessGateway implements ExportShareGateway {
  @override
  Future<String> share(ExportStoredFile file) async => 'success';
}

final class _ErrorGateway implements ExportShareGateway {
  @override
  Future<String> share(ExportStoredFile file) async => throw StateError('boom');
}

void main() {
  test('returns share status when share succeeds', () async {
    final dir = await Directory.systemTemp.createTemp('export_writer_test_');
    addTearDown(() => dir.delete(recursive: true));

    final writer = PlatformExportFileWriter(
      artifactStore: _InMemoryStore(dir),
      shareGateway: _SuccessGateway(),
    );

    final result = await writer.shareJson(
      suggestedFileName: 'point_data.json',
      json: '{"users":[]}',
    );

    expect(result, 'success');
  });

  test('falls back to local persistence when share fails', () async {
    final dir = await Directory.systemTemp.createTemp('export_writer_test_');
    addTearDown(() => dir.delete(recursive: true));
    final store = _InMemoryStore(dir);

    final writer = PlatformExportFileWriter(
      artifactStore: store,
      shareGateway: _ErrorGateway(),
    );

    final result = await writer.shareJson(
      suggestedFileName: 'point_data.json',
      json: '{"users":[]}',
    );

    expect(result, startsWith('saved_locally:'));
    expect(store.lastFallback, isNotNull);
    expect(await store.lastFallback!.readAsString(), '{"users":[]}');
  });
}
