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
  final isLoading = false.obs;
  final ipAddress = ''.obs;
  final port = ''.obs;

  @override
  void onInit() async {
    final prefs = await SharedPreferences.getInstance();
    ipAddress.value = prefs.getString(Constants.ipAddressKey) ?? 'localhost';
    port.value = prefs.getString(Constants.portKey) ?? '9005';

    //Prune thoughts that are over 1 day old
    List<Thought> thoughts = await PersistedData.listThoughts();
    for (Thought thought in thoughts) {
      if (thought.shouldDelete()) {
        await PersistedData.deleteThought(thought.id!);
        thoughts.removeWhere((el) => el.id == thought.id);
      }
    }
    recentThoughts.value = thoughts;
    super.onInit();
  }

  void saveThought(String text) async {
    Thought thought = Thought(
        creationTime: DateTime.now().millisecondsSinceEpoch, text: text);
    recentThoughts.add(thought);
    int id = await PersistedData.insertThought(thought);
    thought.id = id;
    await _thoughtPost(thought);
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
        syncTime.updateSyncTime();
        thought.updateServerSaveTime();
        await PersistedData.updateThought(thought);
        await _syncUnsavedThoughts();
        return true;
      } else {
        return false;
      }
    } catch (err) {
      return false;
    }
  }

  Future<void> _syncUnsavedThoughts() async {
    for (Thought thought in recentThoughts) {
      if (!thought.hasBeenSavedOnServer()) {
        await _thoughtPost(thought);
      }
    }
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
