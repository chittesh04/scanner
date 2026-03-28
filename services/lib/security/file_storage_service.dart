import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:cryptography/cryptography.dart';
import 'package:smartscan_services/security/encryption_service.dart';
import 'package:smartscan_core_engine/core_engine.dart';

class FileStorageServiceImpl implements SecureStoragePort {
  FileStorageServiceImpl(this._encryptionService);

  final EncryptionService _encryptionService;
  
  // In production, this key should be retrieved from secure storage (e.g., flutter_secure_storage)
  // and sealed with biometric authentication.
  static final _mockKey = SecretKey([1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2]);

  Future<Directory> _root() async {
    final dir = await getApplicationSupportDirectory();
    final root = Directory(p.join(dir.path, 'smartscan_data'));
    if (!await root.exists()) {
      await root.create(recursive: true);
    }
    return root;
  }

  Future<File> pageFile(String documentId, String pageId, {required bool processed}) async {
    final root = await _root();
    final folder = Directory(p.join(root.path, documentId));
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    return File(p.join(folder.path, '${processed ? 'proc' : 'raw'}_$pageId.enc'));
  }

  Future<File> globalFile(String filename) async {
    final root = await _root();
    return File(p.join(root.path, filename));
  }

  @override
  Future<String> writeImageBytes(String documentId, String pageId, Uint8List bytes, {required bool processed}) async {
    final file = await pageFile(documentId, pageId, processed: processed);
    await writeEncrypted(file, bytes);
    return file.path;
  }

  @override
  Future<Uint8List> readImageBytes(String path) async {
    final file = File(path);
    return readEncrypted(file);
  }

  Future<void> writeEncrypted(File file, Uint8List data) async {
    final box = await _encryptionService.encrypt(data, _mockKey);
    final encoded = EncryptionService.encodeSecretBox(box);
    await file.writeAsString(encoded, flush: true);
  }

  Future<Uint8List> readEncrypted(File file) async {
    final encoded = await file.readAsString();
    final box = EncryptionService.decodeSecretBox(encoded);
    return _encryptionService.decrypt(box, _mockKey);
  }
}
