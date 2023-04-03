import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_service.dart';

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
                await AuthService.firebase().sendEmailVerification();
                print("send a verification email");
              },
              child: const Text("Send")
          ),
          TextButton(
              onPressed: () async {
                await AuthService.firebase().logout();
                print("sign out");
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(registerRoute, (route) => false);
              },
              child: const Text("Restart")
          )
        ],
      ),
    );
  }
}
