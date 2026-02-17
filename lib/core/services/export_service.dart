import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/note.dart';

/// Export Service - Handle note exports to various formats
class ExportService {
  /// Export note as plain text
  static String exportAsText(Note note) {
    final buffer = StringBuffer();

    buffer.writeln('Title: ${note.title}');
    buffer.writeln('Created: ${note.createdAt}');
    buffer.writeln('Updated: ${note.updatedAt}');
    buffer.writeln('Tags: ${note.tags.join(', ')}');
    buffer.writeln('\n---\n');
    buffer.writeln(note.content);

    if (note.todos != null && note.todos!.isNotEmpty) {
      buffer.writeln('\n\nTasks:');
      for (var todo in note.todos!) {
        buffer.writeln('${todo.isCompleted ? '✓' : '☐'} ${todo.text}');
      }
    }

    return buffer.toString();
  }

  /// Export note as Markdown
  static String exportAsMarkdown(Note note) {
    final buffer = StringBuffer();

    buffer.writeln('# ${note.title}');
    buffer.writeln();
    buffer.writeln('**Created:** ${note.createdAt}');
    buffer.writeln('**Updated:** ${note.updatedAt}');

    if (note.tags.isNotEmpty) {
      buffer.writeln('**Tags:** ${note.tags.map((t) => '#$t').join(' ')}');
    }

    buffer.writeln();
    buffer.writeln('---');
    buffer.writeln();
    buffer.writeln(note.content);

    if (note.todos != null && note.todos!.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('## Tasks');
      buffer.writeln();
      for (var todo in note.todos!) {
        buffer.writeln('- [${todo.isCompleted ? 'x' : ' '}] ${todo.text}');
      }
    }

    if (note.media.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('## Media');
      buffer.writeln();
      for (var media in note.media) {
        buffer.writeln('- ${media.type.name}: ${media.filePath}');
      }
    }

    return buffer.toString();
  }

  /// Export note as HTML
  static String exportAsHtml(Note note) {
    final buffer = StringBuffer();

    buffer.writeln('<!DOCTYPE html>');
    buffer.writeln('<html>');
    buffer.writeln('<head>');
    buffer.writeln('  <meta charset="UTF-8">');
    buffer.writeln(
      '  <meta name="viewport" content="width=device-width, initial-scale=1.0">',
    );
    buffer.writeln('  <title>${note.title}</title>');
    buffer.writeln('  <style>');
    buffer.writeln(
      '    body { font-family: Arial, sans-serif; max-width: 800px; margin: 40px auto; padding: 20px; }',
    );
    buffer.writeln(
      '    h1 { color: #333; border-bottom: 2px solid #007bff; padding-bottom: 10px; }',
    );
    buffer.writeln(
      '    .meta { color: #666; font-size: 14px; margin-bottom: 20px; }',
    );
    buffer.writeln('    .content { line-height: 1.6; white-space: pre-wrap; }');
    buffer.writeln('    .tags { margin: 10px 0; }');
    buffer.writeln(
      '    .tag { background: #e7f3ff; color: #007bff; padding: 4px 8px; border-radius: 4px; margin-right: 5px; font-size: 12px; }',
    );
    buffer.writeln('    .todos { margin-top: 20px; }');
    buffer.writeln(
      '    .todo-item { padding: 8px; margin: 4px 0; border-left: 3px solid #28a745; }',
    );
    buffer.writeln(
      '    .todo-item.completed { text-decoration: line-through; opacity: 0.6; }',
    );
    buffer.writeln('  </style>');
    buffer.writeln('</head>');
    buffer.writeln('<body>');
    buffer.writeln('  <h1>${_escapeHtml(note.title)}</h1>');

    buffer.writeln('  <div class="meta">');
    buffer.writeln('    <p><strong>Created:</strong> ${note.createdAt}</p>');
    buffer.writeln('    <p><strong>Updated:</strong> ${note.updatedAt}</p>');
    buffer.writeln('  </div>');

    if (note.tags.isNotEmpty) {
      buffer.writeln('  <div class="tags">');
      for (var tag in note.tags) {
        buffer.writeln('    <span class="tag">#$tag</span>');
      }
      buffer.writeln('  </div>');
    }

    buffer.writeln('  <div class="content">');
    buffer.writeln(_escapeHtml(note.content));
    buffer.writeln('  </div>');

    if (note.todos != null && note.todos!.isNotEmpty) {
      buffer.writeln('  <div class="todos">');
      buffer.writeln('    <h2>Tasks</h2>');
      for (var todo in note.todos!) {
        buffer.writeln(
          '    <div class="todo-item ${todo.isCompleted ? 'completed' : ''}">',
        );
        buffer.writeln(
          '      ${todo.isCompleted ? '✓' : '☐'} ${_escapeHtml(todo.text)}',
        );
        buffer.writeln('    </div>');
      }
      buffer.writeln('  </div>');
    }

    buffer.writeln('</body>');
    buffer.writeln('</html>');

    return buffer.toString();
  }

  /// Share note content
  static Future<void> shareNote(Note note, {String format = 'text'}) async {
    String content;
    String fileName;

    switch (format) {
      case 'markdown':
        content = exportAsMarkdown(note);
        fileName = '${_sanitizeFileName(note.title)}.md';
        break;
      case 'html':
        content = exportAsHtml(note);
        fileName = '${_sanitizeFileName(note.title)}.html';
        break;
      default:
        content = exportAsText(note);
        fileName = '${_sanitizeFileName(note.title)}.txt';
    }

    // Create temporary file
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsString(content);

    // Share the file
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: note.title,
      text: 'Shared from MyNotes',
    );
  }

