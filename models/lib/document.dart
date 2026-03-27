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

/// Bounding-box data for a single OCR word/element.
class OcrBlock {
  const OcrBlock({
    required this.text,
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  final String text;
  final double left;
  final double top;
  final double right;
  final double bottom;
}

class DocumentPage {
  const DocumentPage({
    required this.pageId,
    required this.order,
    required this.processedImagePath,
    required this.imageWidth,
    required this.imageHeight,
    this.ocrText,
    this.ocrBlocks = const [],
    this.hasSignature = false,
    this.signatureX,
    this.signatureY,
    this.signatureScale,
  });

  final String pageId;
  final int order;
  final String processedImagePath;
  final int imageWidth;
  final int imageHeight;
  final String? ocrText;
  final List<OcrBlock> ocrBlocks;
  final bool hasSignature;
  final double? signatureX;
  final double? signatureY;
  final double? signatureScale;
}
