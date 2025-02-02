import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:nuthoughts/constants.dart' as constants;
import 'package:nuthoughts/controllers/persisted_storage.dart';
import 'package:nuthoughts/models/history_log_item.dart';
import 'package:nuthoughts/models/thought.dart';
import 'package:nuthoughts/utils/snackbar_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppController extends GetxController {
  final savedThoughts = <Thought>[].obs;
  final historyLog = <HistoryLogItem>[].obs;
  final ipAddress = ''.obs;
  final port = ''.obs;

  late SharedPreferences _prefs;
  TextEditingController textController = TextEditingController();
  GlobalKey scaffoldKey = GlobalKey();

  @override
  void onInit() async {
    _prefs = await SharedPreferences.getInstance();

    ipAddress.value = _prefs.getString(constants.ipAddressKey) ?? 'localhost';
    port.value = _prefs.getString(constants.portKey) ?? '8123';

    Uint8List? caData = await PersistedStorage.getCertificateAuthority();
    if (caData != null) {
      _updateSecurityContext(caData);
    }

    await _pruneOldThoughts();
    historyLog.value = await PersistedStorage.getHistoryLog();

    super.onInit();
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

      for (Thought thought in thoughtsToSave) {
        try {
          await _thoughtPost(thought);
        } on HandshakeException catch (err) {
          print(err);
          displayErrorSnackBar(scaffoldKey.currentContext!,
              "Handshake error. Check certificate authority");
          break;
        } on SocketException catch (err) {
          print(err);
          displayErrorSnackBar(scaffoldKey.currentContext!,
              "Socket error. Cannot connect to server.\nCheck IP address and port.\nIs the server running?");
          break;
        } catch (err) {
          print(err);
          displayErrorSnackBar(
              scaffoldKey.currentContext!, "Unhandled exception");
          break;
        }
      }
      savedThoughts.refresh();
    }
  }

  Future<void> addHistoryItem(
      constants.HistoryLogEvent eventType, String text) async {
    final HistoryLogItem item = HistoryLogItem(eventType, text);
    await PersistedStorage.insertHistoryItem(item);
    historyLog.add(item);
    historyLog.refresh();
  }

  Future<void> saveThought(String text) async {
    //Save the thought
    final Thought thought = Thought(text.trim());

    int id = await PersistedStorage.insertThought(thought);
    //Set the id, this is important for future operations
    thought.id = id;

    savedThoughts.add(thought);
    savedThoughts.refresh();
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
    await PersistedStorage.insertCertificateAuthority(value);
    _updateSecurityContext(value);
  }

  void _updateSecurityContext(Uint8List value) {
    // String string = String.fromCharCodes(value);
    // print(string);

    //TODO there was a bug where changing from an invalid to a new certificate
    //wasn't updating. Does this function update?
    SecurityContext.defaultContext.setTrustedCertificatesBytes(value);
  }

  Future<void> restoreThought(int id) async {
    Thought thought = savedThoughts.firstWhere((el) => el.id == id);
    //Update text controller
    textController.text += thought.text;
    saveText(textController.text);

    await PersistedStorage.deleteThought(id);
    savedThoughts.removeWhere((el) => el.id == id);
    savedThoughts.refresh();
  }

  Future<void> deleteThought(int id) async {
    await PersistedStorage.deleteThought(id);
    savedThoughts.removeWhere((el) => el.id == id);
    savedThoughts.refresh();
  }

  Future<void> _pruneOldThoughts() async {
    List<Thought> thoughts = await PersistedStorage.getThoughts();

    //Create a copy of the list to prevent concurrent modification
    //Concurrent modification during iteration
    for (Thought thought in List.from(thoughts)) {
      int id = thought.id;
      if (id != -1) {
        if (thought.shouldDelete()) {
          await PersistedStorage.deleteThought(id);
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
  Future<void> _thoughtPost(Thought thought) async {
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
      await PersistedStorage.updateThought(thought);
    }
  }
}
