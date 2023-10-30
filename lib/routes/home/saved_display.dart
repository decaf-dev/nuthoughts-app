import 'package:flutter/material.dart';

class SavedDisplay extends StatelessWidget {
  const SavedDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
        padding: EdgeInsets.fromLTRB(0, 5, 20, 15),
        child: Text("Saved",
            style: TextStyle(color: Colors.white70, fontSize: 12)));
  }
}
