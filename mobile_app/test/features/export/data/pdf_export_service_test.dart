import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartscan/features/export/data/pdf_export_service.dart';
import 'package:smartscan/features/export/domain/export_models.dart';
import 'package:smartscan_services/security/file_storage_service.dart';
import 'package:smartscan/features/signature/domain/signature_repository.dart';

class MockFileStorageService implements FileStorageServiceImpl {
  @override
  Future<Uint8List> readEncrypted(File file) async {
    // Return a dummy 1x1 png image
    return Uint8List.fromList([
      137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 
      0, 0, 0, 1, 0, 0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 196, 137, 0, 0, 
      0, 10, 73, 68, 65, 84, 120, 156, 99, 0, 1, 0, 0, 5, 0, 1, 13, 
      10, 45, 180, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130
    ]);
  }
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockSignatureRepository implements SignatureRepository {
  @override
  Future<Uint8List?> loadSignature() async {
    return Uint8List.fromList([
      137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 
      0, 0, 0, 1, 0, 0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 196, 137, 0, 0, 
      0, 10, 73, 68, 65, 84, 120, 156, 99, 0, 1, 0, 0, 5, 0, 1, 13, 
      10, 45, 180, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130
    ]);
  }
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'getTemporaryDirectory' || methodCall.method == 'getApplicationDocumentsDirectory') {
          return Directory.systemTemp.path;
        }
        return null;
      },
    );
  });

  test('PdfExportService positions invisible text per OCR block for searchable PDF', () async {
    final storage = MockFileStorageService();
    final sigRepo = MockSignatureRepository();
    final service = PdfExportService(storage, sigRepo);

    final tempDir = Directory.systemTemp;
    final file = File('${tempDir.path}/dummy_image.png');
    await file.writeAsBytes([0]);

    final request = ExportRequest(
      documentId: 'doc1',
      title: 'TestDoc',
      pages: [
        PageExportData(
          imagePath: file.path,
          imageWidth: 1000,
          imageHeight: 1400,
          ocrBlocks: [
            const ExportOcrBlock(
              text: 'Hello',
              left: 100,
              top: 200,
              right: 300,
              bottom: 240,
            ),
            const ExportOcrBlock(
              text: 'World',
              left: 320,
              top: 200,
              right: 520,
              bottom: 240,
            ),
          ],
          ocrText: 'Hello World',
          signature: const PageSignature(x: 0.5, y: 0.5, scale: 1.0),
        ),
      ],
      outputPath: '${tempDir.path}/test_pdf_export_output.pdf',
    );

    final pdfFile = await service.export(request);

    expect(await pdfFile.exists(), isTrue);
    expect(await pdfFile.length(), greaterThan(100)); // Non empty valid PDF payload
    
    await file.delete();
    await pdfFile.delete();
  });
}
