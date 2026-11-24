import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart' show PdfPageFormat;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../models/paper.dart';
import '../../models/question.dart';

final RegExp _questionMarkerPattern = RegExp(
  r'^\s*(?:(?:\d{1,2}|[০-৯]{1,2}|[ক-হ])\s*[).:])\s*',
);

const List<String> _bengaliOptionLabels = [
  'ক',
  'খ',
  'গ',
  'ঘ',
  'ঙ',
  'চ',
  'ছ',
  'জ',
  'ঝ',
  'ট',
];

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
        footer: (context) => pw.Center(
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: pw.TextStyle(fontSize: 10),
          ),
        ),
        build: (context) => _buildQuestions(paper, boldFont),
      ),
    );

    return document.save();
  }

  pw.Widget _buildHeader(Paper paper, pw.Font boldFont) {
    final classSubject = [paper.className, paper.subject]
        .where((value) => value.isNotEmpty)
        .join(' • ');

    return pw.Center(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            paper.schoolName.isEmpty ? 'QuesGen' : paper.schoolName,
            style: pw.TextStyle(font: boldFont, fontSize: 18),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            paper.examName.isEmpty ? 'Question Paper' : paper.examName,
            style: pw.TextStyle(font: boldFont, fontSize: 14),
          ),
          if (classSubject.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Text(classSubject, style: pw.TextStyle(fontSize: 12)),
          ],
          pw.SizedBox(height: 4),
          pw.Text(
            'Total Marks: ${_toBengaliDigits(_formatMarks(paper.totalMarks))}',
            style: pw.TextStyle(font: boldFont, fontSize: 12),
          ),
          pw.SizedBox(height: 10),
          pw.Divider(),
        ],
      ),
    );
  }

  List<pw.Widget> _buildQuestions(Paper paper, pw.Font boldFont) {
    final questions = paper.questions
        .where((question) => question.text.trim().isNotEmpty)
        .toList();
    final widgets = <pw.Widget>[];

    for (var i = 0; i < questions.length; i++) {
      final question = questions[i];
      final questionText = _formatQuestionText(question, i);
      if (questionText.isEmpty) {
        continue;
      }

      widgets.add(
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Text(
                    questionText,
                    style: pw.TextStyle(fontSize: 12),
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Text(
                  '[${_toBengaliDigits(_formatMarks(question.marks))}]',
                  style: pw.TextStyle(font: boldFont, fontSize: 12),
                ),
              ],
            ),
            if (question.options.isNotEmpty) ...[
              pw.SizedBox(height: 4),
              for (var j = 0; j < question.options.length; j++)
                pw.Padding(
                  padding: pw.EdgeInsets.only(left: 24, top: 2),
                  child: pw.Text(
                    '${_bengaliOptionLabel(j)}) ${question.options[j].trim()}',
                    style: pw.TextStyle(fontSize: 11),
                  ),
                ),
            ],
            pw.SizedBox(height: 10),
          ],
        ),
      );
    }

    return widgets;
  }

  String _formatQuestionText(Question question, int index) {
    final stripped = question.text.replaceFirst(_questionMarkerPattern, '').trim();
    if (stripped.isEmpty) {
      return '';
    }
    return '${_toBengaliDigits('${index + 1}')} . $stripped';
  }

  String _bengaliOptionLabel(int index) {
    if (index >= 0 && index < _bengaliOptionLabels.length) {
      return _bengaliOptionLabels[index];
    }
    return _toBengaliDigits('${index + 1}');
  }

  String _toBengaliDigits(String value) {
    const bengaliDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    final buffer = StringBuffer();
    for (final char in value.split('')) {
      final code = char.codeUnitAt(0);
      buffer.write(
        code >= 48 && code <= 57 ? bengaliDigits[code - 48] : char,
      );
    }
    return buffer.toString();
  }

  String _formatMarks(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
  }
}
