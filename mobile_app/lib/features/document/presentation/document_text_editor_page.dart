import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartscan/features/document/presentation/document_list_controller.dart';
import 'package:smartscan_models/document.dart';

class DocumentTextEditorPage extends ConsumerStatefulWidget {
  const DocumentTextEditorPage({super.key, required this.documentId});

  final String documentId;

  @override
  ConsumerState<DocumentTextEditorPage> createState() =>
      _DocumentTextEditorPageState();
}

class _DocumentTextEditorPageState
    extends ConsumerState<DocumentTextEditorPage> {
  final Map<String, TextEditingController> _controllers =
      <String, TextEditingController>{};
  final Map<String, String> _initialValues = <String, String>{};
  bool _saving = false;

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _syncControllers(Document doc) {
    for (final page in doc.pages) {
      final current = page.ocrText ?? '';
      _controllers.putIfAbsent(
          page.pageId, () => TextEditingController(text: current));
      _initialValues.putIfAbsent(page.pageId, () => current);
    }
  }

  Future<void> _save(Document doc) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final updateText = ref.read(updateDocumentPageTextProvider);
      for (final page in doc.pages) {
        final controller = _controllers[page.pageId];
        final updated = controller?.text ?? '';
        final original = _initialValues[page.pageId] ?? '';
        if (updated.trim() != original.trim()) {
          await updateText(widget.documentId, page.pageId, updated);
          _initialValues[page.pageId] = updated;
        }
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Text changes saved')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save text: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final docAsync = ref.watch(documentProvider(widget.documentId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Extracted Text'),
        actions: [
          TextButton.icon(
            onPressed: _saving
                ? null
                : () async {
                    final doc = await ref
                        .read(documentProvider(widget.documentId).future);
                    if (doc == null) return;
                    await _save(doc);
                  },
            icon: _saving
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_rounded),
            label: const Text('Save'),
          ),
        ],
      ),
      body: docAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Failed to load text: $error')),
        data: (doc) {
          if (doc == null) {
            return const Center(child: Text('Document not found'));
          }
          if (doc.pages.isEmpty) {
            return const Center(child: Text('No pages available'));
          }

          _syncControllers(doc);

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: doc.pages.length,
            itemBuilder: (context, index) {
              final page = doc.pages[index];
              final controller = _controllers[page.pageId]!;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Page ${page.order + 1}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: controller,
                        minLines: 4,
                        maxLines: 14,
                        textInputAction: TextInputAction.newline,
                        decoration: const InputDecoration(
                          hintText: 'No extracted text yet. Enter manually...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
