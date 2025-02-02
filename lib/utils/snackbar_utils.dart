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
    content: Text(message),
    action: type == SnackBarType.error
        ? SnackBarAction(
            label: 'Dismiss',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          )
        : null,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
