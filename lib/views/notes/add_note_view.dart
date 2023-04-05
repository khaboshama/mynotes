import 'package:flutter/material.dart';

class AddNoteView extends StatefulWidget {
  const AddNoteView({Key? key}) : super(key: key);

  @override
  State<AddNoteView> createState() => _AddNoteViewState();
}

class _AddNoteViewState extends State<AddNoteView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Note"),),
      body: const Text("add your note"),
    );
  }
}
