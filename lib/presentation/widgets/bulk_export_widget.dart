import 'package:flutter/material.dart';
import 'package:mynotes/injection_container.dart';
import 'dart:io';
import 'dart:async';
import '../../core/services/global_ui_service.dart';

enum BulkExportFormat {
  zip('ZIP Archive', '.zip'),
  pdf('Combined PDF', '.pdf'),
  markdown('Markdown Archive', '.zip');

  final String displayName;
  final String extension;

  const BulkExportFormat(this.displayName, this.extension);
}

/// Note item for bulk export
class ExportableNote {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  bool isSelected = false;

  ExportableNote({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.isSelected = false,
  });
}

/// Bulk note export manager
class BulkNoteExportManager {
  static Future<String?> exportNotes({
    required List<ExportableNote> notes,
    required BulkExportFormat format,
    required String destinationPath,
  }) async {
    if (notes.isEmpty) return null;

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'notes_export_$timestamp${format.extension}';
      final filePath = '$destinationPath/$fileName';

      switch (format) {
        case BulkExportFormat.zip:
          return await _generateZipArchive(notes, filePath);
        case BulkExportFormat.pdf:
          return await _generateCombinedPdf(notes, filePath);
        case BulkExportFormat.markdown:
          return await _generateMarkdownArchive(notes, filePath);
      }
    } catch (e) {
      print('Bulk export error: $e');
      return null;
    }
  }

  static Future<String?> _generateZipArchive(
    List<ExportableNote> notes,
    String filePath,
  ) async {
    // Mock ZIP generation
    // In real app, use archive package
    final content = StringBuffer();
    content.writeln('PK\x03\x04'); // ZIP header mock

    for (final note in notes) {
      content.writeln('--\nTitle: ${note.title}');
      content.writeln('Created: ${note.createdAt}');
      content.writeln('Content:\n${note.content}\n');
    }

    final file = File(filePath);
    await file.writeAsString(content.toString());
    return filePath;
  }

  static Future<String?> _generateCombinedPdf(
    List<ExportableNote> notes,
    String filePath,
  ) async {
    // Mock PDF generation
    final content = StringBuffer();
    content.writeln('%PDF-1.4\n');

    for (int i = 0; i < notes.length; i++) {
      final note = notes[i];
      content.writeln('--- Note ${i + 1}: ${note.title} ---');
      content.writeln('Created: ${note.createdAt}');
      content.writeln('${note.content}\n');
      if (i < notes.length - 1) {
        content.writeln('\n\n[Page Break]\n\n');
      }
    }

    final file = File(filePath);
    await file.writeAsString(content.toString());
    return filePath;
  }

  static Future<String?> _generateMarkdownArchive(
    List<ExportableNote> notes,
    String filePath,
  ) async {
    // Mock Markdown archive
    final content = StringBuffer();
    content.writeln('# Notes Export');
    content.writeln('Exported: ${DateTime.now()}\n');
    content.writeln('Total Notes: ${notes.length}\n\n');

    for (final note in notes) {
      content.writeln('## ${note.title}');
      content.writeln('*Created: ${note.createdAt}*\n');
      content.writeln('${note.content}\n\n');
      content.writeln('---\n\n');
    }

    final file = File(filePath);
    await file.writeAsString(content.toString());
    return filePath;
  }
}

/// Bulk export format selector
class BulkExportFormatSelector extends StatelessWidget {
  final Function(BulkExportFormat) onFormatSelected;
  final int noteCount;

  const BulkExportFormatSelector({
    super.key,
    required this.onFormatSelected,
    required this.noteCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Export Format',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(
          '$noteCount note(s) selected',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        SizedBox(height: 16),
        ...BulkExportFormat.values.map((format) {
          return Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(format.displayName),
              subtitle: Text(_getFormatDescription(format)),
              trailing: Icon(Icons.arrow_forward),
              onTap: () => onFormatSelected(format),
            ),
          );
        }),
      ],
    );
  }

  String _getFormatDescription(BulkExportFormat format) {
    switch (format) {
      case BulkExportFormat.zip:
        return 'Individual files in a ZIP archive';
      case BulkExportFormat.pdf:
        return 'All notes combined into one PDF';
      case BulkExportFormat.markdown:
        return 'Markdown formatted in ZIP archive';
    }
  }
}

/// Bulk export progress dialog
class BulkExportProgressDialog extends StatefulWidget {
  final List<ExportableNote> notes;
  final BulkExportFormat format;

  const BulkExportProgressDialog({
    super.key,
    required this.notes,
    required this.format,
  });

  @override
  State<BulkExportProgressDialog> createState() =>
      _BulkExportProgressDialogState();
}

class _BulkExportProgressDialogState extends State<BulkExportProgressDialog> {
  late Future<String?> _exportFuture;
  int _processedCount = 0;

  @override
  void initState() {
    super.initState();
    _exportFuture = _performExport();
  }

