class SavedBlock {
  final int id;
  final DateTime submissionDateTime;
  final String text;

  const SavedBlock(
      {required this.id, required this.submissionDateTime, required this.text});

  Map<String, dynamic> toMap() {
    return {
      'submissionDateTime': submissionDateTime,
      'text': text,
    };
  }

  @override
  String toString() {
    return 'SavedBlock{id: $id, submissionDateTime: $submissionDateTime, text: $text}';
  }
}
