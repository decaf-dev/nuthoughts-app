import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:nuthoughts/constants.dart' as constants;
import 'package:nuthoughts/controllers/sql_data.dart';
import 'package:nuthoughts/models/thought.dart';
import 'package:nuthoughts/models/sync_time.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AppController extends GetxController {
  final savedThoughts = <Thought>[].obs;
  final syncTime = SyncTime();
  final ipAddress = ''.obs;
  final port = ''.obs;

  Timer? _reconnectionTimer;

  late SharedPreferences _prefs;
  TextEditingController textController = TextEditingController();

  @override
  void onInit() async {
    _prefs = await SharedPreferences.getInstance();

    ipAddress.value = _prefs.getString(constants.ipAddressKey) ?? 'localhost';
    port.value = _prefs.getString(constants.portKey) ?? '8123';

    Uint8List? caData = await SQLData.getCertificateAuthority();
    if (caData != null) {
      _updateSecurityContext(caData);
    }

    await _pruneOldThoughts();

    //Start the timer to update the sync time string
    syncTime.startTimer();

    super.onInit();
  }

  @override
  void dispose() {
    syncTime.dispose();
    _reconnectionTimer?.cancel();
    super.dispose();
  }

  Future<void> syncThoughts() async {
    print("Syncing thoughts");
    //Get the thoughts that haven't been saved
    List<Thought> thoughtsToSave = savedThoughts
        .where((thought) => thought.hasBeenSavedOnServer() == false)
        .toList();

    //Only preform the action if not empty
    if (thoughtsToSave.isNotEmpty) {
      //Attempt to sync every thought
      List<bool> result = await Future.wait(
          thoughtsToSave.map((thought) => _thoughtPost(thought)));

      //If one thought was successful, update the sync time
      if (result.any((val) => val == true)) {
        syncTime.updateSyncTime();
        //Restart the time. This is because the sync time needs to update exactly
        //1 minute from the last successful sync. Otherwise it will be out off by a few seconds
        syncTime.restartTimer();
      }
    }
  }

  void saveThought(String text) async {
    //Save the thought
    final Thought thought = Thought(text.trim());

    int id = await SQLData.insertThought(thought);
    //Set the id, this is important for future operations
    thought.id = id;

    savedThoughts.add(thought);
    savedThoughts.refresh();
    // bool wasSuccessful = await _thoughtPost(thought);

    // if (wasSuccessful) {
    //   syncTime.updateSyncTime();
    //   //Restart the time. This is because the sync time needs to update exactly
    //   //1 minute from the last successful sync. Otherwise it will be out off by a few seconds
    //   syncTime.restartTimer();
    // }
  }

  Future<void> saveIpAddress(String value) async {
    await _prefs.setString(constants.ipAddressKey, value);
    ipAddress.value = value;
  }

  Future<void> savePort(String value) async {
    await _prefs.setString(constants.portKey, value);
    port.value = value;
  }

  Future<void> saveText(String value) async {
    await _prefs.setString(constants.textKey, value);
  }

  Future<void> saveCertificateAuthority(Uint8List value) async {
    await SQLData.insertCertificateAuthority(value);
    _updateSecurityContext(value);
  }

  void _updateSecurityContext(Uint8List value) {
    print("Updating security context with certificate authority");
    SecurityContext.defaultContext.setTrustedCertificatesBytes(value);
  }

  Future<void> restoreThought(int id) async {
    Thought thought = savedThoughts.firstWhere((el) => el.id == id);
    //Update text controller
    textController.text += thought.text;
    saveText(textController.text);

    await SQLData.deleteThought(id);
    savedThoughts.removeWhere((el) => el.id == id);
    savedThoughts.refresh();
  }

  Future<void> _pruneOldThoughts() async {
    List<Thought> thoughts = await SQLData.listThoughts();

    //Create a copy of the list to prevent concurrent modification
    //Concurrent modification during iteration
    for (Thought thought in List.from(thoughts)) {
      int id = thought.id;
      if (id != -1) {
        if (thought.shouldDelete()) {
          await SQLData.deleteThought(id);
          thoughts.removeWhere((el) => el.id == id);
        }
      }
    }

    //Set the recent thoughts to the pruned list
    savedThoughts.value = thoughts;
  }

  ///Posts a thought to server
  ///Return true if receives 201
  ///Otherwise returns false
  Future<bool> _thoughtPost(Thought thought) async {
    try {
      print("POST https://${ipAddress.value}:${port.value}/thought");
      print(thought.toString());
      final response = await http
          .post(Uri.parse('https://${ipAddress.value}:${port.value}/thought'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: thought.toJson())
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 201) {
        thought.savedOnServer();
        await SQLData.updateThought(thought);
        return true;
      }
      return false;
    } catch (err) {
      print(err);
      return false;
    }
  }
}
