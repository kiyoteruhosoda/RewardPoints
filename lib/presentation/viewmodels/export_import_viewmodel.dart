import 'dart:convert';
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:rewardpoints/application/usecases/data/export_data_usecase.dart';
import 'package:rewardpoints/application/usecases/data/import_data_usecase.dart';
import 'package:rewardpoints/shared/errors/app_error.dart';

enum ExportImportState { idle, loading, success, error }

final class ExportImportViewModel extends ChangeNotifier {
  ExportImportViewModel(this._export, this._import);

  final ExportDataUseCase _export;
  final ImportDataUseCase _import;

  ExportImportState _state = ExportImportState.idle;
  AppError? _error;
  String? _lastMessage;

  ExportImportState get state => _state;
  AppError? get error => _error;
  String? get lastMessage => _lastMessage;

  Future<void> exportData() async {
    _state = ExportImportState.loading;
    _error = null;
    notifyListeners();
    try {
      final result = await _export.execute();
      final name = p.basenameWithoutExtension(result.suggestedFileName);
      await FileSaver.instance.saveFile(
        name: name,
        bytes: Uint8List.fromList(utf8.encode(result.json)),
        fileExtension: 'json',
        customMimeType: 'application/json',
      );
      _lastMessage = result.suggestedFileName;
      _state = ExportImportState.success;
    } catch (e, st) {
      _error = UnexpectedError('Export failed', cause: e, stackTrace: st);
      _state = ExportImportState.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> importFromJson(String jsonContent) async {
    _state = ExportImportState.loading;
    _error = null;
    notifyListeners();
    try {
      final count = await _import.executeFromJson(jsonContent);
      _lastMessage = count.toString();
      _state = ExportImportState.success;
    } on InvalidImportDataException catch (e, st) {
      _error = UnexpectedError('Invalid JSON', cause: e, stackTrace: st);
      _state = ExportImportState.error;
    } catch (e, st) {
      _error = UnexpectedError('Import failed', cause: e, stackTrace: st);
      _state = ExportImportState.error;
    } finally {
      notifyListeners();
    }
  }

  void reset() {
    _state = ExportImportState.idle;
    _error = null;
    _lastMessage = null;
    notifyListeners();
  }
}
