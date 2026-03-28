class DocumentSummary {
  const DocumentSummary({
    required this.documentId,
    required this.title,
    required this.pageCount,
    required this.updatedAt,
    required this.isStarred,
    this.collectionId,
    this.thumbnailImagePath,
  });

  final String documentId;
  final String title;
  final int pageCount;
  final DateTime updatedAt;
  final bool isStarred;
  final String? collectionId;
  final String? thumbnailImagePath;
}
