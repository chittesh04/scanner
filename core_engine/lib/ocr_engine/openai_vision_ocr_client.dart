import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import 'package:smartscan_core_engine/logging/engine_logger.dart';
import 'package:smartscan_core_engine/ocr_engine/ocr_pipeline.dart';

class OpenAiVisionOcrClient {
  OpenAiVisionOcrClient({
    http.Client? httpClient,
    String? apiKey,
    String? model,
    String? endpoint,
  })  : _httpClient = httpClient ?? http.Client(),
        _apiKey =
            (apiKey ?? const String.fromEnvironment('SMARTSCAN_OPENAI_API_KEY'))
                .trim(),
        _model = (model ??
                const String.fromEnvironment(
                  'SMARTSCAN_OPENAI_MODEL',
                  defaultValue: 'gpt-4.1-mini',
                ))
            .trim(),
        _endpoint = Uri.parse(
          (endpoint ??
                  const String.fromEnvironment(
                    'SMARTSCAN_OPENAI_RESPONSES_URL',
                    defaultValue: 'https://api.openai.com/v1/responses',
                  ))
              .trim(),
        );

  final http.Client _httpClient;
  final String _apiKey;
  final String _model;
  final Uri _endpoint;

  bool get isConfigured => _apiKey.isNotEmpty;

  Future<OcrResult?> recognizeText(
    Uint8List imageBytes,
    String imagePath, {
    List<String> languageHints = const [],
  }) async {
    if (!isConfigured) {
      return null;
    }

    if (!await _hasInternet()) {
      EngineLogger.info(
        'ocr',
        'Cloud OCR skipped because no internet is available',
      );
      return null;
    }

    final response = await _httpClient.post(
      _endpoint,
      headers: <String, String>{
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, Object?>{
        'model': _model,
        'input': <Object?>[
          <String, Object?>{
            'role': 'user',
            'content': <Object?>[
              <String, String>{
                'type': 'input_text',
                'text': _buildPrompt(languageHints),
              },
              <String, String>{
                'type': 'input_image',
                'image_url':
                    'data:${_inferMimeType(imagePath)};base64,${base64Encode(imageBytes)}',
              },
            ],
          },
        ],
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'Cloud OCR request failed (${response.statusCode}): ${response.body}',
        uri: _endpoint,
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Unexpected cloud OCR response payload');
    }

    final outputText = (decoded['output_text'] as String? ?? '').trim();
    if (outputText.isEmpty) {
      return null;
    }

    return OcrResult(
      fullText: outputText,
      words: const <OcrWord>[],
      detectedLanguages: languageHints,
    );
  }

  Future<bool> _hasInternet() async {
    final host = _endpoint.host;
    if (host.isEmpty) {
      return false;
    }

    try {
      final lookup = await InternetAddress.lookup(host);
      return lookup.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static String _buildPrompt(List<String> languageHints) {
    final languages = languageHints
        .map((hint) => hint.trim())
        .where((hint) => hint.isNotEmpty)
        .join(', ');
    final languagePreference = languages.isEmpty
        ? 'Preserve the original language exactly as shown.'
        : 'Prefer these languages when relevant: $languages.';
    return [
      'Extract all readable text from this scanned document.',
      languagePreference,
      'Return only the document text with preserved line breaks.',
      'Do not add commentary, labels, markdown, or explanations.',
    ].join(' ');
  }

  static String _inferMimeType(String imagePath) {
    switch (p.extension(imagePath).toLowerCase()) {
      case '.png':
        return 'image/png';
      case '.webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
}
