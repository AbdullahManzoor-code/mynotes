import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import './permission_handler_service.dart';

/// Model for scanned document
class ScannedDocument {
  final String id;
  final List<String> pagePaths; // Paths to scanned page images
  final String title;
  final DateTime createdAt;
  final String? ocrText; // Extracted text from OCR

  ScannedDocument({
    required this.id,
    required this.pagePaths,
    required this.title,
    required this.createdAt,
    this.ocrText,
  });

  /// Get document folder path
  Future<String> getFolderPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/scanned_docs/$id';
  }
}

/// Service for document scanning and processing
class DocumentScannerService {
  static final DocumentScannerService _instance =
      DocumentScannerService._internal();
  final PermissionHandlerService _permissionService =
      PermissionHandlerService();

  DocumentScannerService._internal();

  factory DocumentScannerService() {
    return _instance;
  }

  /// Start document scanning using cunning_document_scanner
  Future<ScannedDocument?> scanDocument({required String documentTitle}) async {
    try {
      final hasPermission = await _permissionService.requestCameraPermission();
      if (!hasPermission) {
        return null;
      }

      final List<String>? images = await CunningDocumentScanner.getPictures();
      if (images == null || images.isEmpty) {
        return null;
      }

      return ScannedDocument(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        pagePaths: images,
        title: documentTitle,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      print('Error scanning document: $e');
    }
    return null;
  }

  /// Add page to existing document
  Future<List<String>?> scanAdditionalPages() async {
    try {
      final hasPermission = await _permissionService.requestCameraPermission();
      if (!hasPermission) {
        return null;
      }

      return await CunningDocumentScanner.getPictures();
    } catch (e) {
      print('Error adding pages to document: $e');
    }
    return null;
  }

  /// Extract text from scanned document using ML Kit
  Future<String?> extractTextFromPages(List<String> pagePaths) async {
    try {
      final textRecognizer = TextRecognizer(
        script: TextRecognitionScript.latin,
      );
      final buffer = StringBuffer();

      for (final path in pagePaths) {
        final inputImage = InputImage.fromFilePath(path);
        final RecognizedText recognizedText = await textRecognizer.processImage(
          inputImage,
        );
        buffer.writeln(recognizedText.text);
        buffer.writeln('\n---PAGE BREAK---\n');
      }

      await textRecognizer.close();
      return buffer.toString().trim();
    } catch (e) {
      print('Error extracting text: $e');
    }
    return null;
  }

  /// Convert scanned document pages to PDF using pdf package
  Future<String?> convertToPDF(
    String documentId,
    List<String> pagePaths,
  ) async {
    try {
      final pdf = pw.Document();

      for (final imagePath in pagePaths) {
        final imageFile = File(imagePath);
        if (!await imageFile.exists()) continue;

        final image = pw.MemoryImage(imageFile.readAsBytesSync());
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.FullPage(
                ignoreMargins: true,
                child: pw.Image(image, fit: pw.BoxFit.contain),
              );
            },
          ),
        );
      }

      final docDir = await getApplicationDocumentsDirectory();
      final pdfFile = File('${docDir.path}/scanned_docs/$documentId.pdf');

      if (!await pdfFile.parent.exists()) {
        await pdfFile.parent.create(recursive: true);
      }

      await pdfFile.writeAsBytes(await pdf.save());
      return pdfFile.path;
    } catch (e) {
      print('Error converting to PDF: $e');
    }
    return null;
  }

  /// Delete entire scanned document
  Future<bool> deleteDocument(String documentId) async {
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final docFolder = Directory('${docDir.path}/scanned_docs/$documentId');

      if (await docFolder.exists()) {
        await docFolder.delete(recursive: true);
        return true;
      }
    } catch (e) {
      print('Error deleting document: $e');
    }
    return false;
  }

  /// Get all scanned documents
  Future<List<ScannedDocument>> getAllDocuments() async {
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final docsFolder = Directory('${docDir.path}/scanned_docs');

      if (!await docsFolder.exists()) {
        return [];
      }

      final documents = <ScannedDocument>[];
      final items = docsFolder.listSync();

      for (final item in items) {
        if (item is Directory) {
          final pages = Directory(
            item.path,
          ).listSync().whereType<File>().map((f) => f.path).toList();

          if (pages.isNotEmpty) {
            documents.add(
              ScannedDocument(
                id: item.path.split('/').last,
                pagePaths: pages,
                title: 'Document ${item.path.split('/').last}',
                createdAt: item.statSync().modified,
              ),
            );
          }
        }
      }

      return documents;
    } catch (e) {
      print('Error getting documents: $e');
    }
    return [];
  }
}
