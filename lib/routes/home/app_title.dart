import 'package:flutter/material.dart';

class AppTitle extends StatelessWidget {
  const AppTitle(
    this.title,
    this.selectedThoughtId,
    this.onSelectedThoughtClear, {
    super.key,
  });

  final String title;
  final int? selectedThoughtId;
  final Function() onSelectedThoughtClear;

  @override
  Widget build(BuildContext context) {
    if (selectedThoughtId != null) {
      return IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            onSelectedThoughtClear();
          });
    } else {
      return Text(title);
    }
  }
}
