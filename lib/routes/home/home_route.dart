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
      key: controller.scaffoldKey,
      appBar: AppBar(
        title: actionBarThoughtId != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () async {
                  setState(() {
                    actionBarThoughtId = null;
                  });
                })
            : Text(widget.title),
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
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    showConfirmationDialog(context, "Delete thought", () async {
                      await controller.deleteThought(actionBarThoughtId!);
                      setState(() {
                        actionBarThoughtId = null;
                      });
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
        const SizedBox(height: 10),
        Obx(() => Expanded(
                child: ListView.builder(
              itemBuilder: (context, index) {
                return Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ThoughtBubble(controller.savedThoughts[index].text, () {
                          setState(() {
                            actionBarThoughtId =
                                controller.savedThoughts[index].id;
                          });
                        }),
                        if (controller.savedThoughts[index]
                            .hasBeenSavedOnServer()) ...[
                          const Padding(
                              padding: EdgeInsets.fromLTRB(0, 5, 20, 15),
                              child: Text("Saved",
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 12))),
                        ],
                        if (!controller.savedThoughts[index]
                            .hasBeenSavedOnServer()) ...[
                          const SizedBox(height: 15),
                        ]
                      ]),
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
}
