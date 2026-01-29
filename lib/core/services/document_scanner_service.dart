import 'dart:io';
import 'package:path_provider/path_provider.dart';
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

  /// Start document scanning (integrate with document_scanner_sdk)
  Future<ScannedDocument?> scanDocument({required String documentTitle}) async {
    try {
      final hasPermission = await _permissionService.requestCameraPermission();
      if (!hasPermission) {
        return null;
      }

      // In a real app, integrate with flutter_document_scanner or similar
      // For now, return mock scanned document
      final docDir = await getApplicationDocumentsDirectory();
      final docFolder =
          '${docDir.path}/scanned_docs/${DateTime.now().millisecondsSinceEpoch}';

      // Create folder
      await Directory(docFolder).create(recursive: true);

      // Mock: Create placeholder for scanned pages
      final pages = ['$docFolder/page_1.jpg', '$docFolder/page_2.jpg'];

      for (final pagePath in pages) {
        File(pagePath).createSync(recursive: true);
      }

      return ScannedDocument(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        pagePaths: pages,
        title: documentTitle,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      print('Error scanning document: $e');
    }
    return null;
  }

  /// Add page to existing document
  Future<String?> scanAdditionalPage(String documentId) async {
    try {
      final hasPermission = await _permissionService.requestCameraPermission();
      if (!hasPermission) {
        return null;
      }

      final docDir = await getApplicationDocumentsDirectory();
      final docFolder = '${docDir.path}/scanned_docs/$documentId';

      // Get existing pages count
      final dir = Directory(docFolder);
      final pages = await dir.list().toList();
      final nextPageNum = pages.length + 1;

      final pagePath = '$docFolder/page_$nextPageNum.jpg';
      File(pagePath).createSync(recursive: true);

      return pagePath;
    } catch (e) {
      print('Error adding page to document: $e');
    }
    return null;
  }

  /// Delete a page from document
  Future<bool> deletePage(String pagePath) async {
    try {
      final file = File(pagePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
    } catch (e) {
      print('Error deleting page: $e');
    }
    return false;
  }

  /// Reorder pages in document
  Future<bool> reorderPages(String documentId, List<String> pageOrder) async {
    try {
      // Implementation would handle page reordering
      // For mock: just validate the order
      return pageOrder.isNotEmpty;
    } catch (e) {
      print('Error reordering pages: $e');
    }
    return false;
  }

  /// Extract text from scanned document using OCR
  /// In production, integrate with google_mlkit_text_recognition
  Future<String?> extractTextFromPages(List<String> pagePaths) async {
    try {
      // Mock OCR extraction
      // In real app, use google_mlkit or similar
      final ocrTexts = <String>[];

      for (final pagePath in pagePaths) {
        // Simulate OCR processing
        ocrTexts.add('Scanned text from $pagePath');
      }

      return ocrTexts.join('\n---PAGE BREAK---\n');
    } catch (e) {
      print('Error extracting text: $e');
    }
    return null;
  }

  /// Convert scanned document pages to PDF
  Future<String?> convertToPDF(
    String documentId,
    List<String> pagePaths,
  ) async {
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final pdfPath = '${docDir.path}/scanned_docs/$documentId.pdf';

      // Mock: In real app, use pdf package or similar to merge images into PDF
      File(pdfPath).createSync(recursive: true);

      return pdfPath;
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
