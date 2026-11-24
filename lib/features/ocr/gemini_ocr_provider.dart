import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'ai_provider.dart';

class GeminiOcrProvider implements AiOcrProvider {
  GeminiOcrProvider({String? apiKey, String? model, http.Client? client})
    : apiKey = apiKey ?? const String.fromEnvironment('GEMINI_API_KEY'),
      model = model ??
          const String.fromEnvironment(
            'GEMINI_MODEL',
            defaultValue: 'gemini-3.8-flash',
          ),
      _client = client ?? http.Client();

  final String apiKey;
  final String model;
  final http.Client _client;

  @override
  String get name => 'Gemini';

  @override
  bool get isConfigured => apiKey.isNotEmpty;

  @override
  Future<String> extractText(String imagePath) async {
    if (!isConfigured) {
      throw AiProviderException(name, 'GEMINI_API_KEY is not configured');
    }

    final bytes = await File(imagePath).readAsBytes();
    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {
              'text':
                  'Extract all text from this image exactly. Preserve line breaks, numbering, and punctuation.',
            },
            {
              'inline_data': {
                'mime_type': _mimeTypeFor(imagePath),
                'data': base64Encode(bytes),
              },
            },
          ],
        },
      ],
    });

    final uri = Uri.https(
      'generativelanguage.googleapis.com',
      '/v1beta/models/$model:generateContent',
      {'key': apiKey},
    );

    final response = await _client.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
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
    final candidates = json['candidates'] as List<dynamic>?;
    final parts =
        (candidates?.isNotEmpty ?? false)
            ? (candidates!.first['content']['parts'] as List<dynamic>?)
            : null;
    final text = parts
        ?.whereType<Map<String, dynamic>>()
        .map((part) => part['text']?.toString() ?? '')
        .join();

    if (text == null || text.trim().isEmpty) {
      throw AiProviderException(name, 'No text returned');
    }
    return text;
  }

  bool _isQuotaError(int statusCode, String body) {
    return statusCode == 429 ||
        body.contains('RESOURCE_EXHAUSTED') ||
        body.contains('quota');
  }

  String _mimeTypeFor(String path) {
    return path.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg';
  }
}
