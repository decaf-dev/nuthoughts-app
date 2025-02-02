import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nuthoughts/controllers/app_controller.dart';
import 'package:nuthoughts/models/thought.dart';
import 'package:nuthoughts/routes/home/app_title.dart';
import 'package:nuthoughts/routes/home/message_input.dart';
import 'package:nuthoughts/routes/home/saved_display.dart';
import 'package:nuthoughts/routes/home/thought_bubble.dart';
import 'package:nuthoughts/routes/settings/settings_route.dart';
import 'package:nuthoughts/widgets/confirmation.dart';

class HomeRoute extends StatefulWidget {
  const HomeRoute({super.key, required this.title});

  final String title;

  @override
  State<HomeRoute> createState() => _HomeRouteState();
}

class _HomeRouteState extends State<HomeRoute> {
  final AppController controller = Get.find();
  final ScrollController scrollController = ScrollController();
  late StreamSubscription savedThoughtsSubscription;
  Thought? selectedThought;

  @override
  initState() {
    super.initState();
    savedThoughtsSubscription = controller.savedThoughts.listen((value) {
      Future.delayed(const Duration(milliseconds: 10), () {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
      });
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    savedThoughtsSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: controller.scaffoldKey,
      appBar: AppBar(
        title: AppTitle(
          widget.title,
          selectedThought?.id,
          () {
            setState(() {
              selectedThought = null;
            });
          },
        ),
        actions: selectedThought != null
            ? [
                IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () async {
                      Clipboard.setData(
                          ClipboardData(text: selectedThought!.text));

                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Thought copied to clipboard"),
                          backgroundColor: Colors.blueAccent,
                        ),
                      );
                    }),
                if (!selectedThought!.hasBeenSavedOnServer()) ...[
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      await controller.restoreThought(selectedThought!.id);
                      setState(() {
                        selectedThought = null;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      showConfirmationDialog(context, "Delete thought",
                          () async {
                        await controller.deleteThought(selectedThought!.id);
                        setState(() {
                          selectedThought = null;
                        });
                      });
                    },
                  ),
                ]
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
        const SizedBox(height: 15),
        Obx(() => Expanded(
                child: ListView.builder(
              controller: scrollController,
              itemBuilder: (context, index) {
                return Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ThoughtBubble(controller.savedThoughts[index].text, () {
                          setState(() {
                            selectedThought = controller.savedThoughts[index];
                          });
                        }),
                        if (controller.savedThoughts[index]
                            .hasBeenSavedOnServer()) ...[const SavedDisplay()],
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
