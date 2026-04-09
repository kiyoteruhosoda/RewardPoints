import 'package:flutterbase/domain/entities/point_entry.dart';
import 'package:flutterbase/domain/value_objects/point_entry_id.dart';
import 'package:flutterbase/domain/value_objects/user_id.dart';

abstract interface class PointEntryRepository {
  Future<List<PointEntry>> getByUserId(UserId userId);
  Future<PointEntry> addPoints({
    required UserId userId,
    required DateTime dateTime,
    required int points,
    required String reason,
    String? tag,
  });
  Future<PointEntry> consumePoints({
    required UserId userId,
    required DateTime dateTime,
    required int points,
    required String application,
    String? tag,
  });
  Future<void> update(
    PointEntryId id, {
    required DateTime dateTime,
    required int points,
    String? reason,
    String? application,
    String? tag,
  });
  Future<void> delete(PointEntryId id);
  Future<void> deleteByUserId(UserId userId);
  Future<List<String>> getDistinctReasons(UserId userId);
  Future<List<String>> getDistinctApplications(UserId userId);
}
