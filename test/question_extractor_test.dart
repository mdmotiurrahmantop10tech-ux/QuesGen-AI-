import 'package:flutter_test/flutter_test.dart';
import 'package:quesgen/features/ocr/question_extractor.dart';

void main() {
  test('splits ASCII numbered questions', () {
    final questions = extractQuestions(
      '1. First question\n2. Second question\n3. Third question',
    );

    expect(questions, hasLength(3));
    expect(questions[0].text, '1. First question');
    expect(questions[1].text, '2. Second question');
    expect(questions[2].text, '3. Third question');
  });

  test('splits Bengali numbered and lettered questions', () {
    final questions = extractQuestions(
      '১. প্রথম প্রশ্ন\n২. দ্বিতীয় প্রশ্ন\nক. তৃতীয় প্রশ্ন\nখ. চতুর্থ প্রশ্ন',
    );

    expect(questions, hasLength(4));
    expect(questions[0].text, '১. প্রথম প্রশ্ন');
    expect(questions[1].text, '২. দ্বিতীয় প্রশ্ন');
    expect(questions[2].text, 'ক. তৃতীয় প্রশ্ন');
    expect(questions[3].text, 'খ. চতুর্থ প্রশ্ন');
  });

  test('returns whole text when no markers are found', () {
    final questions = extractQuestions('Unstructured recognized text');

    expect(questions, hasLength(1));
    expect(questions.single.text, 'Unstructured recognized text');
  });
}
