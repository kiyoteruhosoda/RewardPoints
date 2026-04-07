import 'package:flutterbase/application/dto/app_info_dto.dart';

/// Provides build-time and runtime application metadata.
///
/// Implementations live in `infrastructure/repositories/`.
abstract interface class AppInfoRepository {
  /// Returns the application's version, build, and runtime metadata.
  Future<AppInfoDto> getAppInfo();
}
