import 'package:flutterbase/domain/entities/point_entry.dart';
import 'package:flutterbase/domain/value_objects/point_entry_id.dart';
import 'package:flutterbase/domain/value_objects/user_id.dart';
import 'package:flutterbase/infrastructure/db/sqlite/rows/point_entry_row.dart';

final class PointEntryMapper {
  const PointEntryMapper._();

  static PointEntry toDomain(PointEntryRow row) {
    final id = PointEntryId(row.id);
    final userId = UserId(row.userId);
    final dateTime = DateTime.parse(row.dateTime);
    return switch (row.type) {
      'addition' => PointAddition(
          id: id,
          userId: userId,
          dateTime: dateTime,
          points: row.points,
          reason: row.reason ?? '',
          tag: row.tag,
        ),
      'consumption' => PointConsumption(
          id: id,
          userId: userId,
          dateTime: dateTime,
          points: row.points,
          application: row.application ?? '',
          tag: row.tag,
        ),
      _ => throw StateError('Unknown point entry type: ${row.type}'),
    };
  }
}
