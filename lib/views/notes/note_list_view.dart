import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/crud/note_database.dart';

import '../../services/crud/notes_service.dart';
import '../../utils/show_loading_dialog.dart';

class NoteListView extends StatefulWidget {
  final List<DatabaseNote> allNotes;
  const NoteListView({required this.allNotes, Key? key}) : super(key: key);

  @override
  State<NoteListView> createState() => _NoteListViewState();
}

class _NoteListViewState extends State<NoteListView> {
  late final NotesService _notesService;

  @override
  void initState() {
    _notesService = NotesService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.allNotes.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(widget.allNotes[index].text),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  deleteNote(widget.allNotes[index].id);
                },
              ),
            ],
          ),
          onTap: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
              addNoteRoute,
              (route) => true,
              arguments: widget.allNotes[index],
            );
          },
        );
      },
    );
  }

  Future<void> deleteNote(int id) async {
    showLoadingDialog(context);
    await _notesService.deleteNote(id: id);
    Navigator.of(context).pop(false);
  }
}
