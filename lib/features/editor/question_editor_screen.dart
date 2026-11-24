import 'package:material_ui/material_ui.dart';

import '../../models/paper.dart';
import '../../models/question.dart';

class QuestionEditorScreen extends StatefulWidget {
  const QuestionEditorScreen({super.key, required this.paper});

  final Paper paper;

  @override
  State<QuestionEditorScreen> createState() => _QuestionEditorScreenState();
}

class _QuestionEditorScreenState extends State<QuestionEditorScreen> {
  late final List<Question> _questions;
  late final List<TextEditingController> _controllers;
  int _idCounter = 0;

  @override
  void initState() {
    super.initState();
    _questions = List.of(widget.paper.questions);
    if (_questions.isEmpty) {
      _questions.add(_newQuestion(''));
    }
    _controllers = _questions
        .map((question) => TextEditingController(text: question.text))
        .toList();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
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

  void _addQuestion() {
    setState(() {
      _questions.add(_newQuestion(''));
      _controllers.add(TextEditingController());
    });
  }

  void _removeQuestion(int index) {
    if (_questions.length == 1) {
      setState(() {
        _controllers[0].clear();
      });
      return;
    }

    setState(() {
      _controllers.removeAt(index).dispose();
      _questions.removeAt(index);
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
        ),
    ];

    return Paper(
      id: widget.paper.id,
      title: widget.paper.title,
      createdAt: widget.paper.createdAt,
      questions: questions,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.paper.title),
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
          Text(
            '${_questions.length} question${_questions.length == 1 ? '' : 's'}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < _questions.length; i++) ...[
            _QuestionCard(
              index: i,
              controller: _controllers[i],
              onDelete: () => _removeQuestion(i),
            ),
            const SizedBox(height: 12),
          ],
          FilledButton.tonalIcon(
            onPressed: _addQuestion,
            icon: const Icon(Icons.add),
            label: const Text('Add question'),
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
    required this.onDelete,
  });

  final int index;
  final TextEditingController controller;
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
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete question',
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
