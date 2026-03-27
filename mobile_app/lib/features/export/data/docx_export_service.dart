import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:smartscan/features/export/domain/export_models.dart';
import 'package:smartscan/core/storage/file_storage_service.dart';

/// Exports a scanned document as a valid `.docx` (Office Open XML) file.
///
/// Each page becomes a section with:
/// * A heading ("Page N")
/// * The OCR-extracted text as paragraphs
/// * The scanned image inlined below the text
class DocxExportService {
  DocxExportService(this._storageService);

  final FileStorageService _storageService;

  Future<File> export(ExportRequest request) async {
    final archive = Archive();

    // ── Collect images ──
    final imageEntries = <_ImageEntry>[];
    for (var i = 0; i < request.pages.length; i++) {
      final page = request.pages[i];
      final imageFile = File(page.imagePath);
      if (!await imageFile.exists()) continue;
      final bytes = await _storageService.readEncrypted(imageFile);
      final rId = 'rId${i + 10}';
      final filename = 'image${i + 1}.png';
      imageEntries.add(_ImageEntry(rId: rId, filename: filename, bytes: bytes));
      archive.addFile(ArchiveFile(
        'word/media/$filename',
        bytes.length,
        bytes,
      ));
    }

    // ── [Content_Types].xml ──
    final contentTypes = _buildContentTypes(imageEntries);
    archive.addFile(_textFile('[Content_Types].xml', contentTypes));

    // ── _rels/.rels ──
    archive.addFile(_textFile('_rels/.rels', _rootRels));

    // ── word/_rels/document.xml.rels ──
    final docRels = _buildDocumentRels(imageEntries);
    archive.addFile(_textFile('word/_rels/document.xml.rels', docRels));

    // ── word/document.xml ──
    final docXml = _buildDocumentXml(request, imageEntries);
    archive.addFile(_textFile('word/document.xml', docXml));

    // ── word/styles.xml (minimal) ──
    archive.addFile(_textFile('word/styles.xml', _minimalStyles));

    // ── Encode & write ──
    final encoded = ZipEncoder().encode(archive)!;
    final root = await getTemporaryDirectory();
    final outPath = request.outputPath ??
        p.join(root.path, '${request.title}_${request.documentId}.docx');
    final file = File(outPath);
    await file.writeAsBytes(encoded, flush: true);
    return file;
  }

  // ─────────────────────── XML Builders ───────────────────────

  String _buildContentTypes(List<_ImageEntry> images) {
    final imageParts = images
        .map((img) =>
            '<Override PartName="/word/media/${img.filename}" ContentType="image/png"/>')
        .join('\n  ');
    return '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
  <Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>
  $imageParts
</Types>''';
  }

  static const _rootRels = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
</Relationships>''';

  String _buildDocumentRels(List<_ImageEntry> images) {
    final rels = images
        .map((img) =>
            '<Relationship Id="${img.rId}" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/${img.filename}"/>')
        .join('\n  ');
    return '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
  $rels
</Relationships>''';
  }

  String _buildDocumentXml(
      ExportRequest request, List<_ImageEntry> imageEntries) {
    final body = StringBuffer();

    for (var i = 0; i < request.pages.length; i++) {
      final page = request.pages[i];

      // Heading
      body.writeln('''
      <w:p>
        <w:pPr><w:pStyle w:val="Heading1"/></w:pPr>
        <w:r><w:t>Page ${i + 1}</w:t></w:r>
      </w:p>''');

      // OCR text paragraphs (split by newlines)
      final lines = page.ocrText.split('\n');
      for (final line in lines) {
        if (line.trim().isEmpty) continue;
        final escaped = _xmlEscape(line);
        body.writeln('''
      <w:p>
        <w:r><w:t xml:space="preserve">$escaped</w:t></w:r>
      </w:p>''');
      }

      // Inline image (if available)
      if (i < imageEntries.length) {
        final entry = imageEntries[i];
        // EMU (English Metric Units): 1 inch = 914400 EMUs, assume 96 dpi
        final cxEmu = (page.imageWidth / 96.0 * 914400).round();
        final cyEmu = (page.imageHeight / 96.0 * 914400).round();
        // Cap at ~6 inches wide for A4
        final maxCx = (6.0 * 914400).round();
        final scale = cxEmu > maxCx ? maxCx / cxEmu : 1.0;
        final finalCx = (cxEmu * scale).round();
        final finalCy = (cyEmu * scale).round();

        body.writeln('''
      <w:p>
        <w:r>
          <w:drawing>
            <wp:inline distT="0" distB="0" distL="0" distR="0"
                       xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing">
              <wp:extent cx="$finalCx" cy="$finalCy"/>
              <wp:docPr id="${i + 1}" name="Image ${i + 1}"/>
              <a:graphic xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">
                <a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">
                  <pic:pic xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">
                    <pic:nvPicPr>
                      <pic:cNvPr id="${i + 1}" name="${entry.filename}"/>
                      <pic:cNvPicPr/>
                    </pic:nvPicPr>
                    <pic:blipFill>
                      <a:blip r:embed="${entry.rId}" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"/>
                      <a:stretch><a:fillRect/></a:stretch>
                    </pic:blipFill>
                    <pic:spPr>
                      <a:xfrm><a:off x="0" y="0"/><a:ext cx="$finalCx" cy="$finalCy"/></a:xfrm>
                      <a:prstGeom prst="rect"><a:avLst/></a:prstGeom>
                    </pic:spPr>
                  </pic:pic>
                </a:graphicData>
              </a:graphic>
            </wp:inline>
          </w:drawing>
        </w:r>
      </w:p>''');
      }
    }

    return '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
            xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
  <w:body>
    $body
  </w:body>
</w:document>''';
  }

  static const _minimalStyles = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:style w:type="paragraph" w:styleId="Heading1">
    <w:name w:val="heading 1"/>
    <w:pPr><w:outlineLvl w:val="0"/></w:pPr>
    <w:rPr><w:b/><w:sz w:val="32"/></w:rPr>
  </w:style>
</w:styles>''';

  // ─────────────────────── Helpers ───────────────────────

  static ArchiveFile _textFile(String path, String content) {
    final bytes = utf8.encode(content);
    return ArchiveFile(path, bytes.length, bytes);
  }

  static String _xmlEscape(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }
}

class _ImageEntry {
  _ImageEntry({required this.rId, required this.filename, required this.bytes});
  final String rId;
  final String filename;
  final Uint8List bytes;
}
