class Thought {
  final int id;
  final int creationTime;
  final String text;
  int serverSaveTime = -1;

  Thought({required this.id, required this.creationTime, required this.text});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'creationTime': creationTime,
      'text': text,
      'serverSaveTime': serverSaveTime
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'creationTime': creationTime,
      'text': text,
    };
  }

  bool hasBeenSavedOnServer() {
    return serverSaveTime != -1;
  }

  void updateServerSaveTime() {
    serverSaveTime = DateTime.now().microsecondsSinceEpoch;
  }

  @override
  String toString() {
    return 'Thought{id: $id, creationTime: $creationTime, text: $text, serverSaveTime: $serverSaveTime}';
  }
}
