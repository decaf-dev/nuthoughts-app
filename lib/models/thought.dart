class Thought {
  //Will be assigned from the id returned from the PersistedData.insertThought function
  int? id;
  final int creationTime;
  final String text;
  int serverSaveTime;

  Thought(
      {required this.creationTime,
      required this.text,
      this.id,
      this.serverSaveTime = -1});

  Map<String, dynamic> toMap() {
    return {
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

  //If the thought is older than 1 day and it is has been saved, then delete it from the list
  bool shouldDelete() {
    return DateTime.now().millisecondsSinceEpoch - creationTime >
            1000 * 60 * 60 * 24 &&
        hasBeenSavedOnServer();
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
