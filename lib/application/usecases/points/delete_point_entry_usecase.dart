import 'package:flutterbase/domain/repositories/point_entry_repository.dart';
import 'package:flutterbase/domain/value_objects/point_entry_id.dart';

final class DeletePointEntryUseCase {
  const DeletePointEntryUseCase(this._repo);
  final PointEntryRepository _repo;

  Future<void> execute(int entryId) async {
    await _repo.delete(PointEntryId(entryId));
  }
}
