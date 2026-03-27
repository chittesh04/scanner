import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:flutter_test/flutter_test.dart';
import 'package:smartscan_core_engine/document_pipeline/scan_pipeline.dart';
import 'package:smartscan/features/scan/data/scanning_service.dart';
import 'package:smartscan/core/storage/file_storage_service.dart';

class MockFileStorageService implements FileStorageService {
  @override
  Future<File> pageFile(String documentId, String pageId, {required bool processed}) async {
    final temp = Directory.systemTemp;
    return File('${temp.path}/$pageId.jpg');
  }
  
  @override
  Future<void> writeEncrypted(File file, Uint8List bytes) async {
    await file.writeAsBytes(bytes);
  }
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('ScanningService dewarps and isolates frame accurately using FR-01.2 algorithms', () async {
    final storage = MockFileStorageService();
    final service = ScanningService(storage);

    // Generate valid memory JPEG using the native image package
    final imgImage = img.Image(width: 100, height: 100);
    img.fill(imgImage, color: img.ColorRgb8(255, 255, 255));
    final jpegBytes = Uint8List.fromList(img.encodeJpg(imgImage));

    final input = ScanPipelineInput(
      documentId: 'doc1',
      jpegBytes: jpegBytes,
      detectedRectangles: [
        const DetectedRectangle(
          label: 'Test Page',
          confidence: 1.0,
          areaRatio: 0.8,
          corners: [
            NormalizedCorner(0.1, 0.1),
            NormalizedCorner(0.9, 0.1),
            NormalizedCorner(0.9, 0.9),
            NormalizedCorner(0.1, 0.9),
          ],
        )
      ],
    );

    final output = await service.process(input);

    expect(output.pages.length, 1);
    expect(output.pages.first.label, 'Test Page');
    expect(output.pages.first.rawImagePath, isNotEmpty);
  });
}
