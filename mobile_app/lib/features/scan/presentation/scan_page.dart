import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartscan/core/di/service_locator.dart';
import 'package:smartscan/core/logging/app_logger.dart';
import 'package:smartscan_services/background_tasks/work_manager_dispatcher.dart';

class ScanPage extends ConsumerStatefulWidget {
  const ScanPage({super.key, required this.documentId});

  final String documentId;

  @override
  ConsumerState<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends ConsumerState<ScanPage> {
  bool _scanning = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Launch the native ML Kit scanner immediately on page open.
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScan());
  }

  Future<void> _startScan() async {
    if (_scanning) return;

    setState(() {
      _scanning = true;
      _error = null;
    });

    try {
      AppLogger.info('scan', 'Launching scanner for ${widget.documentId}');
      final scanner = ref.read(scannerServiceProvider);
      final output = await scanner.scanDocument(
        documentId: widget.documentId,
      );

      if (!mounted) return;

      if (output == null || output.pages.isEmpty) {
        AppLogger.info(
            'scan', 'Scan canceled or empty for ${widget.documentId}');
        if (mounted) {
          setState(() => _scanning = false);
        }
        Navigator.of(context).maybePop();
        return;
      }

      await ref.read(addScannedPagesUseCaseProvider).call(
            widget.documentId,
            output,
          );
      AppLogger.info(
        'scan',
        'Stored ${output.pages.length} pages for ${widget.documentId}',
      );

      // Fire-and-forget background OCR indexing for the updated document.
      try {
        await WorkManagerDispatcher.enqueueOcrIndexJob(widget.documentId);
      } catch (error, stackTrace) {
        AppLogger.warn(
          'background',
          'Failed to enqueue OCR background job',
          error: error,
        );
        AppLogger.error(
          'background',
          'OCR enqueue stack trace',
          error: error,
          stackTrace: stackTrace,
        );
      }

      if (!mounted) return;
      await HapticFeedback.mediumImpact();

      final pageCount = output.pages.length;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Added $pageCount scanned page${pageCount > 1 ? 's' : ''}',
          ),
        ),
      );

      if (mounted) {
        setState(() => _scanning = false);
      }
      final addAnother = await _showAddAnotherPagePrompt();
      if (!mounted) return;
      if (addAnother) {
        await _startScan();
        return;
      }
      Navigator.of(context).maybePop();
    } on PlatformException catch (e) {
      AppLogger.error('scan', 'Platform scan failure', error: e);
      if (!mounted) return;
      setState(() {
        _error = e.message ?? 'Platform error while opening scanner.';
        _scanning = false;
      });
    } catch (e) {
      AppLogger.error('scan', 'Unexpected scan failure', error: e);
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _scanning = false;
      });
    }
  }

  Future<bool> _showAddAnotherPagePrompt() async {
    final addAnother = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Page Added'),
        content: const Text('Do you want to scan another page?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Finish'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Add Another'),
          ),
        ],
      ),
    );
    return addAnother == true;
  }

  @override
  Widget build(BuildContext context) {
    final errorMessage = _error;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Document'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: errorMessage != null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Scan failed',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _startScan,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try Again'),
                    ),
                  ],
                )
              : const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(),
                    ),
                    SizedBox(height: 16),
                    Text('Preparing camera scanner...'),
                  ],
                ),
        ),
      ),
    );
  }
}
