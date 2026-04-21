import 'package:flutter/foundation.dart';
import 'package:rewardpoints/application/usecases/data/export_data_usecase.dart';
import 'package:rewardpoints/application/usecases/data/import_data_usecase.dart';
import 'package:rewardpoints/infrastructure/files/export_file_writer.dart';
import 'package:rewardpoints/shared/errors/app_error.dart';

enum ExportImportState { idle, loading, success, error }

final class ExportImportViewModel extends ChangeNotifier {
  ExportImportViewModel(this._export, this._import, this._fileWriter);

  final ExportDataUseCase _export;
  final ImportDataUseCase _import;
  final ExportFileWriter _fileWriter;

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
      final shareResult = await _fileWriter.shareJson(
        suggestedFileName: result.suggestedFileName,
        json: result.json,
      );
      _lastMessage = shareResult;
      _state = ExportImportState.success;
    } catch (e, st) {
      _error = UnexpectedError('Share failed', cause: e, stackTrace: st);
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
