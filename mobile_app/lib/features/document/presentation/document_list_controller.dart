import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartscan/core/di/service_locator.dart';
import 'package:smartscan_models/document_collection.dart';
import 'package:smartscan_models/document_summary.dart';

final documentListProvider = StreamProvider<List<DocumentSummary>>((ref) {
  final repo = ref.watch(documentRepositoryProvider);
  return repo.watchDocuments();
});

final documentCollectionsProvider =
    StreamProvider<List<DocumentCollection>>((ref) {
  final repo = ref.watch(documentRepositoryProvider);
  return repo.watchCollections();
});

final createCollectionProvider =
    Provider<Future<String> Function(String)>((ref) {
  final repo = ref.watch(documentRepositoryProvider);
  return repo.createCollection;
});

final assignDocumentCollectionProvider =
    Provider<Future<void> Function(String, String?)>((ref) {
  final repo = ref.watch(documentRepositoryProvider);
  return repo.assignDocumentToCollection;
});

final documentsByCollectionProvider =
    StreamProvider.family<List<DocumentSummary>, String>((ref, collectionId) {
  final repo = ref.watch(documentRepositoryProvider);
  return repo.watchDocumentsByCollection(collectionId);
});

final inboxDocumentsProvider = StreamProvider<List<DocumentSummary>>((ref) {
  final repo = ref.watch(documentRepositoryProvider);
  return repo.watchInboxDocuments();
});

class SearchMatchModel {
  const SearchMatchModel({required this.document, this.preview});

  final DocumentSummary document;
  final String? preview;
}

final createDocumentProvider = Provider<Future<String> Function(String)>((ref) {
  final repo = ref.watch(documentRepositoryProvider);
  return repo.createDocument;
});

final documentSearchQueryProvider = StateProvider<String>((_) => '');

final recentDocumentsProvider = Provider<AsyncValue<List<DocumentSummary>>>((ref) {
  final docsAsync = ref.watch(documentListProvider);
  return docsAsync.whenData((docs) {
    final sorted = [...docs]
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sorted.take(8).toList(growable: false);
  });
});

final filteredDocumentsProvider =
    Provider<AsyncValue<List<SearchMatchModel>>>((ref) {
  final docsAsync = ref.watch(documentListProvider);
  final query = ref.watch(documentSearchQueryProvider).trim().toLowerCase();

  return docsAsync.whenData((docs) {
    final items = [...docs]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    if (query.isEmpty) {
      return items
          .map((document) => SearchMatchModel(document: document))
          .toList(growable: false);
    }

    // Use SearchIndexService for deep full-text OCR search.
    // Since search() is async but Riverpod's whenData is sync,
    // we do a hybrid: filter by title immediately, and use the
    // ocrSnippet for OCR matches (the snippet is populated from
    // PageEntity.fullText which is indexed by Isar).
    final results = <SearchMatchModel>[];
    for (final document in items) {
      final titleMatch = document.title.toLowerCase().contains(query);
      final ocrSnippet = document.ocrSnippet?.toLowerCase() ?? '';
      final ocrMatch = ocrSnippet.contains(query);

      if (titleMatch || ocrMatch) {
        String? preview;
        if (ocrMatch && document.ocrSnippet != null) {
          // Show context around the match in the OCR text.
          final idx = ocrSnippet.indexOf(query);
          final start = (idx - 20).clamp(0, ocrSnippet.length);
          final end = (idx + query.length + 40).clamp(0, document.ocrSnippet!.length);
          preview = '${start > 0 ? '...' : ''}${document.ocrSnippet!.substring(start, end)}${end < document.ocrSnippet!.length ? '...' : ''}';
        }
        results.add(SearchMatchModel(document: document, preview: preview));
      }
    }
    return results;
  });
});

/// Async deep search provider — queries Isar's fullText index via
/// SearchIndexService for results that the in-memory ocrSnippet filter
/// would miss (e.g. text beyond the 200-char snippet).
final deepSearchProvider =
    FutureProvider.family<Set<String>, String>((ref, query) async {
  if (query.trim().isEmpty) return <String>{};
  final searchIndex = ref.watch(searchIndexServiceProvider);
  return searchIndex.search(query);
});

final toggleStarredProvider =
    Provider<Future<void> Function(String, bool)>((ref) {
  final repo = ref.watch(documentRepositoryProvider);
  return repo.setStarred;
});

final deleteDocumentsProvider =
    Provider<Future<void> Function(List<String>)>((ref) {
  final repo = ref.watch(documentRepositoryProvider);
  return repo.deleteDocuments;
});
