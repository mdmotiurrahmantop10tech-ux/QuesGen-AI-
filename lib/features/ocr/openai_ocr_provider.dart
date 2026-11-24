import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'ai_provider.dart';

class OpenAiOcrProvider implements AiOcrProvider {
  OpenAiOcrProvider({String? apiKey, String? model, http.Client? client})
    : apiKey = apiKey ?? const String.fromEnvironment('OPENAI_API_KEY'),
      model = model ??
          const String.fromEnvironment('OPENAI_MODEL', defaultValue: 'gpt-4o-mini'),
      _client = client ?? http.Client();

  final String apiKey;
  final String model;
  final http.Client _client;

  @override
  String get name => 'OpenAI';

  @override
  bool get isConfigured => apiKey.isNotEmpty;

  @override
  Future<String> extractText(String imagePath) async {
    if (!isConfigured) {
      throw AiProviderException(name, 'OPENAI_API_KEY is not configured');
    }

    final bytes = await File(imagePath).readAsBytes();
    final body = jsonEncode({
      'model': model,
      'temperature': 0,
      'max_tokens': 2000,
      'messages': [
        {
          'role': 'system',
          'content':
              'You are an OCR engine. Extract all text from images exactly, preserving line breaks and numbering.',
        },
        {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': 'Extract the text from this image.'},
            {
              'type': 'image_url',
              'image_url': {
                'url': 'data:${_mimeTypeFor(imagePath)};base64,${base64Encode(bytes)}',
                'detail': 'high',
              },
            },
          ],
        },
      ],
    });

    final response = await _client.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: body,
    );

    if (response.statusCode != 200) {
      throw AiProviderException(
        name,
        'HTTP ${response.statusCode}: ${response.body}',
        quotaExceeded: _isQuotaError(response.statusCode, response.body),
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = json['choices'] as List<dynamic>?;
    String? content;
    if (choices != null && choices.isNotEmpty) {
      final message = choices.first['message'];
      if (message is Map) {
        content = message['content']?.toString();
      }
    }

    if (content == null || content.trim().isEmpty) {
      throw AiProviderException(name, 'No text returned');
    }
    return content;
  }

  bool _isQuotaError(int statusCode, String body) {
    return statusCode == 429 ||
        body.contains('insufficient_quota') ||
        body.contains('quota');
  }

  String _mimeTypeFor(String path) {
    return path.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg';
  }
}
