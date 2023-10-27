import 'package:nuthoughts/constants.dart' as constants;
import 'package:nuthoughts/controllers/app_controller.dart';
import 'package:nuthoughts/routes/settings/settings_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nuthoughts/routes/home/message_input.dart';

class HomeRoute extends StatefulWidget {
  const HomeRoute({super.key, required this.title});

  final String title;

  @override
  State<HomeRoute> createState() => _HomeRouteState();
}

class _HomeRouteState extends State<HomeRoute> {
  final AppController controller = Get.find();

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
        actions: [
          IconButton(
              icon: const Icon(
                Icons.sync,
                color: Colors.white,
              ),
              onPressed: () {
                controller.syncUnsavedThoughts();
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
        // Expanded(
        //     child: Padding(
        //         padding: const EdgeInsets.fromLTRB(20, 0, 20, 60),
        //         child: SingleChildScrollView(
        //           child: Column(
        //               crossAxisAlignment: CrossAxisAlignment.start,
        //               children: [
        //                 TextField(
        //                     spellCheckConfiguration: kIsWeb
        //                         ? null
        //                         : const SpellCheckConfiguration(),
        //                     controller: textFieldController,
        //                     onChanged: (value) {
        //                       controller.saveText(value);
        //                     },
        //                     style: const TextStyle(height: 1.3),
        //                     autofocus: true,
        //                     decoration: const InputDecoration(
        //                         border: InputBorder.none),
        //                     keyboardType: TextInputType.multiline,
        //                     minLines: 10,
        //                     maxLines: null)
        //               ]),
        //         )))
        MessageInput(controller.saveText, (String text) {
          print("HERE!");
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
