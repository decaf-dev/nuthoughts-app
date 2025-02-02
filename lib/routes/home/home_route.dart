import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nuthoughts/constants.dart';
import 'package:nuthoughts/controllers/app_controller.dart';
import 'package:nuthoughts/models/history_log_item.dart';
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
  bool isEditing = false;

  @override
  initState() {
    super.initState();
    savedThoughtsSubscription = controller.savedThoughts.listen((value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToBottom();
      });
    });
  }

  void scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
      );
    }
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
            if (isEditing) {
              setState(() {
                isEditing = false;
                controller.textController.clear();
                setState(() {
                  selectedThought = null;
                });
              });
            } else {
              setState(() {
                selectedThought = null;
              });
            }
          },
        ),
        shape: Border(
            bottom: BorderSide(
          color: Theme.of(context).colorScheme.outline,
          width: 2,
        )),
        actions: selectedThought != null
            ? [
                if (!isEditing)
                  IconButton(
                      icon: const Icon(Icons.copy_outlined),
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
                if (!selectedThought!.hasBeenSavedOnServer() && !isEditing)
                  IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () async {
                        await controller
                            .updateMessageInput(selectedThought!.text);
                        setState(() {
                          isEditing = true;
                        });
                      }),
                if (!selectedThought!.hasBeenSavedOnServer() && !isEditing)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      showConfirmationDialog(context, "Delete Thought",
                          () async {
                        await controller.deleteThought(selectedThought!.id);
                        await controller.addHistoryItem(
                            HistoryLogEvent.deleteThought,
                            jsonEncode(selectedThought));

                        setState(() {
                          selectedThought = null;
                        });
                      });
                    },
                  ),
              ]
            : [
                Row(children: [
                  IconButton(
                    icon: const Icon(Icons.undo_outlined),
                    onPressed: () async {
                      if (controller.currentHistoryItemIndex < 0) {
                        return;
                      }

                      final HistoryLogItem item = controller
                          .historyLog[controller.currentHistoryItemIndex];
                      controller.undoHistoryEvent(item);

                      controller.currentHistoryItemIndex =
                          controller.currentHistoryItemIndex - 1;
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.redo_outlined),
                    onPressed: () async {
                      if (controller.currentHistoryItemIndex ==
                          controller.historyLog.length - 1) {
                        return;
                      }

                      controller.currentHistoryItemIndex =
                          controller.currentHistoryItemIndex + 1;

                      final HistoryLogItem item = controller
                          .historyLog[controller.currentHistoryItemIndex];
                      controller.redoHistoryEvent(item);
                    },
                  ),
                ]),
                IconButton(
                    icon: const Icon(
                      Icons.sync_outlined,
                    ),
                    onPressed: () {
                      controller.syncThoughts();
                    }),
                IconButton(
                    icon: const Icon(
                      Icons.settings_outlined,
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
      body: Column(
        children: [
          Obx(() => Expanded(
              child: Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      border: Border(
                          bottom: BorderSide(
                        color: Theme.of(context).colorScheme.outline,
                        width: 2,
                      ))),
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    controller: scrollController,
                    itemBuilder: (context, index) {
                      return Align(
                        alignment: Alignment.centerRight,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              ThoughtBubble(
                                  controller.savedThoughts[index].text, () {
                                setState(() {
                                  selectedThought =
                                      controller.savedThoughts[index];
                                });
                              }),
                              if (controller.savedThoughts[index]
                                  .hasBeenSavedOnServer()) ...[
                                const SavedDisplay()
                              ],
                              if (!controller.savedThoughts[index]
                                  .hasBeenSavedOnServer()) ...[
                                const SizedBox(height: 15),
                              ]
                            ]),
                      );
                    },
                    itemCount: controller.savedThoughts.length,
                  )))),
          MessageInput(
              isEditing, controller.textController, controller.saveText,
              (String text) async {
            controller.textController.clear();
            await controller.saveText("");

            if (isEditing) {
              final Map<String, dynamic> updatedThought =
                  await controller.updateThought(selectedThought!.id, text);
              await controller.addHistoryItem(
                  HistoryLogEvent.editThought, jsonEncode(updatedThought));
              setState(() {
                isEditing = false;
                selectedThought = null;
              });
            } else {
              final Thought newThought = await controller.createThought(text);
              await controller.addHistoryItem(
                  HistoryLogEvent.addThought, jsonEncode(newThought.toMap()));
            }
          }),
        ],
      ),
    );
  }
}
