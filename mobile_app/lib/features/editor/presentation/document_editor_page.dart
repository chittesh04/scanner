import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartscan_models/document.dart';
import 'package:smartscan/core/di/service_locator.dart';
import 'package:smartscan/core/logging/app_logger.dart';
import 'package:smartscan/core/storage/encrypted_image.dart';

class DocumentEditorPage extends ConsumerStatefulWidget {
  const DocumentEditorPage({
    super.key,
    required this.documentId,
    required this.page,
  });

  final String documentId;
  final DocumentPage page;

  @override
  ConsumerState<DocumentEditorPage> createState() => _DocumentEditorPageState();
}

class _DocumentEditorPageState extends ConsumerState<DocumentEditorPage> {
  bool _hasSignature = false;
  bool _saving = false;
  double _x = 0.5;
  double _y = 0.5;
  double _scale = 1.0;

  ImageProvider? _signatureImage;

  @override
  void initState() {
    super.initState();
    _hasSignature = widget.page.hasSignature;
    _x = widget.page.signatureX ?? 0.5;
    _y = widget.page.signatureY ?? 0.5;
    _scale = widget.page.signatureScale ?? 1.0;
    _loadSignature();
  }

  Future<void> _loadSignature() async {
    try {
      final bytes = await ref.read(signatureRepositoryProvider).loadSignature();
      if (bytes != null && mounted) {
        setState(() => _signatureImage = MemoryImage(bytes));
      }
    } catch (error, stackTrace) {
      AppLogger.error(
        'signature',
        'Failed to load signature in editor',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load signature: $error')),
      );
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final repo = ref.read(documentRepositoryProvider);
      if (_hasSignature) {
        await repo.updatePageSignature(
          widget.documentId,
          widget.page.pageId,
          _x,
          _y,
          _scale,
        );
      } else {
        await repo.removePageSignature(widget.documentId, widget.page.pageId);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save signature placement: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final signatureImage = _signatureImage;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Signature'),
        actions: [
          IconButton(
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          LayoutBuilder(builder: (context, constraints) {
            final imgRatio = widget.page.imageWidth / widget.page.imageHeight;
            final viewRatio = constraints.maxWidth / constraints.maxHeight;

            double renderWidth, renderHeight;
            if (imgRatio > viewRatio) {
              renderWidth = constraints.maxWidth;
              renderHeight = constraints.maxWidth / imgRatio;
            } else {
              renderHeight = constraints.maxHeight;
              renderWidth = constraints.maxHeight * imgRatio;
            }

            return Center(
                child: SizedBox(
                    width: renderWidth,
                    height: renderHeight,
                    child: Stack(children: [
                      EncryptedImage(
                          imagePath: widget.page.processedImagePath,
                          fit: BoxFit.fill),
                      if (_hasSignature && signatureImage != null)
                        Positioned(
                          left: _x * renderWidth,
                          top: _y * renderHeight,
                          child: GestureDetector(
                            onPanUpdate: (details) {
                              setState(() {
                                _x = (_x + details.delta.dx / renderWidth)
                                    .clamp(0.0, 1.0);
                                _y = (_y + details.delta.dy / renderHeight)
                                    .clamp(0.0, 1.0);
                              });
                            },
                            child: Transform.scale(
                              scale: _scale,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.blueAccent, width: 2),
                                ),
                                child: Image(
                                    image: signatureImage,
                                    width: renderWidth * 0.25),
                              ),
                            ),
                          ),
                        )
                    ])));
          }),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Container(
                color: Colors.black87,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Show Signature',
                            style:
                                TextStyle(color: Colors.white, fontSize: 13)),
                        value: _hasSignature,
                        onChanged: (val) {
                          if (_signatureImage == null && val) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'No signature found. Please create one on the Home Screen first.')));
                            return;
                          }
                          setState(() => _hasSignature = val);
                        },
                      ),
                    ),
                    if (_hasSignature)
                      Expanded(
                        child: Slider(
                          value: _scale,
                          min: 0.2,
                          max: 3.0,
                          onChanged: (val) => setState(() => _scale = val),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
