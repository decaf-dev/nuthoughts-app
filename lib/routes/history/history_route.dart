import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nuthoughts/controllers/app_controller.dart';

class HistoryRoute extends StatefulWidget {
  const HistoryRoute({super.key});

  @override
  State<HistoryRoute> createState() => _HistoryRouteState();
}

class _HistoryRouteState extends State<HistoryRoute> {
  final AppController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('History'),
        ),
        body: Obx(() => ListView.builder(
              itemCount: controller.historyLog.length,
              itemBuilder: (context, index) {
                return Card(
                    child: Text(
                        controller.historyLog[index].eventType.toString()));
              },
            )));
  }
}
