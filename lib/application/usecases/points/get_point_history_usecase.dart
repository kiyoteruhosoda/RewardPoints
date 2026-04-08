import 'package:flutterbase/application/dto/point_entry_dto.dart';
import 'package:flutterbase/domain/entities/point_entry.dart';
import 'package:flutterbase/domain/repositories/point_entry_repository.dart';
import 'package:flutterbase/domain/value_objects/user_id.dart';

final class GetPointHistoryUseCase {
  const GetPointHistoryUseCase(this._repo);
  final PointEntryRepository _repo;

  Future<List<PointEntryDto>> execute(int userId) async {
    final entries = await _repo.getByUserId(UserId(userId));
    return entries.map(_toDto).toList();
  }

  PointEntryDto _toDto(PointEntry e) => switch (e) {
        PointAddition a => PointEntryDto(
            id: a.id.value,
            userId: a.userId.value,
            type: PointEntryTypeDto.addition,
            dateTime: a.dateTime,
            points: a.points,
            reason: a.reason,
            tag: a.tag,
          ),
        PointConsumption c => PointEntryDto(
            id: c.id.value,
            userId: c.userId.value,
            type: PointEntryTypeDto.consumption,
            dateTime: c.dateTime,
            points: c.points,
            application: c.application,
            tag: c.tag,
          ),
      };
}
