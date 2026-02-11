import 'package:equatable/equatable.dart';
import 'params/note_params.dart';
import '../../domain/entities/note.dart';

abstract class NoteEditorState extends Equatable {
  final NoteParams params;
  final bool isListening;
  final bool isDirty;
  final bool isSaving;
  final bool isSummarizing;
  final bool isExtracting;
  final String? summary;
  final String? extractedText;
  final String? errorCode;
  // OPTIONAL FEATURE: Knowledge Graph & Linking (may be removed)
  // Backlinks list
  // OPTIONAL FEATURE: Knowledge Graph & Linking (may be removed)
  // Backlinks list
  final List<Note> linkedNotes;

  const NoteEditorState({
    required this.params,
    this.isListening = false,
    this.isDirty = false,
    this.isSaving = false,
    this.isSummarizing = false,
    this.isExtracting = false,
    this.summary,
    this.extractedText,
    this.errorCode,
    // OPTIONAL FEATURE: Knowledge Graph & Linking (may be removed)
    // OPTIONAL FEATURE: Knowledge Graph & Linking (may be removed)
    this.linkedNotes = const [],
  });

  @override
  List<Object?> get props => [
    params,
    isListening,
    isDirty,
    isSaving,
    isSummarizing,
    isExtracting,
    summary,
    extractedText,
    errorCode,
    errorCode,
    linkedNotes,
  ];
}

class NoteEditorInitial extends NoteEditorState {
  const NoteEditorInitial() : super(params: const NoteParams());
}

class NoteEditorLoaded extends NoteEditorState {
  const NoteEditorLoaded({
    required super.params,
    super.isListening,
    super.isDirty,
    super.isSaving,
    super.isSummarizing,
    super.isExtracting,
    super.summary,
    super.extractedText,
    super.errorCode,
    // OPTIONAL FEATURE: Knowledge Graph & Linking (may be removed)
    // OPTIONAL FEATURE: Knowledge Graph & Linking (may be removed)
    super.linkedNotes,
  });

  NoteEditorLoaded copyWith({
    NoteParams? params,
    bool? isListening,
    bool? isDirty,
    bool? isSaving,
    bool? isSummarizing,
    bool? isExtracting,
    String? summary,
    String? extractedText,
    String? errorCode,
    // OPTIONAL FEATURE: Knowledge Graph & Linking (may be removed)
    // OPTIONAL FEATURE: Knowledge Graph & Linking (may be removed)
    List<Note>? linkedNotes,
  }) {
    return NoteEditorLoaded(
      params: params ?? this.params,
      isListening: isListening ?? this.isListening,
      isDirty: isDirty ?? this.isDirty,
      isSaving: isSaving ?? this.isSaving,
      isSummarizing: isSummarizing ?? this.isSummarizing,
      isExtracting: isExtracting ?? this.isExtracting,
      summary: summary ?? this.summary,
      extractedText: extractedText ?? this.extractedText,
      errorCode: errorCode ?? this.errorCode,
      linkedNotes: linkedNotes ?? this.linkedNotes,
    );
  }
}
