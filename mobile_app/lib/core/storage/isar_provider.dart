import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smartscan_database/isar_schema.dart';

class IsarProvider {
  static Future<Isar> open() async {
    final directory = await getApplicationDocumentsDirectory();
    return Isar.open(
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
}
