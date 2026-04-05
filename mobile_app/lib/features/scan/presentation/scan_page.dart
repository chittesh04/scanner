import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartscan/core/di/service_locator.dart';

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
      final scanner = ref.read(scannerServiceProvider);
      final output = await scanner.scanDocument(
        documentId: widget.documentId,
      );

      if (!mounted) return;

      if (output == null || output.pages.isEmpty) {
        // User cancelled or no pages scanned — go back.
        if (!mounted) return;
        Navigator.of(context).maybePop();
        return;
      }

      // Save scanned pages to the repository.
      final repository = ref.read(documentRepositoryProvider);
      await repository.addPage(widget.documentId, output);

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

      Navigator.of(context).maybePop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _scanning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Document'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _error != null
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
                      _error!,
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
                    Text('Launching document scanner...'),
                  ],
                ),
        ),
      ),
    );
  }
}
