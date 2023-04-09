import 'dart:async';

import 'package:mynotes/extension/list/filter.dart';
import 'package:mynotes/services/auth/auth_exception.dart';
import 'package:mynotes/services/crud/note_database.dart';
import 'package:mynotes/services/crud/user_database.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'crud_exceptions.dart';

class NotesService {
  Database? _db;

  DatabaseUser? _user;

  static final NotesService _share = NotesService._shareInstance();
  NotesService._shareInstance() {
    _notesStreamController = StreamController<List<DatabaseNote>>.broadcast(
      onListen: () {
        _notesStreamController.sink.add(_notes);
      }
    );
  }
  factory NotesService() => _share;

  List<DatabaseNote> _notes = [];
  late final StreamController<List<DatabaseNote>> _notesStreamController;

  Stream<List<DatabaseNote>> get allNotes =>
      _notesStreamController.stream.filter((note) {
        final currentUser = _user;
        if (currentUser == null) throw UserShouldBeSetBeforeReadingAllNotes();
        return note.userId == currentUser.id;
      });

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {

    }
  }
  Future<void> open() async {
    if (_db != null) throw DatabaseAlreadyOpenException();
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, databaseName);
      final db = await openDatabase(dbPath);
      _db = db;

      await db.execute(createUserTable);
      await db.execute(createNoteTable);
      await _cacheNotes();
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
    await _ensureDbIsOpen();
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
    await _ensureDbIsOpen();
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
    await _ensureDbIsOpen();
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

  Future<DatabaseUser> getOrCreateUser({
    required String email,
    bool setAsCurrentUser = true,
  }) async {
    try {
      final user = await getUser(email: email);
      if (setAsCurrentUser) _user = user;
      return user;
    } on CouldNotFindUser {
      final currentUser = await createUser(email: email);
      if (setAsCurrentUser) _user = currentUser;
      return currentUser;
    } catch (_) {
      rethrow;
    }
  }


  // notes
  Future<DatabaseNote> createNote({
    required DatabaseUser owner,
    required String text,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) throw CouldNotFindUser();

    final noteId = await db.insert(
        noteTable,
        {
          userIdColumn: owner.id,
          textColumn : text,
          isSyncedToCloudColumn: 1
        }
    );
    final note = DatabaseNote(id: noteId, userId: owner.id, text: text, isSyncedToCloud: true);
    _notes.add(note);
    _notesStreamController.add(_notes);
    return note;
  }

  Future<void> deleteNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
        noteTable,
        where: "id = ?",
        whereArgs: [id]);
    if (deletedCount == 0) {
      throw CouldNotDeleteNote();
    }
    _notes.removeWhere((note) => note.id == id);
    _notesStreamController.add(_notes);
  }

  Future<int> deleteAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final numberOfDeletions = await db.delete(noteTable);
    _notes = [];
    _notesStreamController.add(_notes);
    return numberOfDeletions;
  }
  Future<DatabaseNote> getNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
        noteTable,
        limit: 1,
        where: "id = ?",
        whereArgs: [id]
    );
    if (notes.isEmpty) throw CouldNotFindNote();
    final note = DatabaseNote.fromRow(notes.first);
    _notes.removeWhere((note) => note.id == id);
    _notes.add(note);
    _notesStreamController.add(_notes);
    return note;
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(noteTable);
    return notes.map((n) => DatabaseNote.fromRow(n));
  }

  Future<DatabaseNote> updateNote({required int id, required String text}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    await getNote(id: id);
    final notesCount = await db.update(noteTable, {
      textColumn: text,
      isSyncedToCloudColumn: 0,
    },
        where: "id = ?",
        whereArgs: [id]
    );
    if (notesCount == 0) CouldNotUpdateNote();
    final updatedNote =  await getNote(id: id);
    _notes.removeWhere((note) => note.id == updatedNote.id);
    _notes.add(updatedNote);
    _notesStreamController.add(_notes);
    return updatedNote;
  }
  // cache notes
  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }
}

const databaseName = 'notes.db';
const noteTable = 'note';
const userTable = 'user';
const createUserTable = '''CREATE TABLE IF NOT EXISTS "$userTable" (
        "id"	INTEGER NOT NULL,
        "email"	TEXT NOT NULL UNIQUE,
        PRIMARY KEY("id")
      );''';
const createNoteTable = '''CREATE TABLE IF NOT EXISTS "$noteTable" (
        "id"	INTEGER NOT NULL,
        "user_id"	INTEGER NOT NULL,
        "text"	TEXT,
        "is_synced_to_cloud"	INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY("id" AUTOINCREMENT),
        FOREIGN KEY("user_id") REFERENCES "user"("id")
      );''';
