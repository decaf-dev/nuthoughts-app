import 'dart:convert';

import 'package:chisel_notes/constants.dart';
import 'package:chisel_notes/models/saved_block.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AppController extends GetxController {
  final savedBlocks = <SavedBlock>[];
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

  int getNextBlockId(int bufferLength) {
    return savedBlocks.length + bufferLength + 1;
  }

  Future<bool> saveText(String text) async {
    //Set the loading icon
    isLoading.value = true;

    //We will split all of the text based on a new line
    LineSplitter ls = const LineSplitter();
    final List<String> lines = ls.convert(text);
    List<SavedBlock> blockBuffer = [];

    //We then will group the blocks together and save them
    StringBuffer textBuffer = StringBuffer();
    for (var i = 0; i < lines.length; i++) {
      String line = lines[i];
      if (line.isNotEmpty) textBuffer.writeln(line);
      if (line.isEmpty || i == lines.length - 1) {
        String block = textBuffer.toString().trim();
        SavedBlock newBlock = SavedBlock(
            id: getNextBlockId(blockBuffer.length),
            submissionDateTime: DateTime.now(),
            text: block);
        blockBuffer.add(newBlock);
        textBuffer.clear();
      }
    }

    bool success = await saveBlocks(blockBuffer);
    savedBlocks.addAll(blockBuffer);
    isLoading.value = false;
    return success;
  }

  Future<bool> saveBlocks(List<SavedBlock> blocks) async {
    try {
      final response = await http.post(
        Uri.parse('http://${ipAddress.value}:${port.value}/save-blocks'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(blocks.map((block) => block.toJson()).toList()),
      );
      if (response.statusCode == 201) {
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
