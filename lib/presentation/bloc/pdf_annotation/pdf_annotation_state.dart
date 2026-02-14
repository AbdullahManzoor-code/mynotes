import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/presentation/pages/pdf_annotation_screen.dart'
    show AnnotationTool, Annotation;

class PdfAnnotationState extends Equatable {
  final List<Annotation> annotations;
  final List<Annotation> undoStack;
  final List<Offset> currentStroke;
  final AnnotationTool selectedTool;
  final Color selectedColor;
  final double selectedOpacity;
  final int currentPage;
  final int totalPages;
  final bool isSaving;
  final String? pdfPath;
  final String? errorMessage;

  const PdfAnnotationState({
    this.annotations = const [],
    this.undoStack = const [],
    this.currentStroke = const [],
    this.selectedTool = AnnotationTool.pen,
    this.selectedColor = Colors.black,
    this.selectedOpacity = 1.0,
    this.currentPage = 1,
    this.totalPages = 1,
    this.isSaving = false,
    this.pdfPath,
    this.errorMessage,
  });

  PdfAnnotationState copyWith({
    List<Annotation>? annotations,
    List<Annotation>? undoStack,
    List<Offset>? currentStroke,
    AnnotationTool? selectedTool,
    Color? selectedColor,
    double? selectedOpacity,
    int? currentPage,
    int? totalPages,
    bool? isSaving,
    String? pdfPath,
    String? errorMessage,
  }) {
    return PdfAnnotationState(
      annotations: annotations ?? this.annotations,
      undoStack: undoStack ?? this.undoStack,
      currentStroke: currentStroke ?? this.currentStroke,
      selectedTool: selectedTool ?? this.selectedTool,
      selectedColor: selectedColor ?? this.selectedColor,
      selectedOpacity: selectedOpacity ?? this.selectedOpacity,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      isSaving: isSaving ?? this.isSaving,
      pdfPath: pdfPath ?? this.pdfPath,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    annotations,
    undoStack,
    currentStroke,
    selectedTool,
    selectedColor,
    selectedOpacity,
    currentPage,
    totalPages,
    isSaving,
    pdfPath,
    errorMessage,
  ];
}
