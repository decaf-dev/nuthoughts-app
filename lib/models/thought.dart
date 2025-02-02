import 'dart:convert';

import 'package:nuthoughts/constants.dart' as constants;

class Thought {
  //-1 because sqlite doesn't allow null values
  int id = -1;
  int serverSaveTime = -1;
  final String text;
  late int createdOn;

  Thought(this.text, {int? createdOn}) {
    if (createdOn != null) {
      this.createdOn = createdOn;
    } else {
      this.createdOn = DateTime.now().millisecondsSinceEpoch;
    }
  }

  Thought.fromDatabase(Map<String, dynamic> map)
      : id = map['id'],
        text = map['text'],
        createdOn = map['createdOn'],
        serverSaveTime = map['serverSaveTime'];

  ///Converts a thought to a map that can be saved in the database
  Map<String, dynamic> toMap() {
    return {
      'createdOn': createdOn,
      'text': text,
      'serverSaveTime': serverSaveTime
    };
  }

  /// Converts a thought to a json string
  String toJson() {
    return jsonEncode({
      'createdOn': createdOn,
      'text': text,
    });
  }

  ///If the thought is older than 3 days and it is has been saved on the server
  bool shouldDelete() {
    return DateTime.now().millisecondsSinceEpoch - createdOn >
            constants.millisDay * 3 &&
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
    return 'Thought{id: $id, createdOn: $createdOn, text: $text, serverSaveTime: $serverSaveTime}';
  }
}
