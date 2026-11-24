import 'dart:io';

import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../models/paper.dart';
import '../../models/question.dart';
import '../../services/gemini_service.dart';
import '../editor/question_editor_screen.dart';

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
  final GeminiService _geminiService = GeminiService();

  bool _looksLikeScreenshot(XFile image) {
    final name = image.name.toLowerCase();
    return name.contains('screenshot') ||
        name.contains('screen shot') ||
        name.contains('scrot');
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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

    final colorScheme = Theme.of(context).colorScheme;
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

      final cropped = await ImageCropper().cropImage(
        sourcePath: image.path,
        maxWidth: 4096,
        maxHeight: 4096,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop document',
            toolbarColor: colorScheme.primary,
            toolbarWidgetColor: colorScheme.onPrimary,
            activeControlsWidgetColor: colorScheme.primary,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            hideBottomControls: true,
          ),
          IOSUiSettings(
            title: 'Crop document',
            aspectRatioPickerButtonHidden: true,
            aspectRatioLockEnabled: false,
          ),
        ],
      );
      if (cropped == null) {
        return;
      }

      final questions = await _geminiService.generateQuestionsFromImage(
        image: File(cropped.path),
      );
      if (!mounted) {
        return;
      }

      final now = DateTime.now();
      final paper = Paper(
        id: 'scan_${now.millisecondsSinceEpoch}',
        title: 'Scanned paper',
        createdAt: now,
        questions: [
          for (var index = 0; index < questions.length; index++)
            Question(
              id: 'q_${now.millisecondsSinceEpoch}_$index',
              text: questions[index],
            ),
        ],
      );

      await Navigator.of(context).push(
        MaterialPageRoute<Paper>(
          builder: (_) => QuestionEditorScreen(paper: paper),
        ),
      );
    } on GeminiServiceException catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage('অজানা এরর হয়েছে। পরে আবার চেষ্টা করুন।');
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
