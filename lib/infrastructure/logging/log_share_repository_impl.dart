import 'package:cross_file/cross_file.dart';
import 'package:rewardpoints/domain/repositories/log_share_repository.dart';
import 'package:rewardpoints/shared/logging/app_logger.dart';
import 'package:share_plus/share_plus.dart';

final class LogShareUnavailableException implements Exception {
  const LogShareUnavailableException(this.message);

  final String message;

  @override
  String toString() => message;
}

final class PlatformLogShareRepository implements LogShareRepository {
  @override
  Future<String> share({required String filePath}) async {
    final result = await Share.shareXFiles(
      [XFile(filePath, mimeType: 'text/plain')],
      subject: 'PointBook Logs',
      text: 'PointBook application logs',
    );

    if (result.status == ShareResultStatus.unavailable) {
      throw const LogShareUnavailableException('この端末では共有機能を利用できません。');
    }

    return result.status.name;
  }
}

final class LoggedLogShareRepository implements LogShareRepository {
  LoggedLogShareRepository(this._delegate, this._logger);

  final LogShareRepository _delegate;
  final AppLogger _logger;

  @override
  Future<String> share({required String filePath}) async {
    _logger.info('[LogShareRepository] share start (path: $filePath)');
    try {
      final status = await _delegate.share(filePath: filePath);
      _logger.info('[LogShareRepository] share completed (status: $status)');
      return status;
    } on LogShareUnavailableException catch (e, st) {
      _logger.warning(
        '[LogShareRepository] share unavailable',
        error: e,
        stackTrace: st,
      );
      rethrow;
    } catch (e, st) {
      _logger.error(
        '[LogShareRepository] share failed',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }
}
