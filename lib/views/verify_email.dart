import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/bloc/auth_bloc.dart';
import 'package:mynotes/services/bloc/auth_event.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({Key? key}) : super(key: key);

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify email"),
      ),
      body: Column(
        children: [
          const Text("Please send a verification code"),
          TextButton(
              onPressed: () async {
                context.read<AuthBloc>().add(
                    const AuthEventSendVerificationEmail());
                print("send a verification email");
              },
              child: const Text("Send")
          ),
          TextButton(
              onPressed: () async {
                await AuthService.firebase().logout();
                context.read<AuthBloc>().add(const AuthEventLogOut());
                print("sign out");
              },
              child: const Text("Restart")
          )
        ],
      ),
    );
  }
}
