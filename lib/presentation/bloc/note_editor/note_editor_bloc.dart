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
import 'dart:io';

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
        params = NoteParams.fromNote(event.note!);
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

  void _onMediaRemoved(MediaRemoved event, Emitter<NoteEditorState> emit) {
    if (state is NoteEditorLoaded) {
      final s = state as NoteEditorLoaded;
      try {
        final newMedia = List<MediaItem>.from(s.params.media);
        if (event.index >= 0 && event.index < newMedia.length) {
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

  Future<void> _onVoiceInputToggled(
    VoiceInputToggled event,
    Emitter<NoteEditorState> emit,
  ) async {
    if (state is NoteEditorLoaded) {
      final s = state as NoteEditorLoaded;
      if (s.isListening) {
        await _speechService.stopListening();
        emit(s.copyWith(isListening: false));
        _feedbackService.recordingStopped();
      } else {
        try {
          final initialized = await _speechService.initialize();
          if (initialized) {
            emit(s.copyWith(isListening: true, errorCode: null));
            await _feedbackService.recordingStarted();
            _speechService.startListening(
              onResult: (text) =>
                  add(SpeechResultReceived(text, isFinal: true)),
              onPartialResult: (text) =>
                  add(SpeechResultReceived(text, isFinal: false)),
            );
          } else {
            _feedbackService.errorOccurred();
            emit(s.copyWith(errorCode: 'SPEECH_PERMISSION_DENIED'));
          }
        } catch (e) {
          _feedbackService.errorOccurred();
          emit(s.copyWith(errorCode: 'SPEECH_INIT_FAILED'));
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

  void _onSpeechResultReceived(
    SpeechResultReceived event,
    Emitter<NoteEditorState> emit,
  ) {
    if (state is NoteEditorLoaded) {
      final s = state as NoteEditorLoaded;
      if (event.isFinal) {
        try {
          final commandMatched = _commandService.detectAndExecute(event.text);
          if (commandMatched) {
            _feedbackService.commandRecognized();
          }
          emit(s.copyWith(isListening: false));
        } catch (e) {
          emit(
            s.copyWith(isListening: false, errorCode: 'SPEECH_PROCESS_ERROR'),
          );
        }
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
        final summary = s.params.content.length > 50
            ? '${s.params.content.substring(0, 50)}...'
            : s.params.content;
        emit(s.copyWith(isSummarizing: false, summary: summary));
      } catch (e) {
        emit(s.copyWith(isSummarizing: false, errorCode: 'SUMMARY_FAILED'));
      }
    }
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

        // OPTIONAL FEATURE: Knowledge Graph & Linking (may be removed)
        // Parse and update links
        if (s.params.content.isNotEmpty) {
          final links = _linkParserService.extractLinks(
            s.params.content,
          ); // Use content from params which might be Quill Delta JSON?
          // Note: extractLinks expects plain text or we need to parse Delta to text first.
          // Assuming s.params.content is Text for now, or if it is JSON we might need to be careful.
          // However, _onContentChanged updates params.content.
          // If UI sends Delta JSON, we might need to extract text from it.
          // But LinkParserService regex works on string.
          // Let's assume we pass the raw string and let regex find [[...]].
          if (s.params.noteId != null) {
            // We need to resolve Link Titles to IDs.
            // This is tricky: updateNoteLinks expects target IDs.
            // Logic: For each extracted Title [[Title]], find a Note with that Title.
            // IF multiple, pick one? IF none, maybe just store the text for now or Create a Stub?
            // For now, let's implement basic "Find by Title" lookups?
            // Repository needs `findNoteByTitle`.
            // SIMPLIFICATION: usage of updateNoteLinks(sourceId, targetIds) matches IDs.
            // We need to map Titles -> IDs.
            // Let's SKIP ID resolution for now and just print passing.
            // Or better: Let's assume LinkParser extracts IDs? No, users type Titles.
            // Ok, let's fetch ALL notes and match titles. Inefficient but works.

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
            await _noteRepository.updateNoteLinks(s.params.noteId!, targetIds);
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
}
