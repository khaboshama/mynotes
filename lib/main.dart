
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/views/login_view.dart';
import 'package:mynotes/views/register_view.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.green,
    ),
    home: const HomePage(),
    routes: {
      "/login/" : (context) => const LoginView(),
      "/register/" : (context) => const RegisterView()
    },
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
          // final user = FirebaseAuth.instance.currentUser;
          // print(" user = $user");
          // if (user?.emailVerified == true) {
          //   print("email is verified");
          //   return const Text("done complete");
          // } else {
          //   print("email is not verified");
          //   // Navigator.of(context).push(MaterialPageRoute(
          //   //     builder: (context) => const VerifyEmailView()));
          //   return const VerifyEmailView();
            return const LoginView();
        // }
          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}
