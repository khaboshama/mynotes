import 'package:flutter/foundation.dart';

@immutable
class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedToCloud;

  const DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedToCloud,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedToCloud =
            (map[isSyncedToCloudColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      'note id = $id userId = $userId text = $text isSyncedWithCloud = $isSyncedToCloud';

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const idColumn = "id";
const userIdColumn = "user_id";
const textColumn = "text";
const isSyncedToCloudColumn = "is_synced_to_cloud";
