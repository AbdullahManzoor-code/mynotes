import 'package:equatable/equatable.dart';

/// Complete Param Model for OCR Extraction Operations
/// 📦 Container for all OCR-related data
class OcrParams extends Equatable {
  final String? ocrId;
  final String imagePath;
  final String language;
  final bool detectText;
  final bool detectTables;
  final String? extractedText;
  final String? extractedTableData;
  final double? confidence;
  final DateTime? extractedAt;
  final String? noteId;

  const OcrParams({
    this.ocrId,
    required this.imagePath,
    this.language = 'en',
    this.detectText = true,
    this.detectTables = false,
    this.extractedText,
    this.extractedTableData,
    this.confidence,
    this.extractedAt,
    this.noteId,
  });

  OcrParams copyWith({
    String? ocrId,
    String? imagePath,
    String? language,
    bool? detectText,
    bool? detectTables,
    String? extractedText,
    String? extractedTableData,
    double? confidence,
    DateTime? extractedAt,
    String? noteId,
  }) {
    return OcrParams(
      ocrId: ocrId ?? this.ocrId,
      imagePath: imagePath ?? this.imagePath,
      language: language ?? this.language,
      detectText: detectText ?? this.detectText,
      detectTables: detectTables ?? this.detectTables,
      extractedText: extractedText ?? this.extractedText,
      extractedTableData: extractedTableData ?? this.extractedTableData,
      confidence: confidence ?? this.confidence,
      extractedAt: extractedAt ?? this.extractedAt,
      noteId: noteId ?? this.noteId,
    );
  }

  @override
  List<Object?> get props => [
    ocrId,
    imagePath,
    language,
    detectText,
    detectTables,
    extractedText,
    extractedTableData,
    confidence,
    extractedAt,
    noteId,
  ];
}
