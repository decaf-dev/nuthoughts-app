class Thought {
  final int id;
  final DateTime creationDateTime;
  final String text;
  DateTime? savedDateTime;

  Thought(
      {required this.id, required this.creationDateTime, required this.text});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createDateTime': creationDateTime,
      'text': text,
      'savedDateTime': savedDateTime
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'creationTime': creationDateTime.millisecondsSinceEpoch,
      'text': text,
    };
  }

  bool hasBeenSaved() {
    return savedDateTime != null;
  }

  @override
  String toString() {
    return 'Thought{id: $id, creationDateTime: $creationDateTime, text: $text, savedDateTime: $savedDateTime}';
  }
}
