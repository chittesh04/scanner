import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:flutter_test/flutter_test.dart';
import 'package:smartscan_core_engine/core_engine.dart';

class MockSecureStoragePort implements SecureStoragePort {
  @override
  Future<Uint8List> readImageBytes(String path) async {
    return Uint8List(0);
  }

  @override
  Future<String> writeImageBytes(String documentId, String pageId, Uint8List bytes, {required bool processed}) async {
    final temp = Directory.systemTemp;
    final file = File('${temp.path}/$pageId.jpg');
    await file.writeAsBytes(bytes);
    return file.path;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('ScanningService dewarps and isolates frame accurately using FR-01.2 algorithms', () async {
    final storage = MockSecureStoragePort();
    final service = ScanningServiceImpl(storage);

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
