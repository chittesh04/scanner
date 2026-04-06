import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smartscan_database/isar_schema.dart';

class DatabaseManager {
  static DatabaseManager? _instance;
  static DatabaseManager get instance => _instance ??= DatabaseManager._();

  DatabaseManager._();

  Isar? _isar;
  Future<void>? _opening;
  Isar get isar {
    final instance = _isar;
    if (instance == null || !instance.isOpen) {
      throw StateError(
        'DatabaseManager is not open. Call open() before accessing isar.',
      );
    }
    return instance;
  }

  static Future<Isar> openInstance() async {
    final manager = DatabaseManager.instance;
    await manager.open();
    return manager.isar;
  }

  Future<void> open() async {
    final instance = _isar;
    if (instance != null && instance.isOpen) return;
    if (_opening != null) {
      await _opening;
      return;
    }

    _opening = () async {
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
    }();

    try {
      await _opening;
    } finally {
      _opening = null;
    }
  }

  Future<void> close() async {
    final instance = _isar;
    if (instance != null && instance.isOpen) {
      await instance.close();
      _isar = null;
    }
  }
}
