import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart' show PdfPageFormat;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../models/paper.dart';
import '../../models/question.dart';

final RegExp _questionMarkerPattern = RegExp(
  r'^\s*(?:(?:\d{1,2}|[০-৯]{1,2})\s*[).:]|[ক-হ]\s*[.:])',
);

abstract class PdfExportService {
  Future<void> exportPaper(Paper paper);
}

class PdfExportServiceImpl implements PdfExportService {
  const PdfExportServiceImpl();

  @override
  Future<void> exportPaper(Paper paper) async {
    final bytes = await _buildPdf(paper);
    await Printing.layoutPdf(
      onLayout: (format) async => bytes,
      name: '${paper.title}.pdf',
    );
  }

  Future<Uint8List> _buildPdf(Paper paper) async {
    final regularFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSansBengali-Regular.ttf'),
    );
    final boldFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSansBengali-Bold.ttf'),
    );

    final document = pw.Document(
      theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
    );

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildHeader(paper, boldFont),
        build: (context) => _buildQuestions(paper),
      ),
    );

    return document.save();
  }

  pw.Widget _buildHeader(Paper paper, pw.Font boldFont) {
    final classSubject = [paper.className, paper.subject]
        .where((value) => value.isNotEmpty)
        .join(' • ');

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          paper.schoolName.isEmpty ? 'QuesGen' : paper.schoolName,
          style: pw.TextStyle(font: boldFont, fontSize: 20),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          paper.examName.isEmpty ? 'Question Paper' : paper.examName,
          style: pw.TextStyle(font: boldFont, fontSize: 16),
        ),
        if (classSubject.isNotEmpty) ...[
          pw.SizedBox(height: 4),
          pw.Text(classSubject, style: pw.TextStyle(fontSize: 12)),
        ],
        if (paper.totalMarks > 0) ...[
          pw.SizedBox(height: 4),
          pw.Text(
            'Total Marks: ${_formatMarks(paper.totalMarks)}',
            style: pw.TextStyle(fontSize: 12),
          ),
        ],
        pw.SizedBox(height: 8),
        pw.Divider(),
      ],
    );
  }

  List<pw.Widget> _buildQuestions(Paper paper) {
    final questions = paper.questions
        .where((question) => question.text.trim().isNotEmpty)
        .toList();

    return [
      for (var i = 0; i < questions.length; i++) ...[
        pw.Text(
          _formatQuestion(questions[i], i),
          style: pw.TextStyle(fontSize: 12),
        ),
        pw.SizedBox(height: 8),
      ],
    ];
  }

  String _formatQuestion(Question question, int index) {
    final text = question.text.trim();
    if (_questionMarkerPattern.hasMatch(text)) {
      return text;
    }
    return '${index + 1}. $text';
  }

  String _formatMarks(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
  }
}
