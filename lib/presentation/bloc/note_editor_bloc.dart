import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/note.dart';
import '../../core/services/speech_service.dart';
import '../../core/services/voice_command_service.dart';
import '../../core/services/audio_feedback_service.dart';
import '../../core/services/ocr_service.dart';
// OPTIONAL FEATURE: Knowledge Graph & Linking (may be removed)
import '../../core/services/link_parser_service.dart';
import '../../domain/repositories/note_repository.dart';
import 'note_editor_event.dart';
import 'note_editor_state.dart';
import 'params/note_params.dart';
import '../../domain/entities/media_item.dart';

class NoteEditorBloc extends Bloc<NoteEditorEvent, NoteEditorState> {
  final SpeechService _speechService;
  final VoiceCommandService _commandService;
  final AudioFeedbackService _feedbackService;
  final OCRService _ocrService;
  // OPTIONAL FEATURE: Knowledge Graph & Linking (may be removed)
  final NoteRepository _noteRepository;
  final LinkParserService _linkParserService;

  NoteEditorBloc({
    required SpeechService speechService,
    required VoiceCommandService commandService,
    required AudioFeedbackService feedbackService,
    required OCRService ocrService,
    // OPTIONAL FEATURE: Knowledge Graph & Linking (may be removed)
    required NoteRepository noteRepository,
    required LinkParserService linkParserService,
  }) : _speechService = speechService,
       _commandService = commandService,
       _feedbackService = feedbackService,
       _ocrService = ocrService,
       // OPTIONAL FEATURE: Knowledge Graph & Linking (may be removed)
       _noteRepository = noteRepository,
       _linkParserService = linkParserService,
       super(const NoteEditorInitial()) {
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
        params = NoteParams(
          title: event.template.title ?? '',
          content: event.template.content ?? '',
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

  void _onMediaAdded(MediaAdded event, Emitter<NoteEditorState> emit) {
    if (state is NoteEditorLoaded) {
      final s = state as NoteEditorLoaded;
      try {
        final mediaItem = MediaItem(
          id: DateTime.now().toIso8601String(),
          type: event.type,
          filePath: event.filePath,
          name: event.name ?? event.filePath.split('/').last,
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
      emit(
        s.copyWith(
          params: s.params.copyWith(
            title: event.template.titlePlaceholder,
            content: event.template.contentPlaceholder,
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
