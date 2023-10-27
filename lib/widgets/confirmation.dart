import 'package:flutter/material.dart';

Future<void> showConfirmationDialog(
    BuildContext context, String actionName, VoidCallback onConfirmPressed,
    {VoidCallback? onCancelPressed}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap a button to close dialog
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(actionName),
        content: const SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Are you sure you want to do this?'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              onCancelPressed ?? ();
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Confirm'),
            onPressed: () {
              onConfirmPressed();
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
