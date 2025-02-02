import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/io_client.dart';
import 'package:nuthoughts/constants.dart' as constants;
import 'package:nuthoughts/constants.dart';
import 'package:nuthoughts/controllers/persisted_storage.dart';
import 'package:nuthoughts/models/history_log_item.dart';
import 'package:nuthoughts/models/thought.dart';
import 'package:nuthoughts/utils/snackbar_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppController extends GetxController {
  final RxList<Thought> savedThoughts = <Thought>[].obs;
  final RxList<HistoryLogItem> historyLog = <HistoryLogItem>[].obs;
  final RxString ipAddress = ''.obs;
  final RxString port = ''.obs;
  final Rx<Thought> selectedThought = Thought("").obs;
  final RxString themeMode = 'system'.obs;

  final TextEditingController textController = TextEditingController();
  final GlobalKey scaffoldKey = GlobalKey();

  int currentHistoryItemIndex = -1.obs;
  IOClient? ioClient;

  late SharedPreferences _prefs;

  @override
  void onInit() async {
    _prefs = await SharedPreferences.getInstance();

    ipAddress.value =
        _prefs.getString(constants.ipAddressKey) ?? constants.defaultIpAddress;
    port.value = _prefs.getString(constants.portKey) ?? constants.defaultPort;

    Uint8List? caData = await PersistedStorage.getCertificateAuthority();
    if (caData != null) {
      _loadCertificateAuthority(caData);
    }

    await _pruneOldThoughts();
    // historyLog.value = await PersistedStorage.getHistoryLog();
    // currentHistoryItemIndex = historyLog.length - 1;

    super.onInit();
  }

  Future<void> updateMessageInput(String text) async {
    textController.text = text;
    await saveText(textController.text);
  }

  Future<void> syncThoughts() async {
    //Get the thoughts that haven't been saved
    List<Thought> thoughtsToSave = savedThoughts
        .where((thought) => thought.hasBeenSavedOnServer() == false)
        .toList();

    IOClient? ioClient = this.ioClient;
    if (ioClient == null) {
      showSnackBar(scaffoldKey.currentContext!, SnackBarType.error,
          "No certificate authority found. Please set one in settings.");
      return;
    }

    if (thoughtsToSave.isNotEmpty) {
      for (Thought thought in thoughtsToSave) {
        try {
          await _postThought(ioClient, thought);

          historyLog.removeWhere((el) {
            if (el.eventType == HistoryLogEvent.editThought) {
              return Thought.fromJson(jsonDecode(el.payload)['old']).id ==
                  thought.id;
            }
            return Thought.fromJson(el.payload).id == thought.id;
          });
          currentHistoryItemIndex = historyLog.length - 1;
        } on HandshakeException catch (_) {
          showSnackBar(scaffoldKey.currentContext!, SnackBarType.error,
              "Handshake error. Invalid certificate authority");
          break;
        } on SocketException catch (_) {
          showSnackBar(scaffoldKey.currentContext!, SnackBarType.error,
              "Error connecting to server");
          break;
        } catch (err) {
          print(err);
          showSnackBar(scaffoldKey.currentContext!, SnackBarType.error,
              "Unhandled exception");
          break;
        }
      }
      savedThoughts.refresh();
    }
  }

  Future<void> addHistoryItem(
      constants.HistoryLogEvent eventType, String text) async {
    final HistoryLogItem item = HistoryLogItem(eventType, text);

    historyLog.add(item);
    historyLog.refresh();

    if (eventType == HistoryLogEvent.addThought ||
        eventType == HistoryLogEvent.editThought) {
      currentHistoryItemIndex = currentHistoryItemIndex + 1;
    } else if (eventType == HistoryLogEvent.deleteThought) {
      currentHistoryItemIndex = currentHistoryItemIndex - 1;
    }
  }

  Future<Thought> createThought(String text) async {
    //Save the thought
    final Thought thought = Thought(text.trim());

    int id = await PersistedStorage.insertThought(thought);
    thought.id = id;

    savedThoughts.add(thought);
    savedThoughts.refresh();
    return thought;
  }

  Future<Map<String, dynamic>> updateThought(int id, String text) async {
    int index = savedThoughts.indexWhere((t) => t.id == id);
    if (index == -1) throw Exception('Thought not found');

    Thought selectedThought = savedThoughts[index];

    Thought updatedThought = Thought.fromMap({
      'id': selectedThought.id,
      'text': text,
      'creationTime': selectedThought.creationTime,
      'serverSaveTime': selectedThought.serverSaveTime,
    });

    await PersistedStorage.updateThought(updatedThought);
    savedThoughts[index] = updatedThought;
    savedThoughts.refresh();

    return {
      'old': jsonEncode(selectedThought.toMap()),
      'new': jsonEncode(updatedThought.toMap()),
    };
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
    _loadCertificateAuthority(value);
  }

  void _loadCertificateAuthority(Uint8List value) {
    ioClient?.close();

    //Create a new context with the trusted certificate
    SecurityContext newContext = SecurityContext();
    newContext.setTrustedCertificatesBytes(value);

    //Create a new IOClient with the new context
    HttpClient client = HttpClient(context: newContext)
      ..connectionTimeout =
          const Duration(seconds: constants.httpTimeoutSeconds);
    ioClient = IOClient(client);
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
  Future<void> _postThought(IOClient ioClient, Thought thought) async {
    final response = await ioClient.post(
        Uri.parse('https://${ipAddress.value}:${port.value}/thought'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: thought.toJson());

    if (response.statusCode == 201) {
      thought.savedOnServer();
      await PersistedStorage.updateThought(thought);
    } else {
      print(response.statusCode);
      print(response.body);
      throw Exception('Failed to post thought');
    }
  }

  Future<void> redoHistoryEvent(HistoryLogItem event) async {
    switch (event.eventType) {
      case HistoryLogEvent.addThought:
        Thought thought = Thought.fromJson(event.payload);
        savedThoughts.add(thought);
        await PersistedStorage.insertThought(thought, includeId: true);
        break;
      case HistoryLogEvent.deleteThought:
        Thought thought = Thought.fromJson(event.payload);
        savedThoughts.removeWhere((t) => t.id == thought.id);
        await PersistedStorage.deleteThought(thought.id);
        break;
      case HistoryLogEvent.editThought:
        Map<String, dynamic> data = jsonDecode(event.payload);
        Thought newThought = Thought.fromJson(data['new']);
        int index = savedThoughts.indexWhere((t) => t.id == newThought.id);
        if (index != -1) {
          savedThoughts[index] = newThought;
        }
        break;
    }
  }

  Future<void> undoHistoryEvent(HistoryLogItem event) async {
    switch (event.eventType) {
      case HistoryLogEvent.addThought:
        Thought thought = Thought.fromJson(event.payload);
        savedThoughts.removeWhere((t) => t.id == thought.id);
        await PersistedStorage.deleteThought(thought.id);
        break;
      case HistoryLogEvent.deleteThought:
        Thought thought = Thought.fromJson(event.payload);
        savedThoughts.add(thought);
        await PersistedStorage.insertThought(thought, includeId: true);
        break;
      case HistoryLogEvent.editThought:
        Map<String, dynamic> data = jsonDecode(event.payload);
        Thought oldThought = Thought.fromJson(data['old']);
        int index = savedThoughts.indexWhere((t) => t.id == oldThought.id);
        if (index != -1) {
          savedThoughts[index] = oldThought;
        }
        break;
    }
  }
}
