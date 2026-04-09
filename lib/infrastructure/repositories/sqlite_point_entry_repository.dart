import 'package:flutterbase/domain/entities/point_entry.dart';
import 'package:flutterbase/domain/repositories/point_entry_repository.dart';
import 'package:flutterbase/domain/value_objects/point_entry_id.dart';
import 'package:flutterbase/domain/value_objects/user_id.dart';
import 'package:flutterbase/infrastructure/db/sqlite/dao/point_entry_dao.dart';
import 'package:flutterbase/infrastructure/db/sqlite/rows/point_entry_row.dart';
import 'package:flutterbase/infrastructure/mappers/point_entry_mapper.dart';

final class SqlitePointEntryRepository implements PointEntryRepository {
  const SqlitePointEntryRepository(this._dao);
  final PointEntryDao _dao;

  @override
  Future<List<PointEntry>> getByUserId(UserId userId) async {
    final rows = await _dao.getByUserId(userId.value);
    return rows.map(PointEntryMapper.toDomain).toList();
  }

  @override
  Future<PointEntry> addPoints({
    required UserId userId,
    required DateTime dateTime,
    required int points,
    required String reason,
    String? tag,
  }) async {
    final row = PointEntryRow(
      id: 0,
      userId: userId.value,
      type: 'addition',
      dateTime: dateTime.toIso8601String(),
      points: points,
      reason: reason,
      tag: tag,
    );
    final id = await _dao.insert(row);
    return PointAddition(
      id: PointEntryId(id),
      userId: userId,
      dateTime: dateTime,
      points: points,
      reason: reason,
      tag: tag,
    );
  }

  @override
  Future<PointEntry> consumePoints({
    required UserId userId,
    required DateTime dateTime,
    required int points,
    required String application,
    String? tag,
  }) async {
    final row = PointEntryRow(
      id: 0,
      userId: userId.value,
      type: 'consumption',
      dateTime: dateTime.toIso8601String(),
      points: points,
      application: application,
      tag: tag,
    );
    final id = await _dao.insert(row);
    return PointConsumption(
      id: PointEntryId(id),
      userId: userId,
      dateTime: dateTime,
      points: points,
      application: application,
      tag: tag,
    );
  }

  @override
  Future<void> update(
    PointEntryId id, {
    required DateTime dateTime,
    required int points,
    String? reason,
    String? application,
    String? tag,
  }) async {
    await _dao.update(
      id: id.value,
      dateTime: dateTime.toIso8601String(),
      points: points,
      reason: reason,
      application: application,
      tag: tag,
    );
  }

  @override
  Future<void> delete(PointEntryId id) async {
    await _dao.delete(id.value);
  }

  @override
  Future<void> deleteByUserId(UserId userId) async {
    await _dao.deleteByUserId(userId.value);
  }

  @override
  Future<List<String>> getDistinctReasons(UserId userId) async {
    return _dao.getDistinctReasons(userId.value);
  }

  @override
  Future<List<String>> getDistinctApplications(UserId userId) async {
    return _dao.getDistinctApplications(userId.value);
  }
}
