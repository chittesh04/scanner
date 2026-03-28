import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smartscan_database/isar_schema.dart';

class DatabaseManager {
  static DatabaseManager? _instance;
  static DatabaseManager get instance => _instance ??= DatabaseManager._();

  DatabaseManager._();

  Isar? _isar;
  Isar get isar => _isar!;

  Future<void> open() async {
    if (_isar != null && _isar!.isOpen) return;

    final directory = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [
        DocumentEntitySchema,
        PageEntitySchema,
        OcrBlockEntitySchema,
        TagEntitySchema,
        CollectionEntitySchema,
      ],
      directory: directory.path,
      name: 'smartscan',
      inspector: false,
    );
  }

  Future<void> close() async {
    if (_isar != null && _isar!.isOpen) {
      await _isar!.close();
      _isar = null;
    }
  }
}
