import '../../models/question.dart';

final RegExp _questionStartPattern = RegExp(
  r'^\s*(?:(?:\d{1,2}|[০-৯]{1,2})\s*[).:]|[ক-হ]\s*[.:])',
  multiLine: true,
);

List<Question> extractQuestions(String text) {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final matches = _questionStartPattern.allMatches(text).toList();

  if (matches.isEmpty) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return const [];
    }
    return [Question(id: 'ocr_${timestamp}_0', text: trimmed)];
  }

  final questions = <Question>[];
  for (var i = 0; i < matches.length; i++) {
    final start = matches[i].start;
    final end = i + 1 < matches.length ? matches[i + 1].start : text.length;
    final questionText = text.substring(start, end).trim();
    if (questionText.isEmpty) {
      continue;
    }
    questions.add(Question(id: 'ocr_${timestamp}_$i', text: questionText));
  }

  return questions;
}
