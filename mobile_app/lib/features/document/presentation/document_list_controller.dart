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

    return items
        .where((document) => document.title.toLowerCase().contains(query))
        .map((document) => SearchMatchModel(document: document))
        .toList(growable: false);
  });
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
