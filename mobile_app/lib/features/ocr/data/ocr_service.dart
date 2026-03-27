import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:smartscan_core_engine/ocr_engine/ocr_pipeline.dart';

import 'package:smartscan/core/storage/file_storage_service.dart';
import 'dart:io';

class OcrService implements OcrPipeline {
  OcrService(this._storageService,
      {TextRecognitionScript script = TextRecognitionScript.latin})
      : _textRecognizer = TextRecognizer(script: script);

  final TextRecognizer _textRecognizer;
  final FileStorageService _storageService;

  @override
  Future<OcrResult> recognizeText(String imagePath,
      {List<String> languageHints = const []}) async {
    final file = File(imagePath);
    final imageBytes = await _storageService.readEncrypted(file);
    final tempFile = File('${file.path}.tmp');
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

  Future<void> dispose() => _textRecognizer.close();
}
