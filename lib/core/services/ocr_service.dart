import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:pdf/pdf.dart' hide PdfDocument;
import 'package:syncfusion_flutter_pdf/pdf.dart';

/// OCR Service for extracting text from images and PDFs
class OCRService {
  static final OCRService _instance = OCRService._internal();
  final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  OCRService._internal();

  factory OCRService() {
    return _instance;
  }

  /// Extract text from image file
  Future<String> extractText(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText recognizedText = await _textRecognizer.processImage(
        inputImage,
      );
      return recognizedText.text;
    } catch (e) {
      print('OCR image extraction error: $e');
      return '';
    }
  }

  /// Extract text from PDF file
  Future<String> extractTextFromPDF(String pdfPath) async {
    try {
      final File file = File(pdfPath);
      final List<int> bytes = await file.readAsBytes();

      // Load the PDF document
      final PdfDocument document = PdfDocument(inputBytes: bytes);

      // Create PDF text extractor to extract text
      final PdfTextExtractor extractor = PdfTextExtractor(document);

      // Extract all the text from the document
      final String text = extractor.extractText();

      // Dispose the document
      document.dispose();

      return text;
    } catch (e) {
      print('OCR PDF extraction error: $e');
      // If PDF extraction fails, maybe it's a scanned PDF?
      // In a more advanced version, we could convert PDF pages to images and then OCR them.
      return 'Error extracting text from PDF: $e';
    }
  }

  /// Extract text from DOCX (Mock/Simulated since DOCX extraction is complex)
  Future<String> extractTextFromDoc(String docPath) async {
    // For now, return a placeholder as DOCX text extraction requires more dependencies
    return 'Text extraction for .docx/.pptx is currently simulated. Path: $docPath';
  }

  /// Generic extract text method based on file extension
  Future<String> extractTextFromFile(String filePath) async {
    final extension = filePath.split('.').last.toLowerCase();

    if (['jpg', 'jpeg', 'png', 'bmp', 'webp'].contains(extension)) {
      return await extractText(filePath);
    } else if (extension == 'pdf') {
      return await extractTextFromPDF(filePath);
    } else if (['doc', 'docx', 'ppt', 'pptx'].contains(extension)) {
      return await extractTextFromDoc(filePath);
    } else {
      return 'Unsupported file type for text extraction: $extension';
    }
  }

  /// Extract text with confidence scores (Images only)
  Future<Map<String, dynamic>> extractTextWithDetails(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText recognizedText = await _textRecognizer.processImage(
        inputImage,
      );

      return {
        'text': recognizedText.text,
        'blocks': recognizedText.blocks
            .map(
              (block) => {
                'text': block.text,
                'boundingBox': block.boundingBox,
                'lines': block.lines.map((line) => line.text).toList(),
              },
            )
            .toList(),
      };
    } catch (e) {
      return {'text': '', 'error': e.toString()};
    }
  }

  /// Cleanup resources
  void dispose() {
    _textRecognizer.close();
  }
}
