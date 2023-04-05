
import 'package:flutter/material.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/notes_service.dart';

import '../../constants/routes.dart';
import '../../enums/menu_action.dart';
import '../../main.dart';

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {

  late final NotesService _notesService;
  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState() {
    _notesService = NotesService();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _notesService.getAllNotes(),
      builder: (context, snapshot) {
        switch(snapshot.connectionState) {
          case ConnectionState.done:
          case ConnectionState.active:
            print("ConnectionState ${snapshot.data?.length}");
            break;
        }
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
          body: FutureBuilder(
            future: _notesService.getOrCreateUser(email: userEmail),
            builder: (context, snapshot) {
              switch(snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.active:
                  return const Text("waiting list note...");
                default:
                  return const CircularProgressIndicator();
              }
            }),
        );
      }
    );
  }

  @override
  void dispose() {
    _notesService.close();
    super.dispose();
  }
}
