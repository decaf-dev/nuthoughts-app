import 'package:flutter/material.dart';

class SavedDisplay extends StatelessWidget {
  const SavedDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0, 5, 20, 15),
        child: Text("Saved",
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondary,
                fontSize: 12)));
  }
}
