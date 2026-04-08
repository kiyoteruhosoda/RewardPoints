import 'package:flutterbase/domain/value_objects/point_entry_id.dart';
import 'package:flutterbase/domain/value_objects/user_id.dart';

sealed class PointEntry {
  const PointEntry({
    required this.id,
    required this.userId,
    required this.dateTime,
    required this.points,
  });
  final PointEntryId id;
  final UserId userId;
  final DateTime dateTime;
  final int points;
}

final class PointAddition extends PointEntry {
  const PointAddition({
    required super.id,
    required super.userId,
    required super.dateTime,
    required super.points,
    required this.reason,
    this.tag,
  });
  final String reason;
  final String? tag;
}

final class PointConsumption extends PointEntry {
  const PointConsumption({
    required super.id,
    required super.userId,
    required super.dateTime,
    required super.points,
    required this.application,
    this.tag,
  });
  final String application;
  final String? tag;
}
