import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:nuthoughts/controllers/app_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsRoute extends StatefulWidget {
  const SettingsRoute({super.key});

  @override
  State<SettingsRoute> createState() => _SettingsRouteState();
}

class _SettingsRouteState extends State<SettingsRoute> {
  final AppController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: Obx(
          () => SettingsList(
            sections: [
              SettingsSection(
                title: const Text('Server'),
                tiles: <SettingsTile>[
                  SettingsTile.navigation(
                    leading: const Icon(Icons.computer),
                    title: const Text('IP Address'),
                    value: Text(controller.ipAddress.value),
                    onPressed: (BuildContext context) {
                      _showSettingDialog(
                          "IP Address", controller.saveIpAddress);
                    },
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.dns),
                    title: const Text('Port'),
                    value: Text(controller.port.value),
                    onPressed: (BuildContext context) {
                      _showSettingDialog("Port", controller.savePort);
                    },
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.security),
                    title: const Text('Certificate authority'),
                    onPressed: (BuildContext context) async {
                      FilePickerResult? result =
                          await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['pem'],
                      );

                      if (result != null) {
                        File file = File(result.files.single.path!);
                        Uint8List data = await file.readAsBytes();
                        SecurityContext.defaultContext
                            .setTrustedCertificatesBytes(data);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  void _showSettingDialog(String title, Function(String value) onSave) {
    final textController = TextEditingController();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: TextField(controller: textController, autofocus: true),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    _dismissDialog();
                  },
                  child: const Text('Close')),
              TextButton(
                onPressed: () {
                  onSave(textController.text);
                  _dismissDialog();
                },
                child: const Text('Save'),
              )
            ],
          );
        });
  }

  _dismissDialog() {
    Navigator.pop(context);
  }
}
