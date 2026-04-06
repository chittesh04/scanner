import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartscan/features/document/presentation/document_list_controller.dart';
import 'package:smartscan/features/scan/presentation/scan_page.dart';
import 'package:smartscan_models/document.dart';

class PageManagementPage extends ConsumerStatefulWidget {
  const PageManagementPage({super.key, required this.documentId});

  final String documentId;

  @override
  ConsumerState<PageManagementPage> createState() => _PageManagementPageState();
}

class _PageManagementPageState extends ConsumerState<PageManagementPage> {
  bool _reordering = false;

  Future<void> _reorder(
      List<DocumentPage> pages, int oldIndex, int newIndex) async {
    if (_reordering) return;
    setState(() => _reordering = true);

    final mutable = [...pages];
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final moved = mutable.removeAt(oldIndex);
    mutable.insert(newIndex, moved);

    try {
      final orderedPageIds =
          mutable.map((page) => page.pageId).toList(growable: false);
      await ref.read(reorderDocumentPagesProvider)(
          widget.documentId, orderedPageIds);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not reorder pages: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _reordering = false);
      }
    }
  }

  Future<void> _deletePage(DocumentPage page) async {
    try {
      await ref.read(deleteDocumentPageProvider)(
        widget.documentId,
        page.pageId,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete page: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final docAsync = ref.watch(documentProvider(widget.documentId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Pages'),
        actions: [
          IconButton(
            tooltip: 'Add page',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ScanPage(documentId: widget.documentId),
                ),
              );
            },
            icon: const Icon(Icons.add_a_photo_rounded),
          ),
        ],
      ),
      body: docAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Failed to load pages: $error')),
        data: (doc) {
          if (doc == null || doc.pages.isEmpty) {
            return const Center(child: Text('No pages available.'));
          }

          return ReorderableListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: doc.pages.length,
            onReorder: (oldIndex, newIndex) =>
                _reorder(doc.pages, oldIndex, newIndex),
            itemBuilder: (context, index) {
              final page = doc.pages[index];
              return Card(
                key: ValueKey(page.pageId),
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text('Page ${page.order + 1}'),
                  subtitle: Text(
                    page.ocrText?.trim().isNotEmpty == true
                        ? 'Text available'
                        : 'No OCR text',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline_rounded),
                    onPressed:
                        doc.pages.length <= 1 ? null : () => _deletePage(page),
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar:
          _reordering ? const LinearProgressIndicator(minHeight: 2) : null,
    );
  }
}
