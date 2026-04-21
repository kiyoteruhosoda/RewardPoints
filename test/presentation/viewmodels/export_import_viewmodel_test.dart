import 'package:flutter_test/flutter_test.dart';
import 'package:rewardpoints/application/usecases/data/export_data_usecase.dart';
import 'package:rewardpoints/application/usecases/data/import_data_usecase.dart';
import 'package:rewardpoints/domain/entities/point_entry.dart';
import 'package:rewardpoints/domain/entities/user.dart';
import 'package:rewardpoints/domain/repositories/point_entry_repository.dart';
import 'package:rewardpoints/domain/repositories/user_repository.dart';
import 'package:rewardpoints/domain/value_objects/point_entry_id.dart';
import 'package:rewardpoints/domain/value_objects/user_id.dart';
import 'package:rewardpoints/infrastructure/files/export_file_writer.dart';
import 'package:rewardpoints/presentation/viewmodels/export_import_viewmodel.dart';

class _FakeUserRepo implements UserRepository {
  _FakeUserRepo(this._users);
  final List<User> _users;

  @override
  Future<List<User>> getAll() async => List.unmodifiable(_users);

  @override
  Future<User?> getById(UserId id) async =>
      _users.where((u) => u.id == id).firstOrNull;

  @override
  Future<User> create(String name) => throw UnimplementedError();

  @override
  Future<void> delete(UserId id) => throw UnimplementedError();
}

class _FakePointRepo implements PointEntryRepository {
  _FakePointRepo(this.byUserId);

  final Map<int, List<PointEntry>> byUserId;

  @override
  Future<List<PointEntry>> getByUserId(UserId userId) async =>
      byUserId[userId.value] ?? const [];

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
  Future<void> update(
    PointEntryId id, {
    required DateTime dateTime,
    required int points,
    String? reason,
    String? application,
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

class _CapturingWriter implements ExportFileWriter {
  String? lastSuggestedName;
  String? lastJson;
  String resultToReturn = 'success';

  @override
  Future<String> shareJson({
    required String suggestedFileName,
    required String json,
  }) async {
    lastSuggestedName = suggestedFileName;
    lastJson = json;
    return resultToReturn;
  }
}

void main() {
  test('export stores share result returned from writer', () async {
    final user = User(
      id: const UserId(1),
      name: 'Alice',
      createdAt: DateTime.utc(2026, 4, 20),
    );

    final writer = _CapturingWriter();
    final vm = ExportImportViewModel(
      ExportDataUseCase(
        _FakeUserRepo([user]),
        _FakePointRepo(const {}),
      ),
      ImportDataUseCase(
        _FakeUserRepo(const []),
        _FakePointRepo(const {}),
      ),
      writer,
    );

    await vm.exportData();

    expect(vm.state, ExportImportState.success);
    expect(vm.lastMessage, writer.resultToReturn);
    expect(writer.lastSuggestedName, startsWith('point_data_'));
    expect(writer.lastJson, contains('"users"'));
    expect(writer.lastJson, contains('"entries"'));
  });
}
