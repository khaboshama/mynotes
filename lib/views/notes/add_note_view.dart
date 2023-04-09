import 'package:flutter/material.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/firebase_cloud_storage.dart';

import '../../utils/show_loading_dialog.dart';

class AddNoteView extends StatefulWidget {
  const AddNoteView({Key? key}) : super(key: key);

  @override
  State<AddNoteView> createState() => _AddNoteViewState();
}

class _AddNoteViewState extends State<AddNoteView> {
  CloudNote? _note;
  late final FirebaseCloudStorage _notesService;
  bool _isUpdatedMode = false;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    super.initState();
  }

  Future<CloudNote> addNote() async {
    final existingNote = _note;
    if (existingNote != null) return existingNote;
    final currentUser = AuthService
        .firebase()
        .currentUser!;
    final currentUserId = currentUser.id;
    return await _notesService.createNewNote(
        ownerUserId: currentUserId,
        content: _controller.text
    );
  }

  void updateNote() async {
    await _notesService.updateNote(
        documentId: _note!.documentId,
        text: _controller.text
    );
  }

  @override
  Widget build(BuildContext context) {
    _note = ModalRoute.of(context)!.settings.arguments as CloudNote?;
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
                   updateNote();
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
