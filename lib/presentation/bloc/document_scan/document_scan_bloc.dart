import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

// Events
abstract class DocumentScanEvent extends Equatable {
  const DocumentScanEvent();

  @override
  List<Object?> get props => [];
}

class CaptureImage extends DocumentScanEvent {
  final ImageSource source;
  const CaptureImage(this.source);

  @override
  List<Object?> get props => [source];
}

class ResetScanner extends DocumentScanEvent {
  const ResetScanner();
}

// State
enum DocumentScanStatus { initial, processing, success, failure }

class DocumentScanState extends Equatable {
  final File? capturedImage;
  final String extractedText;
  final DocumentScanStatus status;
  final String errorMessage;

  const DocumentScanState({
    this.capturedImage,
    this.extractedText = '',
    this.status = DocumentScanStatus.initial,
    this.errorMessage = '',
  });

  DocumentScanState copyWith({
    File? capturedImage,
    String? extractedText,
    DocumentScanStatus? status,
    String? errorMessage,
  }) {
    return DocumentScanState(
      capturedImage: capturedImage ?? this.capturedImage,
      extractedText: extractedText ?? this.extractedText,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    capturedImage,
    extractedText,
    status,
    errorMessage,
  ];
}

// Bloc
class DocumentScanBloc extends Bloc<DocumentScanEvent, DocumentScanState> {
  final ImagePicker _picker = ImagePicker();

  DocumentScanBloc() : super(const DocumentScanState()) {
    on<CaptureImage>(_onCaptureImage);
    on<ResetScanner>(_onResetScanner);
  }

  void _onResetScanner(ResetScanner event, Emitter<DocumentScanState> emit) {
    emit(const DocumentScanState());
  }

  Future<void> _onCaptureImage(
    CaptureImage event,
    Emitter<DocumentScanState> emit,
  ) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: event.source,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image != null) {
        emit(
          state.copyWith(
            capturedImage: File(image.path),
            status: DocumentScanStatus.processing,
            errorMessage: '',
          ),
        );

        await _processImage(emit);
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: DocumentScanStatus.failure,
          errorMessage: 'Failed to capture image: $e',
        ),
      );
    }
  }

  Future<void> _processImage(Emitter<DocumentScanState> emit) async {
    try {
      // Simulate OCR processing
      await Future.delayed(const Duration(seconds: 3));

      // Mock extracted text - replace with actual OCR implementation
      const mockText = '''Sample extracted text from the scanned document.

This is where the OCR technology would extract the text content from the captured image. The text recognition would identify:

• Headers and titles
• Body paragraphs
• Lists and bullet points
• Tables and structured data

The accuracy depends on image quality, lighting conditions, and font clarity.''';

      emit(
        state.copyWith(
          extractedText: mockText,
          status: DocumentScanStatus.success,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: DocumentScanStatus.failure,
          errorMessage: 'Failed to process image: $e',
        ),
      );
    }
  }
}
