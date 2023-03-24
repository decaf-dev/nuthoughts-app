import 'package:chisel/controllers/app_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SavedBlocksRoute extends StatefulWidget {
  const SavedBlocksRoute({super.key});

  @override
  State<SavedBlocksRoute> createState() => _SavedBlocksRouteState();
}

class _SavedBlocksRouteState extends State<SavedBlocksRoute> {
  final AppController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recently Saved'),
      ),
      body: Center(
          child: Padding(
        padding: const EdgeInsets.all(25),
        child: ListView.builder(
          itemCount: controller.savedBlocks.length,
          itemBuilder: (context, index) {
            return Card(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                        controller.savedBlocks.reversed.toList()[index].text)));
          },
        ),
      )),
    );
  }
}
