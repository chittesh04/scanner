import 'package:isar/isar.dart';
import 'package:smartscan_database/isar_schema.dart';

/// Persistent full-text search index backed by Isar.
///
/// Instead of maintaining an in-memory token map, queries run directly
/// against [PageEntity.fullText] via Isar string filters. The background
/// OCR job populates `fullText` when it completes, so no explicit
/// `indexDocument()` step is needed in the foreground.
class SearchIndexService {
  SearchIndexService(this._isar);

  final Isar _isar;

  /// Indexes are now written by the background OCR job.
  /// This method is retained for API compatibility but is a no-op.
  void indexDocument(String documentId, String text) {
    // No-op — the background WorkManager callback writes
    // PageEntity.fullText directly into Isar.
  }

  /// Returns documentIds whose pages contain **all** query tokens
  /// (case-insensitive substring match on [PageEntity.fullText]).
  Future<Set<String>> search(String query) async {
    final tokens = query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();

    if (tokens.isEmpty) return <String>{};

    // Start with pages matching the first token.
    var pages = await _isar.pageEntitys
        .filter()
        .fullTextContains(tokens.first, caseSensitive: false)
        .findAll();

    var documentIds = pages.map((p) => p.documentId).toSet();

    // Intersect with subsequent tokens.
    for (var i = 1; i < tokens.length && documentIds.isNotEmpty; i++) {
      final matching = await _isar.pageEntitys
          .filter()
          .fullTextContains(tokens[i], caseSensitive: false)
          .findAll();

      final matchingDocIds = matching.map((p) => p.documentId).toSet();
      documentIds = documentIds.intersection(matchingDocIds);
    }

    return documentIds;
  }
}
