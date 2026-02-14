import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'pdf_annotation_event.dart';
import 'pdf_annotation_state.dart';
import '../../../presentation/pages/pdf_annotation_screen.dart'; // For AnnotationTool and Annotation

class PdfAnnotationBloc extends Bloc<PdfAnnotationEvent, PdfAnnotationState> {
  PdfAnnotationBloc() : super(const PdfAnnotationState()) {
    on<LoadPdfAnnotations>(_onLoadPdfAnnotations);
    on<StartDrawing>(_onStartDrawing);
    on<UpdateDrawing>(_onUpdateDrawing);
    on<EndDrawing>(_onEndDrawing);
    on<UndoAnnotation>(_onUndoAnnotation);
    on<RedoAnnotation>(_onRedoAnnotation);
    on<ClearAnnotations>(_onClearAnnotations);
    on<SelectAnnotationTool>(_onSelectAnnotationTool);
    on<ChangeAnnotationColor>(_onChangeAnnotationColor);
    on<ChangeAnnotationOpacity>(_onChangeAnnotationOpacity);
    on<ChangePdfPage>(_onChangePdfPage);
    on<SavePdfAnnotations>(_onSavePdfAnnotations);
  }

  void _onLoadPdfAnnotations(
    LoadPdfAnnotations event,
    Emitter<PdfAnnotationState> emit,
  ) {
    emit(
      state.copyWith(pdfPath: event.pdfPath, totalPages: 5),
    ); // Placeholder total pages
  }

  void _onStartDrawing(StartDrawing event, Emitter<PdfAnnotationState> emit) {
    emit(state.copyWith(currentStroke: [event.point]));
  }

  void _onUpdateDrawing(UpdateDrawing event, Emitter<PdfAnnotationState> emit) {
    final updatedStroke = List<Offset>.from(state.currentStroke)
      ..add(event.point);
    emit(state.copyWith(currentStroke: updatedStroke));
  }

  void _onEndDrawing(EndDrawing event, Emitter<PdfAnnotationState> emit) {
    if (state.currentStroke.isNotEmpty) {
      final newAnnotation = Annotation(
        points: List<Offset>.from(state.currentStroke),
        color: state.selectedColor,
        opacity: state.selectedOpacity,
        tool: state.selectedTool,
        // createdAt: DateTime.now(),
      );

      final updatedAnnotations = List<Annotation>.from(state.annotations)
        ..add(newAnnotation);
      emit(
        state.copyWith(
          annotations: updatedAnnotations,
          currentStroke: [],
          undoStack: [], // Clear redo stack on new action
        ),
      );
    }
  }

  void _onUndoAnnotation(
    UndoAnnotation event,
    Emitter<PdfAnnotationState> emit,
  ) {
    if (state.annotations.isNotEmpty) {
      final updatedAnnotations = List<Annotation>.from(state.annotations);
      final removed = updatedAnnotations.removeLast();
      final updatedUndoStack = List<Annotation>.from(state.undoStack)
        ..add(removed);
      emit(
        state.copyWith(
          annotations: updatedAnnotations,
          undoStack: updatedUndoStack,
        ),
      );
    }
  }

  void _onRedoAnnotation(
    RedoAnnotation event,
    Emitter<PdfAnnotationState> emit,
  ) {
    if (state.undoStack.isNotEmpty) {
      final updatedUndoStack = List<Annotation>.from(state.undoStack);
      final restored = updatedUndoStack.removeLast();
      final updatedAnnotations = List<Annotation>.from(state.annotations)
        ..add(restored);
      emit(
        state.copyWith(
          annotations: updatedAnnotations,
          undoStack: updatedUndoStack,
        ),
      );
    }
  }

  void _onClearAnnotations(
    ClearAnnotations event,
    Emitter<PdfAnnotationState> emit,
  ) {
    emit(state.copyWith(annotations: [], undoStack: [], currentStroke: []));
  }

  void _onSelectAnnotationTool(
    SelectAnnotationTool event,
    Emitter<PdfAnnotationState> emit,
  ) {
    emit(state.copyWith(selectedTool: event.tool));
  }

  void _onChangeAnnotationColor(
    ChangeAnnotationColor event,
    Emitter<PdfAnnotationState> emit,
  ) {
    emit(state.copyWith(selectedColor: event.color));
  }

  void _onChangeAnnotationOpacity(
    ChangeAnnotationOpacity event,
    Emitter<PdfAnnotationState> emit,
  ) {
    emit(state.copyWith(selectedOpacity: event.opacity));
  }

  void _onChangePdfPage(ChangePdfPage event, Emitter<PdfAnnotationState> emit) {
    if (event.page >= 1 && event.page <= state.totalPages) {
      emit(state.copyWith(currentPage: event.page));
    }
  }

  void _onSavePdfAnnotations(
    SavePdfAnnotations event,
    Emitter<PdfAnnotationState> emit,
  ) async {
    emit(state.copyWith(isSaving: true));
    // Simulate save
    await Future.delayed(const Duration(seconds: 1));
    emit(state.copyWith(isSaving: false));
  }
}
