import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:smartscan/core/storage/isar_provider.dart';
import 'package:smartscan/core/storage/file_storage_service.dart';
import 'package:smartscan/core/security/encryption_service.dart';
import 'package:smartscan_core_engine/ocr_engine/ocr_pipeline.dart';
import 'package:smartscan_core_engine/document_pipeline/scan_pipeline.dart';
import 'package:smartscan/features/document/data/document_repository_impl.dart';
import 'package:smartscan/features/document/domain/document_repository.dart';
import 'package:smartscan/features/ocr/data/ocr_service.dart';
import 'package:smartscan/features/scan/data/scanning_service.dart';
import 'package:smartscan/features/export/data/pdf_export_service.dart';
import 'package:smartscan/features/signature/data/signature_repository_impl.dart';
import 'package:smartscan/features/signature/domain/signature_repository.dart';

late final Isar isarInstance;

Future<void> configureDependencies() async {
  isarInstance = await IsarProvider.open();
}

final signatureRepositoryProvider = Provider<SignatureRepository>((ref) {
  return SignatureRepositoryImpl(ref.watch(fileStorageProvider));
});

final isarProvider = Provider<Isar>((_) => isarInstance);

final encryptionProvider = Provider<EncryptionService>((_) => EncryptionService());

final fileStorageProvider = Provider<FileStorageService>((ref) {
  return FileStorageService(ref.watch(encryptionProvider));
});

final scanPipelineProvider = Provider<ScanPipeline>((ref) {
  return ScanningService(ref.watch(fileStorageProvider));
});

final ocrPipelineProvider = Provider<OcrPipeline>((ref) => OcrService(ref.watch(fileStorageProvider)));

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  return DocumentRepositoryImpl(
    ref.watch(isarProvider),
    ref.watch(ocrPipelineProvider),
  );
});

final pdfExportProvider = Provider<PdfExportService>((ref) {
  return PdfExportService(
    ref.watch(fileStorageProvider),
    ref.watch(signatureRepositoryProvider),
  );
});
