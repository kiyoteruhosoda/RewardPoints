import 'package:flutterbase/application/dto/update_point_entry_dto.dart';
import 'package:flutterbase/domain/repositories/point_entry_repository.dart';
import 'package:flutterbase/domain/value_objects/point_entry_id.dart';

final class UpdatePointEntryUseCase {
  const UpdatePointEntryUseCase(this._repo);
  final PointEntryRepository _repo;

  Future<void> execute(UpdatePointEntryDto dto) async {
    await _repo.update(
      PointEntryId(dto.id),
      dateTime: dto.dateTime,
      points: dto.points,
      reason: dto.reason,
      application: dto.application,
      tag: dto.tag,
    );
  }
}
