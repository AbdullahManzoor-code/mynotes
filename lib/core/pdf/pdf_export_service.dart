import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart' as intl;

/// PDF Export Service
/// Generates proper PDF files from notes with formatting
class PdfExportService {
  PdfExportService._();

  /// Export single note to PDF
  static Future<String> exportNoteToPdf(dynamic note) async {
    final pdf = pw.Document();
    final timestamp = intl.DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());

    // Add page with note content
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Title
              pw.Text(
                note.title ?? 'Note',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),

              // Created date
              pw.Text(
                'Created: ${intl.DateFormat('MMM dd, yyyy HH:mm').format(note.createdAt ?? DateTime.now())}',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 16),

              // Divider
              pw.Divider(),
              pw.SizedBox(height: 16),

              // Content
              pw.Text(
                note.content ?? '',
                style: const pw.TextStyle(fontSize: 12),
              ),
            ],
          );
        },
      ),
    );

    // Save to file
    final directory = await getApplicationDocumentsDirectory();
    final pdfDir = Directory('${directory.path}/exports');

    if (!await pdfDir.exists()) {
      await pdfDir.create(recursive: true);
    }

    final filePath = '${pdfDir.path}/note_$timestamp.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    return filePath;
  }

  /// Export multiple notes to single PDF
  static Future<String> exportMultipleNotesToPdf(List<dynamic> notes) async {
    final pdf = pw.Document();
    final timestamp = intl.DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());

    for (var note in notes) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Title
                pw.Text(
                  note.title ?? 'Note',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),

                // Created date
                pw.Text(
                  'Created: ${intl.DateFormat('MMM dd, yyyy HH:mm').format(note.createdAt ?? DateTime.now())}',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.SizedBox(height: 16),

                // Divider
                pw.Divider(),
                pw.SizedBox(height: 16),

                // Content
                pw.Text(
                  note.content ?? '',
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ],
            );
          },
        ),
      );
    }

    // Save to file
    final directory = await getApplicationDocumentsDirectory();
    final pdfDir = Directory('${directory.path}/exports');

    if (!await pdfDir.exists()) {
      await pdfDir.create(recursive: true);
    }

    final filePath = '${pdfDir.path}/notes_export_$timestamp.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    return filePath;
  }
}

