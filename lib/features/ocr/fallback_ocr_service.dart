import 'ai_provider.dart';
import 'gemini_ocr_provider.dart';
import 'ocr_service.dart';

class FallbackOcrService implements OcrService {
  FallbackOcrService({
    List<AiOcrProvider>? cloudProviders,
    OcrService? offlineService,
  }) : _cloudProviders = cloudProviders ?? [GeminiOcrProvider()],
       _offlineService = offlineService ?? const MlKitOcrService();

  final List<AiOcrProvider> _cloudProviders;
  final OcrService _offlineService;

  @override
  Future<String> extractText(String imagePath) async {
    for (final provider in _cloudProviders) {
      if (!provider.isConfigured) {
        continue;
      }
      try {
        final text = await provider.extractText(imagePath);
        if (!isUnreadableOcrText(text)) {
          return text;
        }
      } catch (_) {
        continue;
      }
    }

    final offlineText = await _offlineService.extractText(imagePath);
    if (isUnreadableOcrText(offlineText)) {
      throw const OcrUnavailableException();
    }
    return offlineText;
  }
}
