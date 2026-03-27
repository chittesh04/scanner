enum ExportFormat { pdf, docx, xlsx }

class ExportRequest {
  const ExportRequest({
    required this.documentId,
    required this.title,
    required this.pageImagePaths,
    required this.ocrTexts,
    required this.signatures,
    this.outputPath,
  });

  final String documentId;
  final String title;
  final List<String> pageImagePaths;
  final List<String> ocrTexts;
  final List<PageSignature?> signatures;
  final String? outputPath;
}

class PageSignature {
  const PageSignature({
    required this.x,
    required this.y,
    required this.scale,
  });
  final double x;
  final double y;
  final double scale;
}
