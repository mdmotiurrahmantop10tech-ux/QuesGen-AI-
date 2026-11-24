import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

abstract class OcrService {
  Future<String> extractText(String imagePath);
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
