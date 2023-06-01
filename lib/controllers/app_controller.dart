import 'dart:async';

import 'package:cryptography/cryptography.dart';
import 'package:nuthoughts/constants.dart';
import 'package:nuthoughts/controllers/saved_data.dart';
import 'package:nuthoughts/models/encryption.dart';
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

  SecretKey? encryptionKey;
  String? encryptionKeyText;
  Timer? _reconnectionTimer;

  late SharedPreferences _prefs;

  @override
  void onInit() async {
    _prefs = await SharedPreferences.getInstance();

    ipAddress.value = _prefs.getString(Constants.ipAddressKey) ?? 'localhost';
    port.value = _prefs.getString(Constants.portKey) ?? '9005';

    await _setupEncryption();
    await _pruneOldThoughts();

    //Start the timer to update the sync time string
    syncTime.startTimer();

    //Attempt to sync thoughts on start up
    bool success = await _syncUnsavedThoughts();
    if (!success) {
      _restartReconnectionTimer();
    }
    super.onInit();
  }

  Future<void> _setupEncryption() async {
    //If have a base64Key in memory, convert it to a secret key
    //Otherwise create a new random key, and save it in memory
    String? base64Key = _prefs.getString(Constants.encryptionKey);
    if (base64Key != null) {
      encryptionKeyText = base64Key;
      encryptionKey = await Encryption.serializeSecretKey(base64Key);
    } else {
      final SecretKey encryptionKey = await Encryption.createRandomKey();
      this.encryptionKey = encryptionKey;

      final String serializedKey =
          await Encryption.deserializeSecretKey(encryptionKey);
      encryptionKeyText = serializedKey;
      await saveEncryptionKey(serializedKey);
    }
  }

  Future<void> _pruneOldThoughts() async {
    List<Thought> thoughts = await SavedData.listThoughts();
    for (Thought thought in thoughts) {
      int id = thought.id;
      if (id != -1) {
        if (thought.shouldDelete()) {
          await SavedData.deleteThought(id);
          thoughts.removeWhere((el) => el.id == id);
        }
      }
    }

    //Set the recent thoughts to the pruned list
    recentThoughts.value = thoughts;
  }

  void _restartReconnectionTimer() {
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
    //Save the thought
    final Thought thought = Thought(text.trim());
    await SavedData.insertThought(thought);
    recentThoughts.add(thought);

    bool wasSuccessful = await _thoughtPost(thought);
    if (wasSuccessful) {
      syncTime.updateSyncTime();
      //Restart the time. This is because the sync time needs to update exactly
      //1 minute from the last successful sync. Otherwise it will be out off by a few seconds
      syncTime.restartTimer();

      _syncUnsavedThoughts();
    }
  }

  Future<String> encryptThought(Thought thought) {
    final SecretKey? encryptionKey = this.encryptionKey;
    if (encryptionKey == null) {
      throw Exception('Encryption key not set');
    }
    return Encryption.encryptString(encryptionKey, thought.toJson());
  }

  ///Posts a thought to server
  ///Return true if receives 201
  ///Otherwise returns false
  Future<bool> _thoughtPost(Thought thought) async {
    try {
      String encryptedText = await encryptThought(thought);
      final response = await http
          .post(Uri.parse('http://${ipAddress.value}:${port.value}/thought'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: encryptedText)
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 201) {
        thought.savedOnServer();
        await SavedData.updateThought(thought);
        return true;
      }
      return false;
    } catch (err) {
      return false;
    }
  }

  Future<bool> _syncUnsavedThoughts() async {
    //Get the thoughts that haven't been saved
    List<Thought> thoughtsToSave = recentThoughts
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

      //If every thought was successful
      if (result.every((val) => val == true)) {
        //Cancel reconnection timer
        _reconnectionTimer?.cancel();
        return true;
      }
      return false;
    }
    return true;
  }

  Future<void> saveIpAddress(String value) async {
    await _prefs.setString(Constants.ipAddressKey, value);
    ipAddress.value = value;
  }

  Future<void> savePort(String value) async {
    await _prefs.setString(Constants.portKey, value);
    port.value = value;
  }

  Future<void> saveText(String value) async {
    await _prefs.setString(Constants.textKey, value);
  }

  Future<void> saveEncryptionKey(String value) async {
    await _prefs.setString(Constants.encryptionKey, value);
  }
}
