
import 'package:flutter/cupertino.dart';
import 'package:mynotes/utils/show_error_dialog.dart';

Future<void> showCannotShareEmptyNoteDialog(BuildContext context) {
  return showErrorDialog(context, "You cannot sharing empty note!");
}