import 'dart:typed_data';

abstract interface class SecureStoragePort {
  Future<Uint8List> readImageBytes(String path);
  Future<String> writeImageBytes(String documentId, String pageId, Uint8List bytes, {required bool processed});
}