  /// Copy note to clipboard
  static Future<void> copyToClipboard(
    Note note, {
    String format = 'text',
  }) async {
    String content;

    switch (format) {
      case 'markdown':
        content = exportAsMarkdown(note);
        break;
      case 'html':
        content = exportAsHtml(note);
        break;
      default:
        content = exportAsText(note);
    }

    await Clipboard.setData(ClipboardData(text: content));
  }

  /// Save note to file
  static Future<File> saveToFile(Note note, {String format = 'text'}) async {
    String content;
    String extension;

    switch (format) {
      case 'markdown':
        content = exportAsMarkdown(note);
        extension = 'md';
        break;
      case 'html':
        content = exportAsHtml(note);
        extension = 'html';
        break;
      default:
        content = exportAsText(note);
        extension = 'txt';
    }

    final directory = await getApplicationDocumentsDirectory();
    final fileName = '${_sanitizeFileName(note.title)}.$extension';
    final file = File('${directory.path}/$fileName');

    return await file.writeAsString(content);
  }

  /// Export multiple notes
  static Future<void> exportMultipleNotes(
    List<Note> notes, {
    String format = 'text',
  }) async {
    final buffer = StringBuffer();

    for (var note in notes) {
      switch (format) {
        case 'markdown':
          buffer.writeln(exportAsMarkdown(note));
          break;
        case 'html':
          buffer.writeln(exportAsHtml(note));
          break;
        default:
          buffer.writeln(exportAsText(note));
      }
      buffer.writeln('\n${'=' * 80}\n');
    }

    final tempDir = await getTemporaryDirectory();
    final fileName =
        'my_notes_export_${DateTime.now().millisecondsSinceEpoch}.$format';
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsString(buffer.toString());

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'My Notes Export',
      text: '${notes.length} notes exported',
    );
  }

  static String _escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }

  static String _sanitizeFileName(String fileName) {
    return fileName
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
  }

  /// Export as PDF file
  Future<File?> exportPdf({
    required String title,
    required String content,
    List<String>? tags,
    required DateTime createdDate,
    bool includeTags = true,
    bool includeTimestamps = true,
    bool includeMediaRefs = true,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          '${_sanitizeFileName(title)}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory.path}/$fileName');

      // Create PDF content as plain text if pdf package not available
      final pdfContent = _createPdfContent(
        title: title,
        content: content,
        tags: includeTags ? (tags ?? []) : [],
        createdDate: createdDate,
        includeTimestamps: includeTimestamps,
      );

      await file.writeAsString(pdfContent);
      return file;
    } catch (e) {
      print('PDF Export Error: $e');
      return null;
    }
  }

  /// Export as Markdown file
  Future<File?> exportMarkdown({
    required String title,
    required String content,
    List<String>? tags,
    required DateTime createdDate,
    bool includeTags = true,
    bool includeTimestamps = true,
    bool includeMediaRefs = true,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = '${_sanitizeFileName(title)}.md';
      final file = File('${directory.path}/$fileName');

      final mdContent = _createMarkdownContent(
        title: title,
        content: content,
        tags: includeTags ? (tags ?? []) : [],
        createdDate: createdDate,
        includeTimestamps: includeTimestamps,
      );

      await file.writeAsString(mdContent);
      return file;
    } catch (e) {
      return null;
    }
  }

  /// Export as JSON file
  Future<File?> exportJson({
    required String title,
    required String content,
    List<String>? tags,
    required DateTime createdDate,
    bool includeTags = true,
    bool includeTimestamps = true,
    bool includeMediaRefs = true,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = '${_sanitizeFileName(title)}.json';
      final file = File('${directory.path}/$fileName');

      final jsonContent = _createJsonContent(
        title: title,
        content: content,
        tags: includeTags ? (tags ?? []) : [],
        createdDate: createdDate,
        includeTimestamps: includeTimestamps,
      );

      await file.writeAsString(jsonContent);
      return file;
    } catch (e) {
      return null;
    }
  }

  /// Create PDF content (text-based PDF format)
  String _createPdfContent({
    required String title,
    required String content,
    required List<String> tags,
    required DateTime createdDate,
    required bool includeTimestamps,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('%PDF-1.4');
    buffer.writeln('1 0 obj');
    buffer.writeln('<<');
    buffer.writeln('/Type /Catalog');
    buffer.writeln('/Pages 2 0 R');
    buffer.writeln('>>');
    buffer.writeln('endobj');
    buffer.writeln('2 0 obj');
    buffer.writeln('<<');
    buffer.writeln('/Type /Pages');
    buffer.writeln('/Kids [3 0 R]');
    buffer.writeln('/Count 1');
    buffer.writeln('>>');
    buffer.writeln('endobj');
    buffer.writeln('3 0 obj');
    buffer.writeln('<<');
    buffer.writeln('/Type /Page');
    buffer.writeln('/Parent 2 0 R');
    buffer.writeln('/MediaBox [0 0 612 792]');
    buffer.writeln('/Contents 4 0 R');
    buffer.writeln('/Resources <<');
    buffer.writeln('/Font <<');
    buffer.writeln('/F1 5 0 R');
    buffer.writeln('>>');
    buffer.writeln('>>');
    buffer.writeln('>>');
    buffer.writeln('endobj');
    buffer.writeln('4 0 obj');
    buffer.writeln('<<');
    buffer.writeln('/Length 200');
    buffer.writeln('>>');
    buffer.writeln('stream');
    buffer.writeln('BT');
    buffer.writeln('/F1 12 Tf');
    buffer.writeln('50 750 Td');
    buffer.writeln('(${_escapeText(title)}) Tj');
    if (includeTimestamps) {
      buffer.writeln('0 -20 Td');
      buffer.writeln('(Created: ${_escapeText(createdDate.toString())}) Tj');
    }
    if (tags.isNotEmpty) {
      buffer.writeln('0 -20 Td');
      buffer.writeln('(Tags: ${_escapeText(tags.join(", "))}) Tj');
    }
    buffer.writeln('0 -40 Td');
    buffer.writeln('(${_escapeText(content)}) Tj');
    buffer.writeln('ET');
    buffer.writeln('endstream');
    buffer.writeln('endobj');
    buffer.writeln('5 0 obj');
    buffer.writeln('<<');
    buffer.writeln('/Type /Font');
    buffer.writeln('/Subtype /Type1');
    buffer.writeln('/BaseFont /Helvetica');
    buffer.writeln('>>');
    buffer.writeln('endobj');
    buffer.writeln('xref');
    buffer.writeln('0 6');
    buffer.writeln('0000000000 65535 f');
    buffer.writeln('0000000009 00000 n');
    buffer.writeln('0000000058 00000 n');
    buffer.writeln('0000000115 00000 n');
    buffer.writeln('0000000273 00000 n');
    buffer.writeln('0000000542 00000 n');
    buffer.writeln('trailer');
    buffer.writeln('<<');
    buffer.writeln('/Size 6');
    buffer.writeln('/Root 1 0 R');
    buffer.writeln('>>');
    buffer.writeln('startxref');
    buffer.writeln('621');
    buffer.writeln('%%EOF');

    return buffer.toString();
  }

  /// Create Markdown content
  String _createMarkdownContent({
    required String title,
    required String content,
    required List<String> tags,
    required DateTime createdDate,
    required bool includeTimestamps,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('# $title');
    buffer.writeln();
    if (includeTimestamps) {
      buffer.writeln('**Created:** $createdDate');
      buffer.writeln();
    }
    if (tags.isNotEmpty) {
      buffer.writeln('**Tags:** ${tags.map((t) => '#$t').join(' ')}');
      buffer.writeln();
    }
    buffer.writeln('---');
    buffer.writeln();
    buffer.writeln(content);

    return buffer.toString();
  }

  /// Create JSON content
  String _createJsonContent({
    required String title,
    required String content,
    required List<String> tags,
    required DateTime createdDate,
    required bool includeTimestamps,
  }) {
    final jsonData = <String, dynamic>{
      'title': title,
      'content': content,
      'exportedAt': DateTime.now().toIso8601String(),
    };

    if (includeTimestamps) {
      jsonData['createdDate'] = createdDate.toIso8601String();
    }

    if (tags.isNotEmpty) {
      jsonData['tags'] = tags;
    }

    // Manual JSON serialization for better control
    final buffer = StringBuffer();
    buffer.writeln('{');
    buffer.writeln('  "title": "${_escapeJson(title)}",');
    buffer.writeln('  "content": "${_escapeJson(content)}",');
    if (includeTimestamps) {
      buffer.writeln('  "createdDate": "${createdDate.toIso8601String()}",');
    }
    if (tags.isNotEmpty) {
      buffer.writeln(
        '  "tags": [${tags.map((t) => '"${_escapeJson(t)}"').join(', ')}],',
      );
    }
    buffer.writeln('  "exportedAt": "${DateTime.now().toIso8601String()}"');
    buffer.writeln('}');

    return buffer.toString();
  }

  String _escapeText(String text) {
    return text.replaceAll('(', '\\(').replaceAll(')', '\\)');
  }

  String _escapeJson(String text) {
    return text
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\t', '\\t');
  }
}
