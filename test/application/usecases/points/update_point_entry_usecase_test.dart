import 'package:flutter_test/flutter_test.dart';
import 'package:rewardpoints/application/dto/update_point_entry_dto.dart';
import 'package:rewardpoints/application/usecases/points/update_point_entry_usecase.dart';
import 'package:rewardpoints/domain/entities/point_entry.dart';
import 'package:rewardpoints/domain/repositories/point_entry_repository.dart';
import 'package:rewardpoints/domain/value_objects/point_entry_id.dart';
import 'package:rewardpoints/domain/value_objects/user_id.dart';

class _CapturingRepo implements PointEntryRepository {
  PointEntryId? updatedId;
  DateTime? updatedDateTime;
  int? updatedPoints;
  String? updatedReason;
  String? updatedApplication;
  String? updatedTag;

  @override
  Future<void> update(
    PointEntryId id, {
    required DateTime dateTime,
    required int points,
    String? reason,
    String? application,
    String? tag,
  }) async {
    updatedId = id;
    updatedDateTime = dateTime;
    updatedPoints = points;
    updatedReason = reason;
    updatedApplication = application;
    updatedTag = tag;
  }

  @override
  Future<List<PointEntry>> getByUserId(UserId userId) =>
      throw UnimplementedError();
  @override
  Future<PointEntry> addPoints({
    required UserId userId,
    required DateTime dateTime,
    required int points,
    required String reason,
    String? tag,
  }) =>
      throw UnimplementedError();
  @override
  Future<PointEntry> consumePoints({
    required UserId userId,
    required DateTime dateTime,
    required int points,
    required String application,
    String? tag,
  }) =>
      throw UnimplementedError();
  @override
  Future<void> delete(PointEntryId id) => throw UnimplementedError();
  @override
  Future<void> deleteByUserId(UserId userId) => throw UnimplementedError();
  @override
  Future<List<String>> getDistinctReasons(UserId userId) async => const [];
  @override
  Future<List<String>> getDistinctApplications(UserId userId) async => const [];
}

void main() {
  test('forwards update dto values to repository', () async {
    final repo = _CapturingRepo();
    final useCase = UpdatePointEntryUseCase(repo);
    final now = DateTime(2026, 4, 20, 22, 0);

    await useCase.execute(
      UpdatePointEntryDto(
        id: 42,
        dateTime: now,
        points: 99,
        reason: 'Manual update',
        application: null,
        tag: 'campaign',
      ),
    );

    expect(repo.updatedId, const PointEntryId(42));
    expect(repo.updatedDateTime, now);
    expect(repo.updatedPoints, 99);
    expect(repo.updatedReason, 'Manual update');
    expect(repo.updatedApplication, isNull);
    expect(repo.updatedTag, 'campaign');
  });
}
