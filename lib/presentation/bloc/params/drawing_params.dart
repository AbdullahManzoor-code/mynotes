import 'package:equatable/equatable.dart';

/// Complete Param Model for Drawing Canvas Operations
/// 📦 Container for all drawing-related data
class DrawingParams extends Equatable {
  final String? drawingId;
  final List<dynamic> strokes; // List of drawing strokes
  final String backgroundColor;
  final String strokeColor;
  final double strokeWidth;
  final bool isErasing;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? noteId;

  const DrawingParams({
    this.drawingId,
    this.strokes = const [],
    this.backgroundColor = '#FFFFFF',
    this.strokeColor = '#000000',
    this.strokeWidth = 2.0,
    this.isErasing = false,
    this.createdAt,
    this.updatedAt,
    this.noteId,
  });

  DrawingParams copyWith({
    String? drawingId,
    List<dynamic>? strokes,
    String? backgroundColor,
    String? strokeColor,
    double? strokeWidth,
    bool? isErasing,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? noteId,
  }) {
    return DrawingParams(
      drawingId: drawingId ?? this.drawingId,
      strokes: strokes ?? this.strokes,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      strokeColor: strokeColor ?? this.strokeColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      isErasing: isErasing ?? this.isErasing,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      noteId: noteId ?? this.noteId,
    );
  }

  DrawingParams addStroke(dynamic stroke) {
    return copyWith(strokes: [...strokes, stroke]);
  }

  DrawingParams clearDrawing() => copyWith(strokes: []);
  DrawingParams toggleEraser() => copyWith(isErasing: !isErasing);

  @override
  List<Object?> get props => [
    drawingId,
    strokes,
    backgroundColor,
    strokeColor,
    strokeWidth,
    isErasing,
    createdAt,
    updatedAt,
    noteId,
  ];
}
