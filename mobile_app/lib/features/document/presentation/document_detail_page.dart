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

  // Cached signature bytes — loaded once, passed to children.
  Uint8List? _signatureBytes;
  bool _signatureLoaded = false;

  // Inline title editing state.
  bool _editingTitle = false;
  final _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _docStream = ref.read(documentRepositoryProvider).watchDocument(widget.documentId);
    _loadSignature();
  }

  Future<void> _loadSignature() async {
    final bytes = await ref.read(signatureRepositoryProvider).loadSignature();
    if (mounted) {
      setState(() {
        _signatureBytes = bytes;
        _signatureLoaded = true;
      });
    }
  }

  @override
  void didUpdateWidget(DocumentDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.documentId != widget.documentId) {
      _docStream = ref.read(documentRepositoryProvider).watchDocument(widget.documentId);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(documentRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: _editingTitle
            ? TextField(
                controller: _titleController,
                autofocus: true,
                style: Theme.of(context).textTheme.titleLarge,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Document title',
                ),
                onSubmitted: _saveTitle,
              )
            : StreamBuilder<Document?>(
                stream: _docStream,
                builder: (context, snapshot) {
                  final title = snapshot.data?.title ?? 'Document';
                  return GestureDetector(
                    onTap: () {
                      _titleController.text = title;
                      setState(() => _editingTitle = true);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.edit_rounded,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  );
                },
              ),
        actions: [
          if (_editingTitle)
            IconButton(
              icon: const Icon(Icons.check_rounded),
              onPressed: () => _saveTitle(_titleController.text),
            ),
          if (!_editingTitle) ...[
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'collection') _showAssignCollectionSheet();
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
              onPressed: _exporting ? null : () => _showExportMenu(context),
            ),
          ],
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
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AspectRatio(
                          aspectRatio: page.imageWidth > 0 && page.imageHeight > 0 
                              ? page.imageWidth / page.imageHeight 
                              : 0.75,
                          child: index == 0
                              ? Hero(
                                  tag: 'document_image_${widget.documentId}',
                                  child: _PageImageWithSignature(
                                    page: page,
                                    signatureBytes: _signatureBytes,
                                    signatureLoaded: _signatureLoaded,
                                  ),
                                )
                              : _PageImageWithSignature(
                                  page: page,
                                  signatureBytes: _signatureBytes,
                                  signatureLoaded: _signatureLoaded,
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
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
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
                                              if (!context.mounted) return;
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'OCR complete for Page ${page.order + 1}'),
                                                ),
                                              );
                                            } catch (e) {
                                              if (!context.mounted) return;
                                              ScaffoldMessenger.of(context)
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
                                  // Delete page button
                                  if (doc.pages.length > 1)
                                    FilledButton.tonalIcon(
                                      onPressed: () => _confirmDeletePage(
                                          doc, page),
                                      icon: const Icon(Icons.delete_outline_rounded,
                                          size: 18),
                                      label: const Text('Delete'),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
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

  Future<void> _saveTitle(String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      setState(() => _editingTitle = false);
      return;
    }
    await ref.read(documentRepositoryProvider).updateTitle(
          widget.documentId,
          trimmed,
        );
    if (mounted) setState(() => _editingTitle = false);
  }

  Future<void> _confirmDeletePage(Document doc, DocumentPage page) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Page?'),
        content: Text('Remove Page ${page.order + 1} permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    await HapticFeedback.lightImpact();
    await ref
        .read(documentRepositoryProvider)
        .deletePage(widget.documentId, page.pageId);
  }

  // ─────────────────── Export ───────────────────

  Future<void> _showExportMenu(BuildContext context) async {
    final format = await showModalBottomSheet<ExportFormat>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Export As',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_rounded),
              title: const Text('PDF'),
              subtitle: const Text('Searchable PDF with invisible OCR text'),
              onTap: () => Navigator.pop(context, ExportFormat.pdf),
            ),
            ListTile(
              leading: const Icon(Icons.description_rounded),
              title: const Text('DOCX'),
              subtitle: const Text('Word document with images and text'),
              onTap: () => Navigator.pop(context, ExportFormat.docx),
            ),
            ListTile(
              leading: const Icon(Icons.table_chart_rounded),
              title: const Text('XLSX'),
              subtitle: const Text('Spreadsheet from detected tables'),
              onTap: () => Navigator.pop(context, ExportFormat.xlsx),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );

    if (format == null || !context.mounted) return;

    switch (format) {
      case ExportFormat.pdf:
        await _exportPdf(context);
      case ExportFormat.docx:
        await _exportDocx(context);
      case ExportFormat.xlsx:
        await _exportXlsx(context);
    }
  }

  Future<ExportRequest?> _buildExportRequest() async {
    final repo = ref.read(documentRepositoryProvider);
    final doc = await repo.watchDocument(widget.documentId).first;
    if (doc == null || doc.pages.isEmpty) return null;

    return ExportRequest(
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
  }

  Future<void> _exportPdf(BuildContext context) async {
    await HapticFeedback.lightImpact();
    setState(() => _exporting = true);
    try {
      final request = await _buildExportRequest();
      if (request == null || !context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generating PDF...')),
      );

      final file = await ref.read(pdfExportProvider).export(request);

      if (!context.mounted) return;
      await Share.shareXFiles([XFile(file.path)],
          text: 'Exported Document: ${request.title}');
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _exportDocx(BuildContext context) async {
    await HapticFeedback.lightImpact();
    setState(() => _exporting = true);
    try {
      final request = await _buildExportRequest();
      if (request == null || !context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generating DOCX...')),
      );

      final file = await ref.read(docxExportProvider).export(request);

      if (!context.mounted) return;
      await Share.shareXFiles([XFile(file.path)],
          text: 'Exported Document: ${request.title}');
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _exportXlsx(BuildContext context) async {
    await HapticFeedback.lightImpact();
    setState(() => _exporting = true);
    try {
      final request = await _buildExportRequest();
      if (request == null || !context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generating XLSX...')),
      );

      final file = await ref.read(xlsxExportProvider).export(request);

      if (!context.mounted) return;
      await Share.shareXFiles([XFile(file.path)],
          text: 'Exported Document: ${request.title}');
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  // ─────────────────── Collection Assignment ───────────────────

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
            return SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Padding(
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
                  ),
                ),
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

// ─────────────────── Page Image Widget ───────────────────

class _PageImageWithSignature extends StatelessWidget {
  const _PageImageWithSignature({
    required this.page,
    required this.signatureBytes,
    required this.signatureLoaded,
  });

  final DocumentPage page;
  final Uint8List? signatureBytes;
  final bool signatureLoaded;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          fit: StackFit.expand,
          children: [
            EncryptedImage(
              imagePath: page.processedImagePath,
              fit: BoxFit.fill,
            ),
            if (page.hasSignature && signatureLoaded && signatureBytes != null)
              Positioned(
                left: (page.signatureX ?? 0.5) * constraints.maxWidth,
                top: (page.signatureY ?? 0.5) * constraints.maxHeight,
                child: Transform.scale(
                  scale: page.signatureScale ?? 1.0,
                  child: Image.memory(
                    signatureBytes!,
                    width: constraints.maxWidth * 0.25,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
