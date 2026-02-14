part of 'ocr_extraction_bloc.dart';

abstract class OcrExtractionEvent extends Equatable {
  const OcrExtractionEvent();

  @override
  List<Object?> get props => [];
}

class ExtractTextFromImageEvent extends OcrExtractionEvent {
  final String imagePath;
  final String? language;

  const ExtractTextFromImageEvent(this.imagePath, {this.language});

  @override
  List<Object?> get props => [imagePath, language];
}

class StartOcrProcessEvent extends OcrExtractionEvent {
  final List<String> imagePaths;
  final String? languageHint;

  const StartOcrProcessEvent(this.imagePaths, {this.languageHint});

  @override
  List<Object?> get props => [imagePaths, languageHint];
}

class CancelOcrProcessEvent extends OcrExtractionEvent {
  const CancelOcrProcessEvent();
}

class SaveExtractedTextEvent extends OcrExtractionEvent {
  final String imageId;
  final String text;

  const SaveExtractedTextEvent(this.imageId, this.text);

  @override
  List<Object?> get props => [imageId, text];
}

class EditExtractedTextEvent extends OcrExtractionEvent {
  final String imageId;
  final String editedText;

  const EditExtractedTextEvent(this.imageId, this.editedText);

  @override
  List<Object?> get props => [imageId, editedText];
}
