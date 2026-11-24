import 'package:flutter_test/flutter_test.dart';
import 'package:quesgen/features/ocr/ai_provider.dart';
import 'package:quesgen/features/ocr/fallback_ocr_service.dart';
import 'package:quesgen/features/ocr/ocr_service.dart';

class _FakeProvider implements AiOcrProvider {
  _FakeProvider(this.providerName, {this.result, this.shouldThrow = false});

  final String providerName;
  final String? result;
  final bool shouldThrow;
  final List<String> calls = [];

  @override
  String get name => providerName;

  @override
  bool get isConfigured => true;

  @override
  Future<String> extractText(String imagePath) async {
    calls.add(providerName);
    if (shouldThrow) {
      throw AiProviderException(providerName, 'failed');
    }
    return result ?? '';
  }
}

class _FakeOfflineService implements OcrService {
  _FakeOfflineService(this.result);

  final String result;
  int calls = 0;

  @override
  Future<String> extractText(String imagePath) async {
    calls += 1;
    return result;
  }
}

void main() {
  test('falls back from failing provider to next provider', () async {
    final providerA = _FakeProvider('A', shouldThrow: true);
    final providerB = _FakeProvider('B', result: 'from B');
    final offline = _FakeOfflineService('offline');

    final service = FallbackOcrService(
      cloudProviders: [providerA, providerB],
      offlineService: offline,
    );

    expect(await service.extractText('image.jpg'), 'from B');
    expect(providerA.calls, ['A']);
    expect(providerB.calls, ['B']);
    expect(offline.calls, 0);
  });

  test('falls back to offline ML Kit when cloud providers fail', () async {
    final providerA = _FakeProvider('A', shouldThrow: true);
    final providerB = _FakeProvider('B', shouldThrow: true);
    final offline = _FakeOfflineService('offline');

    final service = FallbackOcrService(
      cloudProviders: [providerA, providerB],
      offlineService: offline,
    );

    expect(await service.extractText('image.jpg'), 'offline');
    expect(offline.calls, 1);
  });

  test('skips garbage cloud text and keeps usable offline text', () async {
    final provider = _FakeProvider('A', result: 'anofaT');
    final offline = _FakeOfflineService('1. প্রথম প্রশ্ন');

    final service = FallbackOcrService(
      cloudProviders: [provider],
      offlineService: offline,
    );

    expect(await service.extractText('image.jpg'), '1. প্রথম প্রশ্ন');
  });

  test('throws when both cloud and offline text are garbage', () async {
    final provider = _FakeProvider('A', result: 'anofaT');
    final offline = _FakeOfflineService('UHGIRT');

    final service = FallbackOcrService(
      cloudProviders: [provider],
      offlineService: offline,
    );

    expect(
      service.extractText('image.jpg'),
      throwsA(isA<OcrUnavailableException>()),
    );
  });

  test('detects garbage and accepts real Bengali or English text', () {
    expect(isUnreadableOcrText('anofaT'), isTrue);
    expect(isUnreadableOcrText('UHGIRT'), isTrue);
    expect(isUnreadableOcrText('sdjkfhsdk'), isTrue);
    expect(isUnreadableOcrText('   '), isTrue);
    expect(isUnreadableOcrText('১. প্রথম প্রশ্ন'), isFalse);
    expect(isUnreadableOcrText('1. What is your name?'), isFalse);
  });
}
