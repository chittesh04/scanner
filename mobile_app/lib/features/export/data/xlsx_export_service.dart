import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:smartscan/features/export/domain/export_models.dart';

/// Exports OCR-detected tabular data as a valid `.xlsx` (SpreadsheetML) file.
///
/// The tabular detection algorithm:
/// 1. Sort OCR blocks by vertical position (Y)
/// 2. Cluster into rows using a Y-tolerance (blocks within ~15 px)
/// 3. Within each row, sort by X to establish column order
/// 4. Align columns across rows using X midpoint proximity
class XlsxExportService {
  Future<File> export(ExportRequest request) async {
    // Detect tables from each page's OCR blocks.
    final allTables = <TableData>[];
    for (final page in request.pages) {
      final table = detectTable(page.ocrBlocks);
      if (!table.isEmpty) {
        allTables.add(table);
      }
    }

    // If no tabular data detected, fall back to one row per page with
    // the full OCR text.
    if (allTables.isEmpty) {
      final rows = request.pages
          .where((p) => p.ocrText.isNotEmpty)
          .map((p) => [p.ocrText])
          .toList();
      allTables.add(TableData(rows: rows));
    }

    // Build the SpreadsheetML archive.
    final archive = Archive();
    final sharedStrings = <String>[];
    final sheetXmls = <String>[];

    for (final table in allTables) {
      sheetXmls.add(_buildSheetXml(table, sharedStrings));
    }

    // ── [Content_Types].xml ──
    archive.addFile(_textFile('[Content_Types].xml',
        _buildContentTypes(sheetXmls.length)));

    // ── _rels/.rels ──
    archive.addFile(_textFile('_rels/.rels', _rootRels));

    // ── xl/_rels/workbook.xml.rels ──
    archive.addFile(_textFile(
        'xl/_rels/workbook.xml.rels', _buildWorkbookRels(sheetXmls.length)));

    // ── xl/workbook.xml ──
    archive.addFile(
        _textFile('xl/workbook.xml', _buildWorkbookXml(sheetXmls.length)));

    // ── xl/worksheets/sheetN.xml ──
    for (var i = 0; i < sheetXmls.length; i++) {
      archive.addFile(
          _textFile('xl/worksheets/sheet${i + 1}.xml', sheetXmls[i]));
    }

    // ── xl/sharedStrings.xml ──
    archive.addFile(
        _textFile('xl/sharedStrings.xml', _buildSharedStrings(sharedStrings)));

    // ── xl/styles.xml (minimal) ──
    archive.addFile(_textFile('xl/styles.xml', _minimalStyles));

    // ── Encode & write ──
    final encoded = ZipEncoder().encode(archive)!;
    final root = await getTemporaryDirectory();
    final outPath = request.outputPath ??
        p.join(root.path, '${request.title}_${request.documentId}.xlsx');
    final file = File(outPath);
    await file.writeAsBytes(encoded, flush: true);
    return file;
  }

  // ────────────────── Tabular Detection ──────────────────

  /// Clusters OCR blocks into rows and columns to form a table.
  ///
  /// Strategy:
  /// * Sort by vertical midpoint, cluster blocks that share a similar Y
  ///   (within [yTolerance] pixels) into the same row.
  /// * Within each row sort by X midpoint → column order.
  /// * Determine global column boundaries by collecting all X midpoints
  ///   across rows and clustering them into columns.
  static TableData detectTable(List<ExportOcrBlock> blocks,
      {double yTolerance = 15.0, double xTolerance = 30.0}) {
    if (blocks.isEmpty) return const TableData(rows: []);

    // Sort by vertical midpoint.
    final sorted = [...blocks]
      ..sort((a, b) {
        final midA = (a.top + a.bottom) / 2;
        final midB = (b.top + b.bottom) / 2;
        return midA.compareTo(midB);
      });

    // Cluster into rows.
    final rows = <List<ExportOcrBlock>>[];
    var currentRow = <ExportOcrBlock>[sorted.first];
    var currentY = (sorted.first.top + sorted.first.bottom) / 2;

    for (var i = 1; i < sorted.length; i++) {
      final midY = (sorted[i].top + sorted[i].bottom) / 2;
      if ((midY - currentY).abs() <= yTolerance) {
        currentRow.add(sorted[i]);
      } else {
        rows.add(currentRow);
        currentRow = [sorted[i]];
        currentY = midY;
      }
    }
    rows.add(currentRow);

    // If only one row with one block, not really a table.
    if (rows.length <= 1 && rows.first.length <= 1) {
      return const TableData(rows: []);
    }

    // Sort each row by X midpoint.
    for (final row in rows) {
      row.sort((a, b) {
        final midA = (a.left + a.right) / 2;
        final midB = (b.left + b.right) / 2;
        return midA.compareTo(midB);
      });
    }

    // Collect all X midpoints to determine global column centres.
    final allXMids = <double>[];
    for (final row in rows) {
      for (final block in row) {
        allXMids.add((block.left + block.right) / 2);
      }
    }
    allXMids.sort();

    // Cluster X midpoints into columns.
    final columnCentres = <double>[];
    for (final xMid in allXMids) {
      final match = columnCentres.indexWhere((c) => (c - xMid).abs() <= xTolerance);
      if (match == -1) {
        columnCentres.add(xMid);
      } else {
        // Running average.
        columnCentres[match] = (columnCentres[match] + xMid) / 2;
      }
    }
    columnCentres.sort();

    // Map each row's blocks into the global column grid.
    final tableRows = <List<String>>[];
    for (final row in rows) {
      final cells = List.filled(columnCentres.length, '');
      for (final block in row) {
        final xMid = (block.left + block.right) / 2;
        var bestCol = 0;
        var bestDist = double.infinity;
        for (var c = 0; c < columnCentres.length; c++) {
          final dist = (columnCentres[c] - xMid).abs();
          if (dist < bestDist) {
            bestDist = dist;
            bestCol = c;
          }
        }
        // Append if cell already has text (merge adjacent blocks in same column).
        cells[bestCol] = cells[bestCol].isEmpty
            ? block.text
            : '${cells[bestCol]} ${block.text}';
      }
      tableRows.add(cells);
    }

    return TableData(rows: tableRows);
  }

