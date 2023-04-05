import 'package:flutter/material.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/note_database.dart';
import 'package:mynotes/services/crud/notes_service.dart';

import '../../utils/show_loading_dialog.dart';

class AddNoteView extends StatefulWidget {
  const AddNoteView({Key? key}) : super(key: key);

  @override
  State<AddNoteView> createState() => _AddNoteViewState();
}

class _AddNoteViewState extends State<AddNoteView> {
  String userNote = "";
  DatabaseNote? _note;
  late final NotesService _notesService;

  @override
  void initState() {
    _notesService = NotesService();
    super.initState();
  }

  Future<DatabaseNote> addNote() async {
    final existingNote = _note;
    if (existingNote != null) return existingNote;
    final currentUser = AuthService
        .firebase()
        .currentUser!;
    final email = currentUser.email!;
    final owner = await _notesService.getUser(email: email);
    return await _notesService.createNote(owner: owner, text: userNote);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Note"),),
      body: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Enter your note",
            ),
            onChanged: (text) {
              userNote = text;
            },
          ),
          TextButton(
              onPressed: () async {
                if (userNote.isEmpty) return;
                showLoadingDialog(context);
                await addNote();
                Navigator.of(context).pop(false);
                Navigator.of(context).pop(true);
              }, child: const Text('Add'))
        ],
      ),
    );
  }
}
