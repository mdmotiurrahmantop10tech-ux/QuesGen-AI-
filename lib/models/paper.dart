import 'question.dart';

class Paper {
  const Paper({
    required this.id,
    required this.title,
    required this.createdAt,
    this.schoolName = '',
    this.examName = '',
    this.className = '',
    this.subject = '',
    this.totalMarks = 0,
    this.questions = const <Question>[],
  });

  final String id;
  final String title;
  final DateTime createdAt;
  final String schoolName;
  final String examName;
  final String className;
  final String subject;
  final double totalMarks;
  final List<Question> questions;

  Paper copyWith({
    String? id,
    String? title,
    String? schoolName,
    String? examName,
    String? className,
    String? subject,
    double? totalMarks,
    List<Question>? questions,
  }) {
    return Paper(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt,
      schoolName: schoolName ?? this.schoolName,
      examName: examName ?? this.examName,
      className: className ?? this.className,
      subject: subject ?? this.subject,
      totalMarks: totalMarks ?? this.totalMarks,
      questions: questions ?? this.questions,
    );
  }
}
