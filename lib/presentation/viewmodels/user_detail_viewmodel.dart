import 'package:flutter/foundation.dart';
import 'package:flutterbase/application/dto/point_entry_dto.dart';
import 'package:flutterbase/application/dto/update_point_entry_dto.dart';
import 'package:flutterbase/application/usecases/points/delete_point_entry_usecase.dart';
import 'package:flutterbase/application/usecases/points/get_point_balance_usecase.dart';
import 'package:flutterbase/application/usecases/points/get_point_history_usecase.dart';
import 'package:flutterbase/application/usecases/points/update_point_entry_usecase.dart';
import 'package:flutterbase/shared/errors/app_error.dart';

enum UserDetailState { loading, loaded, empty, error }

final class UserDetailViewModel extends ChangeNotifier {
  UserDetailViewModel(
    this._getHistory,
    this._getBalance,
    this._deleteEntry,
    this._updateEntry,
  );
  final GetPointHistoryUseCase _getHistory;
  final GetPointBalanceUseCase _getBalance;
  final DeletePointEntryUseCase _deleteEntry;
  final UpdatePointEntryUseCase _updateEntry;

  UserDetailState _state = UserDetailState.loading;
  List<PointEntryDto> _entries = [];
  int _balance = 0;
  AppError? _error;
  int? _currentUserId;

  UserDetailState get state => _state;
  List<PointEntryDto> get entries => _entries;
  int get balance => _balance;
  AppError? get error => _error;

  Future<void> load(int userId) async {
    _currentUserId = userId;
    _state = UserDetailState.loading;
    _error = null;
    notifyListeners();
    try {
      _entries = await _getHistory.execute(userId);
      _balance = await _getBalance.execute(userId);
      _state = _entries.isEmpty ? UserDetailState.empty : UserDetailState.loaded;
    } catch (e, st) {
      _error = UnexpectedError('Failed to load point history', cause: e, stackTrace: st);
      _state = UserDetailState.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> updateEntry(UpdatePointEntryDto dto) async {
    try {
      await _updateEntry.execute(dto);
      if (_currentUserId != null) {
        await load(_currentUserId!);
      }
    } catch (e, st) {
      _error = UnexpectedError('Failed to update entry', cause: e, stackTrace: st);
      _state = UserDetailState.error;
      notifyListeners();
    }
  }

  Future<void> deleteEntry(int entryId) async {
    try {
      await _deleteEntry.execute(entryId);
      if (_currentUserId != null) {
        await load(_currentUserId!);
      }
    } catch (e, st) {
      _error = UnexpectedError('Failed to delete entry', cause: e, stackTrace: st);
      _state = UserDetailState.error;
      notifyListeners();
    }
  }
}
