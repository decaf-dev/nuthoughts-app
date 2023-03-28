import 'package:nuthoughts/constants.dart';
import 'package:nuthoughts/controllers/app_controller.dart';
import 'package:nuthoughts/routes/recent_thoughts/recent_thoughts.dart';
import 'package:nuthoughts/routes/settings/settings_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeRoute extends StatefulWidget {
  const HomeRoute({super.key, required this.title});

  final String title;

  @override
  State<HomeRoute> createState() => _HomeRouteState();
}

class _HomeRouteState extends State<HomeRoute> {
  final AppController controller = Get.find();
  final TextEditingController textFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeTextController();
  }

  void initializeTextController() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      textFieldController.text = prefs.getString(Constants.textKey) ?? '';
    });
  }

  @override
  void dispose() {
    textFieldController.dispose();
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
                  Icons.notes,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RecentThoughtsRoute()),
                  );
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
          Expanded(
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 60),
                  child: SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                              controller: textFieldController,
                              onChanged: (value) {
                                controller.setText(value);
                              },
                              style: const TextStyle(height: 1.3),
                              autofocus: true,
                              decoration: const InputDecoration(
                                  border: InputBorder.none),
                              keyboardType: TextInputType.multiline,
                              minLines: 10,
                              maxLines: null)
                        ]),
                  )))
        ]),
        floatingActionButton: FloatingActionButton.extended(
          icon: const Icon(Icons.add),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          label: const Text('New Thought'),
          onPressed: () async {
            String text = textFieldController.text;
            if (text.isNotEmpty) {
              controller.saveThought(text);
              textFieldController.clear();
              controller.setText("");
            }
          },
        ));
    // bottomSheet: ((MediaQuery.of(context).viewInsets.bottom != 0
    //     ? Container(
    //         padding:
    //             const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
    //         child: Row(
    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //           children: [
    //             FloatingActionButton.extended(
    //               icon: const Icon(Icons.add),
    //               backgroundColor: Colors.deepPurple,
    //               foregroundColor: Colors.white,
    //               label: const Text('New Thought'),
    //               onPressed: () => {},
    //             ),
    //           ],
    //         ),
    //       )
    //     : const SizedBox())));
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
