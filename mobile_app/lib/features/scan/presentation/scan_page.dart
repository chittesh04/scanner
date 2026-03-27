import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartscan/core/di/service_locator.dart';
import 'package:smartscan/features/scan/presentation/scan_controller.dart';
import 'package:smartscan_core_engine/document_pipeline/scan_pipeline.dart';

class ScanPage extends ConsumerStatefulWidget {
  const ScanPage({super.key, required this.documentId});

  final String documentId;

  @override
  ConsumerState<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends ConsumerState<ScanPage>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  bool _isProcessingCapture = false;
  bool _flashOverlayVisible = false;
  List<ScannedPage> _capturedPagesPreview = const <ScannedPage>[];
  String? _cameraError;
  ProviderSubscription<ScanViewState>? _scanStateSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scanStateSubscription = ref.listenManual<ScanViewState>(
      scanControllerProvider,
      (previous, next) {
        final shouldAutoCapture = next.autoCaptureTriggered &&
            !(previous?.autoCaptureTriggered ?? false);
        if (shouldAutoCapture) {
          ref.read(scanControllerProvider.notifier).resetAutoCaptureFlag();
          _capture();
        }
      },
    );
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          setState(() => _cameraError = 'No camera available on this device.');
        }
        return;
      }

      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        backCamera,
        ResolutionPreset.max,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await controller.initialize();
      await controller.setFocusMode(FocusMode.auto);
      _cameraController = controller;
      _cameraError = null;

      await _startImageStream();

      if (mounted) {
        setState(() {});
      }
    } catch (error) {
      if (mounted) {
        setState(() => _cameraError = 'Failed to initialize camera: $error');
      }
    }
  }

  Future<void> _startImageStream() async {
    final controller = _cameraController;
    if (controller == null ||
        !controller.value.isInitialized ||
        controller.value.isStreamingImages) {
      return;
    }

    await controller.startImageStream((image) {
      final scanController = ref.read(scanControllerProvider.notifier);
      unawaited(
        scanController.onPreviewFrame(
          image: image,
          rotationDegrees: controller.description.sensorOrientation,
        ),
      );
    });
  }

  Future<void> _stopImageStream() async {
    final controller = _cameraController;
    if (controller != null && controller.value.isStreamingImages) {
      await controller.stopImageStream();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scanStateSubscription?.close();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      unawaited(_stopImageStream());
      controller.pausePreview();
    }

    if (state == AppLifecycleState.resumed) {
      controller.resumePreview();
      unawaited(_startImageStream());
    }
  }

  Future<void> _toggleFlash() async {
    final controller = _cameraController;
    if (controller == null) {
      return;
    }

    final scanController = ref.read(scanControllerProvider.notifier);
    final state = ref.read(scanControllerProvider);
    final next = !state.torchEnabled;

    await HapticFeedback.selectionClick();
    await controller.setFlashMode(next ? FlashMode.torch : FlashMode.off);
    scanController.setTorchEnabled(next);
  }

  Future<void> _capture() async {
    final controller = _cameraController;
    if (controller == null ||
        !controller.value.isInitialized ||
        _isProcessingCapture) {
      return;
    }

    setState(() {
      _isProcessingCapture = true;
      _flashOverlayVisible = true;
    });

    await HapticFeedback.lightImpact();

    try {
      await _stopImageStream();
      final file = await controller.takePicture();
      final bytes = await file.readAsBytes();

      final output =
          await ref.read(scanControllerProvider.notifier).processCapture(
                documentId: widget.documentId,
                jpegBytes: bytes,
              );

      if (mounted) {
        setState(() {
          _capturedPagesPreview = output.pages;
        });
      }

      final repository = ref.read(documentRepositoryProvider);
      await repository.addPage(widget.documentId, output);

      if (!mounted) {
        return;
      }

      final pageCount = output.pages.length;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Added $pageCount scanned page${pageCount > 1 ? 's' : ''}')),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Scan failed: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _flashOverlayVisible = false);
      }
      await Future<void>.delayed(const Duration(milliseconds: 120));
      if (mounted) {
        setState(() => _isProcessingCapture = false);
      }
      await _startImageStream();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _cameraController;
    final scanState = ref.watch(scanControllerProvider);

    if (_cameraError != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(_cameraError!, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    if (controller == null || !controller.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          _CameraPreviewLayer(
            controller: controller,
            scanState: scanState,
          ),
          AnimatedOpacity(
            opacity: _flashOverlayVisible ? 0.35 : 0.0,
            duration: const Duration(milliseconds: 120),
            child: Container(color: Colors.white),
          ),
          if (_isProcessingCapture)
            const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text('Processing pages...'),
                    ],
                  ),
                ),
              ),
            ),
          _TopStatusBar(scanState: scanState),
          if (_capturedPagesPreview.isNotEmpty)
            _CapturedPagesPreview(pages: _capturedPagesPreview),
          _BottomControlBar(
            autoMode: scanState.autoMode,
            flashOn: scanState.torchEnabled,
            isBusy: _isProcessingCapture,
            onAutoModeToggle: (enabled) =>
                ref.read(scanControllerProvider.notifier).setAutoMode(enabled),
            onFlashToggle: _toggleFlash,
            onDoneTap: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).maybePop();
            },
            onCaptureTap: _capture,
          ),
        ],
      ),
    );
  }
}

class _TopStatusBar extends StatelessWidget {
  const _TopStatusBar({required this.scanState});

  final ScanViewState scanState;

