import 'package:flutterbase/domain/repositories/point_entry_repository.dart';
import 'package:flutterbase/domain/value_objects/user_id.dart';

final class GetPastReasonsUseCase {
  const GetPastReasonsUseCase(this._repo);
  final PointEntryRepository _repo;

  Future<List<String>> execute(int userId) async {
    return _repo.getDistinctReasons(UserId(userId));
  }
}
