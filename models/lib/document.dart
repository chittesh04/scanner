class Document {
  const Document({
    required this.documentId,
    required this.title,
    required this.pages,
    required this.tags,
    required this.isStarred,
    required this.collectionId,
    required this.updatedAt,
  });

  final String documentId;
  final String title;
  final List<DocumentPage> pages;
  final List<String> tags;
  final bool isStarred;
  final String? collectionId;
  final DateTime updatedAt;
}

class DocumentPage {
  const DocumentPage({
    required this.pageId,
    required this.order,
    required this.processedImagePath,
    this.ocrText,
    this.hasSignature = false,
    this.signatureX,
    this.signatureY,
    this.signatureScale,
  });

  final String pageId;
  final int order;
  final String processedImagePath;
  final String? ocrText;
  final bool hasSignature;
  final double? signatureX;
  final double? signatureY;
  final double? signatureScale;
}
