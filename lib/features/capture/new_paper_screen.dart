import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/paper.dart';
import '../editor/question_editor_screen.dart';
import '../ocr/fallback_ocr_service.dart';
import '../ocr/ocr_service.dart';
import '../ocr/question_extractor.dart';

const String _readFailureMessage =
    'লেখাটি পড়া যায়নি। দয়া করে পরিষ্কার ছবি তুলুন অথবা ম্যানুয়ালি লিখুন।';

class NewPaperScreen extends StatefulWidget {
  const NewPaperScreen({super.key});

  @override
  State<NewPaperScreen> createState() => _NewPaperScreenState();
}

class _NewPaperScreenState extends State<NewPaperScreen> {
  bool _isScanning = false;
  final ImagePicker _imagePicker = ImagePicker();
  final OcrService _ocrService = FallbackOcrService();

  Future<ImageSource?> _chooseImageSource() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Take Photo'),
                onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from Gallery'),
                onTap: () =>
                    Navigator.of(sheetContext).pop(ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showReadFailure() {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(_readFailureMessage)),
    );
  }

  Future<void> _scanFromImage() async {
    if (_isScanning) {
      return;
    }

    final source = await _chooseImageSource();
    if (source == null || !mounted) {
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
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
                onPressed: _isScanning ? null : _scanFromImage,
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
              height: 88,
              child: FilledButton.tonalIcon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<Paper>(
                      builder: (_) => QuestionEditorScreen(
                        paper: _createDraftPaper(),
                      ),
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
    );
  }
}
