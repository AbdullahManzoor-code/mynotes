// ════════════════════════════════════════════════════════════════════════════
// [M007 CONSOLIDATION] Note Editor BLoC - TextExtractionRequested (OCR)
//
// SCOPE: Note editing with integrated OCR text extraction
// - TextExtractionRequested: PRIMARY OCR handler (consolidated from 3 locations)
//
// CONSOLIDATED FROM (SESSION 19):
// ❌ OcrExtractionBloc: DISABLED (duplicate implementation)
// ❌ MediaBloc implicit OCR: DEPRECATED (was implicit in media processing)
// ✅ NoteEditorBloc: PRIMARY handler for all OCR (this file)
//
// ARCHITECTURE DECISION:
// TextExtractionRequested moved to NoteEditorBloc because:
// ✅ OCR is part of note creation workflow
// ✅ Extracted text directly integrated into note content
// ✅ No need for separate standalone OCR BLoC
// ✅ Cleaner UI: OCR completion → note updated directly
//
// USAGE:
// Context: In enhanced_note_editor_screen.dart
// Code: noteEditorBloc.add(TextExtractionRequested('/path/to/image'))
// Result: State emits with extractedText property
// Flow: User selects image → extract text → display in note field
//
// STATUS (SESSION 19):
// ✅ NoteEditorBloc.TextExtractionRequested: Active and working
// ✅ Integrated with OCRService.extractTextFromFile()
// ❌ OcrExtractionBloc: Disabled (file preserved for reference)
// ❌ MediaBloc OCR support: Deprecated (use NoteEditorBloc instead)
//
// BENEFITS:
// ✅ Single source of truth for OCR in app
// ✅ No code duplication across 3 locations
// ✅ Simpler to test and maintain
// ✅ Better state management (OCR state is note state)
// ════════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'dart:convert' show jsonEncode;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/domain/entities/universal_item.dart';
import 'package:mynotes/presentation/bloc/params/note_params.dart';
import 'package:mynotes/domain/entities/note.dart';
import 'package:mynotes/core/services/speech_service.dart';
import 'package:mynotes/core/services/voice_command_service.dart';
import 'package:mynotes/core/services/audio_feedback_service.dart';
import 'package:mynotes/core/services/ocr_service.dart';
// OPTIONAL FEATURE: Knowledge Graph & Linking (may be removed)
import 'package:mynotes/core/services/link_parser_service.dart';
import 'package:mynotes/domain/repositories/note_repository.dart';
import 'package:mynotes/core/utils/context_scanner.dart';
import 'package:mynotes/domain/entities/todo_item.dart';
import 'package:mynotes/domain/entities/alarm.dart';
import 'package:mynotes/presentation/bloc/note_editor/note_editor_event.dart';
import 'package:mynotes/presentation/bloc/note_editor/note_editor_state.dart';
import 'package:mynotes/domain/entities/media_item.dart';
import 'package:mynotes/core/services/media_processing_service.dart';
import 'package:video_compress/video_compress.dart'; // M010/M011: VideoQuality enum
import 'dart:io';
import 'package:mynotes/core/services/app_logger.dart';

import 'package:mynotes/presentation/widgets/note_template_selector.dart';

class NoteEditorBloc extends Bloc<NoteEditorEvent, NoteEditorState> {
  final SpeechService _speechService;
  final VoiceCommandService _commandService;
  final AudioFeedbackService _feedbackService;
  final OCRService _ocrService;
  final MediaProcessingService _mediaProcessingService;
  // OPTIONAL FEATURE: Knowledge Graph & Linking (may be removed)
  final NoteRepository _noteRepository;
  final LinkParserService _linkParserService;

