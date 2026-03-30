// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartscan/core/di/service_locator.dart';
import 'package:smartscan/features/document/presentation/document_list_controller.dart';
import 'package:smartscan/features/scan/presentation/scan_page.dart';
import 'package:smartscan/features/export/domain/export_models.dart';
import 'package:smartscan/core/storage/encrypted_image.dart';
import 'package:smartscan/features/editor/presentation/document_editor_page.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smartscan_models/document.dart';

class DocumentDetailPage extends ConsumerStatefulWidget {
  const DocumentDetailPage({super.key, required this.documentId});

  final String documentId;

  @override
  ConsumerState<DocumentDetailPage> createState() => _DocumentDetailPageState();
}

class _DocumentDetailPageState extends ConsumerState<DocumentDetailPage> {
  bool _exporting = false;
  final Set<String> _ocrLoadingPageIds = <String>{};
  late Stream<Document?> _docStream;

  @override
  void initState() {
    super.initState();
    _docStream = ref.read(documentRepositoryProvider).watchDocument(widget.documentId);
  }

  @override
  void didUpdateWidget(DocumentDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.documentId != widget.documentId) {
      _docStream = ref.read(documentRepositoryProvider).watchDocument(widget.documentId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(documentRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Document'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'collection') {
                _showAssignCollectionSheet();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem<String>(
                value: 'collection',
                child: Row(
                  children: [
                    Icon(Icons.folder_open_rounded),
                    SizedBox(width: 8),
                    Text('Add to Collection'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              ),
              child: _exporting
                  ? const SizedBox(
                      key: ValueKey('export-loading'),
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(
                      Icons.file_download_rounded,
                      key: ValueKey('export-icon'),
                    ),
            ),
            onPressed: _exporting ? null : () => _exportPdf(context),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _docStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final doc = snapshot.data;
          if (doc == null) {
            return const Center(child: Text('Document not found'));
          }

          if (doc.pages.isEmpty) {
            return const Center(child: Text('No pages in this document'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: doc.pages.length,
            itemBuilder: (context, index) {
              final page = doc.pages[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: index == 0
                          ? Hero(
                              tag: 'document_image_${widget.documentId}',
                              child: EncryptedImage(
                                imagePath: page.processedImagePath,
                                fit: BoxFit.cover,
                              ),
                            )
                          : EncryptedImage(
                              imagePath: page.processedImagePath,
                              fit: BoxFit.cover,
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Page ${page.order + 1}',
                              style: Theme.of(context).textTheme.titleMedium),
                          if (page.ocrText != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              page.ocrText!,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              FilledButton.tonalIcon(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => DocumentEditorPage(
                                        documentId: widget.documentId,
                                        page: page,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.draw_rounded, size: 18),
                                label: const Text('Sign'),
                              ),
                              const SizedBox(width: 8),
                              FilledButton.tonalIcon(
                                onPressed: _ocrLoadingPageIds
                                        .contains(page.pageId)
                                    ? null
                                    : () async {
                                        await HapticFeedback.selectionClick();
                                        setState(() {
                                          _ocrLoadingPageIds.add(page.pageId);
                                        });
                                        try {
                                          await repo.performOcr(
                                              widget.documentId, page.pageId);
                                          if (!mounted) return;
                                          ScaffoldMessenger.of(this.context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'OCR complete for Page ${page.order + 1}'),
                                            ),
                                          );
                                        } catch (e) {
                                          if (!mounted) return;
                                          ScaffoldMessenger.of(this.context)
                                              .showSnackBar(
                                            SnackBar(
                                                content:
                                                    Text('OCR failed: $e')),
                                          );
                                        } finally {
                                          if (mounted) {
                                            setState(() {
                                              _ocrLoadingPageIds
                                                  .remove(page.pageId);
                                            });
                                          }
                                        }
                                      },
                                icon: _ocrLoadingPageIds.contains(page.pageId)
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    : const Icon(Icons.auto_awesome_rounded,
                                        size: 18),
                                label: const Text('Run OCR'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.selectionClick();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ScanPage(documentId: widget.documentId),
            ),
          );
        },
        child: const Icon(Icons.document_scanner_rounded),
      ),
    );
  }

  Future<void> _exportPdf(BuildContext context) async {
    await HapticFeedback.lightImpact();
    setState(() => _exporting = true);
    final repo = ref.read(documentRepositoryProvider);
    final exportService = ref.read(pdfExportProvider);
    try {
      final doc = await repo.watchDocument(widget.documentId).first;
      if (doc == null || doc.pages.isEmpty || !context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generating PDF...')),
      );

      final request = ExportRequest(
        documentId: widget.documentId,
        title: doc.title,
        pages: doc.pages.map((p) => PageExportData(
          imagePath: p.processedImagePath,
          imageWidth: p.imageWidth,
          imageHeight: p.imageHeight,
          ocrBlocks: p.ocrBlocks.map((b) => ExportOcrBlock(
            text: b.text,
            left: b.left,
            top: b.top,
            right: b.right,
            bottom: b.bottom,
          )).toList(),
          ocrText: p.ocrText ?? '',
          signature: p.hasSignature
              ? PageSignature(x: p.signatureX ?? 0.5, y: p.signatureY ?? 0.5, scale: p.signatureScale ?? 1.0)
              : null,
        )).toList(),
      );

      final file = await exportService.export(request);

      if (!context.mounted) return;
      await Share.shareXFiles([XFile(file.path)],
          text: 'Exported Document: ${doc.title}');
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _exporting = false);
      }
    }
  }

  Future<void> _showAssignCollectionSheet() async {
    final collections = await ref.read(documentCollectionsProvider.future);
    final current = await ref
        .read(documentRepositoryProvider)
        .watchDocument(widget.documentId)
        .first;
    if (!mounted || current == null) {
      return;
    }

    String? selectedCollectionId = current.collectionId;

    final result = await showModalBottomSheet<Map<String, Object?>>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Add to Collection',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 8),
                  RadioListTile<String?>(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('No collection'),
                    value: null,
                    groupValue: selectedCollectionId,
                    onChanged: (value) => setSheetState(() {
                      selectedCollectionId = value;
                    }),
                  ),
                  ...collections.map(
                    (collection) => RadioListTile<String?>(
                      contentPadding: EdgeInsets.zero,
                      title: Text(collection.name),
                      value: collection.collectionId,
                      groupValue: selectedCollectionId,
                      onChanged: (value) => setSheetState(() {
                        selectedCollectionId = value;
                      }),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(
                        <String, Object?>{
                          'saved': true,
                          'collectionId': selectedCollectionId,
                        },
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (result == null || result['saved'] != true) {
      return;
    }

    await ref.read(assignDocumentCollectionProvider)(
      widget.documentId,
      result['collectionId'] as String?,
    );
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Collection updated')),
    );
  }
}
