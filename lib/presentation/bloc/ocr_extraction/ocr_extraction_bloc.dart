// DISABLED (SESSION 15 FIX): OCR handling consolidated to NoteEditorBloc
// The imports below are preserved for reference but not used due to disabled class

// import 'package:bloc/bloc.dart';
// import 'package:equatable/equatable.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// part 'ocr_extraction_event.dart';
// part 'ocr_extraction_state.dart';

/* ════════════════════════════════════════════════════════════════════════════
   CONSOLIDATED (SESSION 15 FIX M007): OCR Handling Unified
   
   REASON FOR DISABLING:
   This BLoC duplicates OCR functionality that exists in:
   - NoteEditorBloc.TextExtractionRequested (PRIMARY OCR handler)
   - Triple duplication across three locations
   
   CONSOLIDATION STRATEGY:
   1. NoteEditorBloc.TextExtractionRequested = Primary OCR path
      - Integrated into note creation/editing workflow
      - Direct integration with media processing  
      - Used in: enhanced_note_editor_screen.dart (lines 727, 752, 1543)
   
   2. This BLoC (OcrExtractionBloc) = DEPRECATED/SECONDARY
      - Kept for reference but not registered in DI
      - If migrating old OCR code, route to NoteEditorBloc instead
   
   MIGRATION PATH (if used elsewhere):
   - Old: OcrExtractionBloc.add(ExtractTextFromImageEvent(imagePath))
   - New: NoteEditorBloc.add(TextExtractionRequested(imagePath))
   
   BENEFITS:
   ✅ Single source of truth for OCR
   ✅ Reduced code duplication (was in 3 places)
   ✅ Simpler maintenance and testing
   ✅ Better UI cohesion (OCR result integrated into note directly)
   
   STATUS: File preserved, class disabled, migration complete
══════════════════════════════════════════════════════════════════════════════ */

/*  ORIGINAL CLASS (DISABLED):

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'ocr_extraction_event.dart';
part 'ocr_extraction_state.dart';
  OcrExtractionBloc() : super(const OcrExtractionInitial()) {
    on<ExtractTextFromImageEvent>(_onExtractTextFromImage);
    on<StartOcrProcessEvent>(_onStartOcrProcess);
    on<CancelOcrProcessEvent>(_onCancelOcrProcess);
    on<SaveExtractedTextEvent>(_onSaveExtractedText);
    on<EditExtractedTextEvent>(_onEditExtractedText);
  }

  Future<void> _onExtractTextFromImage(
    ExtractTextFromImageEvent event,
    Emitter<OcrExtractionState> emit,
  ) async {
    try {
      emit(const OcrExtractionLoading());

      // Mock: In production, use google_mlkit_text_recognition
      // This would call ML Kit for real OCR processing
      final extractedText = 'Extracted text from image...';
      final confidence = 0.92;

      emit(
        TextExtracted(
          text: extractedText,
          confidence: confidence,
          imagePath: event.imagePath,
        ),
      );
    } catch (e) {
      emit(OcrExtractionError(e.toString()));
    }
  }

  Future<void> _onStartOcrProcess(
    StartOcrProcessEvent event,
    Emitter<OcrExtractionState> emit,
  ) async {
    try {
      emit(const OcrExtractionLoading());

      // Start OCR processing with language hints
      // Mock progress updates
      for (int i = 0; i <= 100; i += 20) {
        emit(OcrProcessing(progress: i / 100));
        await Future.delayed(const Duration(milliseconds: 100));
      }
    } catch (e) {
      emit(OcrExtractionError(e.toString()));
    }
  }

  Future<void> _onCancelOcrProcess(
    CancelOcrProcessEvent event,
    Emitter<OcrExtractionState> emit,
  ) async {
    try {
      emit(const OcrExtractionCancelled());
    } catch (e) {
      emit(OcrExtractionError(e.toString()));
    }
  }

  Future<void> _onSaveExtractedText(
    SaveExtractedTextEvent event,
    Emitter<OcrExtractionState> emit,
  ) async {
    try {
      emit(const OcrExtractionLoading());

      // Save to preferences or database
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('ocr_text_${event.imageId}', event.text);

      emit(TextSaved(imageId: event.imageId, text: event.text));
    } catch (e) {
      emit(OcrExtractionError(e.toString()));
    }
  }

  Future<void> _onEditExtractedText(
    EditExtractedTextEvent event,
    Emitter<OcrExtractionState> emit,
  ) async {
    try {
      emit(TextEdited(text: event.editedText, imageId: event.imageId));
    } catch (e) {
      emit(OcrExtractionError(e.toString()));
    }
  }
}
*/
