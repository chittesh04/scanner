import 'dart:async';

import 'package:isar/isar.dart';
import 'package:smartscan_database/isar_schema.dart';
import 'package:smartscan_models/document.dart';
import 'package:smartscan_models/document_collection.dart';
import 'package:smartscan/features/document/domain/document_repository.dart';
import 'package:smartscan_core_engine/document_pipeline/scan_pipeline.dart';
import 'package:smartscan_core_engine/ocr_engine/ocr_pipeline.dart';
import 'package:uuid/uuid.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  DocumentRepositoryImpl(this._isar, this._ocrPipeline);

  final Isar _isar;
  final OcrPipeline _ocrPipeline;
  final _uuid = const Uuid();
  static const _starredTag = '_starred';

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
  Stream<List<Document>> watchDocumentsByCollection(String collectionId) {
    return _isar.documentEntitys
        .filter()
        .collectionIdEqualTo(collectionId)
        .watch(fireImmediately: true)
        .asyncMap((entities) async {
      final output = <Document>[];
      for (final doc in entities) {
        output.add(await _mapToDocument(doc));
      }
      output.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return output;
    });
  }

  @override
  Stream<List<Document>> watchInboxDocuments() {
    return _isar.documentEntitys
        .filter()
        .collectionIdIsNull()
        .watch(fireImmediately: true)
        .asyncMap((entities) async {
      final output = <Document>[];
      for (final doc in entities) {
        final d = await _mapToDocument(doc);
        if (d.tags.isEmpty) {
          output.add(d);
        }
      }
      output.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return output;
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
  Future<void> deleteDocument(String documentId) async {
    final doc = await _isar.documentEntitys
        .filter()
        .documentIdEqualTo(documentId)
        .findFirst();
    if (doc == null) return;
    await _isar.writeTxn(() => _isar.documentEntitys.delete(doc.id));
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

    await _isar.writeTxn(() async {
      await _isar.documentEntitys.deleteAll(docs.map((e) => e.id).toList());
    });
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

    unawaited(
      Future.wait(
        insertedPageIds.map((pageId) => performOcr(documentId, pageId)),
      ),
    );
  }

  @override
  Future<void> updatePageSignature(String documentId, String pageId, double x, double y, double scale) async {
    final page = await _isar.pageEntitys.filter().pageIdEqualTo(pageId).findFirst();
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
    final page = await _isar.pageEntitys.filter().pageIdEqualTo(pageId).findFirst();
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
  Future<void> performOcr(String documentId, String pageId) async {
    final page =
        await _isar.pageEntitys.filter().pageIdEqualTo(pageId).findFirst();
    if (page == null) return;

    final result = await _ocrPipeline.recognizeText(page.processedImagePath);

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
      page.updatedAt = DateTime.now();
      await _isar.pageEntitys.put(page);
    });
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
  Stream<List<Document>> watchDocuments() {
    return _isar.documentEntitys
        .where()
        .watch(fireImmediately: true)
        .asyncMap((entities) async {
      final output = <Document>[];
      for (final doc in entities) {
        output.add(await _mapToDocument(doc));
      }
      return output;
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
      final ocrText = page.ocrBlocks.map((b) => b.text).join(' ');

      mappedPages.add(DocumentPage(
        pageId: page.pageId,
        order: page.order,
        processedImagePath: page.processedImagePath,
        ocrText: ocrText.isEmpty ? null : ocrText,
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
