part of 'ocr_extraction_bloc.dart';

abstract class OcrExtractionState extends Equatable {
  const OcrExtractionState();

  @override
  List<Object?> get props => [];
}

class OcrExtractionInitial extends OcrExtractionState {
  const OcrExtractionInitial();
}

class OcrExtractionLoading extends OcrExtractionState {
  const OcrExtractionLoading();
}

class OcrProcessing extends OcrExtractionState {
  final double progress; // 0.0 to 1.0

  const OcrProcessing({required this.progress});

  @override
  List<Object?> get props => [progress];
}

class TextExtracted extends OcrExtractionState {
  final String text;
  final double confidence; // 0.0 to 1.0
  final String imagePath;

  const TextExtracted({
    required this.text,
    required this.confidence,
    required this.imagePath,
  });

  @override
  List<Object?> get props => [text, confidence, imagePath];
}

class TextEdited extends OcrExtractionState {
  final String text;
  final String imageId;

  const TextEdited({required this.text, required this.imageId});

  @override
  List<Object?> get props => [text, imageId];
}

class TextSaved extends OcrExtractionState {
  final String imageId;
  final String text;

  const TextSaved({required this.imageId, required this.text});

  @override
  List<Object?> get props => [imageId, text];
}

class OcrExtractionCancelled extends OcrExtractionState {
  const OcrExtractionCancelled();
}

class OcrExtractionError extends OcrExtractionState {
  final String message;

  const OcrExtractionError(this.message);

  @override
  List<Object?> get props => [message];
}
