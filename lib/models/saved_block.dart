class SavedBlock {
  final int id;
  final DateTime submissionDateTime;
  final String text;

  const SavedBlock(
      {required this.id, required this.submissionDateTime, required this.text});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'submissionDateTime': submissionDateTime,
      'text': text,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'submissionDateTime': submissionDateTime.millisecondsSinceEpoch,
      'text': text,
    };
  }

  @override
  String toString() {
    return 'SavedBlock{id: $id, submissionDateTime: $submissionDateTime, text: $text}';
  }
}
