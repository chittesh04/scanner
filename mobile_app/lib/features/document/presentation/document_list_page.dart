import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smartscan/core/di/service_locator.dart';
import 'package:smartscan/core/logging/app_logger.dart';
import 'package:smartscan/core/storage/encrypted_image.dart';
import 'package:smartscan/core/widgets/text_value_dialog.dart';
import 'package:smartscan/features/document/presentation/collection_detail_page.dart';
import 'package:smartscan/features/document/presentation/document_detail_page.dart';
import 'package:smartscan/features/document/presentation/document_list_controller.dart';
import 'package:smartscan/features/scan/presentation/scan_page.dart';
import 'package:smartscan_models/document.dart';
import 'package:smartscan_models/document_collection.dart';
import 'package:smartscan_models/document_summary.dart';
import 'package:smartscan/features/signature/presentation/signature_pad_page.dart';

const double _space2 = 8;
const double _space3 = 12;
const double _space4 = 16;

class DocumentListPage extends ConsumerStatefulWidget {
  const DocumentListPage({super.key});

  @override
  ConsumerState<DocumentListPage> createState() => _DocumentListPageState();
}

class _DocumentListPageState extends ConsumerState<DocumentListPage> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedDocumentIds = <String>{};
  bool _actionInProgress = false;

  bool get _multiSelectMode => _selectedDocumentIds.isNotEmpty;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _guardedAction(Future<void> Function() action) async {
    if (_actionInProgress) {
      return;
    }
    _actionInProgress = true;
    try {
      await action();
    } catch (error) {
      _showError('Action failed: $error');
    } finally {
      _actionInProgress = false;
    }
  }

  Future<void> _createAndScan() async {
    await _guardedAction(() async {
      await HapticFeedback.mediumImpact();
      final documentName = await _promptForDocumentName();
      if (!mounted || documentName == null) {
        return;
      }
      final docId = await ref.read(createDocumentProvider)(
        documentName,
      );
      if (!mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ScanPage(documentId: docId)),
      );
    });
  }

  Future<void> _toggleStar(String documentId, bool isStarred) async {
    await _guardedAction(() async {
      await HapticFeedback.selectionClick();
      await ref.read(toggleStarredProvider)(documentId, !isStarred);
    });
  }

  Future<void> _deleteDocument(String documentId) async {
    await _guardedAction(() async {
      await HapticFeedback.lightImpact();
      await ref.read(deleteDocumentsProvider)([documentId]);
      _selectedDocumentIds.remove(documentId);
      if (mounted) setState(() {});
    });
  }

  Future<void> _deleteSelected() async {
    if (_selectedDocumentIds.isEmpty) return;
    await _guardedAction(() async {
      await HapticFeedback.heavyImpact();
      final ids = _selectedDocumentIds.toList(growable: false);
      await ref.read(deleteDocumentsProvider)(ids);
      if (!mounted) return;
      setState(_selectedDocumentIds.clear);
    });
  }

  Future<void> _exportSelectedAsZip() async {
    if (_selectedDocumentIds.isEmpty) return;
    await _guardedAction(() async {
      await HapticFeedback.lightImpact();
      final ids = _selectedDocumentIds.toList(growable: false);
      final docs = await Future.wait(
        ids.map((id) => ref.read(documentProvider(id).future)),
      );
      final existingDocs = docs.whereType<Document>().toList(growable: false);
      if (existingDocs.isEmpty) {
        _showError('No documents available to export.');
        return;
      }

      final file =
          await ref.read(zipExportProvider).exportDocuments(existingDocs);
      if (!mounted) return;
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'SmartScan export (${existingDocs.length} documents)',
      );
    });
  }

  Future<void> _createCollection() async {
    final result = await showTextValueDialog(
      context,
      title: 'New Collection',
      confirmLabel: 'Create',
      hintText: 'Collection name',
    );

    final name = result?.trim() ?? '';
    if (name.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Collection name is required')),
      );
      return;
    }

    try {
      await HapticFeedback.selectionClick();
      await ref.read(createCollectionProvider)(name);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Collection "$name" ready')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not create collection: $error')),
      );
    }
  }

  Future<String?> _promptForDocumentName() async {
    final result = await showTextValueDialog(
      context,
      title: 'Document Name',
      confirmLabel: 'Continue',
      initialValue:
          'Document ${DateTime.now().toIso8601String().substring(0, 16)}',
      hintText: 'File name',
    );

    final name = result?.trim();
    if (name == null || name.isEmpty) {
      return null;
    }
    return name;
  }

  Future<void> _renameCollection(DocumentCollection collection) async {
    final result = await showTextValueDialog(
      context,
      title: 'Rename Collection',
      confirmLabel: 'Save',
      initialValue: collection.name,
      hintText: 'Collection name',
    );

    final name = result?.trim() ?? '';
    if (name.isEmpty || name == collection.name) return;

    try {
      await ref.read(renameCollectionProvider)(collection.collectionId, name);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Collection renamed')),
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'collection',
        'Failed to rename collection ${collection.collectionId}',
        error: error,
        stackTrace: stackTrace,
      );
      _showError('Could not rename collection: $error');
    }
  }

  Future<void> _deleteCollection(DocumentCollection collection) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Collection?'),
        content: Text(
          '"${collection.name}" will be removed. Documents stay in Inbox.',
        ),
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

    if (confirmed != true) return;
    try {
      await ref.read(deleteCollectionProvider)(collection.collectionId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Collection deleted')),
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'collection',
        'Failed to delete collection ${collection.collectionId}',
        error: error,
        stackTrace: stackTrace,
      );
      _showError('Could not delete collection: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredDocs = ref.watch(filteredDocumentsProvider);
    final recentDocs = ref.watch(recentDocumentsProvider);
    final collections = ref.watch(documentCollectionsProvider);
    final docsAsync = ref.watch(documentListProvider);
    final collectionCounts = docsAsync.maybeWhen(
      data: (docs) {
        final counts = <String, int>{};
        for (final document in docs) {
          final collectionId = document.collectionId;
          if (collectionId == null || collectionId.isEmpty) {
            continue;
          }
          counts.update(collectionId, (value) => value + 1, ifAbsent: () => 1);
        }
        return counts;
      },
      orElse: () => const <String, int>{},
    );

    final screenWidth = MediaQuery.sizeOf(context).width;
    final int docCrossAxisCount = (screenWidth / 180).floor().clamp(2, 8);
    final int colCrossAxisCount = (screenWidth / 200).floor().clamp(2, 8);

    return Scaffold(
      appBar: AppBar(
        title: _multiSelectMode
            ? Text('${_selectedDocumentIds.length} selected')
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/logo.png',
                      width: 24,
                      height: 24,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('SmartScan'),
                ],
              ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: Theme.of(context)
                .colorScheme
                .outlineVariant
                .withValues(alpha: 0.25),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Create Signature',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SignaturePadPage()),
              );
            },
            icon: const Icon(Icons.draw_rounded),
          ),
          IconButton(
            tooltip: 'Create collection',
            onPressed: _createCollection,
            icon: const Icon(Icons.create_new_folder_rounded),
          ),
          if (_multiSelectMode)
            IconButton(
              tooltip: 'Export selected ZIP',
              onPressed: _exportSelectedAsZip,
              icon: const Icon(Icons.folder_zip_rounded),
            ),
          if (_multiSelectMode)
            IconButton(
              tooltip: 'Delete selected',
              onPressed: _deleteSelected,
              icon: const Icon(Icons.delete_sweep_rounded),
            ),
          if (_multiSelectMode)
            IconButton(
              tooltip: 'Clear selection',
              onPressed: () => setState(_selectedDocumentIds.clear),
              icon: const Icon(Icons.close_rounded),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _actionInProgress ? null : _createAndScan,
        icon: const Icon(Icons.document_scanner_rounded),
        label: const Text('Scan'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate.fixed([
                _HeroHeader(searchController: _searchController),
                const SizedBox(height: 16),
                const _SectionTitle(
                  title: 'Inbox',
                  subtitle: 'Unclassified scans waiting to be organized',
                ),
                const SizedBox(height: 10),
                ref.watch(inboxDocumentsProvider).when(
                      data: (docs) => _RecentCarousel(
                        documents: docs,
                        emptyMessage: 'Inbox is clean.',
                        onOpen: (documentId) {
                          HapticFeedback.selectionClick();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  DocumentDetailPage(documentId: documentId),
                            ),
                          );
                        },
                      ),
                      loading: () => const _HorizontalSkeletonRow(height: 112),
                      error: (error, _) => const SizedBox.shrink(),
                    ),
                const SizedBox(height: 18),
                const _SectionTitle(
                  title: 'Recent',
                  subtitle: 'Quick access to your latest captures',
                ),
                const SizedBox(height: 10),
                recentDocs.when(
                  data: (docs) => _RecentCarousel(
                    documents: docs,
                    onOpen: (documentId) {
                      HapticFeedback.selectionClick();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              DocumentDetailPage(documentId: documentId),
                        ),
                      );
                    },
                  ),
                  loading: () => const _HorizontalSkeletonRow(height: 112),
                  error: (error, _) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 18),
                const _SectionTitle(
                  title: 'Collections',
                  subtitle: 'Smart views for your workspace',
                ),
                const SizedBox(height: 10),
                collections.when(
                  data: (items) {
                    if (items.isEmpty) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          onPressed: _createCollection,
                          icon: const Icon(Icons.create_new_folder_rounded),
                          label: const Text('Create your first collection'),
                        ),
                      );
                    }

                    return _CollectionGrid(
                      collections: items,
                      counts: collectionCounts,
                      crossAxisCount: colCrossAxisCount,
                      onTap: (collection) {
                        HapticFeedback.selectionClick();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CollectionDetailPage(
                              collectionId: collection.collectionId,
                              collectionName: collection.name,
                            ),
                          ),
                        );
                      },
                      onRename: _renameCollection,
                      onDelete: _deleteCollection,
                    );
                  },
                  loading: () => _GridSkeleton(
                    itemCount: 4,
                    crossAxisCount: colCrossAxisCount,
                    childAspectRatio: 1.9,
                  ),
                  error: (error, _) => _InlineStateCard(
                    icon: Icons.error_outline_rounded,
                    message: 'Failed to load collections: $error',
                  ),
                ),
                const SizedBox(height: 18),
                const _SectionTitle(
                  title: 'Documents',
                  subtitle: 'Search OCR text and open or manage documents',
                ),
                const SizedBox(height: 10),
              ]),
            ),
          ),
          filteredDocs.when(
            data: (items) {
              if (items.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: _InlineStateCard(
                      icon: Icons.search_off_rounded,
                      message: 'No documents match your filters.',
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = items[index];
                      final document = item.document;
                      final selected =
                          _selectedDocumentIds.contains(document.documentId);

                      return Dismissible(
                        key: ValueKey(document.documentId),
                        background: _SwipeBackground(
                          alignment: Alignment.centerLeft,
                          color: Colors.amber,
                          icon: Icons.star_rounded,
                          label: document.isStarred ? 'Unstar' : 'Star',
                        ),
                        secondaryBackground: const _SwipeBackground(
                          alignment: Alignment.centerRight,
                          color: Colors.red,
                          icon: Icons.delete_outline,
                          label: 'Delete',
                        ),
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.startToEnd) {
                            await _toggleStar(
                                document.documentId, document.isStarred);
                            return false;
                          }

                          await _deleteDocument(document.documentId);
                          return true;
                        },
                        child: LongPressDraggable<String>(
                          data: document.documentId,
                          feedback: Material(
                            color: Colors.transparent,
                            child: SizedBox(
                              width: 200,
                              child: _DocumentCard(
                                item: item,
                                selected: selected,
                                onTap: () {},
                                onLongPress: () {},
                              ),
                            ),
                          ),
                          child: _DocumentCard(
                            item: item,
                            selected: selected,
                            onTap: () async {
                              if (_multiSelectMode) {
                                setState(() {
                                  if (selected) {
                                    _selectedDocumentIds
                                        .remove(document.documentId);
                                  } else {
                                    _selectedDocumentIds
                                        .add(document.documentId);
                                  }
                                });
                                return;
                              }

                              await HapticFeedback.selectionClick();
                              if (!mounted) return;

                              await Navigator.of(this.context).push(
                                MaterialPageRoute(
                                  builder: (_) => DocumentDetailPage(
                                      documentId: document.documentId),
                                ),
                              );
                            },
                            onLongPress: () {
                              HapticFeedback.mediumImpact();
                              setState(() {
                                if (selected) {
                                  _selectedDocumentIds
                                      .remove(document.documentId);
                                } else {
                                  _selectedDocumentIds.add(document.documentId);
                                }
                              });
                            },
                          ),
                        ),
                      );
                    },
                    childCount: items.length,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: docCrossAxisCount,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                ),
              );
            },
            loading: () => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: _GridSkeleton(
                  itemCount: 8,
                  crossAxisCount: docCrossAxisCount,
                ),
              ),
            ),
            error: (error, _) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: _InlineStateCard(
                  icon: Icons.error_outline_rounded,
                  message: 'Failed to load documents: $error',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroHeader extends ConsumerWidget {
  const _HeroHeader({required this.searchController});

  final TextEditingController searchController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(_space4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.14),
                Theme.of(context).colorScheme.secondary.withValues(alpha: 0.08),
              ],
            ),
            border: Border.all(
              color: Theme.of(context)
                  .colorScheme
                  .outlineVariant
                  .withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good to see you',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: _space2 / 2),
              Text(
                'Organize, search, and review your docs instantly.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: _space3 + 2),
              TextField(
                controller: searchController,
                onChanged: (value) => ref
                    .read(documentSearchQueryProvider.notifier)
                    .state = value,
                decoration: InputDecoration(
                  hintText: 'Search title or OCR text',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: searchController,
                    builder: (context, value, _) {
                      if (value.text.isEmpty) return const SizedBox.shrink();
                      return IconButton(
                        onPressed: () {
                          searchController.clear();
                          ref.read(documentSearchQueryProvider.notifier).state =
                              '';
                        },
                        icon: const Icon(Icons.close_rounded),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: _space2 / 4),
        Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _RecentCarousel extends StatelessWidget {
  const _RecentCarousel({
    required this.documents,
    required this.onOpen,
    this.emptyMessage = 'No recent documents yet.',
  });

  final List<DocumentSummary> documents;
  final ValueChanged<String> onOpen;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (documents.isEmpty) {
      return SizedBox(
        height: 112,
        child: Center(child: Text(emptyMessage)),
      );
    }

    return SizedBox(
      height: 112,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: documents.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final document = documents[index];
          final imagePath = document.thumbnailImagePath;
          return SizedBox(
            width: 220,
            child: Card(
              child: InkWell(
                onTap: () => onOpen(document.documentId),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          width: 72,
                          height: 92,
                          child: imagePath == null
                              ? const ColoredBox(color: Colors.black12)
                              : Hero(
                                  tag: 'document_image_${document.documentId}',
                                  child: EncryptedImage(imagePath: imagePath),
                                ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              document.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const Spacer(),
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
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CollectionGrid extends StatelessWidget {
  const _CollectionGrid({
    required this.collections,
    required this.counts,
    required this.onTap,
    required this.onRename,
    required this.onDelete,
    this.crossAxisCount = 2,
  });

  final List<DocumentCollection> collections;
  final Map<String, int> counts;
  final ValueChanged<DocumentCollection> onTap;
  final ValueChanged<DocumentCollection> onRename;
  final ValueChanged<DocumentCollection> onDelete;
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: collections.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.9,
      ),
      itemBuilder: (context, index) {
        final collection = collections[index];
        final count = counts[collection.collectionId] ?? 0;
        const gradient = [Color(0xFF0EA5E9), Color(0xFF0284C7)];

        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: gradient.first.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => onTap(collection),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(Icons.folder_rounded, color: Colors.white),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              collection.name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '$count',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon:
                      const Icon(Icons.more_vert_rounded, color: Colors.white),
                  onSelected: (value) {
                    if (value == 'rename') {
                      onRename(collection);
                    } else if (value == 'delete') {
                      onDelete(collection);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem<String>(
                      value: 'rename',
                      child: Row(
                        children: [
                          Icon(Icons.drive_file_rename_outline_rounded),
                          SizedBox(width: 8),
                          Text('Rename'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded),
                          SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({
    required this.item,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
  });

  final DocumentSearchHit item;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final document = item.document;
    final firstImagePath = document.thumbnailImagePath;

    return AnimatedScale(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      scale: selected ? 0.985 : 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context)
                    .colorScheme
                    .outlineVariant
                    .withValues(alpha: 0.3),
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(17)),
                  child: Container(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    width: double.infinity,
                    child: firstImagePath == null
                        ? const Icon(Icons.description_rounded, size: 40)
                        : Hero(
                            tag: 'document_image_${document.documentId}',
                            child: EncryptedImage(imagePath: firstImagePath),
                          ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            document.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 160),
                          transitionBuilder: (child, animation) =>
                              ScaleTransition(
                            scale: animation,
                            child: FadeTransition(
                                opacity: animation, child: child),
                          ),
                          child: document.isStarred
                              ? const Padding(
                                  key: ValueKey('starred'),
                                  padding: EdgeInsets.only(left: 4),
                                  child: Icon(Icons.auto_awesome_rounded,
                                      size: 16, color: Colors.amber),
                                )
                              : const SizedBox(key: ValueKey('not-starred')),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _friendlyDate(document.updatedAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (item.preview case final preview?) ...[
                      const SizedBox(height: 4),
                      Text(
                        preview,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({
    required this.alignment,
    required this.color,
    required this.icon,
    required this.label,
  });

  final Alignment alignment;
  final Color color;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: color.withValues(alpha: 0.2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: alignment,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _InlineStateCard extends StatelessWidget {
  const _InlineStateCard({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      ),
    );
  }
}

class _HorizontalSkeletonRow extends StatelessWidget {
  const _HorizontalSkeletonRow({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, __) => const SizedBox(
          width: 220,
          child: Card(),
        ),
      ),
    );
  }
}

class _GridSkeleton extends StatelessWidget {
  const _GridSkeleton({
    required this.itemCount,
    required this.crossAxisCount,
    this.childAspectRatio = 0.75,
  });

  final int itemCount;
  final int crossAxisCount;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (_, __) => const Card(),
    );
  }
}

String _friendlyDate(DateTime dateTime) {
  final now = DateTime.now();
  if (dateTime.year == now.year &&
      dateTime.month == now.month &&
      dateTime.day == now.day) {
    return 'Today';
  }
  final yesterday = now.subtract(const Duration(days: 1));
  if (dateTime.year == yesterday.year &&
      dateTime.month == yesterday.month &&
      dateTime.day == yesterday.day) {
    return 'Yesterday';
  }
  return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
}
