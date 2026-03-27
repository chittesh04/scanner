class OcrWord {
  const OcrWord({required this.text, required this.left, required this.top, required this.right, required this.bottom});
  final String text;
  final double left;
  final double top;
  final double right;
  final double bottom;
}

class OcrResult {
  const OcrResult({required this.fullText, required this.words, required this.detectedLanguages});
  final String fullText;
  final List<OcrWord> words;
  final List<String> detectedLanguages;
}

abstract interface class OcrPipeline {
  Future<OcrResult> recognizeText(String imagePath, {List<String> languageHints = const []});
}
