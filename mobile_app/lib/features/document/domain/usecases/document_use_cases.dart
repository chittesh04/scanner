import 'package:smartscan_core_engine/core_engine.dart';
import 'package:smartscan_models/document.dart';
import 'package:smartscan_models/document_collection.dart';
import 'package:smartscan_models/document_summary.dart';
import 'package:smartscan_models/document_summary_page.dart';
import 'package:smartscan_models/repositories/document_repository.dart';

class WatchDocumentsUseCase {
  WatchDocumentsUseCase(this._repository);

  final DocumentRepository _repository;

  Stream<List<DocumentSummary>> call() => _repository.watchDocuments();
}

class FetchDocumentSummaryPageUseCase {
  FetchDocumentSummaryPageUseCase(this._repository);

  final DocumentRepository _repository;

  Future<DocumentSummaryPage> call({
    int limit = 30,
    DateTime? updatedBeforeCursor,
  }) {
    return _repository.fetchDocumentsPage(
      limit: limit,
      updatedBeforeCursor: updatedBeforeCursor,
    );
  }
}

class WatchDocumentUseCase {
  WatchDocumentUseCase(this._repository);

  final DocumentRepository _repository;

  Stream<Document?> call(String documentId) =>
      _repository.watchDocument(documentId);
}

class WatchCollectionsUseCase {
  WatchCollectionsUseCase(this._repository);

  final DocumentRepository _repository;

  Stream<List<DocumentCollection>> call() => _repository.watchCollections();
}

class WatchInboxDocumentsUseCase {
  WatchInboxDocumentsUseCase(this._repository);

  final DocumentRepository _repository;

  Stream<List<DocumentSummary>> call() => _repository.watchInboxDocuments();
}

class WatchDocumentsByCollectionUseCase {
  WatchDocumentsByCollectionUseCase(this._repository);

  final DocumentRepository _repository;

  Stream<List<DocumentSummary>> call(String collectionId) =>
      _repository.watchDocumentsByCollection(collectionId);
}

class CreateDocumentUseCase {
  CreateDocumentUseCase(this._repository);

  final DocumentRepository _repository;

  Future<String> call(String title) => _repository.createDocument(title);
}

class CreateCollectionUseCase {
  CreateCollectionUseCase(this._repository);

  final DocumentRepository _repository;

  Future<String> call(String name) => _repository.createCollection(name);
}

class RenameCollectionUseCase {
  RenameCollectionUseCase(this._repository);

  final DocumentRepository _repository;

  Future<void> call(String collectionId, String newName) =>
      _repository.renameCollection(collectionId, newName);
}

class DeleteCollectionUseCase {
  DeleteCollectionUseCase(this._repository);

  final DocumentRepository _repository;

  Future<void> call(String collectionId) =>
      _repository.deleteCollection(collectionId);
}

class AssignDocumentCollectionUseCase {
  AssignDocumentCollectionUseCase(this._repository);

  final DocumentRepository _repository;

  Future<void> call(String documentId, String? collectionId) =>
      _repository.assignDocumentToCollection(documentId, collectionId);
}

class AddScannedPagesUseCase {
  AddScannedPagesUseCase(this._repository);

  final DocumentRepository _repository;

  Future<void> call(String documentId, ScanPipelineOutput output) =>
      _repository.addPage(documentId, output);
}

class UpdateDocumentTitleUseCase {
  UpdateDocumentTitleUseCase(this._repository);

  final DocumentRepository _repository;

  Future<void> call(String documentId, String title) =>
      _repository.updateTitle(documentId, title);
}

class DeleteDocumentsUseCase {
  DeleteDocumentsUseCase(this._repository);

  final DocumentRepository _repository;

  Future<void> call(List<String> documentIds) =>
      _repository.deleteDocuments(documentIds);
}

class DeleteDocumentPageUseCase {
  DeleteDocumentPageUseCase(this._repository);

  final DocumentRepository _repository;

  Future<void> call(String documentId, String pageId) =>
      _repository.deletePage(documentId, pageId);
}

class ReorderDocumentPagesUseCase {
  ReorderDocumentPagesUseCase(this._repository);

  final DocumentRepository _repository;

  Future<void> call(String documentId, List<String> orderedPageIds) =>
      _repository.reorderPages(documentId, orderedPageIds);
}

class UpdateDocumentPageTextUseCase {
  UpdateDocumentPageTextUseCase(this._repository);

  final DocumentRepository _repository;

  Future<void> call(String documentId, String pageId, String text) =>
      _repository.updatePageText(documentId, pageId, text);
}

class SetDocumentStarredUseCase {
  SetDocumentStarredUseCase(this._repository);

  final DocumentRepository _repository;

  Future<void> call(String documentId, bool isStarred) =>
      _repository.setStarred(documentId, isStarred);
}

class PerformOcrForPageUseCase {
  PerformOcrForPageUseCase(this._repository);

  final DocumentRepository _repository;

  Future<void> call(String documentId, String pageId) =>
      _repository.performOcr(documentId, pageId);
}
