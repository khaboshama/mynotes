import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/bloc/auth_bloc.dart';
import 'package:mynotes/services/bloc/auth_event.dart';

import '../services/auth/auth_exception.dart';
import '../utils/show_error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login View")),
      body: Column(
        children: [
          TextField(
            controller: _email,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: "Enter your email"),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(hintText: "Enter your password"),
          ),
          TextButton(
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;
              try {
                context.read<AuthBloc>().add(AuthEventLogIn(email, password));
                // BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
                //   if (state is AuthStateLoggedIn) {
                //     if (AuthService.firebase().currentUser?.isEmailVerified ==
                //         true) {
                //       Navigator.of(context).pushNamedAndRemoveUntil(
                //           notesRoute, (route) => false);
                //     } else {
                //       Navigator.of(context).pushNamedAndRemoveUntil(
                //           verifyEmailRoute, (route) => true);
                //     }
                //   } else if (state is AuthStateLoginFailure) {
                //     showErrorDialog(context, (state).exception.toString());
                //   } else {
                //     showErrorDialog(context, "Auth error");
                //   }
                // });
              } on UserNotFoundAuthException {
                await showErrorDialog(context, "please enter a valid email");
              } on WrongPasswordAuthException {
                await showErrorDialog(context, "Wrong credential");
              } on GenericAuthException {
                await showErrorDialog(context, "Auth error");
              }
            },
            child: const Text("Login"),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(registerRoute, (route) => false);
              },
              child: const Text("Not registered yet? Register here!"))
        ],
      ),
    );
  }
}
