import 'dart:convert';
import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

abstract interface class ExportFileWriter {
  Future<String> shareJson({
    required String suggestedFileName,
    required String json,
  });
}

final class PlatformExportFileWriter implements ExportFileWriter {
  @override
  Future<String> shareJson({
    required String suggestedFileName,
    required String json,
  }) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$suggestedFileName');
    await file.writeAsString(json, encoding: utf8, flush: true);

    final result = await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/json')],
      fileNameOverrides: [suggestedFileName],
    );

    return result.status.name;
  }
}
