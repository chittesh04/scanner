import 'package:smartscan_models/document_summary.dart';

/// Cursor-like page result for large local datasets.
///
/// The cursor is based on [DocumentSummary.updatedAt] and is intentionally
/// simple for offline-first pagination.
class DocumentSummaryPage {
  const DocumentSummaryPage({
    required this.items,
    required this.hasMore,
    required this.nextCursor,
  });

  final List<DocumentSummary> items;
  final bool hasMore;
  final DateTime? nextCursor;
}
