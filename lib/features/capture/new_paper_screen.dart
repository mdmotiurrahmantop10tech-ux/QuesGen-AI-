import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/paper.dart';
import '../editor/question_editor_screen.dart';
import '../ocr/ai_provider.dart';
import '../ocr/fallback_ocr_service.dart';
import '../ocr/ocr_service.dart';
import '../ocr/question_extractor.dart';

const String _readFailureMessage =
    'লেখাটি পড়া যায়নি। দয়া করে পরিষ্কার ছবি তুলুন অথবা ম্যানুয়ালি লিখুন।';
const String _documentFailureMessage =
    'দয়া করে একটি পরিষ্কার বই বা প্রশ্নপত্রের ছবি তুলুন।';

class NewPaperScreen extends StatefulWidget {
  const NewPaperScreen({super.key});

  @override
  State<NewPaperScreen> createState() => _NewPaperScreenState();
}

class _NewPaperScreenState extends State<NewPaperScreen> {
  bool _isScanning = false;
  final ImagePicker _imagePicker = ImagePicker();
  final OcrService _ocrService = FallbackOcrService();

  bool _looksLikeScreenshot(XFile image) {
    final name = image.name.toLowerCase();
    return name.contains('screenshot') ||
        name.contains('screen shot') ||
        name.contains('scrot');
  }

  void _showReadFailure() {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text(_readFailureMessage)));
  }

  void _showDocumentDialog() {
    if (!mounted) {
      return;
    }
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: const Text(_documentFailureMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _scanImage(ImageSource source) async {
    if (_isScanning) {
      return;
    }

    setState(() {
      _isScanning = true;
    });

    try {
      final image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 4096,
        maxHeight: 4096,
        imageQuality: 100,
      );
      if (image == null) {
        return;
      }
      if (source == ImageSource.gallery && _looksLikeScreenshot(image)) {
        _showDocumentDialog();
        return;
      }

      final text = await _ocrService.extractText(image.path);
      if (isUnreadableOcrText(text)) {
        _showReadFailure();
        return;
      }
      final questions = extractQuestions(text);
      if (!mounted) {
        return;
      }

      if (questions.isEmpty) {
        _showReadFailure();
        return;
      }

      final now = DateTime.now();
      final paper = Paper(
        id: 'scan_${now.millisecondsSinceEpoch}',
        title: 'Scanned paper',
        createdAt: now,
        questions: questions,
      );

      await Navigator.of(context).push(
        MaterialPageRoute<Paper>(
          builder: (_) => QuestionEditorScreen(paper: paper),
        ),
      );
    } on NoDocumentTextException {
      _showDocumentDialog();
    } catch (_) {
      _showReadFailure();
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  Paper _createDraftPaper() {
    final now = DateTime.now();
    return Paper(
      id: 'draft_${now.millisecondsSinceEpoch}',
      title: 'Untitled paper',
      createdAt: now,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Paper')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Create a new question paper',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Scan existing pages or build questions manually.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 88,
                child: FilledButton.icon(
                  onPressed: _isScanning
                      ? null
                      : () => _scanImage(ImageSource.camera),
                  icon: Icon(
                    _isScanning
                        ? Icons.hourglass_top
                        : Icons.document_scanner_outlined,
                    size: 28,
                  ),
                  label: Text(_isScanning ? 'Scanning…' : 'Scan from Image'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 64,
                child: OutlinedButton.icon(
                  onPressed: _isScanning
                      ? null
                      : () => _scanImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined, size: 24),
                  label: const Text('Choose from Gallery'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 88,
                child: FilledButton.tonalIcon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<Paper>(
                        builder: (_) =>
                            QuestionEditorScreen(paper: _createDraftPaper()),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit_note, size: 28),
                  label: const Text('Create Manually'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
