class Question {
  const Question({
    required this.id,
    required this.text,
    this.options = const <String>[],
    this.correctOptionIndex,
  });

  final String id;
  final String text;
  final List<String> options;
  final int? correctOptionIndex;
}
