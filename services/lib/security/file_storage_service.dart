import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:smartscan_core_engine/core_engine.dart';

class FileStorageServiceImpl implements SecureStoragePort {
  FileStorageServiceImpl();

  Future<Directory> _root() async {
    final dir = await getApplicationSupportDirectory();
    final root = Directory(p.join(dir.path, 'smartscan_data'));
    if (!await root.exists()) {
      await root.create(recursive: true);
    }
    return root;
  }

  Future<File> pageFile(String documentId, String pageId,
      {required bool processed}) async {
    final root = await _root();
    final folder = Directory(p.join(root.path, documentId));
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    // Use .jpg instead of .enc — encryption disabled for stability
    return File(
        p.join(folder.path, '${processed ? 'proc' : 'raw'}_$pageId.jpg'));
  }

  Future<File> globalFile(String filename) async {
    final root = await _root();
    return File(p.join(root.path, filename));
  }

  @override
  Future<String> writeImageBytes(
      String documentId, String pageId, Uint8List bytes,
      {required bool processed}) async {
    final file = await pageFile(documentId, pageId, processed: processed);
    await writeEncrypted(file, bytes);
    return file.path;
  }

  @override
  Future<Uint8List> readImageBytes(String path) async {
    final file = File(path);
    return readEncrypted(file);
  }

  // Encryption bypassed — just write raw bytes for stability
  Future<void> writeEncrypted(File file, Uint8List data) async {
    await file.writeAsBytes(data, flush: true);
  }

  // Encryption bypassed — just read raw bytes for stability
  Future<Uint8List> readEncrypted(File file) async {
    return await file.readAsBytes();
  }
}
