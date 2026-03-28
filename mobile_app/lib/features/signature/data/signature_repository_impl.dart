import 'dart:typed_data';
import 'package:smartscan_services/security/file_storage_service.dart';
import 'package:smartscan/features/signature/domain/signature_repository.dart';

class SignatureRepositoryImpl implements SignatureRepository {
  const SignatureRepositoryImpl(this._storage);

  final FileStorageServiceImpl _storage;
  static const _fileName = 'user_signature.enc';

  @override
  Future<void> saveSignature(Uint8List pngBytes) async {
    final file = await _storage.globalFile(_fileName);
    await _storage.writeEncrypted(file, pngBytes);
  }

  @override
  Future<Uint8List?> loadSignature() async {
    final file = await _storage.globalFile(_fileName);
    if (!await file.exists()) {
      return null;
    }
    try {
      return await _storage.readEncrypted(file);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearSignature() async {
    final file = await _storage.globalFile(_fileName);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
