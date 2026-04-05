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
import 'package:smartscan/features/export/data/xlsx_export_service.dart';
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

/// ML Kit scanner service — used by ScanPage to launch the native scanner.
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

/// Full-text search index backed by Isar — queries [PageEntity.fullText].
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
