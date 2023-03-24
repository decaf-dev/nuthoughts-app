import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class SavedBlocksRoute extends StatefulWidget {
  const SavedBlocksRoute({super.key});

  @override
  State<SavedBlocksRoute> createState() => _SavedBlocksRouteState();
}

class _SavedBlocksRouteState extends State<SavedBlocksRoute> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Thoughts'),
      ),
      body: Placeholder(),
    );
  }
}
