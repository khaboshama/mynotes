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
  DatabaseNote? _note;
  late final NotesService _notesService;
  bool _isUpdatedMode = false;
  final TextEditingController _controller = TextEditingController();

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
    return await _notesService.createNote(owner: owner, text: _controller.text);
  }

  Future<DatabaseNote> updateNote() async {
    return await _notesService.updateNote(id: _note!.id, text: _controller.text);
  }

  @override
  Widget build(BuildContext context) {
    _note = ModalRoute.of(context)!.settings.arguments as DatabaseNote?;
    if (_note != null) {
      _controller.text = _note!.text;
      _isUpdatedMode = true;
    } else {
      _controller.text = "";
      _isUpdatedMode = false;
    }
    return Scaffold(
      appBar: AppBar(title: const Text("Add Note"),),
      body: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Enter your note",
            ),
            controller: _controller,
          ),
          TextButton(
              onPressed: () async {
                if (_controller.text.isEmpty) return;
                showLoadingDialog(context);
                if (_isUpdatedMode) {
                  await updateNote();
                } else {
                  await addNote();
                }
                Navigator.of(context).pop(false);
                Navigator.of(context).pop(true);
              }, child: const Text('Add'))
        ],
      ),
    );
  }
}
