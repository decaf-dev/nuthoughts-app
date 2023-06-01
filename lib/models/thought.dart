import 'dart:convert';

import 'package:nuthoughts/constants.dart';

class Thought {
  //-1 because sqlite doesn't allow null values
  int id = -1;
  int serverSaveTime = -1;
  final String text;
  late int creationTime;

  Thought(this.text, {int? creationTime}) {
    if (creationTime != null) {
      this.creationTime = creationTime;
    } else {
      this.creationTime = DateTime.now().millisecondsSinceEpoch;
    }
  }

  Thought.fromDatabase(Map<String, dynamic> map)
      : id = map['id'],
        text = map['text'],
        creationTime = map['creationTime'],
        serverSaveTime = map['serverSaveTime'];

  ///Converts a thought to a map that can be saved in the database
  Map<String, dynamic> toMap() {
    return {
      'creationTime': creationTime,
      'text': text,
      'serverSaveTime': serverSaveTime
    };
  }

  /// Converts a thought to a json string
  String toJson() {
    return jsonEncode({
      'creationTime': creationTime,
      'text': text,
    });
  }

  ///If the thought is older than 1 day and it is has been saved on the server
  bool shouldDelete() {
    return DateTime.now().millisecondsSinceEpoch - creationTime >
            Constants.millisDay &&
        hasBeenSavedOnServer();
  }

  ///If the thought has been saved on the server
  bool hasBeenSavedOnServer() {
    return serverSaveTime != -1;
  }

  ///Sets the server save time to the current time
  void savedOnServer() {
    serverSaveTime = DateTime.now().millisecondsSinceEpoch;
  }

  @override
  String toString() {
    return 'Thought{id: $id, creationTime: $creationTime, text: $text, serverSaveTime: $serverSaveTime}';
  }
}