  // ────────────────── SpreadsheetML Builders ──────────────────

  String _buildSheetXml(TableData table, List<String> sharedStrings) {
    final sb = StringBuffer();
    sb.writeln(
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>');
    sb.writeln(
        '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">');
    sb.writeln('  <sheetData>');

    for (var r = 0; r < table.rows.length; r++) {
      sb.writeln('    <row r="${r + 1}">');
      for (var c = 0; c < table.rows[r].length; c++) {
        final cellRef = '${_colLetter(c)}${r + 1}';
        final value = table.rows[r][c];
        final ssIndex = sharedStrings.length;
        sharedStrings.add(value);
        sb.writeln(
            '      <c r="$cellRef" t="s"><v>$ssIndex</v></c>');
      }
      sb.writeln('    </row>');
    }

    sb.writeln('  </sheetData>');
    sb.writeln('</worksheet>');
    return sb.toString();
  }

  static String _colLetter(int index) {
    final sb = StringBuffer();
    var n = index;
    do {
      sb.write(String.fromCharCode(65 + (n % 26)));
      n = n ~/ 26 - 1;
    } while (n >= 0);
    return sb.toString().split('').reversed.join();
  }

  String _buildContentTypes(int sheetCount) {
    final sheets = List.generate(
      sheetCount,
      (i) =>
          '<Override PartName="/xl/worksheets/sheet${i + 1}.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>',
    ).join('\n  ');

    return '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>
  <Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>
  <Override PartName="/xl/sharedStrings.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sharedStrings+xml"/>
  $sheets
</Types>''';
  }

  static const _rootRels = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>
</Relationships>''';

  String _buildWorkbookRels(int sheetCount) {
    final rels = <String>[
      '<Relationship Id="rIdStyles" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>',
      '<Relationship Id="rIdSS" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/sharedStrings" Target="sharedStrings.xml"/>',
    ];
    for (var i = 0; i < sheetCount; i++) {
      rels.add(
          '<Relationship Id="rIdSheet${i + 1}" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet${i + 1}.xml"/>');
    }
    return '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  ${rels.join('\n  ')}
</Relationships>''';
  }

  String _buildWorkbookXml(int sheetCount) {
    final sheets = List.generate(
      sheetCount,
      (i) =>
          '<sheet name="Page ${i + 1}" sheetId="${i + 1}" r:id="rIdSheet${i + 1}"/>',
    ).join('\n    ');
    return '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"
          xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
  <sheets>
    $sheets
  </sheets>
</workbook>''';
  }

  static String _buildSharedStrings(List<String> strings) {
    final sb = StringBuffer();
    sb.writeln('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>');
    sb.writeln(
        '<sst xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" count="${strings.length}" uniqueCount="${strings.length}">');
    for (final s in strings) {
      final escaped = s
          .replaceAll('&', '&amp;')
          .replaceAll('<', '&lt;')
          .replaceAll('>', '&gt;');
      sb.writeln('  <si><t>$escaped</t></si>');
    }
    sb.writeln('</sst>');
    return sb.toString();
  }

  static const _minimalStyles = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
  <fonts count="1"><font><sz val="11"/><name val="Calibri"/></font></fonts>
  <fills count="1"><fill><patternFill patternType="none"/></fill></fills>
  <borders count="1"><border><left/><right/><top/><bottom/></border></borders>
  <cellStyleXfs count="1"><xf/></cellStyleXfs>
  <cellXfs count="1"><xf/></cellXfs>
</styleSheet>''';

  static ArchiveFile _textFile(String path, String content) {
    final bytes = utf8.encode(content);
    return ArchiveFile(path, bytes.length, bytes);
  }
}
