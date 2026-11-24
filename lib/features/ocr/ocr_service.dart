import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

abstract class OcrService {
  Future<String> extractText(String imagePath);
}

class OcrUnavailableException implements Exception {
  const OcrUnavailableException();

  @override
  String toString() => 'OCR could not read the image';
}

final RegExp _bengaliRegExp = RegExp(r'[\u0980-\u09FF]');
final RegExp _asciiLetterRegExp = RegExp(r'[A-Za-z]');
final RegExp _vowelRegExp = RegExp(r'[aeiouAEIOU]');

bool isUnreadableOcrText(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) {
    return true;
  }
  if (_bengaliRegExp.allMatches(trimmed).length >= 4) {
    return false;
  }

  final tokens = trimmed
      .split(RegExp(r'\s+'))
      .where((token) => token.isNotEmpty)
      .toList();
  if (tokens.isEmpty) {
    return true;
  }

  for (final token in tokens) {
    if (_asciiLetterRegExp.allMatches(token).length < 4) {
      continue;
    }
    final vowelCount = _vowelRegExp.allMatches(token).length;
    if (vowelCount == 0) {
      return true;
    }
    final hasLowercase = token.contains(RegExp(r'[a-z]'));
    final hasUpperCaseAfterFirst =
        token.length > 1 && token.substring(1).contains(RegExp(r'[A-Z]'));
    if (hasLowercase && hasUpperCaseAfterFirst) {
      return true;
    }
    if (!hasLowercase && token.length >= 5 && vowelCount <= 2) {
      return true;
    }
  }

  return false;
}

class MlKitOcrService implements OcrService {
  const MlKitOcrService();

  @override
  Future<String> extractText(String imagePath) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await recognizer.processImage(inputImage);
      return recognizedText.text;
    } finally {
      await recognizer.close();
    }
  }
}
