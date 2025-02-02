import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nuthoughts/controllers/app_controller.dart';
import 'package:nuthoughts/models/history_log_item.dart';
import 'package:nuthoughts/utils/date_utils.dart';

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
                final HistoryLogItem item = controller
                    .historyLog[controller.historyLog.length - index - 1];
                return GestureDetector(
                    child: Card(
                        color: controller.selectedHistoryItemId == item.id
                            ? Colors.blue
                            : Colors.transparent,
                        child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.eventTypeString()),
                                Text(formatTimeAsString(item.creationTime),
                                    style: const TextStyle(fontSize: 12)),
                              ],
                            ))),
                    onTap: () {
                      controller.selectHistoryItem(item.id);
                    });
              },
            )));
  }
}
