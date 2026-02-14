import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../presentation/pages/pdf_annotation_screen.dart'; // For AnnotationTool and Annotation

abstract class PdfAnnotationEvent extends Equatable {
  const PdfAnnotationEvent();

  @override
  List<Object?> get props => [];
}

class LoadPdfAnnotations extends PdfAnnotationEvent {
  final String pdfPath;
  const LoadPdfAnnotations(this.pdfPath);

  @override
  List<Object?> get props => [pdfPath];
}

class StartDrawing extends PdfAnnotationEvent {
  final Offset point;
  const StartDrawing(this.point);

  @override
  List<Object?> get props => [point];
}

class UpdateDrawing extends PdfAnnotationEvent {
  final Offset point;
  const UpdateDrawing(this.point);

  @override
  List<Object?> get props => [point];
}

class EndDrawing extends PdfAnnotationEvent {
  const EndDrawing();
}

class UndoAnnotation extends PdfAnnotationEvent {
  const UndoAnnotation();
}

class RedoAnnotation extends PdfAnnotationEvent {
  const RedoAnnotation();
}

class ClearAnnotations extends PdfAnnotationEvent {
  const ClearAnnotations();
}

class SelectAnnotationTool extends PdfAnnotationEvent {
  final AnnotationTool tool;
  const SelectAnnotationTool(this.tool);

  @override
  List<Object?> get props => [tool];
}

class ChangeAnnotationColor extends PdfAnnotationEvent {
  final Color color;
  const ChangeAnnotationColor(this.color);

  @override
  List<Object?> get props => [color];
}

class ChangeAnnotationOpacity extends PdfAnnotationEvent {
  final double opacity;
  const ChangeAnnotationOpacity(this.opacity);

  @override
  List<Object?> get props => [opacity];
}

class ChangePdfPage extends PdfAnnotationEvent {
  final int page;
  const ChangePdfPage(this.page);

  @override
  List<Object?> get props => [page];
}

class SavePdfAnnotations extends PdfAnnotationEvent {
  const SavePdfAnnotations();
}
