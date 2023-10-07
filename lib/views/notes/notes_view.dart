
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/extension/list/buildContext/loc.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/bloc/auth_bloc.dart';
import 'package:mynotes/services/bloc/auth_event.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/firebase_cloud_storage.dart';

import '../../constants/routes.dart';
import '../../enums/menu_action.dart';
import '../../main.dart';
import 'note_list_view.dart';

extension Count<T extends Iterable> on Stream<T> {
  Stream<int> get getLength => map((event) => event.length);
}

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {

  late final FirebaseCloudStorage _notesService;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title:  StreamBuilder<int>(
              stream: _notesService.allNotes(ownerUserId: AuthService.firebase().currentUser!.id).getLength,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final countNotes = snapshot.data ?? 0;
                  return Text(context.loc.notes_title(countNotes));
                } else {
                  return const Text("Your Notes");
                }
              }
            ),
            actions: [
              IconButton(onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(addNoteRoute, (route) => true);
              }, icon: const Icon(Icons.add)),
              PopupMenuButton<MenuAction>(
                onSelected: (value) async {
                  switch (value) {
                    case MenuAction.logout:
                      final showLogout = await showLogoutDialog(context);
                      if (showLogout) {
                        context.read<AuthBloc>().add(const AuthEventLogOut());
                      }
                      break;
                  }
                },
                itemBuilder: (context) {
                  return [
                    const PopupMenuItem<MenuAction>(
                      value: MenuAction.logout,
                      child: Text("Logout"),
                    )
                  ];
                },
              )
            ],
          ),
          body: StreamBuilder(
              stream: _notesService.allNotes(ownerUserId: userId),
              builder: (context, snapshot) {
                switch(snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.active:
                    print("our data ${snapshot.data?.length}");
                    if (snapshot.hasData && snapshot.data?.isNotEmpty == true) {
                      final allNotes = snapshot.data as Iterable<CloudNote>;
                      return NoteListView(allNotes: allNotes.toList());
                    } else {
                      return const Text("Notes are empty");
                    }
                  case ConnectionState.done:
                    print("done our data ${snapshot.data?.length}");
                    if (snapshot.hasData) {
                      final allNotes = snapshot.data as List<CloudNote>;
                      return NoteListView(allNotes: allNotes);
                    } else {
                      return const Text("Notes are empty");
                    }
                  default:
                    return const CircularProgressIndicator(color: Colors.black,);
                }
              }
          ),
        );
  }
}
