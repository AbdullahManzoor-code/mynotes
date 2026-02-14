import 'package:equatable/equatable.dart';
import 'package:mynotes/presentation/bloc/params/note_params.dart';
import '../../../domain/entities/note.dart';
import '../../../core/utils/context_scanner.dart';

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
  final List<ContextSuggestion> suggestions;
  final List<Note> linkedNotes;
  final Set<String> processedSuggestionIds;

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
    this.suggestions = const [],
    this.linkedNotes = const [],
    this.processedSuggestionIds = const {},
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
    suggestions,
    linkedNotes,
    processedSuggestionIds,
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
    super.suggestions = const [],
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
    List<ContextSuggestion>? suggestions,
    List<Note>? linkedNotes,
    Set<String>? processedSuggestionIds,
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
      suggestions: suggestions ?? this.suggestions,
      linkedNotes: linkedNotes ?? this.linkedNotes,
      // processedSuggestionIds:
      //     processedSuggestionIds ?? this.processedSuggestionIds,
    );
  }
}
