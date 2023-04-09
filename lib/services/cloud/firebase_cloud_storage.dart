import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/cloud_storage_constants.dart';
import 'package:mynotes/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection("notes");
  static final FirebaseCloudStorage _share =
      FirebaseCloudStorage._shareInstance();

  FirebaseCloudStorage._shareInstance();

  factory FirebaseCloudStorage() => _share;

  Future<CloudNote> createNewNote({
    required String ownerUserId,
    required content
  }) async {
    final document = await notes.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: content
    });
    final fetchedNote = await document.get();
    return CloudNote(
        documentId: fetchedNote.id,
        ownerUserId: ownerUserId,
        text: fetchedNote.get(textFieldName),
    );
  }

  Future<Iterable<CloudNote>> getNotes({required String ownerUserId}) async {
    try {
     final list = await notes
          .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
          .get()
          .then((value) {
        value.docs.map((doc) => CloudNote.fromSnapshot(doc));
      });
      return list;
    } catch (e) {
      throw CouldNotGetAllNoteException();
    }
  }

  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) =>
      notes.snapshots().map((event) => event.docs
          .map((doc) => CloudNote.fromSnapshot(doc))
          .where((note) => note.ownerUserId == ownerUserId));

  Future<void> updateNote(
      {required String documentId, required String text}) async {
    try {
      notes.doc(documentId).update({
        textFieldName: text
      });
    } catch(_) {
      throw CouldNotUpdateNoteException();
    }
  }

  Future<void> deleteNote({required String documentId}) async {
    try {
      notes.doc(documentId).delete();
    } catch(_) {
      throw CouldNotDeleteNoteException();
    }
  }
}
