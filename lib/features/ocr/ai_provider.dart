abstract class AiOcrProvider {
  String get name;
  bool get isConfigured;
  Future<String> extractText(String imagePath);
}

class AiProviderException implements Exception {
  const AiProviderException(
    this.provider,
    this.message, {
    this.quotaExceeded = false,
  });

  final String provider;
  final String message;
  final bool quotaExceeded;

  @override
  String toString() => '$provider: $message';
}

class NoDocumentTextException implements Exception {
  const NoDocumentTextException();

  @override
  String toString() => 'No document text found in image';
}
