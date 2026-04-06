import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:smartscan_core_engine/core_engine.dart';
import 'package:smartscan_services/logging/services_logger.dart';
import 'package:smartscan_services/security/encryption_service.dart';

class FileStorageServiceImpl implements SecureStoragePort {
  FileStorageServiceImpl(this._masterKey);

  final SecretKey _masterKey;

  Future<Directory> _root() async {
    final dir = await getApplicationSupportDirectory();
    final root = Directory(p.join(dir.path, 'smartscan_data'));
    if (!await root.exists()) {
      await root.create(recursive: true);
    }
    return root;
  }

  Future<File> pageFile(
    String documentId,
    String pageId, {
    required bool processed,
  }) async {
    final root = await _root();
    final folder = Directory(p.join(root.path, documentId));
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    return File(
        p.join(folder.path, '${processed ? 'proc' : 'raw'}_$pageId.jpg'));
  }

  Future<File> globalFile(String filename) async {
    final root = await _root();
    return File(p.join(root.path, filename));
  }

  @override
  Future<String> writeImageBytes(
    String documentId,
    String pageId,
    Uint8List bytes, {
    required bool processed,
  }) async {
    final file = await pageFile(documentId, pageId, processed: processed);
    await writeEncrypted(file, bytes);
    return file.path;
  }

  @override
  Future<Uint8List> readImageBytes(String path) async {
    final file = File(path);
    return readEncrypted(file);
  }

  /// Encrypts [data] with AES-256-GCM using the master key, then writes
  /// the ciphertext to [file]. Runs in a background isolate to avoid
  /// blocking the UI thread.
  Future<void> writeEncrypted(File file, Uint8List data) async {
    final keyBytes = await _masterKey.extractBytes();
    final encodedBytes = await Isolate.run(() async {
      final svc = EncryptionService();
      final key = SecretKey(keyBytes);
      final box = await svc.encrypt(data, key);
      return EncryptionService.encodeSecretBox(box);
    });
    await file.writeAsBytes(encodedBytes, flush: true);
  }

  /// Reads and decrypts a file. Uses graceful fallback + lazy re-encryption:
  ///
  /// 1. Try AES-GCM decryption (assumes encrypted file).
  /// 2. On failure, assume it is an old unencrypted JPEG from earlier versions.
  /// 3. Fire-and-forget: re-encrypt the file in a background isolate.
  Future<Uint8List> readEncrypted(File file) async {
    final fileBytes = await file.readAsBytes();
    final keyBytes = await _masterKey.extractBytes();

    try {
      return await Isolate.run(() async {
        final svc = EncryptionService();
        final key = SecretKey(keyBytes);
        final box = EncryptionService.decodeSecretBox(fileBytes);
        return svc.decrypt(box, key);
      });
    } catch (error, stackTrace) {
      ServicesLogger.warn(
        'security',
        'Encrypted read failed, falling back to legacy plaintext bytes',
        error: error,
        stackTrace: stackTrace,
      );

      final filePath = file.path;
      unawaited(Isolate.run(() async {
        final svc = EncryptionService();
        final key = SecretKey(keyBytes);
        final box = await svc.encrypt(fileBytes, key);
        final encryptedBytes = EncryptionService.encodeSecretBox(box);
        await File(filePath).writeAsBytes(encryptedBytes, flush: true);
      }).catchError((Object error, StackTrace stackTrace) {
        ServicesLogger.error(
          'security',
          'Lazy re-encryption failed',
          error: error,
          stackTrace: stackTrace,
        );
      }));

      return fileBytes;
    }
  }
}
