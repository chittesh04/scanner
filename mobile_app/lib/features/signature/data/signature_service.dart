import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class SignatureService {
  final _uuid = const Uuid();

  Future<String> saveSignature(List<int> pngBytes) async {
    final root = await getApplicationDocumentsDirectory();
    final folder = Directory(p.join(root.path, 'signatures'));
    if (!await folder.exists()) await folder.create(recursive: true);
    final file = File(p.join(folder.path, '${_uuid.v4()}.png'));
    await file.writeAsBytes(pngBytes, flush: true);
    return file.path;
  }
}
