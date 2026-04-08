import 'package:flutterbase/application/dto/add_points_dto.dart';
import 'package:flutterbase/application/dto/point_entry_dto.dart';
import 'package:flutterbase/domain/entities/point_entry.dart';
import 'package:flutterbase/domain/repositories/point_entry_repository.dart';
import 'package:flutterbase/domain/value_objects/user_id.dart';

final class AddPointsUseCase {
  const AddPointsUseCase(this._repo);
  final PointEntryRepository _repo;

  Future<PointEntryDto> execute(AddPointsDto dto) async {
    final entry = await _repo.addPoints(
      userId: UserId(dto.userId),
      dateTime: dto.dateTime,
      points: dto.points,
      reason: dto.reason,
      tag: dto.tag,
    );
    final addition = entry as PointAddition;
    return PointEntryDto(
      id: entry.id.value,
      userId: dto.userId,
      type: PointEntryTypeDto.addition,
      dateTime: entry.dateTime,
      points: entry.points,
      reason: addition.reason,
      tag: addition.tag,
    );
  }
}
