import 'dart:convert';

import 'package:chisel_notes/models/saved_block.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class AppController extends GetxController {
  final savedBlocks = <SavedBlock>[];
  final isLoading = false.obs;

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
    isLoading.value = false;
    return success;
  }

  Future<bool> saveBlocks(List<SavedBlock> blocks) async {
    print(jsonEncode(blocks.map((block) => block.toJson()).toList()));
    try {
      final response = await http.post(
        Uri.parse('http://<url>/save-blocks'),
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
}
