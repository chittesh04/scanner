import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:smartscan_core_engine/ocr_engine/ocr_pipeline.dart';
import 'package:smartscan_core_engine/ports/secure_storage_port.dart';

import 'dart:io';

class OcrServiceImpl implements OcrPipeline {
  OcrServiceImpl(this._storagePort,
      {TextRecognitionScript script = TextRecognitionScript.latin})
      : _textRecognizer = TextRecognizer(script: script);

  final TextRecognizer _textRecognizer;
  final SecureStoragePort _storagePort;

  @override
  Future<OcrResult> recognizeText(String imagePath,
      {List<String> languageHints = const []}) async {
    final imageBytes = await _storagePort.readImageBytes(imagePath);
    // Write to a temporary file because ML Kit requires a File path or a direct ByteBuffer.
    // Using a temp file is the simplest matching the old logic for now.
    final tempFile = File('$imagePath.tmp');
    await tempFile.writeAsBytes(imageBytes);

    final inputImage = InputImage.fromFile(tempFile);
    final recognized = await _textRecognizer.processImage(inputImage);
    await tempFile.delete();

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
  }

  @override
  Future<void> dispose() => _textRecognizer.close();
}
