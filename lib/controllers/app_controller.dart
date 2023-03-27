import 'dart:convert';

import 'package:chisel_notes/constants.dart';
import 'package:chisel_notes/models/thought.dart';
import 'package:chisel_notes/models/sync_time.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AppController extends GetxController {
  final recentThoughts = <Thought>[];
  final syncTime = SyncTime();
  final isLoading = false.obs;
  final ipAddress = ''.obs;
  final port = ''.obs;

  @override
  void onInit() async {
    final prefs = await SharedPreferences.getInstance();
    ipAddress.value = prefs.getString(Constants.ipAddressKey) ?? 'localhost';
    port.value = prefs.getString(Constants.portKey) ?? '9005';
    super.onInit();
  }

  int getNextBlockId() {
    return recentThoughts.length + 1;
  }

  void saveThought(String text) async {
    Thought thought = Thought(
        id: getNextBlockId(), creationDateTime: DateTime.now(), text: text);
    recentThoughts.add(thought);
    await thoughtPost(thought);
  }

  Future<bool> thoughtPost(Thought thought) async {
    try {
      final response = await http.post(
        Uri.parse('http://${ipAddress.value}:${port.value}/thought'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(thought.toJson()),
      );
      if (response.statusCode == 201) {
        thought.updateServerSaveTime();
        return true;
      } else {
        return false;
      }
    } catch (err) {
      return false;
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
