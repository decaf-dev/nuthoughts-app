class Thought {
  final int id;
  final DateTime creationDateTime;
  final String text;
  DateTime? serverSaveDateTime;

  Thought(
      {required this.id, required this.creationDateTime, required this.text});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createDateTime': creationDateTime,
      'text': text,
      'serverSaveDateTime': serverSaveDateTime
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'creationTime': creationDateTime.millisecondsSinceEpoch,
      'text': text,
    };
  }

  bool hasBeenSavedOnServer() {
    return serverSaveDateTime != null;
  }

  void updateServerSaveTime() {
    serverSaveDateTime = DateTime.now();
  }

  @override
  String toString() {
    return 'Thought{id: $id, creationDateTime: $creationDateTime, text: $text, serverSaveDateTime: $serverSaveDateTime}';
  }
}
