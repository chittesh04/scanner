import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartscan/core/storage/encrypted_image.dart';
import 'package:smartscan/features/document/presentation/document_detail_page.dart';
import 'package:smartscan/features/document/presentation/document_list_controller.dart';

class CollectionDetailPage extends ConsumerWidget {
  const CollectionDetailPage({
    super.key,
    required this.collectionId,
    required this.collectionName,
  });

  final String collectionId;
  final String collectionName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docsAsync = ref.watch(documentsByCollectionProvider(collectionId));

    return Scaffold(
      appBar: AppBar(title: Text(collectionName)),
      body: docsAsync.when(
        data: (docs) {
          if (docs.isEmpty) {
            return const Center(
              child: Text('No documents in this collection yet.'),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.78,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final document = docs[index];
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
                        child: document.pages.isEmpty
                            ? const ColoredBox(color: Colors.black12)
                            : EncryptedImage(
                                imagePath:
                                    document.pages.first.processedImagePath,
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
                              '${document.pages.length} pages',
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
