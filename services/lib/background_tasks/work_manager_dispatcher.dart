import 'package:workmanager/workmanager.dart';

class WorkManagerDispatcher {
  static const syncTask = 'cloud-sync-task';
  static const indexTask = 'ocr-index-task';

  static Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher);
  }

  static void callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      switch (task) {
        case syncTask:
        case indexTask:
          return true;
        default:
          return false;
      }
    });
  }
}
