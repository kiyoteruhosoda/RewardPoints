import 'package:sqflite/sqflite.dart';
import 'package:flutterbase/infrastructure/db/sqlite/rows/point_entry_row.dart';

final class PointEntryDao {
  const PointEntryDao(this._db);
  final Database _db;
  static const String table = 'point_entries';

  Future<List<PointEntryRow>> getByUserId(int userId) async {
    final rows = await _db.query(
      table,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date_time DESC',
    );
    return rows.map(PointEntryRow.fromMap).toList();
  }

  Future<int> insert(PointEntryRow row) async {
    final map = row.toMap()..remove('id');
    return _db.insert(table, map);
  }

  Future<void> update({
    required int id,
    required String dateTime,
    required int points,
    String? reason,
    String? application,
    String? tag,
  }) async {
    await _db.update(
      table,
      {
        'date_time': dateTime,
        'points': points,
        'reason': reason,
        'application': application,
        'tag': tag,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> delete(int id) async {
    await _db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteByUserId(int userId) async {
    await _db.delete(table, where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<List<String>> getDistinctReasons(int userId) async {
    final rows = await _db.rawQuery(
      'SELECT DISTINCT reason FROM $table WHERE user_id = ? AND type = ? AND reason IS NOT NULL ORDER BY reason',
      [userId, 'addition'],
    );
    return rows.map((r) => r['reason'] as String).toList();
  }

  Future<List<String>> getDistinctApplications(int userId) async {
    final rows = await _db.rawQuery(
      'SELECT DISTINCT application FROM $table WHERE user_id = ? AND type = ? AND application IS NOT NULL ORDER BY application',
      [userId, 'consumption'],
    );
    return rows.map((r) => r['application'] as String).toList();
  }
}
