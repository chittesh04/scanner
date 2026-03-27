import 'package:workmanager/workmanager.dart';

class WorkManagerDispatcher {
  static const syncTask = 'cloud-sync-task';
  static const indexTask = 'ocr-index-task';

  /// Initialise WorkManager with a top-level [callbackDispatcher].
  ///
  /// The callback must be a **top-level** or **static** function annotated
  /// with `@pragma('vm:entry-point')` so that it survives AOT tree-shaking.
  /// The concrete implementation lives in
  /// `mobile_app/lib/core/background/ocr_background_callback.dart`.
  static Future<void> initialize(Function callbackDispatcher) async {
    await Workmanager().initialize(callbackDispatcher);
  }

  /// Enqueue a one-off background job that runs ML Kit OCR for every
  /// pending page in the given [documentId].
  ///
  /// WorkManager will execute this even if the app is killed, and
  /// honours battery-saver / Doze constraints automatically.
  static Future<void> enqueueOcrIndexJob(String documentId) async {
    await Workmanager().registerOneOffTask(
      '$indexTask-$documentId',
      indexTask,
      inputData: <String, dynamic>{'documentId': documentId},
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
      ),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
  }

  /// Enqueue a cloud-sync background job for the given [documentId].
  static Future<void> enqueueSyncJob(String documentId) async {
    await Workmanager().registerOneOffTask(
      '$syncTask-$documentId',
      syncTask,
      inputData: <String, dynamic>{'documentId': documentId},
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      existingWorkPolicy: ExistingWorkPolicy.keep,
    );
  }
}
