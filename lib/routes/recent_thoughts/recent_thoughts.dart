import 'package:chisel_notes/controllers/app_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RecentThoughtsRoute extends StatefulWidget {
  const RecentThoughtsRoute({super.key});

  @override
  State<RecentThoughtsRoute> createState() => _RecentThoughtsRouteState();
}

class _RecentThoughtsRouteState extends State<RecentThoughtsRoute> {
  final AppController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Thoughts'),
      ),
      body: Center(
          child: Padding(
        padding: const EdgeInsets.all(25),
        child: ListView.builder(
          itemCount: controller.recentThoughts.length,
          itemBuilder: (context, index) {
            return Card(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(controller.recentThoughts.reversed
                        .toList()[index]
                        .text)));
          },
        ),
      )),
    );
  }
}
