import 'package:flutter/material.dart';

void showMessage(BuildContext context, String text, {SnackBarAction? action}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(text), action: action));
}
