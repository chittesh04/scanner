import 'package:smartscan_models/document.dart';
import 'package:smartscan_models/document_collection.dart';
import 'package:smartscan_models/document_summary.dart';
import 'package:smartscan_core_engine/core_engine.dart';

abstract interface class DocumentRepository {
  Stream<List<DocumentSummary>> watchDocuments();
  Stream<Document?> watchDocument(String documentId);
  Future<String> createDocument(String title);
  Future<void> deleteDocument(String documentId);
  Future<void> deleteDocuments(List<String> documentIds);
  Future<void> reorderPages(String documentId, List<String> orderedPageIds);
  Future<void> addPage(String documentId, ScanPipelineOutput scanOutput);
  Future<void> performOcr(String documentId, String pageId);
  Future<void> setStarred(String documentId, bool starred);
  Future<void> setDocumentTags(String documentId, List<String> tags);
  Stream<List<DocumentCollection>> watchCollections();
  Stream<List<DocumentSummary>> watchDocumentsByCollection(String collectionId);
  Stream<List<DocumentSummary>> watchInboxDocuments();
  Future<String> createCollection(String name);
  Future<void> assignDocumentToCollection(
      String documentId, String? collectionId);
  Future<void> updatePageSignature(String documentId, String pageId, double x, double y, double scale);
  Future<void> removePageSignature(String documentId, String pageId);
}
