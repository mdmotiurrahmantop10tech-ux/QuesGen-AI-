import 'package:material_ui/material_ui.dart';

import '../../models/paper.dart';
import '../../models/question.dart';
import '../pdf_export/paper_details_screen.dart';
import '../pdf_export/pdf_export_service.dart';

class QuestionEditorScreen extends StatefulWidget {
  const QuestionEditorScreen({super.key, required this.paper});

  final Paper paper;

  @override
  State<QuestionEditorScreen> createState() => _QuestionEditorScreenState();
}

class _QuestionEditorScreenState extends State<QuestionEditorScreen> {
  late Paper _paper;
  late final List<Question> _questions;
  late final List<TextEditingController> _controllers;
  late final List<TextEditingController> _markControllers;
  final PdfExportService _pdfExportService = const PdfExportServiceImpl();
  int _idCounter = 0;
  bool _isGeneratingPdf = false;

  @override
  void initState() {
    super.initState();
    _paper = widget.paper;
    _questions = List.of(widget.paper.questions);
    if (_questions.isEmpty) {
      _questions.add(_newQuestion(''));
    }
    _controllers = _questions
        .map((question) => TextEditingController(text: question.text))
        .toList();
    _markControllers = _questions
        .map((question) => TextEditingController(text: _formatMarks(question.marks)))
        .toList();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final controller in _markControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String _newId() {
    _idCounter += 1;
    return 'q_${widget.paper.id}_$_idCounter';
  }

  Question _newQuestion(String text) {
    return Question(id: _newId(), text: text);
  }

  String _formatMarks(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
  }

  double _parseMarks(int index) {
    final parsed = double.tryParse(_markControllers[index].text.trim());
    final value = parsed ?? _questions[index].marks;
    return value < 0 ? 0 : value;
  }

  void _addQuestion() {
    setState(() {
      _questions.add(_newQuestion(''));
      _controllers.add(TextEditingController());
      _markControllers.add(TextEditingController(text: '1'));
    });
  }

  void _removeQuestion(int index) {
    if (_questions.length == 1) {
      setState(() {
        _controllers[0].clear();
        _markControllers[0].text = '1';
      });
      return;
    }

    setState(() {
      _controllers.removeAt(index).dispose();
      _markControllers.removeAt(index).dispose();
      _questions.removeAt(index);
    });
  }

  void _moveQuestion(int index, int direction) {
    final newIndex = index + direction;
    if (newIndex < 0 || newIndex >= _questions.length) {
      return;
    }

    setState(() {
      final question = _questions.removeAt(index);
      _questions.insert(newIndex, question);

      final controller = _controllers.removeAt(index);
      _controllers.insert(newIndex, controller);

      final markController = _markControllers.removeAt(index);
      _markControllers.insert(newIndex, markController);
    });
  }

  Paper _buildPaper() {
    final questions = <Question>[
      for (var i = 0; i < _questions.length; i++)
        Question(
          id: _questions[i].id,
          text: _controllers[i].text,
          options: _questions[i].options,
          correctOptionIndex: _questions[i].correctOptionIndex,
          marks: _parseMarks(i),
        ),
    ];

    return _paper.copyWith(questions: questions);
  }

  Future<void> _openPaperDetails() async {
    final updatedPaper = await Navigator.of(context).push<Paper>(
      MaterialPageRoute<Paper>(
        builder: (_) => PaperDetailsScreen(paper: _paper),
      ),
    );

    if (updatedPaper != null && mounted) {
      setState(() {
        _paper = updatedPaper;
      });
    }
  }

  Future<void> _generatePdf() async {
    if (_isGeneratingPdf) {
      return;
    }

    setState(() {
      _isGeneratingPdf = true;
    });

    try {
      await _pdfExportService.exportPaper(_buildPaper());
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not generate PDF: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingPdf = false;
        });
      }
    }
  }

  String _paperDetailsSummary() {
    final parts = <String>[
      if (_paper.schoolName.isNotEmpty) _paper.schoolName,
      if (_paper.examName.isNotEmpty) _paper.examName,
      if (_paper.className.isNotEmpty || _paper.subject.isNotEmpty)
        [_paper.className, _paper.subject]
            .where((value) => value.isNotEmpty)
            .join(' • '),
      if (_paper.totalMarks > 0) 'Total Marks: ${_paper.totalMarks}',
    ];

    return parts.isEmpty ? 'Add school, exam, class, subject, and marks' : parts.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_paper.title),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(_buildPaper()),
            icon: const Icon(Icons.check),
            tooltip: 'Done',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              leading: const Icon(Icons.assignment_outlined),
              title: const Text('Paper details'),
              subtitle: Text(_paperDetailsSummary()),
              trailing: const Icon(Icons.edit_outlined),
              onTap: _openPaperDetails,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${_questions.length} question${_questions.length == 1 ? '' : 's'}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < _questions.length; i++) ...[
            _QuestionCard(
              index: i,
              controller: _controllers[i],
              markController: _markControllers[i],
              canMoveUp: i > 0,
              canMoveDown: i < _questions.length - 1,
              onMoveUp: () => _moveQuestion(i, -1),
              onMoveDown: () => _moveQuestion(i, 1),
              onDelete: () => _removeQuestion(i),
            ),
            const SizedBox(height: 12),
          ],
          FilledButton.tonalIcon(
            onPressed: _addQuestion,
            icon: const Icon(Icons.add),
            label: const Text('Add question'),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 56,
            child: FilledButton.icon(
              onPressed: _isGeneratingPdf ? null : _generatePdf,
              icon: Icon(
                _isGeneratingPdf
                    ? Icons.hourglass_top
                    : Icons.picture_as_pdf_outlined,
              ),
              label: Text(_isGeneratingPdf ? 'Generating…' : 'Generate PDF'),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.index,
    required this.controller,
    required this.markController,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onDelete,
  });

  final int index;
  final TextEditingController controller;
  final TextEditingController markController;
  final bool canMoveUp;
  final bool canMoveDown;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Question ${index + 1}',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                SizedBox(
                  width: 72,
                  child: TextField(
                    controller: markController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      hintText: 'Marks',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: canMoveUp ? onMoveUp : null,
                  icon: const Icon(Icons.arrow_upward),
                  tooltip: 'Move up',
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  onPressed: canMoveDown ? onMoveDown : null,
                  icon: const Icon(Icons.arrow_downward),
                  tooltip: 'Move down',
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete question',
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              minLines: 3,
              maxLines: null,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: 'Enter question text',
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