  Future<String?> _performExport() async {
    final destinationPath = '/sdcard/Download';

    // Simulate progress updates
    for (int i = 0; i < widget.notes.length; i++) {
      await Future.delayed(Duration(milliseconds: 300));
      if (mounted) {
        setState(() => _processedCount = i + 1);
      }
    }

    return await BulkNoteExportManager.exportNotes(
      notes: widget.notes,
      format: widget.format,
      destinationPath: destinationPath,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Exporting Notes'),
      content: FutureBuilder<String?>(
        future: _exportFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Processing $_processedCount / ${widget.notes.length}'),
                SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _processedCount / widget.notes.length,
                ),
              ],
            );
          } else if (snapshot.hasData && snapshot.data != null) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 48),
                SizedBox(height: 16),
                Text('Export Completed!'),
                SizedBox(height: 8),
                Text(
                  'File saved to:\n${snapshot.data}',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            );
          } else {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error, color: Colors.red, size: 48),
                SizedBox(height: 16),
                Text('Export Failed'),
                SizedBox(height: 8),
                Text(
                  'An error occurred during export',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            );
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close'),
        ),
      ],
    );
  }
}

/// Note selection list for bulk export
class BulkExportNoteSelector extends StatefulWidget {
  final List<ExportableNote> notes;
  final Function(List<ExportableNote>) onNotesSelected;

  const BulkExportNoteSelector({
    super.key,
    required this.notes,
    required this.onNotesSelected,
  });

  @override
  State<BulkExportNoteSelector> createState() => _BulkExportNoteSelectorState();
}

class _BulkExportNoteSelectorState extends State<BulkExportNoteSelector> {
  late List<ExportableNote> _selectedNotes;

  @override
  void initState() {
    super.initState();
    _selectedNotes = widget.notes.where((n) => n.isSelected).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Select Notes to Export',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TextButton(
              onPressed: _selectedNotes.length == widget.notes.length
                  ? () => setState(() => _selectedNotes.clear())
                  : () => setState(
                      () => _selectedNotes = List.from(widget.notes),
                    ),
              child: Text(
                _selectedNotes.length == widget.notes.length
                    ? 'Deselect All'
                    : 'Select All',
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          '${_selectedNotes.length} / ${widget.notes.length} selected',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: widget.notes.length,
            itemBuilder: (context, index) {
              final note = widget.notes[index];
              final isSelected = _selectedNotes.contains(note);

              return CheckboxListTile(
                value: isSelected,
                onChanged: (selected) {
                  setState(() {
                    if (selected == true) {
                      _selectedNotes.add(note);
                    } else {
                      _selectedNotes.remove(note);
                    }
                  });
                  widget.onNotesSelected(_selectedNotes);
                },
                title: Text(note.title),
                subtitle: Text(note.createdAt.toString().split('.')[0]),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Main bulk export dialog
class BulkExportNotesDialog extends StatefulWidget {
  final List<ExportableNote> notes;
  final VoidCallback? onExportComplete;

  const BulkExportNotesDialog({
    super.key,
    required this.notes,
    this.onExportComplete,
  });

  static void show(BuildContext context, List<ExportableNote> notes) {
    showDialog(
      context: context,
      builder: (context) => BulkExportNotesDialog(notes: notes),
    );
  }

  @override
  State<BulkExportNotesDialog> createState() => _BulkExportNotesDialogState();
}

class _BulkExportNotesDialogState extends State<BulkExportNotesDialog> {
  late List<ExportableNote> _selectedNotes;
  BulkExportFormat? _selectedFormat;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _selectedNotes = widget.notes.where((n) => n.isSelected).toList();
  }

  void _proceedToFormat() {
    if (_selectedNotes.isEmpty) {
      getIt<GlobalUiService>().showWarning('Please select at least one note');
      return;
    }
    setState(() => _currentStep = 1);
  }

  void _startExport() {
    if (_selectedFormat == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BulkExportProgressDialog(
        notes: _selectedNotes,
        format: _selectedFormat!,
      ),
    ).then((_) {
      widget.onExportComplete?.call();
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_currentStep == 0 ? 'Select Notes' : 'Select Format'),
      content: SingleChildScrollView(
        child: _currentStep == 0
            ? BulkExportNoteSelector(
                notes: widget.notes,
                onNotesSelected: (selected) => _selectedNotes = selected,
              )
            : BulkExportFormatSelector(
                noteCount: _selectedNotes.length,
                onFormatSelected: (format) {
                  setState(() => _selectedFormat = format);
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        if (_currentStep == 1)
          TextButton(
            onPressed: () => setState(() => _currentStep = 0),
            child: Text('Back'),
          ),
        FilledButton(
          onPressed: _currentStep == 0
              ? _proceedToFormat
              : (_selectedFormat == null ? null : _startExport),
          child: Text(_currentStep == 0 ? 'Next' : 'Export'),
        ),
      ],
    );
  }
}

/// Bulk export button
class BulkExportButton extends StatelessWidget {
  final List<ExportableNote> notes;
  final VoidCallback? onExportComplete;

  const BulkExportButton({
    super.key,
    required this.notes,
    this.onExportComplete,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.download),
      tooltip: 'Bulk Export',
      onPressed: () => BulkExportNotesDialog.show(context, notes),
    );
  }
}


