import 'dart:convert';
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

abstract interface class ExportFileWriter {
  Future<String> saveJson({
    required String suggestedFileName,
    required String json,
  });
}

final class PlatformExportFileWriter implements ExportFileWriter {
  static const MethodChannel _channel = MethodChannel('rewardpoints/export_file');

  @override
  Future<String> saveJson({
    required String suggestedFileName,
    required String json,
  }) async {
    final bytes = Uint8List.fromList(utf8.encode(json));

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      final savedUri = await _channel.invokeMethod<String>(
        'saveJsonToDownloads',
        {
          'fileName': suggestedFileName,
          'bytes': bytes,
        },
      );
      if (savedUri == null || savedUri.isEmpty) {
        throw PlatformException(
          code: 'save_failed',
          message: 'Failed to save file to Downloads.',
        );
      }
      return savedUri;
    }

    final name = p.basenameWithoutExtension(suggestedFileName);
    await FileSaver.instance.saveFile(
      name: name,
      bytes: bytes,
      fileExtension: 'json',
      customMimeType: 'application/json',
    );
    return suggestedFileName;
  }
}
