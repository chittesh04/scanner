import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartscan/core/di/service_locator.dart';
import 'package:smartscan/core/logging/app_logger.dart';
import 'package:smartscan/core/storage/encrypted_image.dart';
import 'package:smartscan/features/document/presentation/document_detail_page.dart';
import 'package:smartscan/features/document/presentation/document_list_controller.dart';
import 'package:smartscan/features/export/presentation/export_helpers.dart';
import 'package:smartscan_models/document.dart';

class CollectionDetailPage extends ConsumerStatefulWidget {
  const CollectionDetailPage({
    super.key,
    required this.collectionId,
    required this.collectionName,
  });

  final String collectionId;
  final String collectionName;

  @override
  ConsumerState<CollectionDetailPage> createState() =>
      _CollectionDetailPageState();
}

class _CollectionDetailPageState extends ConsumerState<CollectionDetailPage> {
  bool _exporting = false;

  Future<void> _exportCollectionZip() async {
    if (_exporting) return;
    setState(() => _exporting = true);
    try {
      await HapticFeedback.lightImpact();
      final summaries = await ref
          .read(documentsByCollectionProvider(widget.collectionId).future);
      final docs = await Future.wait(
        summaries.map(
            (summary) => ref.read(documentProvider(summary.documentId).future)),
      );
      final existingDocs = docs.whereType<Document>().toList(growable: false);
      if (existingDocs.isEmpty || !mounted) {
        return;
      }

      final delivery = await promptForExportDelivery(
        context,
        title: 'Export collection',
      );
      if (delivery == null || !mounted) return;

      final outputPath = await promptForExportPath(
        context,
        extension: 'zip',
        currentTitle: widget.collectionName,
        delivery: delivery,
      );
      if (outputPath == null || !mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generating ZIP...')),
      );

      final file = await ref.read(zipExportProvider).exportDocuments(
            existingDocs,
            outputPath: outputPath,
            archiveName: widget.collectionName,
          );
      if (!mounted) return;
      await handleExportedFile(
        context,
        file,
        widget.collectionName,
        delivery,
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'collection',
        'Failed to export collection ${widget.collectionId}',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not export collection: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _exporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final docsAsync =
        ref.watch(documentsByCollectionProvider(widget.collectionId));
    final screenWidth = MediaQuery.sizeOf(context).width;
    final crossAxisCount = (screenWidth / 180).floor().clamp(2, 8);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.collectionName),
        actions: [
          IconButton(
            tooltip: 'Export collection ZIP',
            onPressed: _exporting ? null : _exportCollectionZip,
            icon: _exporting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.folder_zip_rounded),
          ),
        ],
      ),
      body: docsAsync.when(
        data: (docs) {
          if (docs.isEmpty) {
            return const Center(
              child: Text('No documents in this collection yet.'),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.78,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final document = docs[index];
              final imagePath = document.thumbnailImagePath;
              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            DocumentDetailPage(documentId: document.documentId),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: imagePath == null
                            ? const ColoredBox(color: Colors.black12)
                            : EncryptedImage(
                                imagePath: imagePath,
                                fit: BoxFit.cover,
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              document.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${document.pageCount} pages',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('Failed to load collection: $error'),
        ),
      ),
    );
  }
}
