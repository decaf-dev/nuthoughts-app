import 'dart:convert';

import 'package:nuthoughts/constants.dart';

class Thought {
  final int id;
  final String text;
  late int creationTime;
  int serverSaveTime;

  Thought(this.id, this.text, {int? creationTime, this.serverSaveTime = -1}) {
    if (creationTime != null) {
      this.creationTime = creationTime;
    } else {
      this.creationTime = DateTime.now().millisecondsSinceEpoch;
    }
  }

  ///Converts a thought to a map that can be saved in the database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
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
    serverSaveTime = DateTime.now().microsecondsSinceEpoch;
  }

  @override
  String toString() {
    return 'Thought{id: $id, creationTime: $creationTime, text: $text, serverSaveTime: $serverSaveTime}';
  }
}
