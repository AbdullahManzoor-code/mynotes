import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'ocr_extraction_event.dart';
part 'ocr_extraction_state.dart';

/// OCR Extraction BLoC for extracting text from images
/// Supports text recognition and editable results
class OcrExtractionBloc extends Bloc<OcrExtractionEvent, OcrExtractionState> {
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
