import 'package:flutter/material.dart';

enum SnackBarType { error, info, success }

showSnackBar(BuildContext context, SnackBarType type, String message) {
  Color color;
  if (type == SnackBarType.error) {
    color = Colors.red;
  } else if (type == SnackBarType.info) {
    color = Colors.blueAccent;
  } else {
    color = Colors.green;
  }

  SnackBar snackBar = SnackBar(
    backgroundColor: color,
    content: Text(message,
        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
