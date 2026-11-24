import '../../models/paper.dart';

abstract class PdfExportService {
  Future<String> exportPaper(Paper paper, {required String outputPath});
}

class PlaceholderPdfExportService implements PdfExportService {
  const PlaceholderPdfExportService();

  @override
  Future<String> exportPaper(Paper paper, {required String outputPath}) {
    return Future<String>.error(
      UnimplementedError('PDF export is not configured yet.'),
    );
  }
}
