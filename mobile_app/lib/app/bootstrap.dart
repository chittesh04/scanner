import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smartscan/app/app.dart';
import 'package:smartscan/core/di/service_locator.dart';
import 'package:smartscan_services/background_tasks/ocr_background_callback.dart';
import 'package:smartscan_services/background_tasks/work_manager_dispatcher.dart';

Future<void> bootstrap() async {
  // Show the UI immediately — never block before runApp().
  runApp(const ProviderScope(child: _AppInitializer()));
}

/// Shows a minimal splash while heavy init (DB, WorkManager, cleanup) runs
/// asynchronously. Once ready, swaps in the real [SmartScanApp].
class _AppInitializer extends StatefulWidget {
  const _AppInitializer();

  @override
  State<_AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<_AppInitializer> {
  bool _ready = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      // 1. Open the database (may take a moment on large DBs).
      await configureDependencies();

      // 2. Background WorkManager registration.
      await WorkManagerDispatcher.initialize(ocrBackgroundCallback);

      // 3. Orphan temp-file cleanup in a background isolate.
      _cleanOrphanFilesInBackground();

      if (mounted) setState(() => _ready = true);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  /// Fires-and-forgets temp file cleanup in a background isolate so it
  /// never touches the UI thread.
  static void _cleanOrphanFilesInBackground() {
    getTemporaryDirectory().then((tempDir) {
      final path = tempDir.path;
      Isolate.run(() {
        final dir = Directory(path);
        if (!dir.existsSync()) return;
        for (final file in dir.listSync()) {
          if (file is File && file.path.endsWith('_mlkit_tmp.jpg')) {
            try {
              file.deleteSync();
            } catch (_) {}
          }
        }
      });
    }).catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'Failed to start SmartScan:\n$_error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
          ),
        ),
      );
    }

    if (!_ready) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/logo.png', width: 64, height: 64),
                const SizedBox(height: 24),
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const SmartScanApp();
  }
}
