import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const String _modelName = 'gemini-3.8-flash';
  static const String _prompt =
      'এই ছবিটা একটা বাংলা প্রশ্নপত্র। সব প্রশ্ন পড়ে শুধু প্রশ্নগুলো বাংলায় তালিকা আকারে দাও। কোনো অতিরিক্ত ব্যাখ্যা নয়। '
      'বহুনির্বাচনী প্রশ্ন হলে প্রশ্নসহ ক/খ/গ/ঘ অপশনগুলো একই লাইনে দাও। সংক্ষিপ্ত উত্তরের প্রশ্ন হলে শুধু প্রশ্ন দাও।';

  Future<List<String>> generateQuestionsFromImage({
    required File image,
    String? extraPrompt,
  }) async {
    try {
      final bytes = await image.readAsBytes();
      return await generateQuestionsFromBytes(
        bytes: bytes,
        extraPrompt: extraPrompt,
      );
    } on GeminiServiceException {
      rethrow;
    } catch (_) {
      throw const GeminiServiceException(
        'ছবিটি পড়া যায়নি। পরে আবার চেষ্টা করুন।',
      );
    }
  }

  Future<List<String>> generateQuestionsFromBytes({
    required Uint8List bytes,
    String? extraPrompt,
  }) {
    return _generateQuestions(bytes, _buildPrompt(extraPrompt));
  }

  Future<List<String>> generateQuestionsFromBase64({
    required String base64Image,
    String? extraPrompt,
  }) async {
    try {
      final bytes = base64Decode(base64Image);
      return await generateQuestionsFromBytes(
        bytes: bytes,
        extraPrompt: extraPrompt,
      );
    } on FormatException {
      throw const GeminiServiceException('ছবির base64 ডাটা সঠিক নয়।');
    }
  }

  Future<List<String>> extractQuestionsFromImage(String imagePath) {
    return generateQuestionsFromImage(image: File(imagePath));
  }

  String _buildPrompt(String? extraPrompt) {
    final extra = extraPrompt?.trim();
    if (extra == null || extra.isEmpty) {
      return _prompt;
    }
    return '$_prompt\n\n$extra';
  }

  Future<List<String>> _generateQuestions(
    Uint8List bytes,
    String prompt,
  ) async {
    if (_apiKey.isEmpty) {
      throw const GeminiServiceException(
        'GEMINI_API_KEY সেট করা নেই। --dart-define=GEMINI_API_KEY=আপনার_কী দিয়ে অ্যাপ চালান।',
      );
    }

    try {
      final model = GenerativeModel(model: _modelName, apiKey: _apiKey);
      final response = await model.generateContent([
        Content.multi([TextPart(prompt), DataPart('image/jpeg', bytes)]),
      ]);

      final questions = (response.text?.trim() ?? '')
          .split(RegExp(r'\r?\n'))
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList(growable: false);

      if (questions.isEmpty) {
        throw const GeminiServiceException(
          'ছবি থেকে কোনো প্রশ্ন পড়া যায়নি। পরিষ্কার ছবি দিয়ে আবার চেষ্টা করুন।',
        );
      }
      return questions;
    } on GeminiServiceException {
      rethrow;
    } catch (_) {
      throw const GeminiServiceException(
        'ইন্টারনেট বা Gemini API এরর হয়েছে। পরে আবার চেষ্টা করুন।',
      );
    }
  }
}

class GeminiServiceException implements Exception {
  const GeminiServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
