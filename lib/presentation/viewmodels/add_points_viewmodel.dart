import 'package:flutter/foundation.dart';
import 'package:flutterbase/application/dto/add_points_dto.dart';
import 'package:flutterbase/application/usecases/points/add_points_usecase.dart';
import 'package:flutterbase/application/usecases/points/get_past_reasons_usecase.dart';
import 'package:flutterbase/shared/errors/app_error.dart';

enum AddPointsState { idle, loading, success, error }

final class AddPointsViewModel extends ChangeNotifier {
  AddPointsViewModel(this._addPoints, this._getPastReasons);
  final AddPointsUseCase _addPoints;
  final GetPastReasonsUseCase _getPastReasons;

  AddPointsState _state = AddPointsState.idle;
  AppError? _error;
  List<String> _reasonSuggestions = [];

  AddPointsState get state => _state;
  AppError? get error => _error;
  List<String> get reasonSuggestions => _reasonSuggestions;

  Future<void> loadSuggestions(int userId) async {
    _reasonSuggestions = await _getPastReasons.execute(userId);
    notifyListeners();
  }

  Future<void> submit({
    required int userId,
    required DateTime dateTime,
    required int points,
    required String reason,
    String? tag,
  }) async {
    _state = AddPointsState.loading;
    _error = null;
    notifyListeners();
    try {
      await _addPoints.execute(AddPointsDto(
        userId: userId,
        dateTime: dateTime,
        points: points,
        reason: reason,
        tag: tag,
      ));
      _state = AddPointsState.success;
    } catch (e, st) {
      _error = UnexpectedError('Failed to add points', cause: e, stackTrace: st);
      _state = AddPointsState.error;
    } finally {
      notifyListeners();
    }
  }

  void reset() {
    _state = AddPointsState.idle;
    _error = null;
    notifyListeners();
  }
}