  NoteEditorBloc({
    required SpeechService speechService,
    required VoiceCommandService commandService,
    required AudioFeedbackService feedbackService,
    required OCRService ocrService,
    required MediaProcessingService mediaProcessingService,
    // OPTIONAL FEATURE: Knowledge Graph & Linking (may be removed)
    required NoteRepository noteRepository,
    required LinkParserService linkParserService,
  }) : _speechService = speechService,
       _commandService = commandService,
       _feedbackService = feedbackService,
       _ocrService = ocrService,
       _mediaProcessingService = mediaProcessingService,
       // OPTIONAL FEATURE: Knowledge Graph & Linking (may be removed)
       _noteRepository = noteRepository,
       _linkParserService = linkParserService,
       super(NoteEditorInitial()) {
    on<NoteEditorInitialized>(_onInitialized);
    on<TitleChanged>(_onTitleChanged);
    on<ContentChanged>(_onContentChanged);
    on<TagAdded>(_onTagAdded);
    on<TagRemoved>(_onTagRemoved);
    on<ColorChanged>(_onColorChanged);
    on<PinToggled>(_onPinToggled);
    on<MediaAdded>(_onMediaAdded);
    on<MediaRemoved>(_onMediaRemoved);
    on<VoiceInputToggled>(_onVoiceInputToggled);
    on<StopVoiceInputRequested>(_onStopVoiceInput);
    on<SpeechResultReceived>(_onSpeechResultReceived);
    on<GenerateSummaryRequested>(_onGenerateSummary);
    on<SaveNoteRequested>(_onSaveNote);
    on<AlarmAdded>(_onAlarmAdded);
    on<TemplateApplied>(_onTemplateApplied);
    on<TodoAdded>(_onTodoAdded);
    on<TextExtractionRequested>(_onTextExtractionRequested);
    on<MediaUpdated>(_onMediaUpdated);
    on<ErrorOccurred>(_onErrorOccurred);
    on<ContextScannerTriggered>(_onContextScannerTriggered);
    on<SuggestionActionAccepted>(_onSuggestionActionAccepted);
    on<PromoteToTodoRequested>(_onPromoteToTodoRequested);
    on<VideoTrimmingRequested>(_onVideoTrimmingRequested);
    on<VideoEditingRequested>(_onVideoEditingRequested);
    on<VideoProcessingCompleted>(_onVideoProcessingCompleted);
  }

