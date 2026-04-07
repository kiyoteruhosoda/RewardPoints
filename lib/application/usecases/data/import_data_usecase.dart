import 'dart:convert';
import 'dart:io';

import 'package:flutterbase/domain/repositories/point_entry_repository.dart';
import 'package:flutterbase/domain/repositories/user_repository.dart';
import 'package:flutterbase/domain/value_objects/user_id.dart';

final class ImportDataUseCase {
  const ImportDataUseCase(this._userRepo, this._pointRepo);
  final UserRepository _userRepo;
  final PointEntryRepository _pointRepo;

  /// Import from [filePath]. Returns number of imported users.
  Future<int> execute(String filePath) async {
    final file = File(filePath);
    if (!file.existsSync()) throw const FileNotFoundException();

    final content = await file.readAsString();
    final data = jsonDecode(content) as Map<String, dynamic>;
    final usersJson = data['users'] as List<dynamic>;
    final entriesJson = data['entries'] as List<dynamic>;

    // Delete all existing users (cascades to entries)
    final existingUsers = await _userRepo.getAll();
    for (final u in existingUsers) {
      await _pointRepo.deleteByUserId(u.id);
      await _userRepo.delete(u.id);
    }

    // Re-create users (new IDs assigned by DB)
    final idMap = <int, int>{};
    for (final u in usersJson) {
      final map = u as Map<String, dynamic>;
      final user = await _userRepo.create(map['name'] as String);
      idMap[map['id'] as int] = user.id.value;
    }

    // Re-create entries
    for (final e in entriesJson) {
      final map = e as Map<String, dynamic>;
      final oldUserId = map['userId'] as int;
      final newUserId = idMap[oldUserId];
      if (newUserId == null) continue;
      final userId = UserId(newUserId);
      final dateTime = DateTime.parse(map['dateTime'] as String);
      final points = map['points'] as int;
      final type = map['type'] as String;
      if (type == 'addition') {
        await _pointRepo.addPoints(
          userId: userId,
          dateTime: dateTime,
          points: points,
          reason: map['reason'] as String? ?? '',
        );
      } else if (type == 'consumption') {
        await _pointRepo.consumePoints(
          userId: userId,
          dateTime: dateTime,
          points: points,
          application: map['application'] as String? ?? '',
          tag: map['tag'] as String?,
        );
      }
    }
    return usersJson.length;
  }
}

final class FileNotFoundException implements Exception {
  const FileNotFoundException();
  @override
  String toString() => 'FileNotFoundException: import file not found';
}
