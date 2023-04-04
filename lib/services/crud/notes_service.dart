import 'package:mynotes/services/crud/note_database.dart';
import 'package:mynotes/services/crud/user_database.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'crud_exceptions.dart';

class NotesService {
  Database? _db;

  Future<void> open() async {
    if (_db != null) throw DatabaseAlreadyOpenException();
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, databaseName);
      final db = await openDatabase(dbPath);
      _db = db;

      await db.execute(createUserTable);
      await db.execute(createNoteTable);
    } on MissingPlatformDirectoryException {}
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    } else {
      db.close();
      _db = null;
    }
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    } else {
      return db;
    }
  }

  Future<void> deleteUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
        userTable,
        where: "email = ?",
        whereArgs: [email.toLowerCase()]
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final result = await db.query(
        userTable,
        limit: 1,
        where: "email = ?",
        whereArgs: [email.toLowerCase()]
    );
    if (result.isNotEmpty) throw UserAlreadyExistsException();
    final userId = await db.insert(
        userTable,
        {emailColumn: email.toLowerCase()}
    );
    return DatabaseUser(id: userId, email: email);
  }

  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final result = await db.query(
        userTable,
        limit: 1,
        where: "email = ?",
        whereArgs: [email.toLowerCase()]
    );
    if (result.isNotEmpty) return DatabaseUser.fromRow(result.first);
    throw CouldNotFindUser();
  }
  // notes
  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    final db = _getDatabaseOrThrow();
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) throw CouldNotFindUser();

    const text = '';
    final noteId = await db.insert(
        noteTable,
        {
          userIdColumn: owner.id,
          textColumn : text,
          isSyncedWithCloudColumn: 1
        }
    );
    return DatabaseNote(id: noteId, userId: owner.id, text: text, isSyncedWithCloud: true);
  }

  Future<void> deleteNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
        noteTable,
        where: "id = ?",
        whereArgs: [id]);
    if (deletedCount == 0) {
      throw CouldNotDeleteNote();
    }
  }

  Future<int> deleteAllNotes() async {
    final db = _getDatabaseOrThrow();
    return await db.delete(noteTable);
  }
  Future<DatabaseNote> getNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final result = await db.query(
        noteTable,
        limit: 1,
        where: "id = ?",
        whereArgs: [id]
    );
    if (result.isNotEmpty) return DatabaseNote.fromRow(result.first);
    throw CouldNotFindNote();
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    final db = _getDatabaseOrThrow();
    final notes = await db.query(noteTable);
    return notes.map((n) => DatabaseNote.fromRow(n));
  }

  Future<DatabaseNote> updateNote({required int id, required String text}) async {
    final db = _getDatabaseOrThrow();
    await getNote(id: id);
    final notesCount = await db.update(noteTable, {
      textColumn: text,
      isSyncedWithCloudColumn: 0,
    });
    if (notesCount == 0) CouldNotUpdateNote();
    return getNote(id: id);
  }
}

const databaseName = 'notes.db';
const noteTable = 'note';
const userTable = 'user';
const createUserTable = '''CREATE TABLE "user" (
        "id"	INTEGER NOT NULL,
        "email"	TEXT NOT NULL UNIQUE,
        PRIMARY KEY("id")
      );''';
const createNoteTable = '''CREATE TABLE "note" (
        "id"	INTEGER NOT NULL,
        "user_id"	INTEGER NOT NULL,
        "text"	TEXT,
        "is_synced_to_cloud"	INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY("id" AUTOINCREMENT),
        FOREIGN KEY("user_id") REFERENCES "user"("id")
      );''';
