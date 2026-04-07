import 'package:flutter/foundation.dart';
import 'package:flutterbase/application/dto/app_info_dto.dart';
import 'package:flutterbase/application/usecases/app_info/get_app_info_usecase.dart';
import 'package:flutterbase/app/di/service_locator.dart';
import 'package:flutterbase/shared/errors/app_error.dart';
import 'package:flutterbase/shared/logging/app_logger.dart';

/// UI state for the About page.
enum AboutState { loading, loaded, error }

/// ViewModel for [AboutPage].
///
/// Calls [GetAppInfoUseCase] and exposes the result for display.
/// Contains no business logic — only loading state and display data.
class AboutViewModel extends ChangeNotifier {
  AboutViewModel(this._getAppInfo);

  final GetAppInfoUseCase _getAppInfo;

  AboutState _state = AboutState.loading;
  AppInfoDto? _appInfo;
  AppError? _error;

  AboutState get state => _state;
  AppInfoDto? get appInfo => _appInfo;
  AppError? get appError => _error;

  Future<void> loadAppInfo() async {
    sl<AppLogger>().debug('[AboutViewModel] loadAppInfo start');
    _state = AboutState.loading;
    _error = null;
    notifyListeners();

    try {
      _appInfo = await _getAppInfo.execute();
      _state = AboutState.loaded;
      sl<AppLogger>().debug('[AboutViewModel] loadAppInfo success — v${_appInfo?.version}');
    } catch (e, st) {
      _error = UnexpectedError('Failed to load app info', cause: e, stackTrace: st);
      _state = AboutState.error;
      sl<AppLogger>().error('[AboutViewModel] loadAppInfo failed', error: e, stackTrace: st);
    } finally {
      notifyListeners();
    }
  }
}
