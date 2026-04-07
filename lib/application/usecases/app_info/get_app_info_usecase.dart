import 'package:flutterbase/application/dto/app_info_dto.dart';
import 'package:flutterbase/domain/repositories/app_info_repository.dart';

/// Returns the application's version and build metadata.
final class GetAppInfoUseCase {
  const GetAppInfoUseCase(this._repository);

  final AppInfoRepository _repository;

  Future<AppInfoDto> execute() => _repository.getAppInfo();
}
