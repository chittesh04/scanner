import 'dart:io';
import 'dart:math';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:smartscan_core_engine/logging/engine_logger.dart';
import 'package:smartscan_core_engine/ocr_engine/ocr_pipeline.dart';
import 'package:smartscan_core_engine/ports/secure_storage_port.dart';

class OcrServiceImpl implements OcrPipeline {
  OcrServiceImpl(
    this._storagePort, {
    TextRecognitionScript script = TextRecognitionScript.latin,
  }) : _textRecognizer = TextRecognizer(script: script);

  final TextRecognizer _textRecognizer;
  final SecureStoragePort _storagePort;

  @override
  Future<OcrResult> recognizeText(
    String imagePath, {
    List<String> languageHints = const [],
  }) async {
    EngineLogger.info('ocr', 'Starting OCR for $imagePath');
    final imageBytes = await _storagePort.readImageBytes(imagePath);

    final tempDir = await getTemporaryDirectory();
    final random = Random().nextInt(1 << 31);
    final fileName = '${p.basename(imagePath)}_${random}_mlkit_tmp.jpg';
    final tempFile = File(p.join(tempDir.path, fileName));

    try {
      await tempFile.writeAsBytes(imageBytes, flush: true);

      final inputImage = InputImage.fromFile(tempFile);
      final recognized = await _textRecognizer.processImage(inputImage);

      final words = recognized.blocks
          .expand((block) => block.lines)
          .expand((line) => line.elements)
          .map(
            (element) => OcrWord(
              text: element.text,
              left: element.boundingBox.left,
              top: element.boundingBox.top,
              right: element.boundingBox.right,
              bottom: element.boundingBox.bottom,
            ),
          )
          .toList(growable: false);

      EngineLogger.info(
          'ocr', 'OCR completed for $imagePath: ${words.length} words');
      return OcrResult(
        fullText: recognized.text,
        words: words,
        detectedLanguages: recognized.blocks
            .map((e) => e.recognizedLanguages)
            .expand((e) => e)
            .whereType<String>()
            .toSet()
            .toList(growable: false),
      );
    } catch (error, stackTrace) {
      EngineLogger.error(
        'ocr',
        'OCR failed for $imagePath',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    } finally {
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    }
  }

  @override
  Future<void> dispose() => _textRecognizer.close();
}