  @override
  Widget build(BuildContext context) {
    final isLocked = scanState.detectionStatus == DetectionStatus.locked;
    final statusText = switch (scanState.detectionStatus) {
      DetectionStatus.notDetected => 'Align document in frame',
      DetectionStatus.adjusting => 'Hold steady… detecting edges',
      DetectionStatus.locked => 'Locked. Capturing automatically',
    };

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: AnimatedScale(
          scale: isLocked ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(12),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.15),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: Text(
                key: ValueKey<String>(
                    '${scanState.detectionStatus}:${scanState.confidence.toStringAsFixed(1)}:${scanState.stability.toStringAsFixed(1)}'),
                '$statusText  •  C:${scanState.confidence.toStringAsFixed(2)}  S:${scanState.stability.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CameraPreviewLayer extends StatelessWidget {
  const _CameraPreviewLayer({
    required this.controller,
    required this.scanState,
  });

  final CameraController controller;
  final ScanViewState scanState;

  @override
  Widget build(BuildContext context) {
    final previewSize = controller.value.previewSize;
    if (previewSize == null) {
      return CameraPreview(controller);
    }

    final orientation = MediaQuery.of(context).orientation;
    final isPortrait = orientation == Orientation.portrait;
    final previewWidth = isPortrait ? previewSize.height : previewSize.width;
    final previewHeight = isPortrait ? previewSize.width : previewSize.height;

    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        alignment: Alignment.center,
        child: SizedBox(
          width: previewWidth,
          height: previewHeight,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CameraPreview(controller),
              CustomPaint(
                painter: _ScanOverlayPainter(
                  rectangles: scanState.rectangles,
                  detectionStatus: scanState.detectionStatus,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomControlBar extends StatelessWidget {
  const _BottomControlBar({
    required this.autoMode,
    required this.flashOn,
    required this.isBusy,
    required this.onAutoModeToggle,
    required this.onFlashToggle,
    required this.onDoneTap,
    required this.onCaptureTap,
  });

  final bool autoMode;
  final bool flashOn;
  final bool isBusy;
  final ValueChanged<bool> onAutoModeToggle;
  final VoidCallback onFlashToggle;
  final VoidCallback onDoneTap;
  final VoidCallback onCaptureTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Text('Auto', style: TextStyle(color: Colors.white)),
                    Switch(
                      value: autoMode,
                      onChanged: isBusy
                          ? null
                          : (enabled) {
                              HapticFeedback.selectionClick();
                              onAutoModeToggle(enabled);
                            },
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(flashOn ? Icons.flash_on : Icons.flash_off,
                    color: Colors.white),
                onPressed: isBusy ? null : onFlashToggle,
              ),
              IconButton(
                icon: const Icon(Icons.check_rounded, color: Colors.white),
                onPressed: isBusy ? null : onDoneTap,
              ),
              const SizedBox(width: 8),
              AnimatedScale(
                scale: isBusy ? 0.96 : 1,
                duration: const Duration(milliseconds: 120),
                child: FloatingActionButton.small(
                  heroTag: 'capture_fab',
                  onPressed: isBusy
                      ? null
                      : () {
                          HapticFeedback.mediumImpact();
                          onCaptureTap();
                        },
                  child: const Icon(Icons.camera_alt),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CapturedPagesPreview extends StatelessWidget {
  const _CapturedPagesPreview({required this.pages});

  final List<ScannedPage> pages;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(left: 12, right: 12, bottom: 96),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(14),
          ),
          height: 116,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: pages.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final page = pages[index];
              return Container(
                width: 84,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: page.thumbnailJpegBytes == null
                          ? const ColoredBox(color: Colors.black12)
                          : Image.memory(page.thumbnailJpegBytes!,
                              fit: BoxFit.cover),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 3),
                      color: Colors.black87,
                      child: Text(
                        page.label,
                        textAlign: TextAlign.center,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ScanOverlayPainter extends CustomPainter {
  _ScanOverlayPainter(
      {required this.rectangles, required this.detectionStatus});

  final List<DetectedRectangle> rectangles;
  final DetectionStatus detectionStatus;

  @override
  void paint(Canvas canvas, Size size) {
    final color = switch (detectionStatus) {
      DetectionStatus.notDetected => Colors.redAccent,
      DetectionStatus.adjusting => Colors.yellowAccent,
      DetectionStatus.locked => Colors.greenAccent,
    };

    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (final rectangle in rectangles) {
      final points = rectangle.corners
          .map(
              (corner) => Offset(corner.x * size.width, corner.y * size.height))
          .toList(growable: false);
      if (points.length != 4) {
        continue;
      }

      final path = Path()
        ..moveTo(points[0].dx, points[0].dy)
        ..lineTo(points[1].dx, points[1].dy)
        ..lineTo(points[2].dx, points[2].dy)
        ..lineTo(points[3].dx, points[3].dy)
        ..close();

      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, borderPaint);

      final minX = points.map((p) => p.dx).reduce((a, b) => a < b ? a : b);
      final minY = points.map((p) => p.dy).reduce((a, b) => a < b ? a : b);

      textPainter.text = TextSpan(
        text: rectangle.label,
        style: TextStyle(
          color: Colors.black,
          backgroundColor: color.withValues(alpha: 0.85),
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(minX + 6, minY + 6));
    }
  }

  @override
  bool shouldRepaint(covariant _ScanOverlayPainter oldDelegate) {
    return oldDelegate.rectangles != rectangles ||
        oldDelegate.detectionStatus != detectionStatus;
  }
}
