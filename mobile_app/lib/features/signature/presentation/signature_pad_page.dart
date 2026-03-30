import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartscan/core/di/service_locator.dart';

class SignaturePadPage extends ConsumerStatefulWidget {
  const SignaturePadPage({super.key});

  @override
  ConsumerState<SignaturePadPage> createState() => _SignaturePadPageState();
}

class _SignaturePadPageState extends ConsumerState<SignaturePadPage> {
  final _strokes = <List<Offset>>[];
  List<Offset>? _currentStroke;
  Size _canvasSize = Size.zero;

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _currentStroke = [details.localPosition];
      _strokes.add(_currentStroke!);
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _currentStroke?.add(details.localPosition);
    });
  }

  void _clear() {
    HapticFeedback.selectionClick();
    setState(() {
      _strokes.clear();
      _currentStroke = null;
    });
  }

  Future<void> _save() async {
    if (_strokes.isEmpty) return;
    HapticFeedback.lightImpact();

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    if (_canvasSize.width > 0 && _canvasSize.height > 0) {
      canvas.scale(800 / _canvasSize.width, 400 / _canvasSize.height);
    }

    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final stroke in _strokes) {
      if (stroke.isEmpty) continue;
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (var i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }

    final pic = recorder.endRecording();
    final img = await pic.toImage(800, 400); // Export ratio
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;

    final bytes = byteData.buffer.asUint8List();
    
    // Save via repository
    await ref.read(signatureRepositoryProvider).saveSignature(bytes);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signature saved successfully.')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Signature'),
        actions: [
          IconButton(
            tooltip: 'Clear',
            icon: const Icon(Icons.clear_all_rounded), 
            onPressed: _clear,
          ),
          IconButton(
            tooltip: 'Save',
            icon: const Icon(Icons.check_rounded), 
            onPressed: _save,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: Text(
                'Draw your signature below.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            AspectRatio(
              aspectRatio: 2.0,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white, // Draw on an explicitly white canvas
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      _canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
                      return GestureDetector(
                        onPanStart: _onPanStart,
                        onPanUpdate: _onPanUpdate,
                        child: CustomPaint(
                          painter: _SignaturePainter(_strokes),
                          size: Size.infinite,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  _SignaturePainter(this.strokes);
  final List<List<Offset>> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final stroke in strokes) {
      if (stroke.isEmpty) continue;
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (var i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}
