import 'package:flutter/material.dart';

void showLoadingDialog(BuildContext context) {
  AlertDialog alert = AlertDialog(
    content: Row(children: [
      const CircularProgressIndicator(
        backgroundColor: Colors.red,
      ),
      Container(margin: const EdgeInsets.only(left: 10),
        child: const Text("Loading..."),),
    ]),
  );
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}