import 'package:flutter/material.dart';
import 'package:mynotes/views/login_view.dart';


void main() async {
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.green,
    ),
    home: const LoginView(),
  ));
}
