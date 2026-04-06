import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartscan/core/di/service_locator.dart';
import 'package:smartscan_models/document.dart';
import 'package:smartscan_models/document_collection.dart';
import 'package:smartscan_models/document_summary.dart';

final documentListProvider = StreamProvider<List<DocumentSummary>>((ref) {
  return ref.watch(watchDocumentsUseCaseProvider).call();
});

final documentCollectionsProvider =
    StreamProvider<List<DocumentCollection>>((ref) {
  return ref.watch(watchCollectionsUseCaseProvider).call();
});

final createCollectionProvider =
    Provider<Future<String> Function(String)>((ref) {
  final useCase = ref.watch(createCollectionUseCaseProvider);
  return useCase.call;
});

final renameCollectionProvider =
    Provider<Future<void> Function(String, String)>((ref) {
  final useCase = ref.watch(renameCollectionUseCaseProvider);
  return useCase.call;
});

final deleteCollectionProvider = Provider<Future<void> Function(String)>((ref) {
  final useCase = ref.watch(deleteCollectionUseCaseProvider);
  return useCase.call;
});

final assignDocumentCollectionProvider =
    Provider<Future<void> Function(String, String?)>((ref) {
  final useCase = ref.watch(assignDocumentCollectionUseCaseProvider);
  return useCase.call;
});

final documentsByCollectionProvider =
    StreamProvider.family<List<DocumentSummary>, String>((ref, collectionId) {
  return ref
      .watch(watchDocumentsByCollectionUseCaseProvider)
      .call(collectionId);
});

final documentProvider =
    StreamProvider.family<Document?, String>((ref, documentId) {
  return ref.watch(watchDocumentUseCaseProvider).call(documentId);
});

final inboxDocumentsProvider = StreamProvider<List<DocumentSummary>>((ref) {
  return ref.watch(watchInboxDocumentsUseCaseProvider).call();
});

class DocumentSearchHit {
  const DocumentSearchHit({required this.document, this.preview});

  final DocumentSummary document;
  final String? preview;
}

final createDocumentProvider = Provider<Future<String> Function(String)>((ref) {
  final useCase = ref.watch(createDocumentUseCaseProvider);
  return useCase.call;
});

final documentSearchQueryProvider = StateProvider<String>((_) => '');

final recentDocumentsProvider =
    Provider<AsyncValue<List<DocumentSummary>>>((ref) {
  final docsAsync = ref.watch(documentListProvider);
  return docsAsync.whenData((docs) {
    final sorted = [...docs]
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sorted.take(8).toList(growable: false);
  });
});

final filteredDocumentsProvider =
    Provider<AsyncValue<List<DocumentSearchHit>>>((ref) {
  final docsAsync = ref.watch(documentListProvider);
  final query = ref.watch(documentSearchQueryProvider).trim().toLowerCase();

  return docsAsync.whenData((docs) {
    final items = [...docs]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    if (query.isEmpty) {
      return items
          .map((document) => DocumentSearchHit(document: document))
          .toList(growable: false);
    }

    final results = <DocumentSearchHit>[];
    for (final document in items) {
      final titleMatch = document.title.toLowerCase().contains(query);
      final ocrSnippet = document.ocrSnippet?.toLowerCase() ?? '';
      final ocrMatch = ocrSnippet.contains(query);

      if (titleMatch || ocrMatch) {
        String? preview;
        final snippet = document.ocrSnippet;
        if (ocrMatch && snippet != null) {
          final idx = ocrSnippet.indexOf(query);
          final start = (idx - 20).clamp(0, ocrSnippet.length);
          final end = (idx + query.length + 40).clamp(0, snippet.length);
          preview =
              '${start > 0 ? '...' : ''}${snippet.substring(start, end)}${end < snippet.length ? '...' : ''}';
        }
        results.add(DocumentSearchHit(document: document, preview: preview));
      }
    }
    return results;
  });
});

final toggleStarredProvider =
    Provider<Future<void> Function(String, bool)>((ref) {
  final useCase = ref.watch(setDocumentStarredUseCaseProvider);
  return useCase.call;
});

final deleteDocumentsProvider =
    Provider<Future<void> Function(List<String>)>((ref) {
  final useCase = ref.watch(deleteDocumentsUseCaseProvider);
  return useCase.call;
});

final deleteDocumentPageProvider =
    Provider<Future<void> Function(String, String)>((ref) {
  final useCase = ref.watch(deleteDocumentPageUseCaseProvider);
  return useCase.call;
});

final reorderDocumentPagesProvider =
    Provider<Future<void> Function(String, List<String>)>((ref) {
  final useCase = ref.watch(reorderDocumentPagesUseCaseProvider);
  return useCase.call;
});

final updateDocumentPageTextProvider =
    Provider<Future<void> Function(String, String, String)>((ref) {
  final useCase = ref.watch(updateDocumentPageTextUseCaseProvider);
  return useCase.call;
});
