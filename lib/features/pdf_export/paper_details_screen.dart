import 'package:material_ui/material_ui.dart';

import '../../models/paper.dart';

class PaperDetailsScreen extends StatefulWidget {
  const PaperDetailsScreen({super.key, required this.paper});

  final Paper paper;

  @override
  State<PaperDetailsScreen> createState() => _PaperDetailsScreenState();
}

class _PaperDetailsScreenState extends State<PaperDetailsScreen> {
  late final TextEditingController _schoolNameController;
  late final TextEditingController _examNameController;
  late final TextEditingController _classNameController;
  late final TextEditingController _subjectController;
  late final TextEditingController _totalMarksController;

  @override
  void initState() {
    super.initState();
    _schoolNameController = TextEditingController(
      text: widget.paper.schoolName,
    );
    _examNameController = TextEditingController(text: widget.paper.examName);
    _classNameController = TextEditingController(
      text: widget.paper.className,
    );
    _subjectController = TextEditingController(text: widget.paper.subject);
    _totalMarksController = TextEditingController(
      text: widget.paper.totalMarks == 0
          ? ''
          : _formatMarks(widget.paper.totalMarks),
    );
  }

  @override
  void dispose() {
    _schoolNameController.dispose();
    _examNameController.dispose();
    _classNameController.dispose();
    _subjectController.dispose();
    _totalMarksController.dispose();
    super.dispose();
  }

  String _formatMarks(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
  }

  Paper _buildPaper() {
    return widget.paper.copyWith(
      schoolName: _schoolNameController.text.trim(),
      examName: _examNameController.text.trim(),
      className: _classNameController.text.trim(),
      subject: _subjectController.text.trim(),
      totalMarks:
          double.tryParse(_totalMarksController.text.trim()) ??
          widget.paper.totalMarks,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paper Details'),
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
          TextField(
            controller: _schoolNameController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'School Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _examNameController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Exam Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _classNameController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Class',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _subjectController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Subject',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _totalMarksController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: const InputDecoration(
              labelText: 'Total Marks',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
