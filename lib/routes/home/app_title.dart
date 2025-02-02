import 'package:flutter/material.dart';

class AppTitle extends StatelessWidget {
  const AppTitle(
    this.title,
    this.selectedThoughtId,
    this.onBackPressed, {
    super.key,
  });

  final String title;
  final int? selectedThoughtId;
  final Function() onBackPressed;

  @override
  Widget build(BuildContext context) {
    if (selectedThoughtId != null) {
      return IconButton(
          icon: const Icon(Icons.arrow_back), onPressed: onBackPressed);
    } else {
      return Text(title);
    }
  }
}
