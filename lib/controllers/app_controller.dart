import 'dart:convert';

import 'package:chisel_notes/models/saved_block.dart';
import 'package:get/get.dart';

class AppController extends GetxController {
  final savedBlocks = <SavedBlock>[];

  int getNextBlockId(int bufferLength) {
    return savedBlocks.length + bufferLength + 1;
  }

  Future<bool> saveText(String text) async {
    if (text.isNotEmpty) {
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
      //TODO
      //Encrypt data
      //Send over http and await
      //If successful then add to the savedBlocks
      savedBlocks.addAll(blockBuffer);
    }
    return true;
  }
}
