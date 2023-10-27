import 'package:nuthoughts/controllers/app_controller.dart';
import 'package:nuthoughts/routes/home/thought_bubble.dart';
import 'package:nuthoughts/routes/settings/settings_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nuthoughts/routes/home/message_input.dart';
import 'package:nuthoughts/widgets/confirmation.dart';

class HomeRoute extends StatefulWidget {
  const HomeRoute({super.key, required this.title});

  final String title;

  @override
  State<HomeRoute> createState() => _HomeRouteState();
}

class _HomeRouteState extends State<HomeRoute> {
  final AppController controller = Get.find();

  int? actionBarThoughtId;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: actionBarThoughtId != null
            ? [
                IconButton(
                  icon: const Icon(Icons.restore),
                  onPressed: () async {
                    showConfirmationDialog(context, "Undo thought", () async {
                      await controller.restoreThought(actionBarThoughtId!);
                      setState(() {
                        actionBarThoughtId = null;
                      });
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      actionBarThoughtId = null;
                    });
                  },
                ),
              ]
            : [
                IconButton(
                    icon: const Icon(
                      Icons.sync,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      controller.syncThoughts();
                    }),
                IconButton(
                    icon: const Icon(
                      Icons.settings,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SettingsRoute()),
                      );
                    }),
              ],
      ),
      body: Column(children: [
        _lastSynced(),
        const SizedBox(height: 10),
        Obx(() => Expanded(
                child: ListView.builder(
              itemBuilder: (context, index) {
                return Align(
                  alignment: Alignment.centerRight,
                  child:
                      ThoughtBubble(controller.savedThoughts[index].text, () {
                    setState(() {
                      actionBarThoughtId = controller.savedThoughts[index].id;
                    });
                  }),
                );
              },
              itemCount: controller.savedThoughts.length,
            ))),
        MessageInput(controller.textController, controller.saveText,
            (String text) {
          controller.saveThought(text);
          controller.saveText("");
        }),
      ]),
    );
  }

  Widget _lastSynced() {
    return (Container(
        color: Colors.deepPurple,
        padding: const EdgeInsets.all(10),
        child: Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("Last sync: ${controller.syncTime.syncString}",
                    style: const TextStyle(color: Colors.white))
              ],
            ))));
  }
}
