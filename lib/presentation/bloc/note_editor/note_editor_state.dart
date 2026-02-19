import 'package:equatable/equatable.dart';
import 'package:mynotes/presentation/bloc/params/note_params.dart';
import '../../../domain/entities/note.dart';
import '../../../core/utils/context_scanner.dart';

abstract class NoteEditorState extends Equatable {
  final NoteParams params;
  final bool isListening;
  final String? voicePartialResult; // ISSUE-007: Partial voice input for UI feedback
  final String? lastVoiceInput; // ISSUE-007: Last recognized voice input
  final bool isDirty;
  final bool isSaving;
  final bool isSummarizing;
  final bool isExtracting;
  final bool isProcessing; // M010/M011: Video processing (trim/edit)
  final String? processingMessage; // M010/M011: Processing status message
  final String? summary;
  final String? extractedText;
  final String? errorCode;
  final List<ContextSuggestion> suggestions;
  final List<Note> linkedNotes;
  final Set<String> processedSuggestionIds;

  const NoteEditorState({
    required this.params,
    this.isListening = false,
    this.voicePartialResult,
    this.lastVoiceInput,
    this.isDirty = false,
    this.isSaving = false,
    this.isSummarizing = false,
    this.isExtracting = false,
    this.isProcessing = false, // M010/M011: Default not processing
    this.processingMessage, // M010/M011: Processing message
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
    voicePartialResult,
    lastVoiceInput,
    isDirty,
    isSaving,
    isSummarizing,
    isExtracting,
    isProcessing,
    processingMessage,
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
    super.voicePartialResult,
    super.lastVoiceInput,
    super.isDirty,
    super.isSaving,
    super.isSummarizing,
    super.isExtracting,
    super.isProcessing,
    super.processingMessage,
    super.summary,
    super.extractedText,
    super.errorCode,
    super.suggestions = const [],
    super.linkedNotes,
  });

  NoteEditorLoaded copyWith({
    NoteParams? params,
    bool? isListening,
    String? voicePartialResult,
    String? lastVoiceInput,
    bool? isDirty,
    bool? isSaving,
    bool? isSummarizing,
    bool? isExtracting,
    bool? isProcessing,
    String? processingMessage,
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
      voicePartialResult: voicePartialResult ?? this.voicePartialResult,
      lastVoiceInput: lastVoiceInput ?? this.lastVoiceInput,
      isDirty: isDirty ?? this.isDirty,
      isSaving: isSaving ?? this.isSaving,
      isSummarizing: isSummarizing ?? this.isSummarizing,
      isExtracting: isExtracting ?? this.isExtracting,
      isProcessing: isProcessing ?? this.isProcessing,
      processingMessage: processingMessage ?? this.processingMessage,
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
