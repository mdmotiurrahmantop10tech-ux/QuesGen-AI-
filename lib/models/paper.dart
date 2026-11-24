import 'question.dart';

class Paper {
  const Paper({
    required this.id,
    required this.title,
    required this.createdAt,
    this.questions = const <Question>[],
  });

  final String id;
  final String title;
  final DateTime createdAt;
  final List<Question> questions;
}
