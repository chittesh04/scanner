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
    FutureProvider<List<DocumentSearchHit>>((ref) async {
  final docs = await ref.watch(documentListProvider.future);
  final query = ref.watch(documentSearchQueryProvider).trim().toLowerCase();
  final items = [...docs]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  if (query.isEmpty) {
    return items
        .map((document) => DocumentSearchHit(document: document))
        .toList(growable: false);
  }

  final matchedDocumentIds =
      await ref.watch(searchIndexServiceProvider).search(query);
  final ranked = <({int score, DocumentSearchHit hit})>[];

  for (final document in items) {
    final lowerTitle = document.title.toLowerCase();
    final titleStartsWith = lowerTitle.startsWith(query);
    final titleMatch = lowerTitle.contains(query);
    final snippet = document.ocrSnippet;
    final lowerSnippet = snippet?.toLowerCase() ?? '';
    final snippetMatch = lowerSnippet.contains(query);
    final fullTextMatch = matchedDocumentIds.contains(document.documentId);

    if (!titleMatch && !snippetMatch && !fullTextMatch) {
      continue;
    }

    String? preview;
    if (snippetMatch && snippet != null) {
      final idx = lowerSnippet.indexOf(query);
      final start = (idx - 20).clamp(0, snippet.length);
      final end = (idx + query.length + 40).clamp(0, snippet.length);
      preview =
          '${start > 0 ? '...' : ''}${snippet.substring(start, end)}${end < snippet.length ? '...' : ''}';
    } else if (fullTextMatch) {
      preview = 'Matched in OCR text';
    }

    final score = switch ((titleStartsWith, titleMatch, fullTextMatch)) {
      (true, _, _) => 3,
      (_, true, _) => 2,
      (_, _, true) => 1,
      _ => 0,
    };

    ranked.add((
      score: score,
      hit: DocumentSearchHit(document: document, preview: preview),
    ));
  }

  ranked.sort((left, right) {
    final byScore = right.score.compareTo(left.score);
    if (byScore != 0) {
      return byScore;
    }
    return right.hit.document.updatedAt.compareTo(left.hit.document.updatedAt);
  });

  return ranked.map((entry) => entry.hit).toList(growable: false);
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
