import 'dart:async';
import 'dart:convert';

import 'package:nuthoughts/constants.dart';
import 'package:nuthoughts/controllers/persisted_data.dart';
import 'package:nuthoughts/models/thought.dart';
import 'package:nuthoughts/models/sync_time.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AppController extends GetxController {
  final recentThoughts = <Thought>[].obs;
  final syncTime = SyncTime();
  final ipAddress = ''.obs;
  final port = ''.obs;

  Timer? _reconnectionTimer;

  @override
  void onInit() async {
    //Deserialize preferences
    final prefs = await SharedPreferences.getInstance();
    ipAddress.value = prefs.getString(Constants.ipAddressKey) ?? 'localhost';
    port.value = prefs.getString(Constants.portKey) ?? '9005';

    //Deserialize thoughts
    //Prune thoughts that are over 1 day old
    List<Thought> thoughts = await PersistedData.listThoughts();
    for (Thought thought in thoughts) {
      if (thought.shouldDelete()) {
        await PersistedData.deleteThought(thought.id!);
        thoughts.removeWhere((el) => el.id == thought.id);
      }
    }
    recentThoughts.value = thoughts;

    //Start the timer to update the sync time string
    syncTime.restartTimer();

    //Attempt to sync thoughts on start up
    bool success = await _syncUnsavedThoughts();
    if (!success) {
      restartReconnectionTimer();
    }
    //Start disconnection timer
    super.onInit();
  }

  void restartReconnectionTimer() {
    _reconnectionTimer?.cancel();
    _reconnectionTimer = Timer.periodic(
      const Duration(minutes: 1),
      (Timer timer) async {
        await _syncUnsavedThoughts();
      },
    );
  }

  @override
  void dispose() {
    syncTime.dispose();
    _reconnectionTimer?.cancel();
    super.dispose();
  }

  void saveThought(String text) async {
    Thought thought = Thought(
        creationTime: DateTime.now().millisecondsSinceEpoch, text: text);
    recentThoughts.add(thought);
    int id = await PersistedData.insertThought(thought);
    thought.id = id;
    bool wasSuccessful = await _thoughtPost(thought);
    if (wasSuccessful) {
      syncTime.updateSyncTime();
    } else {
      restartReconnectionTimer();
    }
  }

  Future<bool> _thoughtPost(Thought thought) async {
    try {
      final response = await http
          .post(
            Uri.parse('http://${ipAddress.value}:${port.value}/thought'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(thought.toJson()),
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 201) {
        thought.updateServerSaveTime();
        await PersistedData.updateThought(thought);
        return true;
      } else {
        return false;
      }
    } catch (err) {
      return false;
    }
  }

  Future<bool> _syncUnsavedThoughts() async {
    List<Thought> thoughtsToSave = recentThoughts
        .where((thought) => !thought.hasBeenSavedOnServer())
        .toList();
    if (thoughtsToSave.isNotEmpty) {
      var result = await Future.wait(
          thoughtsToSave.map((thought) => _thoughtPost(thought)));
      if (result.every((val) => val == true)) {
        //Cancel reconnection timer
        _reconnectionTimer?.cancel();
        //If all the thoughts were successful
        //then update the time and the display string
        syncTime.updateSyncTime();
        return true;
      }
      return false;
    }
    return true;
  }

  void setIpAddress(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(Constants.ipAddressKey, value);
    ipAddress.value = value;
  }

  void setPort(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(Constants.portKey, value);
    port.value = value;
  }

  void setText(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(Constants.textKey, value);
  }
}
