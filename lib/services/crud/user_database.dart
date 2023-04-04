import 'package:flutter/foundation.dart';

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person id = $id email = $email';

  @override
  bool operator == (covariant DatabaseUser other)  => id == other.id;

  @override
  int get hashCode => id.hashCode;

}
const idColumn = "id";
const emailColumn = "email";
