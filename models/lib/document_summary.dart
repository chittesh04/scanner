class DocumentSummary {
  const DocumentSummary({
    required this.documentId,
    required this.title,
    required this.pageCount,
    required this.updatedAt,
    required this.isStarred,
    this.collectionId,
    this.thumbnailImagePath,
    this.ocrSnippet,
  });

  final String documentId;
  final String title;
  final int pageCount;
  final DateTime updatedAt;
  final bool isStarred;
  final String? collectionId;
  final String? thumbnailImagePath;

  /// First ~200 characters of concatenated OCR text across all pages.
  /// Used for full-text search from the document list.
  final String? ocrSnippet;
}
