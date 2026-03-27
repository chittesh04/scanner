import 'dart:typed_data';

abstract interface class SignatureRepository {
  Future<void> saveSignature(Uint8List pngBytes);
  Future<Uint8List?> loadSignature();
  Future<void> clearSignature();
}
