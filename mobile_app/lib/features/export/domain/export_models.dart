enum ExportFormat { pdf, docx, xlsx, txt }

/// Positional OCR word/element with bounding box coordinates.
///
/// Coordinates are in the **original image pixel space** (not normalised).
class ExportOcrBlock {
  const ExportOcrBlock({
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

/// Detected table extracted from OCR blocks.
class TableData {
  const TableData({required this.rows});

  /// Each row is a list of cell strings (left-to-right).
  final List<List<String>> rows;

  bool get isEmpty => rows.isEmpty;
  int get columnCount => rows.isEmpty ? 0 : rows.map((r) => r.length).reduce((a, b) => a > b ? a : b);
}

/// Signature placement for a specific page.
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

/// All data needed to export a single page.
class PageExportData {
  const PageExportData({
    required this.imagePath,
    required this.imageWidth,
    required this.imageHeight,
    required this.ocrBlocks,
    required this.ocrText,
    this.signature,
  });

  final String imagePath;

  /// Original image dimensions in pixels (used to map OCR bounding-box
  /// coordinates onto the PDF page).
  final int imageWidth;
  final int imageHeight;

  /// Word-level bounding boxes from OCR.
  final List<ExportOcrBlock> ocrBlocks;

  /// Full concatenated OCR text (used by DOCX export).
  final String ocrText;

  final PageSignature? signature;
}

class ExportRequest {
  const ExportRequest({
    required this.documentId,
    required this.title,
    required this.pages,
    this.outputPath,
  });

  final String documentId;
  final String title;
  final List<PageExportData> pages;
  final String? outputPath;
}