  Future<void> _onPromoteToTodoRequested(
    PromoteToTodoRequested event,
    Emitter<NoteEditorState> emit,
  ) async {
    if (state is NoteEditorLoaded) {
      final s = state as NoteEditorLoaded;

      final todo = TodoItem(
        id: DateTime.now().toIso8601String(),
        text: s.params.title.isNotEmpty ? s.params.title : 'New Task from Note',
        isCompleted: false,
        priority: TodoPriority.medium,
        category: TodoCategory.other,
        noteId: s.params.noteId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      add(TodoAdded(todo));
      _feedbackService.commandRecognized();
    }
  }

  void _onContextScannerTriggered(
    ContextScannerTriggered event,
    Emitter<NoteEditorState> emit,
  ) async {
    if (state is NoteEditorLoaded) {
      final s = state as NoteEditorLoaded;

      // 1. Scan for Action Suggestions (Todo/Reminder)
      final actionSuggestions = ContextScanner.scan(event.text);

      // 2. Scan for Relationship Mapping (Linked Notes)
      final keywords = ContextScanner.extractPotentialKeywords(event.text);
      List<ContextSuggestion> linkSuggestions = [];

      if (keywords.isNotEmpty) {
        try {
          // Search for notes matching these keywords
          final allNotes = await _noteRepository.getAllNotes();
          for (final keyword in keywords) {
            final matches = allNotes.where(
              (n) =>
                  n.id != s.params.noteId && // Don't link to self
                  (n.title.toLowerCase().contains(keyword.toLowerCase()) ||
                      n.tags.any(
                        (t) => t.toLowerCase() == keyword.toLowerCase(),
                      )),
            );

            for (final match in matches) {
              // Avoid duplicates
              if (!linkSuggestions.any((ls) => ls.title == match.title)) {
                linkSuggestions.add(
                  ContextSuggestion(
                    title: match.title,
                    type: SuggestionType.linkedNote,
                    content: match.id, // Store target ID in content
                  ),
                );
              }
            }
          }
        } catch (e) {
          // Ignore lookup errors for suggestions
        }
      }

      // FINAL FILTER: Filter out suggestions already processed in this session
      final filteredSuggestions = [...actionSuggestions, ...linkSuggestions]
          .where((suggestion) {
            final id = suggestion.type == SuggestionType.linkedNote
                ? 'link_${suggestion.content}'
                : '${suggestion.type}_${suggestion.title}';
            return !s.processedSuggestionIds.contains(id);
          })
          .toList();

      emit(s.copyWith(suggestions: filteredSuggestions));
    }
  }

  Future<void> _onSuggestionActionAccepted(
    SuggestionActionAccepted event,
    Emitter<NoteEditorState> emit,
  ) async {
    if (state is NoteEditorLoaded) {
      final s = state as NoteEditorLoaded;
      final suggestion = event.suggestion;

      // TRACK PROCESSED ID
      final id = suggestion.type == SuggestionType.linkedNote
          ? 'link_${suggestion.content}'
          : '${suggestion.type}_${suggestion.title}';
      final newProcessedIds = Set<String>.from(s.processedSuggestionIds)
        ..add(id);

      if (suggestion.type == SuggestionType.todo) {
        final todo = TodoItem(
          id: DateTime.now().toIso8601String(),
          text: suggestion.title,
          isCompleted: false,
          priority: _mapPriority(suggestion.priority),
          category: TodoCategory.other,
          noteId: s.params.noteId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        add(TodoAdded(todo));
      } else if (suggestion.type == SuggestionType.reminder &&
          suggestion.date != null) {
        final alarm = Alarm(
          id: DateTime.now().toIso8601String(),
          message: suggestion.title,
          scheduledTime: suggestion.date!,
          isActive: true,
          isEnabled: true,
          linkedNoteId: s.params.noteId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        add(AlarmAdded(alarm));
      } else if (suggestion.type == SuggestionType.linkedNote) {
        // Find the note and add it to linkedNotes
        try {
          final noteId = suggestion.content;
          final allNotes = await _noteRepository.getAllNotes();
          final targetNote = allNotes.firstWhere((n) => n.id == noteId);

          if (!s.linkedNotes.any((n) => n.id == targetNote.id)) {
            final newList = List<Note>.from(s.linkedNotes)..add(targetNote);
            emit(
              s.copyWith(
                linkedNotes: newList,
                processedSuggestionIds: newProcessedIds,
              ),
            );

            // Persist the link in the repository if possible
            if (s.params.noteId != null) {
              final existingLinks = await _noteRepository.getOutgoingLinks(
                s.params.noteId!,
              );
              if (!existingLinks.contains(targetNote.id)) {
                await _noteRepository.updateNoteLinks(s.params.noteId!, [
                  ...existingLinks,
                  targetNote.id,
                ]);
              }
            }
          }
        } catch (e) {
          // ignore
        }
      } else if (suggestion.type == SuggestionType.template) {
        // Find the template and apply it
        final template = NoteTemplates.builtIn.firstWhere(
          (t) => t.name == suggestion.title,
          orElse: () => NoteTemplates.builtIn.first,
        );
        add(TemplateApplied(template));
      }

      // Clear suggestions after processing one or accepting it
      emit(
        s.copyWith(suggestions: [], processedSuggestionIds: newProcessedIds),
      );
    }
  }

  TodoPriority _mapPriority(ItemPriority priority) {
    switch (priority) {
      case ItemPriority.high:
        return TodoPriority.high;
      case ItemPriority.low:
        return TodoPriority.low;
      default:
        return TodoPriority.medium;
    }
  }

  void _onErrorOccurred(ErrorOccurred event, Emitter<NoteEditorState> emit) {
    if (state is NoteEditorLoaded) {
      final s = state as NoteEditorLoaded;
      emit(s.copyWith(errorCode: event.code ?? 'GENERAL_ERROR'));
    }
  }

  void _onInitialized(
    NoteEditorInitialized event,
    Emitter<NoteEditorState> emit,
  ) async {
    try {
      NoteParams params;
      if (event.note != null) {
        // Verify the note still exists in the database
        // (it might have been deleted from another screen)
        final dbNote = await _noteRepository.getNoteById(event.note!.id);
        if (dbNote == null) {
          // Note was deleted while loading editor
          emit(
            NoteEditorLoaded(
              params: const NoteParams(),
              errorCode: 'NOTE_DELETED',
            ),
          );
          return;
        }
        params = NoteParams.fromNote(dbNote);
      } else if (event.template != null) {
        String content = event.template.contentPlaceholder;
        if (!content.startsWith('[{"insert"')) {
          content = jsonEncode([
            {'insert': '$content\n'},
          ]);
        }
        params = NoteParams(
          title: event.template.titlePlaceholder,
          content: content,
        );
      } else {
        params = NoteParams(content: event.initialContent ?? '');
      }

      // OPTIONAL FEATURE: Knowledge Graph & Linking (may be removed)
      List<Note> backlinks = [];
      if (params.noteId != null) {
        try {
          final backlinkIds = await _noteRepository.getBacklinks(
            params.noteId!,
          );
          if (backlinkIds.isNotEmpty) {
            // Inefficient but simple: fetch all to match. Optimally: getNotesByIds
            final allNotes = await _noteRepository.getAllNotes();
            backlinks = allNotes
                .where((n) => backlinkIds.contains(n.id))
                .toList();
          }
        } catch (e) {
          // ignore backlink fetch errors
        }
      }

      emit(NoteEditorLoaded(params: params, linkedNotes: backlinks));
      _registerVoiceCommands();
    } catch (e) {
      emit(
        NoteEditorLoaded(params: const NoteParams(), errorCode: 'INIT_ERROR'),
      );
    }
  }

  void _registerVoiceCommands() {
    _commandService.clearAllCommands();
    _commandService.registerCommand(
      'save',
      () => add(const SaveNoteRequested()),
    );
    _commandService.registerCommand(
      'bold',
      () => _feedbackService.commandRecognized(),
    );
    _commandService.registerCommand(
      'italic',
      () => _feedbackService.commandRecognized(),
    );
    _commandService.registerCommand(
      'underline',
      () => _feedbackService.commandRecognized(),
    );
  }

  void _onTitleChanged(TitleChanged event, Emitter<NoteEditorState> emit) {
    if (state is NoteEditorLoaded) {
      final s = state as NoteEditorLoaded;
      emit(
        s.copyWith(
          params: s.params.copyWith(title: event.title),
          isDirty: true,
        ),
      );
    }
  }

  void _onContentChanged(ContentChanged event, Emitter<NoteEditorState> emit) {
    if (state is NoteEditorLoaded) {
      final s = state as NoteEditorLoaded;
      emit(
        s.copyWith(
          params: s.params.copyWith(content: event.content),
          isDirty: true,
        ),
      );
    }
  }

  void _onTagAdded(TagAdded event, Emitter<NoteEditorState> emit) {
    if (state is NoteEditorLoaded) {
      final s = state as NoteEditorLoaded;
      emit(s.copyWith(params: s.params.withTag(event.tag), isDirty: true));
    }
  }

  void _onTagRemoved(TagRemoved event, Emitter<NoteEditorState> emit) {
    if (state is NoteEditorLoaded) {
      final s = state as NoteEditorLoaded;
      emit(s.copyWith(params: s.params.withoutTag(event.tag), isDirty: true));
    }
  }

  void _onColorChanged(ColorChanged event, Emitter<NoteEditorState> emit) {
    if (state is NoteEditorLoaded) {
      final s = state as NoteEditorLoaded;
      emit(s.copyWith(params: s.params.withColor(event.color), isDirty: true));
    }
  }

  void _onPinToggled(PinToggled event, Emitter<NoteEditorState> emit) {
    if (state is NoteEditorLoaded) {
      final s = state as NoteEditorLoaded;
      emit(s.copyWith(params: s.params.togglePin(), isDirty: true));
    }
  }

  Future<void> _onMediaAdded(
    MediaAdded event,
    Emitter<NoteEditorState> emit,
  ) async {
    if (state is NoteEditorLoaded) {
      final s = state as NoteEditorLoaded;
      try {
        String finalFilePath = event.filePath;
        String thumbnailPath = '';

        // 1. Process based on type
        if (event.type == MediaType.image) {
          // Compress image
          final compressedFile = await _mediaProcessingService.compressImage(
            File(event.filePath),
          );
          if (compressedFile != null) {
            finalFilePath = compressedFile.path;
          }
        } else if (event.type == MediaType.video) {
          // Generate thumbnail
          final thumb = await _mediaProcessingService.generateVideoThumbnail(
            event.filePath,
          );
          if (thumb != null) {
            thumbnailPath = thumb;
          }
        }

        final mediaItem = MediaItem(
          id: DateTime.now().toIso8601String(),
          type: event.type,
          filePath: finalFilePath,
          thumbnailPath: thumbnailPath,
          name: event.name ?? finalFilePath.split('/').last,
          durationMs: event.duration ?? 0,
          createdAt: DateTime.now(),
        );

        emit(
          s.copyWith(
            params: s.params.copyWith(media: [...s.params.media, mediaItem]),
            isDirty: true,
          ),
        );
      } catch (e) {
        add(ErrorOccurred('Failed to add media: $e', code: 'MEDIA_ADD_FAILED'));
      }
    }
  }

  Future<void> _onMediaRemoved(
    MediaRemoved event,
    Emitter<NoteEditorState> emit,
  ) async {
    if (state is NoteEditorLoaded) {
      final s = state as NoteEditorLoaded;
      try {
        final newMedia = List<MediaItem>.from(s.params.media);
        if (event.index >= 0 && event.index < newMedia.length) {
          // ISSUE-009 FIX: Delete the actual file from disk before removing from list
          final removeItem = newMedia[event.index];
          try {
            await _mediaProcessingService.deleteFile(removeItem.filePath);
            // Also delete thumbnail if it exists
            if (removeItem.thumbnailPath.isNotEmpty) {
              await _mediaProcessingService.deleteFile(
                removeItem.thumbnailPath,
              );
            }
          } catch (e) {
            // Log but don't fail the whole removal operation
            print('Warning: Failed to delete media file: $e');
          }
          newMedia.removeAt(event.index);
        }
        emit(
          s.copyWith(params: s.params.copyWith(media: newMedia), isDirty: true),
        );
      } catch (e) {
        add(
          ErrorOccurred(
            'Failed to remove media: $e',
            code: 'MEDIA_REMOVE_FAILED',
          ),
        );
      }
    }
  }

  // ISSUE-007: Voice input fully integrated with BLoC state
  // Previous: Used SpeechService callbacks directly
  // Now: All voice state changes go through BLoC events and states
  Future<void> _onVoiceInputToggled(
    VoiceInputToggled event,
    Emitter<NoteEditorState> emit,
  ) async {
    if (state is NoteEditorLoaded) {
      final s = state as NoteEditorLoaded;
      if (s.isListening) {
        // Stop listening and emit state through BLoC
        try {
          await _speechService.stopListening();
          _feedbackService.recordingStopped();
          emit(
            s.copyWith(isListening: false, errorCode: null, lastVoiceInput: ''),
          );
          AppLogger.i('✅ [VOICE-INPUT] Voice input stopped via BLoC');
        } catch (e) {
          AppLogger.e('Voice stop error: $e');
          emit(s.copyWith(errorCode: 'VOICE_STOP_ERROR'));
        }
      } else {
        // Start listening and emit state through BLoC
        try {
          emit(s.copyWith(isListening: true, errorCode: null));
          await _feedbackService.recordingStarted();
          AppLogger.i('✅ [VOICE-INPUT] Voice input initialized via BLoC');

          final initialized = await _speechService.initialize();
          if (!initialized) {
            _feedbackService.errorOccurred();
            emit(
              s.copyWith(
                isListening: false,
                errorCode: 'SPEECH_PERMISSION_DENIED',
              ),
            );
            AppLogger.w('Voice permission denied');
            return;
          }

          // Start listening with proper BLoC integration
          _speechService.startListening(
            onResult: (text) {
              AppLogger.i('🎤 [VOICE-INPUT] Final result: $text');
              add(SpeechResultReceived(text, isFinal: true));
            },
            onPartialResult: (text) {
              AppLogger.i('🎤 [VOICE-INPUT] Partial result: $text');
              add(SpeechResultReceived(text, isFinal: false));
            },
            onDone: () {
              AppLogger.i('✅ [VOICE-INPUT] Listening session completed');
              add(const StopVoiceInputRequested());
            },
          );
        } catch (e, stack) {
          AppLogger.e('Voice input error: $e', e, stack);
          _feedbackService.errorOccurred();
          emit(s.copyWith(isListening: false, errorCode: 'SPEECH_INIT_FAILED'));
        }
      }
    }
  }

  Future<void> _onStopVoiceInput(
    StopVoiceInputRequested event,
    Emitter<NoteEditorState> emit,
  ) async {
    if (state is NoteEditorLoaded) {
      final s = state as NoteEditorLoaded;
      await _speechService.stopListening();
      emit(s.copyWith(isListening: false));
      _feedbackService.recordingStopped();
    }
  }

  // ISSUE-007: Enhanced voice result processing with proper BLoC state
  void _onSpeechResultReceived(
    SpeechResultReceived event,
    Emitter<NoteEditorState> emit,
  ) {
    if (state is NoteEditorLoaded) {
      final s = state as NoteEditorLoaded;

      if (event.isFinal) {
        try {
          AppLogger.i(
            '🎤 [VOICE-PROCESS] Processing final voice input: ${event.text}',
          );

          // Try to detect and execute voice commands
          final commandMatched = _commandService.detectAndExecute(event.text);
          if (commandMatched) {
            _feedbackService.commandRecognized();
            AppLogger.i('✅ [VOICE-COMMAND] Command recognized and executed');
          } else {
            // No command matched, treat as content
            AppLogger.i(
              '📝 [VOICE-CONTENT] No command matched, adding as content',
            );
            final updatedContent = s.params.content + ' ' + event.text;
            emit(
              s.copyWith(
                params: s.params.copyWith(content: updatedContent.trim()),
                isListening: false,
                lastVoiceInput: event.text,
              ),
            );
            return;
          }

          // Emit state change indicating listening stopped
          emit(s.copyWith(isListening: false, lastVoiceInput: event.text));
          _feedbackService.recordingStopped();
        } catch (e, stack) {
          AppLogger.e('Voice processing error: $e', e, stack);
          _feedbackService.errorOccurred();
          emit(
            s.copyWith(isListening: false, errorCode: 'SPEECH_PROCESS_ERROR'),
          );
        }
      } else if (event.isFinal == false) {
        // Partial result - update UI with partial text for user feedback
        AppLogger.i('🎤 [VOICE-PARTIAL] Partial input: ${event.text}');
        emit(s.copyWith(voicePartialResult: event.text, isListening: true));
      }
    }
  }

  Future<void> _onGenerateSummary(
    GenerateSummaryRequested event,
    Emitter<NoteEditorState> emit,
  ) async {
    if (state is NoteEditorLoaded) {
      final s = state as NoteEditorLoaded;
      emit(s.copyWith(isSummarizing: true, errorCode: null));
      try {
        await Future.delayed(const Duration(seconds: 1)); // Simulate AI
        if (s.params.content.isEmpty) {
          throw Exception('Content is empty');
        }
        // Generate intelligent summary by extracting first sentence or key phrase
        final summary = _generateIntelligentSummary(s.params.content);
        emit(s.copyWith(isSummarizing: false, summary: summary));
      } catch (e) {
        emit(s.copyWith(isSummarizing: false, errorCode: 'SUMMARY_FAILED'));
      }
    }
  }

  /// Generate intelligent summary by extracting first complete sentence or key phrases
  String _generateIntelligentSummary(String content) {
    if (content.isEmpty) return '';

    // Remove markdown/JSON artifacts and get plain text
    String plainText = content.replaceAll(RegExp(r'[\{\}\[\]"\\]'), '');

    // Extract first sentence (up to . ! or ?)
    final sentenceMatch = RegExp(r'([^.!?]*[.!?])').firstMatch(plainText);
    if (sentenceMatch != null) {
      final sentence = sentenceMatch.group(0)?.trim() ?? '';
      if (sentence.length > 20) {
        return sentence.length > 150
            ? '${sentence.substring(0, 150)}...'
            : sentence;
      }
    }

    // Fallback: first 100 chars with word boundary
    if (plainText.length > 100) {
      final truncated = plainText.substring(0, 100);
      final lastSpace = truncated.lastIndexOf(' ');
      return '${truncated.substring(0, lastSpace)}...';
    }
    return plainText;
  }

  Future<void> _onSaveNote(
    SaveNoteRequested event,
    Emitter<NoteEditorState> emit,
  ) async {
    if (state is NoteEditorLoaded) {
      final s = state as NoteEditorLoaded;
      emit(s.copyWith(isSaving: true, errorCode: null));
      try {
        if (s.params.title.isEmpty && s.params.content.isEmpty) {
          emit(s.copyWith(isSaving: false, errorCode: 'EMPTY_NOTE'));
          return;
        }

        // ISSUE-008 FIX: Actually save the note to database
        // Convert params to Note entity and persist
        final noteToSave = s.params
            .copyWith(updatedAt: DateTime.now())
            .toNote();

        // Create or update based on whether noteId exists
        if (s.params.noteId == null) {
          // Creating new note
          await _noteRepository.createNote(noteToSave);
        } else {
          // Updating existing note
          await _noteRepository.updateNote(noteToSave);
        }

        // OPTIONAL FEATURE: Knowledge Graph & Linking (may be removed)
        // Parse and update links only if note was saved successfully
        if (s.params.content.isNotEmpty) {
          final links = _linkParserService.extractLinks(s.params.content);
          if (noteToSave.id.isNotEmpty) {
            final allNotes = await _noteRepository.getAllNotes();
            final targetIds = <String>[];

            for (final linkTitle in links) {
              final match = allNotes.cast<Note?>().firstWhere(
                (n) =>
                    n?.title.trim().toLowerCase() ==
                    linkTitle.trim().toLowerCase(),
                orElse: () => null,
              );
              if (match != null) {
                targetIds.add(match.id);
              }
            }
            await _noteRepository.updateNoteLinks(noteToSave.id, targetIds);
          }
        }

        emit(s.copyWith(isSaving: false, isDirty: false));
      } catch (e) {
        emit(s.copyWith(isSaving: false, errorCode: 'SAVE_FAILED'));
      }
    }
  }

  void _onAlarmAdded(AlarmAdded event, Emitter<NoteEditorState> emit) {
    if (state is NoteEditorLoaded) {
      final s = state as NoteEditorLoaded;
      emit(
        s.copyWith(
          params: s.params.copyWith(alarms: [...s.params.alarms, event.alarm]),
          isDirty: true,
        ),
      );
    }
  }

  void _onTemplateApplied(
    TemplateApplied event,
    Emitter<NoteEditorState> emit,
  ) {
    if (state is NoteEditorLoaded) {
      final s = state as NoteEditorLoaded;

      // Ensure content is in Quill Delta JSON format
      String formattedContent = event.template.contentPlaceholder;
      if (!formattedContent.startsWith('[{"insert"')) {
        formattedContent = jsonEncode([
          {'insert': '$formattedContent\n'},
        ]);
      }

      emit(
        s.copyWith(
          params: s.params.copyWith(
            title: event.template.titlePlaceholder,
            content: formattedContent,
          ),
          isDirty: true,
        ),
      );
    }
  }

  void _onTodoAdded(TodoAdded event, Emitter<NoteEditorState> emit) {
    if (state is NoteEditorLoaded) {
      final s = state as NoteEditorLoaded;
      emit(
        s.copyWith(
          params: s.params.copyWith(todos: [...s.params.todos, event.todo]),
          isDirty: true,
        ),
      );
    }
  }

  Future<void> _onTextExtractionRequested(
    TextExtractionRequested event,
    Emitter<NoteEditorState> emit,
  ) async {
    if (state is NoteEditorLoaded) {
      final s = state as NoteEditorLoaded;
      emit(s.copyWith(isExtracting: true, errorCode: null));
      try {
        final extractedText = await _ocrService.extractTextFromFile(
          event.filePath,
        );
        if (extractedText.isNotEmpty) {
          emit(s.copyWith(isExtracting: false, extractedText: extractedText));
        } else {
          emit(s.copyWith(isExtracting: false, errorCode: 'EXTRACTION_FAILED'));
        }
      } catch (e) {
        emit(s.copyWith(isExtracting: false, errorCode: 'EXTRACTION_ERROR'));
      }
    }
  }

  Future<void> _onMediaUpdated(
    MediaUpdated event,
    Emitter<NoteEditorState> emit,
  ) async {
    if (state is NoteEditorLoaded) {
      final s = state as NoteEditorLoaded;
      try {
        final newMediaList = s.params.media.map((m) {
          return m.id == event.oldMedia.id ? event.newMedia : m;
        }).toList();

        emit(
          s.copyWith(
            params: s.params.copyWith(media: newMediaList),
            isDirty: true,
          ),
        );
      } catch (e) {
        add(
          ErrorOccurred(
            'Failed to update media: $e',
            code: 'MEDIA_UPDATE_FAILED',
          ),
        );
      }
    }
  }

  /// M010: VIDEO TRIMMING - Process video trimming request
  /// When user selects trim points in the video attachment UI
  /// Updates the media item with trimmed video file
  Future<void> _onVideoTrimmingRequested(
    VideoTrimmingRequested event,
    Emitter<NoteEditorState> emit,
  ) async {
    if (state is NoteEditorLoaded) {
      final s = state as NoteEditorLoaded;

      // Validate media index
      if (event.mediaIndex < 0 || event.mediaIndex >= s.params.media.length) {
        add(
          ErrorOccurred(
            'Invalid media index for trimming',
            code: 'INVALID_MEDIA_INDEX',
          ),
        );
        return;
      }

      final mediaItem = s.params.media[event.mediaIndex];

      // Only trim video files
      if (mediaItem.type != MediaType.video) {
        add(ErrorOccurred('Can only trim video files', code: 'NOT_VIDEO_FILE'));
        return;
      }

      try {
        // Show processing state
        emit(
          s.copyWith(
            isProcessing: true,
            processingMessage: 'Trimming video...',
          ),
        );

        // Call trimVideo service
        final trimmedPath = await _mediaProcessingService.trimVideo(
          videoPath: mediaItem.filePath,
          startMs: event.startMs,
          endMs: event.endMs,
        );

        if (trimmedPath != null && trimmedPath.isNotEmpty) {
          // Emit success - let VideoProcessingCompleted handler update the media
          add(
            VideoProcessingCompleted(
              mediaIndex: event.mediaIndex,
              processedPath: trimmedPath,
              processingType: 'trim',
            ),
          );
        } else {
          emit(s.copyWith(isProcessing: false, errorCode: 'TRIM_FAILED'));
        }
      } catch (e) {
        emit(s.copyWith(isProcessing: false, errorCode: 'TRIM_ERROR'));
        add(ErrorOccurred('Video trimming failed: $e', code: 'TRIM_ERROR'));
      }
    }
  }

  /// M011: VIDEO EDITING - Process video editing request
  /// When user applies filters/effects to attached video
  /// Updates the media item with edited video file
  Future<void> _onVideoEditingRequested(
    VideoEditingRequested event,
    Emitter<NoteEditorState> emit,
  ) async {
    if (state is NoteEditorLoaded) {
      final s = state as NoteEditorLoaded;

      // Validate media index
      if (event.mediaIndex < 0 || event.mediaIndex >= s.params.media.length) {
        add(
          ErrorOccurred(
            'Invalid media index for editing',
            code: 'INVALID_MEDIA_INDEX',
          ),
        );
        return;
      }

      final mediaItem = s.params.media[event.mediaIndex];

      // Only edit video files
      if (mediaItem.type != MediaType.video) {
        add(ErrorOccurred('Can only edit video files', code: 'NOT_VIDEO_FILE'));
        return;
      }

      try {
        // Show processing state
        emit(
          s.copyWith(
            isProcessing: true,
            processingMessage: 'Applying video effects...',
          ),
        );

        // Generate output path with filter suffix
        final originalPath = mediaItem.filePath;
        final filterSuffix = event.filterType ?? 'default';
        final editedPath = originalPath.replaceAll(
          RegExp(r'\.mp4$|\.mov$|\.avi$'),
          '_${filterSuffix}_edited.mp4',
        );

        // Call editVideo service with quality and filter parameters
        final processedPath = await _mediaProcessingService.editVideo(
          videoPath: originalPath,
          outputPath: editedPath,
          quality: event.qualityFactor == null
              ? VideoQuality.DefaultQuality
              : event.qualityFactor! > 0.7
              ? VideoQuality.HighestQuality
              : event.qualityFactor! > 0.4
              ? VideoQuality.MediumQuality
              : VideoQuality.LowQuality,
        );

        if (processedPath != null && processedPath.isNotEmpty) {
          // Emit success - let VideoProcessingCompleted handler update the media
          add(
            VideoProcessingCompleted(
              mediaIndex: event.mediaIndex,
              processedPath: processedPath,
              processingType: 'edit',
            ),
          );
        } else {
          emit(s.copyWith(isProcessing: false, errorCode: 'EDIT_FAILED'));
        }
      } catch (e) {
        emit(s.copyWith(isProcessing: false, errorCode: 'EDIT_ERROR'));
        add(ErrorOccurred('Video editing failed: $e', code: 'EDIT_ERROR'));
      }
    }
  }

  /// M010/M011: Handle completion of video trimming/editing
  /// Updates the media item with the processed video path
  Future<void> _onVideoProcessingCompleted(
    VideoProcessingCompleted event,
    Emitter<NoteEditorState> emit,
  ) async {
    if (state is NoteEditorLoaded) {
      final s = state as NoteEditorLoaded;

      try {
        // Get the original media item
        if (event.mediaIndex < 0 || event.mediaIndex >= s.params.media.length) {
          add(
            ErrorOccurred('Invalid media index', code: 'INVALID_MEDIA_INDEX'),
          );
          return;
        }

        final originalMedia = s.params.media[event.mediaIndex];

        // Create updated media item with processed video path
        final updatedMedia = originalMedia.copyWith(
          filePath: event.processedPath,
          // Regenerate thumbnail for the processed video
          thumbnailPath: '', // Will be regenerated on next access
        );

        // Generate new thumbnail for processed video
        final newThumbnail = await _mediaProcessingService
            .generateVideoThumbnail(event.processedPath);

        final mediaWithThumbnail = updatedMedia.copyWith(
          thumbnailPath: newThumbnail ?? '',
        );

        // Update media list
        final updatedMediaList = s.params.media.toList();
        updatedMediaList[event.mediaIndex] = mediaWithThumbnail;

        // Delete original file if trim/edit was applied
        if (event.processedPath != originalMedia.filePath) {
          try {
            await _mediaProcessingService.deleteFile(originalMedia.filePath);
          } catch (e) {
            // Log but don't fail - deletion is optional cleanup
            print('Warning: Could not delete original video file: $e');
          }
        }

        // Emit success state
        emit(
          s.copyWith(
            params: s.params.copyWith(media: updatedMediaList),
            isDirty: true,
            isProcessing: false,
            processingMessage:
                '${event.processingType.toUpperCase()} complete!',
          ),
        );
      } catch (e) {
        emit(
          s.copyWith(
            isProcessing: false,
            errorCode: 'PROCESSING_COMPLETE_FAILED',
          ),
        );
        add(
          ErrorOccurred(
            'Failed to complete video ${event.processingType}: $e',
            code: 'PROCESSING_COMPLETE_FAILED',
          ),
        );
      }
    }
  }

  /// [ML008 FIX] Cleanup speech service listeners and resources on BLoC close
  @override
  Future<void> close() async {
    // Stop speech recognition to prevent memory leaks and background resource usage
    await _speechService.stopListening();
    // Clear all command callbacks
    _commandService.clearAllCommands();
    await super.close();
  }
}
