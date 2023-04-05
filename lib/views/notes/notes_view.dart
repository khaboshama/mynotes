
import 'package:flutter/material.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/note_database.dart';
import 'package:mynotes/services/crud/notes_service.dart';
import 'package:mynotes/utils/show_loading_dialog.dart';

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
              print("hello ${snapshot.data}");
              switch(snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.active:
                  return const Text("waiting list note...");
                case ConnectionState.done:
                  return StreamBuilder(
                    stream: _notesService.allNotes,
                    builder: (context, snapshot) {
                      switch(snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.active:
                          print("our data ${snapshot.data?.length}");
                          if (snapshot.hasData) {
                            final allNotes = snapshot.data as List<DatabaseNote>;
                            return ListView.builder(
                              itemCount: allNotes.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(allNotes[index].text),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete
                                        ),
                                        onPressed: () async {
                                          deleteNote(allNotes[index].id);
                                        },
                                      ),
                                    ],
                                  ),
                                );
                                },
                            );
                          } else {
                            return const Text("Notes are empty");
                          }
                        case ConnectionState.done:
                          print("done our data ${snapshot.data?.length}");
                          if (snapshot.hasData) {
                            final allNotes = snapshot.data as List<DatabaseNote>;
                            return ListView.builder(
                              itemCount: allNotes.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(allNotes[index].text),
                                );
                              },
                            );
                          } else {
                            return const Text("Notes are empty");
                          }
                        default:
                          return const CircularProgressIndicator(color: Colors.black,);
                      }
                    }
                  );
                default:
                  return const CircularProgressIndicator(color: Colors.brown,);
              }
            }),
        );
      }
    );
  }

  Future<void> deleteNote(int id) async {
    showLoadingDialog(context);
    await _notesService.deleteNote(id: id);
    Navigator.of(context).pop(false);
  }
}
