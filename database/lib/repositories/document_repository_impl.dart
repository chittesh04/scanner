import 'dart:async';
import 'dart:io';

import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:smartscan_database/isar_schema.dart';
import 'package:smartscan_database/database_manager.dart';
import 'package:smartscan_database/logging/db_logger.dart';
import 'package:smartscan_models/document.dart';
import 'package:smartscan_models/document_collection.dart';
import 'package:smartscan_models/document_summary.dart';
import 'package:smartscan_models/document_summary_page.dart';
import 'package:smartscan_models/repositories/document_repository.dart';
import 'package:smartscan_core_engine/core_engine.dart';
import 'package:uuid/uuid.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  DocumentRepositoryImpl(this._dbManager, this._ocrPipeline);

  final DatabaseManager _dbManager;
  final OcrPipeline _ocrPipeline;
  final _uuid = const Uuid();
  static const _starredTag = '_starred';

  Isar get _isar => _dbManager.isar;

  @override
  Stream<List<DocumentCollection>> watchCollections() {
    return _isar.collectionEntitys
        .where()
        .watch(fireImmediately: true)
        .map((entities) {
      final sorted = [...entities]
        ..sort((left, right) => left.name.compareTo(right.name));
      return sorted
          .map(
            (entity) => DocumentCollection(
              collectionId: entity.collectionId,
              name: entity.name,
            ),
          )
          .toList(growable: false);
    });
  }

  @override
  Stream<List<DocumentSummary>> watchDocumentsByCollection(
      String collectionId) {
    return _isar.documentEntitys
        .filter()
        .collectionIdEqualTo(collectionId)
        .watch(fireImmediately: true)
        .asyncMap((entities) async {
      final output = await Future.wait(entities.map(_mapToSummary));
      return output..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    });
  }

  @override
  Stream<List<DocumentSummary>> watchInboxDocuments() {
    return _isar.documentEntitys
        .filter()
        .collectionIdIsNull()
        .watch(fireImmediately: true)
        .asyncMap((entities) async {
      final summaries = await Future.wait(entities.map((doc) async {
        await doc.tags.load();
        final uiTags = doc.tags.where((tag) => tag.name != _starredTag);
        if (uiTags.isEmpty) return await _mapToSummary(doc);
        return null;
      }));

      final output = summaries.whereType<DocumentSummary>().toList();
      return output..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    });
  }

  @override
  Future<String> createCollection(String name) async {
    final normalized = name.trim();
    if (normalized.isEmpty) {
      throw ArgumentError('Collection name cannot be empty');
    }

    final existing = await _isar.collectionEntitys
        .filter()
        .nameEqualTo(normalized, caseSensitive: false)
        .findFirst();
    if (existing != null) {
      return existing.collectionId;
    }

    final collection = CollectionEntity()
      ..collectionId = _uuid.v4()
      ..name = normalized;
    await _isar.writeTxn(() => _isar.collectionEntitys.put(collection));
    return collection.collectionId;
  }

  @override
  Future<void> renameCollection(String collectionId, String newName) async {
    final normalized = newName.trim();
    if (normalized.isEmpty) {
      throw ArgumentError('Collection name cannot be empty');
    }
    final collection = await _isar.collectionEntitys
        .filter()
        .collectionIdEqualTo(collectionId)
        .findFirst();
    if (collection == null) {
      return;
    }
    final duplicate = await _isar.collectionEntitys
        .filter()
        .nameEqualTo(normalized, caseSensitive: false)
        .findFirst();
    if (duplicate != null && duplicate.collectionId != collectionId) {
      throw StateError('Collection name already exists');
    }

    await _isar.writeTxn(() async {
      collection.name = normalized;
      await _isar.collectionEntitys.put(collection);
    });
  }

  @override
  Future<void> deleteCollection(String collectionId) async {
    final collection = await _isar.collectionEntitys
        .filter()
        .collectionIdEqualTo(collectionId)
        .findFirst();
    if (collection == null) {
      return;
    }

    final docs = await _isar.documentEntitys
        .filter()
        .collectionIdEqualTo(collectionId)
        .findAll();

    await _isar.writeTxn(() async {
      for (final doc in docs) {
        doc.collectionId = null;
        doc.updatedAt = DateTime.now();
        await _isar.documentEntitys.put(doc);
      }
      await _isar.collectionEntitys.delete(collection.id);
    });
  }

  @override
  Future<void> assignDocumentToCollection(
      String documentId, String? collectionId) async {
    final document = await _isar.documentEntitys
        .filter()
        .documentIdEqualTo(documentId)
        .findFirst();
    if (document == null) {
      return;
    }

    await _isar.writeTxn(() async {
      document.collectionId = collectionId;
      document.updatedAt = DateTime.now();
      await _isar.documentEntitys.put(document);
    });
  }

  @override
  Future<String> createDocument(String title) async {
    final docId = _uuid.v4();
    final entity = DocumentEntity()
      ..documentId = docId
      ..title = title
      ..collectionId = null
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now()
      ..status = DocumentStatus.draft;

    await _isar.writeTxn(() => _isar.documentEntitys.put(entity));
    return docId;
  }

  @override
  Future<void> updateTitle(String documentId, String title) async {
    final doc = await _isar.documentEntitys
        .filter()
        .documentIdEqualTo(documentId)
        .findFirst();
    if (doc == null) return;

    await _isar.writeTxn(() async {
      doc.title = title.trim();
      doc.updatedAt = DateTime.now();
      await _isar.documentEntitys.put(doc);
    });
  }

  @override
  Future<void> deleteDocument(String documentId) async {
    await deleteDocuments([documentId]);
  }

  @override
  Future<void> deleteDocuments(List<String> documentIds) async {
    if (documentIds.isEmpty) {
      return;
    }

    final docs = await _isar.documentEntitys
        .filter()
        .anyOf(documentIds, (q, id) => q.documentIdEqualTo(id))
        .findAll();

    if (docs.isEmpty) {
      return;
    }

    final docIsarIds = docs.map((e) => e.id).toList();

    // Find all pages belonging to these documents
    final pages = await _isar.pageEntitys
        .filter()
        .anyOf(documentIds, (q, id) => q.documentIdEqualTo(id))
        .findAll();

    final pageIsarIds = pages.map((e) => e.id).toList();

    // Find all OCR blocks for these pages
    final pageIdsStr = pages.map((e) => e.pageId).toList();
    final ocrBlocks = await _isar.ocrBlockEntitys
        .filter()
        .anyOf(pageIdsStr, (q, id) => q.pageIdEqualTo(id))
        .findAll();

    final ocrBlockIsarIds = ocrBlocks.map((e) => e.id).toList();

    await _isar.writeTxn(() async {
      await _isar.ocrBlockEntitys.deleteAll(ocrBlockIsarIds);
      await _isar.pageEntitys.deleteAll(pageIsarIds);
      await _isar.documentEntitys.deleteAll(docIsarIds);
    });
    DbLogger.info('Deleted ${docIsarIds.length} document(s) from Isar');

    try {
      final dir = await getApplicationSupportDirectory();
      final root = Directory(p.join(dir.path, 'smartscan_data'));
      for (final id in documentIds) {
        final docDir = Directory(p.join(root.path, id));
        if (await docDir.exists()) await docDir.delete(recursive: true);
      }
    } catch (error, stackTrace) {
      DbLogger.warn(
        'Document storage cleanup failed for deleted documents',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> deletePage(String documentId, String pageId) async {
    final page =
        await _isar.pageEntitys.filter().pageIdEqualTo(pageId).findFirst();
    if (page == null) return;

    // Delete associated OCR blocks.
    await page.ocrBlocks.load();
    final ocrBlockIds = page.ocrBlocks.map((b) => b.id).toList();

    await _isar.writeTxn(() async {
      await _isar.ocrBlockEntitys.deleteAll(ocrBlockIds);
      await _isar.pageEntitys.delete(page.id);

      // Update document's updatedAt.
      final doc = await _isar.documentEntitys
          .filter()
          .documentIdEqualTo(documentId)
          .findFirst();
      if (doc != null) {
        doc.updatedAt = DateTime.now();
        await _isar.documentEntitys.put(doc);
      }
    });

    // Delete the physical image files.
    try {
      final dir = await getApplicationSupportDirectory();
      final root = Directory(p.join(dir.path, 'smartscan_data'));
      final rawFile = File(p.join(root.path, documentId, 'raw_$pageId.jpg'));
      final procFile = File(p.join(root.path, documentId, 'proc_$pageId.jpg'));
      if (await rawFile.exists()) await rawFile.delete();
      if (await procFile.exists()) await procFile.delete();
    } catch (_) {}
  }

  @override
  Future<void> reorderPages(
      String documentId, List<String> orderedPageIds) async {
    await _isar.writeTxn(() async {
      for (var i = 0; i < orderedPageIds.length; i++) {
        final page = await _isar.pageEntitys
            .filter()
            .pageIdEqualTo(orderedPageIds[i])
            .findFirst();
        if (page != null) {
          page.order = i;
          await _isar.pageEntitys.put(page);
        }
      }
    });
  }

  @override
  Future<void> addPage(String documentId, ScanPipelineOutput scanOutput) async {
    if (scanOutput.pages.isEmpty) {
      DbLogger.warn('addPage called with empty scan output for $documentId');
      return;
    }

    final existingPages = await _isar.pageEntitys
        .filter()
        .documentIdEqualTo(documentId)
        .findAll();
    var order = existingPages.length;
    final insertedPageIds = <String>[];

    await _isar.writeTxn(() async {
      for (final page in scanOutput.pages) {
        final pageId = _uuid.v4();
        final pageEntity = PageEntity()
          ..pageId = pageId
          ..documentId = documentId
          ..order = order++
          ..rawImagePath = page.rawImagePath
          ..processedImagePath = page.processedImagePath
          ..width = page.width
          ..height = page.height
          ..hasSignature = false
          ..ocrStatus = OcrStatus.pending
          ..updatedAt = DateTime.now();
        await _isar.pageEntitys.put(pageEntity);
        insertedPageIds.add(pageId);
      }

      final doc = await _isar.documentEntitys
          .filter()
          .documentIdEqualTo(documentId)
          .findFirst();
      if (doc != null) {
        doc.updatedAt = DateTime.now();
        await _isar.documentEntitys.put(doc);
      }
    });

    DbLogger.info('Added ${insertedPageIds.length} page(s) to $documentId');
  }

  @override
  Future<void> updatePageSignature(String documentId, String pageId, double x,
      double y, double scale) async {
    final page =
        await _isar.pageEntitys.filter().pageIdEqualTo(pageId).findFirst();
    if (page == null) return;

    await _isar.writeTxn(() async {
      page.hasSignature = true;
      page.signatureX = x;
      page.signatureY = y;
      page.signatureScale = scale;
      page.updatedAt = DateTime.now();
      await _isar.pageEntitys.put(page);
    });
  }

  @override
  Future<void> removePageSignature(String documentId, String pageId) async {
    final page =
        await _isar.pageEntitys.filter().pageIdEqualTo(pageId).findFirst();
    if (page == null) return;

    await _isar.writeTxn(() async {
      page.hasSignature = false;
      page.signatureX = null;
      page.signatureY = null;
      page.signatureScale = null;
      page.updatedAt = DateTime.now();
      await _isar.pageEntitys.put(page);
    });
  }

  @override
  Future<void> updatePageText(
      String documentId, String pageId, String text) async {
    final page =
        await _isar.pageEntitys.filter().pageIdEqualTo(pageId).findFirst();
    if (page == null) return;

    final trimmed = text.trim();
    await _isar.writeTxn(() async {
      await page.ocrBlocks.load();
      if (page.ocrBlocks.isNotEmpty) {
        await _isar.ocrBlockEntitys
            .deleteAll(page.ocrBlocks.map((b) => b.id).toList());
        page.ocrBlocks.clear();
        await page.ocrBlocks.save();
      }
      page.fullText = trimmed;
      page.ocrStatus =
          trimmed.isEmpty ? OcrStatus.pending : OcrStatus.completed;
      page.updatedAt = DateTime.now();
      await _isar.pageEntitys.put(page);

      final doc = await _isar.documentEntitys
          .filter()
          .documentIdEqualTo(documentId)
          .findFirst();
      if (doc != null) {
        doc.updatedAt = DateTime.now();
        await _isar.documentEntitys.put(doc);
      }
    });
  }

  @override
  Future<DocumentSummaryPage> fetchDocumentsPage({
    int limit = 30,
    DateTime? updatedBeforeCursor,
  }) async {
    final safeLimit = limit < 1 ? 1 : (limit > 100 ? 100 : limit);

    final entities = updatedBeforeCursor == null
        ? await _isar.documentEntitys.where().findAll()
        : await _isar.documentEntitys
            .filter()
            .updatedAtLessThan(updatedBeforeCursor, include: false)
            .findAll();
    entities.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    final hasMore = entities.length > safeLimit;
    final slice = hasMore ? entities.sublist(0, safeLimit) : entities;
    final mapped = await Future.wait<DocumentSummary>(slice.map(_mapToSummary));
    final sorted = mapped..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return DocumentSummaryPage(
      items: sorted,
      hasMore: hasMore,
      nextCursor: hasMore && sorted.isNotEmpty ? sorted.last.updatedAt : null,
    );
  }

  @override
  Future<void> performOcr(String documentId, String pageId) async {
    final page =
        await _isar.pageEntitys.filter().pageIdEqualTo(pageId).findFirst();
    if (page == null) return;

    // 1. Mark as processing
    await _isar.writeTxn(() async {
      page.ocrStatus = OcrStatus.processing;
      await _isar.pageEntitys.put(page);
    });

    try {
      final result = await _ocrPipeline.recognizeText(page.processedImagePath);

      // 2. Save results
      await _isar.writeTxn(() async {
        // Clear old blocks
        await page.ocrBlocks.load();
        await _isar.ocrBlockEntitys
            .deleteAll(page.ocrBlocks.map((e) => e.id).toList());
        page.ocrBlocks.clear();

        for (final word in result.words) {
          final block = OcrBlockEntity()
            ..pageId = pageId
            ..text = word.text
            ..left = word.left
            ..top = word.top
            ..right = word.right
            ..bottom = word.bottom
            ..languageCode = result.detectedLanguages.firstOrNull ?? 'en';

          await _isar.ocrBlockEntitys.put(block);
          page.ocrBlocks.add(block);
        }

        await page.ocrBlocks.save();
        page.fullText = result.words.map((w) => w.text).join(' ');
        page.ocrStatus = OcrStatus.completed;
        page.updatedAt = DateTime.now();
        await _isar.pageEntitys.put(page);
      });
      DbLogger.info('OCR completed for page $pageId');
    } catch (error, stackTrace) {
      // 3. Mark as failed on error
      await _isar.writeTxn(() async {
        page.ocrStatus = OcrStatus.failed;
        page.updatedAt = DateTime.now();
        await _isar.pageEntitys.put(page);
      });
      DbLogger.error(
        'OCR failed for page $pageId',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<void> setStarred(String documentId, bool starred) async {
    final document = await _isar.documentEntitys
        .filter()
        .documentIdEqualTo(documentId)
        .findFirst();
    if (document == null) {
      return;
    }

    await document.tags.load();

    await _isar.writeTxn(() async {
      final current = document.tags.firstWhere(
        (tag) => tag.name == _starredTag,
        orElse: () => TagEntity()..name = '',
      );

      if (starred) {
        final starredTag =
            current.name.isEmpty ? await _getOrCreateTag(_starredTag) : current;
        document.tags.add(starredTag);
      } else {
        if (current.name.isNotEmpty) {
          document.tags.remove(current);
        }
      }

      document.updatedAt = DateTime.now();
      await document.tags.save();
      await _isar.documentEntitys.put(document);
    });
  }

  @override
  Future<void> setDocumentTags(String documentId, List<String> tags) async {
    final normalized = tags
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toSet()
        .toList(growable: false);

    final document = await _isar.documentEntitys
        .filter()
        .documentIdEqualTo(documentId)
        .findFirst();
    if (document == null) {
      return;
    }

    await document.tags.load();

    await _isar.writeTxn(() async {
      final previousStarred =
          document.tags.any((tag) => tag.name == _starredTag);
      document.tags.clear();

      for (final tag in normalized) {
        final entity = await _getOrCreateTag(tag);
        document.tags.add(entity);
      }

      if (previousStarred) {
        final starredTag = await _getOrCreateTag(_starredTag);
        document.tags.add(starredTag);
      }

      document.updatedAt = DateTime.now();
      await document.tags.save();
      await _isar.documentEntitys.put(document);
    });
  }

  @override
  Stream<List<DocumentSummary>> watchDocuments() {
    return _isar.documentEntitys
        .where()
        .watch(fireImmediately: true)
        .asyncMap((entities) async {
      final output = await Future.wait(entities.map(_mapToSummary));
      return output..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    });
  }

  @override
  Stream<Document?> watchDocument(String documentId) {
    return _isar.documentEntitys
        .filter()
        .documentIdEqualTo(documentId)
        .watch(fireImmediately: true)
        .asyncMap((entities) async {
      if (entities.isEmpty) return null;
      return _mapToDocument(entities.first);
    });
  }

  Future<DocumentSummary> _mapToSummary(DocumentEntity doc) async {
    final pagesCount = await _isar.pageEntitys
        .filter()
        .documentIdEqualTo(doc.documentId)
        .count();

    final firstPage = await _isar.pageEntitys
        .filter()
        .documentIdEqualTo(doc.documentId)
        .sortByOrder()
        .findFirst();

    await doc.tags.load();

    // Build OCR snippet from page.fullText (already indexed/denormalized).
    // This avoids loading every page->ocrBlocks relation per list tile.
    String? ocrSnippet;
    final pages = await _isar.pageEntitys
        .filter()
        .documentIdEqualTo(doc.documentId)
        .sortByOrder()
        .findAll();
    final snippetBuffer = StringBuffer();
    for (final page in pages) {
      final fullText = page.fullText?.trim();
      if (fullText != null && fullText.isNotEmpty) {
        if (snippetBuffer.isNotEmpty) snippetBuffer.write(' ');
        snippetBuffer.write(fullText);
      }
      if (snippetBuffer.length >= 200) break;
    }
    if (snippetBuffer.isNotEmpty) {
      final full = snippetBuffer.toString();
      ocrSnippet = full.length > 200 ? full.substring(0, 200) : full;
    }

    return DocumentSummary(
      documentId: doc.documentId,
      title: doc.title,
      pageCount: pagesCount,
      updatedAt: doc.updatedAt,
      isStarred: doc.tags.any((tag) => tag.name == _starredTag),
      collectionId: doc.collectionId,
      thumbnailImagePath:
          firstPage?.processedImagePath ?? firstPage?.rawImagePath,
      ocrSnippet: ocrSnippet,
    );
  }

  Future<Document> _mapToDocument(DocumentEntity doc) async {
    final pages = await _isar.pageEntitys
        .filter()
        .documentIdEqualTo(doc.documentId)
        .sortByOrder()
        .findAll();
    await doc.tags.load();

    final mappedPages = <DocumentPage>[];
    for (final page in pages) {
      await page.ocrBlocks.load();
      final ocrTextFromBlocks =
          page.ocrBlocks.map((b) => b.text).join(' ').trim();
      final manualOrIndexedText = page.fullText?.trim() ?? '';
      final resolvedOcrText = manualOrIndexedText.isNotEmpty
          ? manualOrIndexedText
          : ocrTextFromBlocks;

      final ocrBlocks = page.ocrBlocks
          .map((b) => OcrBlock(
                text: b.text,
                left: b.left,
                top: b.top,
                right: b.right,
                bottom: b.bottom,
              ))
          .toList(growable: false);

      mappedPages.add(DocumentPage(
        pageId: page.pageId,
        order: page.order,
        processedImagePath: page.processedImagePath,
        imageWidth: page.width,
        imageHeight: page.height,
        ocrText: resolvedOcrText.isEmpty ? null : resolvedOcrText,
        ocrBlocks: ocrBlocks,
        hasSignature: page.hasSignature,
        signatureX: page.signatureX,
        signatureY: page.signatureY,
        signatureScale: page.signatureScale,
      ));
    }

    return Document(
      documentId: doc.documentId,
      title: doc.title,
      pages: mappedPages,
      tags: doc.tags
          .map((tag) => tag.name)
          .where((tag) => tag != _starredTag)
          .toList(growable: false),
      isStarred: doc.tags.any((tag) => tag.name == _starredTag),
      collectionId: doc.collectionId,
      updatedAt: doc.updatedAt,
    );
  }

  Future<TagEntity> _getOrCreateTag(String name) async {
    final existing =
        await _isar.tagEntitys.filter().nameEqualTo(name).findFirst();
    if (existing != null) {
      return existing;
    }

    final created = TagEntity()..name = name;
    await _isar.tagEntitys.put(created);
    return created;
  }
}
