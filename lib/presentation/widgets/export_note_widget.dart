import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import '../bloc/export_bloc.dart';

enum ExportFormat {
  txt('Text File', '.txt'),
  markdown('Markdown', '.md'),
  html('HTML', '.html'),
  pdf('PDF', '.pdf');

  final String displayName;
  final String extension;

  const ExportFormat(this.displayName, this.extension);
}

/// Single note export manager
class NoteExportManager {
  static Future<String?> exportNote({
    required String title,
    required String content,
    required ExportFormat format,
    required String destinationPath,
  }) async {
    try {
      final fileName = _sanitizeFileName(title) + format.extension;
      final filePath = '$destinationPath/$fileName';
      final file = File(filePath);

      String fileContent;
      switch (format) {
        case ExportFormat.txt:
          fileContent = _generateTxt(title, content);
        case ExportFormat.markdown:
          fileContent = _generateMarkdown(title, content);
        case ExportFormat.html:
          fileContent = _generateHtml(title, content);
        case ExportFormat.pdf:
          fileContent = _generatePdf(title, content);
      }

      await file.writeAsString(fileContent);
      return filePath;
    } catch (e) {
      print('Export error: $e');
      return null;
    }
  }

  static String _generateTxt(String title, String content) {
    return '''$title
${DateTime.now().toString()}

$content
''';
  }

  static String _generateMarkdown(String title, String content) {
    return '''# $title

**Exported:** ${DateTime.now()}

---

$content
''';
  }

  static String _generateHtml(String title, String content) {
    final escapedContent = content
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('\n', '<br/>');

    return '''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$title</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; line-height: 1.6; }
        h1 { color: #333; border-bottom: 2px solid #333; padding-bottom: 10px; }
        .meta { color: #666; font-size: 0.9em; font-style: italic; margin-bottom: 20px; }
        .content { color: #444; }
    </style>
</head>
<body>
    <h1>$title</h1>
    <div class="meta">Exported: ${DateTime.now()}</div>
    <div class="content">$escapedContent</div>
</body>
</html>''';
  }

  static String _generatePdf(String title, String content) {
    // Mock PDF generation - in real app use pdf package
    return '''%PDF-1.4
1 0 obj
<< /Type /Catalog /Pages 2 0 R >>
endobj
2 0 obj
<< /Type /Pages /Kids [3 0 R] /Count 1 >>
endobj
3 0 obj
<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] /Contents 4 0 R >>
endobj
4 0 obj
<< /Length 100 >>
stream
BT
/F1 12 Tf
50 750 Td
($title) Tj
ET
endstream
endobj
xref
0 5
0000000000 65535 f
0000000009 00000 n
0000000058 00000 n
0000000115 00000 n
0000000203 00000 n
trailer
<< /Size 5 /Root 1 0 R >>
startxref
352
%%EOF''';
  }

  static String _sanitizeFileName(String fileName) {
    final sanitized = fileName
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '')
        .replaceAll(RegExp(r'\s+'), '_');
    return sanitized.length > 255 ? sanitized.substring(0, 255) : sanitized;
  }
}

/// Export format selector widget
class ExportFormatSelector extends StatelessWidget {
  final Function(ExportFormat) onFormatSelected;

  const ExportFormatSelector({Key? key, required this.onFormatSelected})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Export Format',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 16),
        ...ExportFormat.values.map((format) {
          return Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(format.displayName),
              subtitle: Text('Format: ${format.extension}'),
              trailing: Icon(Icons.arrow_forward),
              onTap: () => onFormatSelected(format),
            ),
          );
        }).toList(),
      ],
    );
  }
}

/// Export dialog for single note
class ExportNoteDialog extends StatefulWidget {
  final String title;
  final String content;
  final VoidCallback? onExportComplete;

  const ExportNoteDialog({
    Key? key,
    required this.title,
    required this.content,
    this.onExportComplete,
  }) : super(key: key);

  static void show(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => ExportNoteDialog(title: title, content: content),
    );
  }

  @override
  State<ExportNoteDialog> createState() => _ExportNoteDialogState();
}

class _ExportNoteDialogState extends State<ExportNoteDialog> {
  ExportFormat? _selectedFormat;
  bool _isExporting = false;
  String? _exportStatus;

  Future<void> _performExport() async {
    if (_selectedFormat == null) return;

    setState(() {
      _isExporting = true;
      _exportStatus = 'Exporting...';
    });

    try {
      // Get Downloads directory (mock path - use path_provider in real app)
      final downloadsPath = '/sdcard/Download';

      final filePath = await NoteExportManager.exportNote(
        title: widget.title,
        content: widget.content,
        format: _selectedFormat!,
        destinationPath: downloadsPath,
      );

      if (filePath != null) {
        setState(() {
          _exportStatus = 'Exported to:\n$filePath';
        });

        widget.onExportComplete?.call();

        // Auto-close after 2 seconds
        Future.delayed(Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      } else {
        setState(() {
          _exportStatus = 'Export failed';
        });
      }
    } catch (e) {
      setState(() {
        _exportStatus = 'Error: $e';
      });
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Export Note'),
      content: SingleChildScrollView(
        child: _selectedFormat == null
            ? ExportFormatSelector(
                onFormatSelected: (format) {
                  setState(() => _selectedFormat = format);
                },
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Format: ${_selectedFormat!.displayName}'),
                  SizedBox(height: 8),
                  Text(
                    'File: ${_sanitizeFileName(widget.title)}${_selectedFormat!.extension}',
                  ),
                  if (_exportStatus != null) ...[
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_exportStatus!),
                    ),
                  ],
                ],
              ),
      ),
      actions: [
        if (_selectedFormat != null)
          TextButton(
            onPressed: () => setState(() => _selectedFormat = null),
            child: Text('Back'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        if (_selectedFormat != null)
          FilledButton(
            onPressed: _isExporting ? null : _performExport,
            child: _isExporting
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('Export'),
          ),
      ],
    );
  }

  String _sanitizeFileName(String fileName) {
    final sanitized = fileName
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '')
        .replaceAll(RegExp(r'\s+'), '_');
    return sanitized.length > 50 ? sanitized.substring(0, 50) : sanitized;
  }
}

/// Export button widget
class ExportNoteButton extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback? onExportComplete;

  const ExportNoteButton({
    Key? key,
    required this.title,
    required this.content,
    this.onExportComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.download),
      tooltip: 'Export Note',
      onPressed: () => ExportNoteDialog.show(context, title, content),
    );
  }
}
