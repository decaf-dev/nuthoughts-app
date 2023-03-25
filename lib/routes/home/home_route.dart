import 'package:chisel_notes/constants.dart';
import 'package:chisel_notes/controllers/app_controller.dart';
import 'package:chisel_notes/routes/saved_blocks/saved_blocks_route.dart';
import 'package:chisel_notes/routes/settings/settings_route.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
                        builder: (context) => const SavedBlocksRoute()),
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
        body: Center(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          child: Obx(() => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextField(
                      controller: textFieldController,
                      onChanged: (value) {
                        controller.setText(value);
                      },
                      autofocus: true,
                      enabled: controller.isLoading.value != true,
                      style: TextStyle(
                          color: controller.isLoading.value
                              ? Colors.grey
                              : Colors.black),
                      decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide:
                                  const BorderSide(color: Colors.green)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide:
                                  const BorderSide(color: Colors.green)),
                          disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: Colors.grey)),
                          hintText: "What are you thinking...?"),
                      keyboardType: TextInputType.multiline,
                      minLines: 10,
                      maxLines: null),
                  const SizedBox(height: 20),
                  if (controller.isLoading.value == true) ...[
                    const CircularProgressIndicator(color: Colors.blue)
                  ],
                  if (controller.isLoading.value == false) ...[
                    MaterialButton(
                      color: Colors.blue,
                      textColor: Colors.white,
                      onPressed: () async {
                        String text = textFieldController.text;
                        if (text.isNotEmpty) {
                          FocusManager.instance.primaryFocus?.unfocus();
                          bool success = await controller
                              .saveText(textFieldController.text);
                          if (success) {
                            textFieldController.clear();
                            controller.setText("");
                          } else {
                            Fluttertoast.showToast(
                              msg: 'An error occurred while submitting data.',
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                            );
                          }
                        }
                      },
                      child: const Text("Save"),
                    )
                  ]
                ],
              )),
        )));
  }
}
