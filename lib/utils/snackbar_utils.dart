import 'package:flutter/material.dart';

displayErrorSnackBar(BuildContext context, String message) {
  SnackBar snackBar = SnackBar(
    backgroundColor: Colors.red,
    content: Text(message),
    action: SnackBarAction(
      label: 'Dismiss',
      onPressed: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      },
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
