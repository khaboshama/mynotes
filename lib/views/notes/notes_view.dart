
import 'package:flutter/material.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/firebase_cloud_storage.dart';

import '../../constants/routes.dart';
import '../../enums/menu_action.dart';
import '../../main.dart';
import 'note_list_view.dart';

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
    return FutureBuilder(
      future: _notesService.getNotes(ownerUserId: AuthService.firebase().currentUser!.id),
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Your Notes"),
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
                        AuthService.firebase().logout();
                        Navigator.of(context)
                            .pushNamedAndRemoveUntil(loginRoute, (route) => false);
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
    );
  }
}
