import 'ai_provider.dart';
import 'gemini_ocr_provider.dart';
import 'ocr_service.dart';
import 'openai_ocr_provider.dart';

class FallbackOcrService implements OcrService {
  FallbackOcrService({
    List<AiOcrProvider>? cloudProviders,
    OcrService? offlineService,
  }) : _cloudProviders =
           cloudProviders ?? [GeminiOcrProvider(), OpenAiOcrProvider()],
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
        return await provider.extractText(imagePath);
      } catch (_) {
        continue;
      }
    }

    return _offlineService.extractText(imagePath);
  }
}
