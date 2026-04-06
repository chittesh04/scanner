import 'package:cryptography/cryptography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:smartscan_services/security/file_storage_service.dart';
import 'package:smartscan_services/search_index/data/search_index_service.dart';
import 'package:smartscan_database/database_manager.dart';
import 'package:smartscan_database/repositories/document_repository_impl.dart';
import 'package:smartscan_models/repositories/document_repository.dart';
import 'package:smartscan_core_engine/core_engine.dart';

import 'package:smartscan/features/export/data/pdf_export_service.dart';
import 'package:smartscan/features/export/data/docx_export_service.dart';
import 'package:smartscan/features/export/data/txt_export_service.dart';
import 'package:smartscan/features/export/data/xlsx_export_service.dart';
import 'package:smartscan/features/export/data/zip_export_service.dart';
import 'package:smartscan/features/document/domain/usecases/document_use_cases.dart';
import 'package:smartscan/features/signature/data/signature_repository_impl.dart';
import 'package:smartscan/features/signature/domain/signature_repository.dart';

late final DatabaseManager databaseManager;

/// Set during bootstrap after [KeyManager.getOrGenerateMasterKey()] completes.
late final SecretKey masterKey;

Future<void> configureDependencies() async {
  databaseManager = DatabaseManager.instance;
  await databaseManager.open();
}

final signatureRepositoryProvider = Provider<SignatureRepository>((ref) {
  return SignatureRepositoryImpl(ref.watch(fileStorageProvider));
});

final databaseManagerProvider =
    Provider<DatabaseManager>((_) => databaseManager);

final fileStorageProvider = Provider<FileStorageServiceImpl>((_) {
  return FileStorageServiceImpl(masterKey);
});

/// ML Kit scanner service used by ScanPage to launch the native scanner.
final scannerServiceProvider = Provider<MlKitScannerService>((ref) {
  return MlKitScannerService(ref.watch(fileStorageProvider));
});

/// Kept for backward compatibility with ScanController.
final scanPipelineProvider = Provider<ScanPipeline>((ref) {
  return ref.watch(scannerServiceProvider);
});

final ocrPipelineProvider = Provider<OcrPipeline>(
    (ref) => OcrServiceImpl(ref.watch(fileStorageProvider)));

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  return DocumentRepositoryImpl(
    ref.watch(databaseManagerProvider),
    ref.watch(ocrPipelineProvider),
  );
});

final watchDocumentsUseCaseProvider = Provider<WatchDocumentsUseCase>((ref) {
  return WatchDocumentsUseCase(ref.watch(documentRepositoryProvider));
});

final fetchDocumentSummaryPageUseCaseProvider =
    Provider<FetchDocumentSummaryPageUseCase>((ref) {
  return FetchDocumentSummaryPageUseCase(ref.watch(documentRepositoryProvider));
});

final watchDocumentUseCaseProvider = Provider<WatchDocumentUseCase>((ref) {
  return WatchDocumentUseCase(ref.watch(documentRepositoryProvider));
});

final watchCollectionsUseCaseProvider =
    Provider<WatchCollectionsUseCase>((ref) {
  return WatchCollectionsUseCase(ref.watch(documentRepositoryProvider));
});

final watchInboxDocumentsUseCaseProvider =
    Provider<WatchInboxDocumentsUseCase>((ref) {
  return WatchInboxDocumentsUseCase(ref.watch(documentRepositoryProvider));
});

final watchDocumentsByCollectionUseCaseProvider =
    Provider<WatchDocumentsByCollectionUseCase>((ref) {
  return WatchDocumentsByCollectionUseCase(
      ref.watch(documentRepositoryProvider));
});

final createDocumentUseCaseProvider = Provider<CreateDocumentUseCase>((ref) {
  return CreateDocumentUseCase(ref.watch(documentRepositoryProvider));
});

final createCollectionUseCaseProvider =
    Provider<CreateCollectionUseCase>((ref) {
  return CreateCollectionUseCase(ref.watch(documentRepositoryProvider));
});

final renameCollectionUseCaseProvider =
    Provider<RenameCollectionUseCase>((ref) {
  return RenameCollectionUseCase(ref.watch(documentRepositoryProvider));
});

final deleteCollectionUseCaseProvider =
    Provider<DeleteCollectionUseCase>((ref) {
  return DeleteCollectionUseCase(ref.watch(documentRepositoryProvider));
});

final assignDocumentCollectionUseCaseProvider =
    Provider<AssignDocumentCollectionUseCase>((ref) {
  return AssignDocumentCollectionUseCase(ref.watch(documentRepositoryProvider));
});

final addScannedPagesUseCaseProvider = Provider<AddScannedPagesUseCase>((ref) {
  return AddScannedPagesUseCase(ref.watch(documentRepositoryProvider));
});

final updateDocumentTitleUseCaseProvider =
    Provider<UpdateDocumentTitleUseCase>((ref) {
  return UpdateDocumentTitleUseCase(ref.watch(documentRepositoryProvider));
});

final deleteDocumentsUseCaseProvider = Provider<DeleteDocumentsUseCase>((ref) {
  return DeleteDocumentsUseCase(ref.watch(documentRepositoryProvider));
});

final deleteDocumentPageUseCaseProvider =
    Provider<DeleteDocumentPageUseCase>((ref) {
  return DeleteDocumentPageUseCase(ref.watch(documentRepositoryProvider));
});

final reorderDocumentPagesUseCaseProvider =
    Provider<ReorderDocumentPagesUseCase>((ref) {
  return ReorderDocumentPagesUseCase(ref.watch(documentRepositoryProvider));
});

final updateDocumentPageTextUseCaseProvider =
    Provider<UpdateDocumentPageTextUseCase>((ref) {
  return UpdateDocumentPageTextUseCase(ref.watch(documentRepositoryProvider));
});

final setDocumentStarredUseCaseProvider =
    Provider<SetDocumentStarredUseCase>((ref) {
  return SetDocumentStarredUseCase(ref.watch(documentRepositoryProvider));
});

final performOcrForPageUseCaseProvider =
    Provider<PerformOcrForPageUseCase>((ref) {
  return PerformOcrForPageUseCase(ref.watch(documentRepositoryProvider));
});

/// Full-text search index backed by Isar and querying [PageEntity.fullText].
final searchIndexServiceProvider = Provider<SearchIndexService>((ref) {
  return SearchIndexService(ref.watch(databaseManagerProvider).isar);
});

final pdfExportProvider = Provider<PdfExportService>((ref) {
  return PdfExportService(
    ref.watch(fileStorageProvider),
    ref.watch(signatureRepositoryProvider),
  );
});

final docxExportProvider = Provider<DocxExportService>((ref) {
  return DocxExportService(ref.watch(fileStorageProvider));
});

final xlsxExportProvider = Provider<XlsxExportService>((_) {
  return XlsxExportService();
});

final txtExportProvider = Provider<TxtExportService>((_) {
  return TxtExportService();
});

final zipExportProvider = Provider<ZipExportService>((_) {
  return ZipExportService();
});
