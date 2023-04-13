import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/services/bloc/auth_bloc.dart';
import 'package:mynotes/services/bloc/auth_event.dart';
import 'package:mynotes/services/bloc/auth_state.dart';
import 'package:mynotes/utils/dialogs/loading_dialog.dart';

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
  CloseDialog? _closeDialog;

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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {
          final closeDialog = _closeDialog;
          if (!state.isLoading && closeDialog != null) {
            closeDialog();
            _closeDialog = null;
          } else if (state.isLoading && closeDialog == null) {
            _closeDialog = showLoadingDialog(
              context: context,
              text: 'loading',
            );
          }
          if (state.exception is UserNotFoundAuthException) {
            await showErrorDialog(context, 'User not found');
          } else if (state.exception is UserNotLoggedInAuthException) {
            await showErrorDialog(context, 'user is not logged in');
          } else if (state.exception is WrongPasswordAuthException) {
            await showErrorDialog(context, 'Wrong credentials');
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, 'Authentication error');
          } else if (state.exception is EmailOrPasswordEmptyAuthException) {
            await showErrorDialog(context, 'Your email or password is empty');
          }
        }
      },
      child: Scaffold(
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
              decoration:
                  const InputDecoration(hintText: "Enter your password"),
            ),
            TextButton(
              onPressed: () async {
                final email = _email.text;
                final password = _password.text;
                context.read<AuthBloc>().add(AuthEventLogIn(email, password));
              },
              child: const Text("Login"),
            ),
            TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthEventShouldRegister());
                },
                child: const Text("Not registered yet? Register here!"))
          ],
        ),
      ),
    );
  }
}
