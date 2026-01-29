import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'deep_linking_event.dart';
part 'deep_linking_state.dart';

/// Deep Linking BLoC for handling deep links
/// Opens specific notes, todos from external links
class DeepLinkingBloc extends Bloc<DeepLinkingEvent, DeepLinkingState> {
  DeepLinkingBloc() : super(const DeepLinkingInitial()) {
    on<ProcessDeepLinkEvent>(_onProcessDeepLink);
    on<ParseDeepLinkEvent>(_onParseDeepLink);
    on<OpenNoteFromLinkEvent>(_onOpenNoteFromLink);
    on<OpenTodoFromLinkEvent>(_onOpenTodoFromLink);
    on<OpenReminderFromLinkEvent>(_onOpenReminderFromLink);
    on<ShareDeepLinkEvent>(_onShareDeepLink);
  }

  Future<void> _onProcessDeepLink(
    ProcessDeepLinkEvent event,
    Emitter<DeepLinkingState> emit,
  ) async {
    try {
      emit(const DeepLinkingLoading());

      final link = event.deepLink;

      // Parse link format: mynotes://note/{id}, mynotes://todo/{id}, mynotes://reminder/{id}
      if (link.startsWith('mynotes://')) {
        final uri = Uri.parse(link);
        final scheme = uri.scheme;
        final path = uri.path;
        final segments = path.split('/');

        if (segments.length >= 2) {
          final type = segments[1];
          final id = segments.length > 2 ? segments[2] : '';

          if (type == 'note' && id.isNotEmpty) {
            emit(
              DeepLinkParsed(
                type: 'note',
                entityId: id,
                metadata: uri.queryParameters,
              ),
            );
          } else if (type == 'todo' && id.isNotEmpty) {
            emit(
              DeepLinkParsed(
                type: 'todo',
                entityId: id,
                metadata: uri.queryParameters,
              ),
            );
          } else if (type == 'reminder' && id.isNotEmpty) {
            emit(
              DeepLinkParsed(
                type: 'reminder',
                entityId: id,
                metadata: uri.queryParameters,
              ),
            );
          } else {
            emit(const DeepLinkingError('Invalid deep link format'));
          }
        } else {
          emit(const DeepLinkingError('Invalid deep link structure'));
        }
      } else {
        emit(const DeepLinkingError('Unsupported deep link scheme'));
      }
    } catch (e) {
      emit(DeepLinkingError(e.toString()));
    }
  }

  Future<void> _onParseDeepLink(
    ParseDeepLinkEvent event,
    Emitter<DeepLinkingState> emit,
  ) async {
    try {
      emit(const DeepLinkingLoading());

      final uri = Uri.parse(event.linkString);
      emit(
        DeepLinkParsed(
          type: uri.path.split('/').elementAtOrNull(1) ?? 'unknown',
          entityId: uri.path.split('/').elementAtOrNull(2) ?? '',
          metadata: uri.queryParameters,
        ),
      );
    } catch (e) {
      emit(DeepLinkingError('Failed to parse link: ${e.toString()}'));
    }
  }

  Future<void> _onOpenNoteFromLink(
    OpenNoteFromLinkEvent event,
    Emitter<DeepLinkingState> emit,
  ) async {
    try {
      emit(DeepLinkingLoading());

      // In real implementation, would fetch note from repository
      emit(NoteDeepLinkOpened(noteId: event.noteId, note: event.noteData));
    } catch (e) {
      emit(DeepLinkingError('Failed to open note: ${e.toString()}'));
    }
  }

  Future<void> _onOpenTodoFromLink(
    OpenTodoFromLinkEvent event,
    Emitter<DeepLinkingState> emit,
  ) async {
    try {
      emit(DeepLinkingLoading());

      emit(TodoDeepLinkOpened(todoId: event.todoId, todoData: event.todoData));
    } catch (e) {
      emit(DeepLinkingError('Failed to open todo: ${e.toString()}'));
    }
  }

  Future<void> _onOpenReminderFromLink(
    OpenReminderFromLinkEvent event,
    Emitter<DeepLinkingState> emit,
  ) async {
    try {
      emit(DeepLinkingLoading());

      emit(
        ReminderDeepLinkOpened(
          reminderId: event.reminderId,
          reminderData: event.reminderData,
        ),
      );
    } catch (e) {
      emit(DeepLinkingError('Failed to open reminder: ${e.toString()}'));
    }
  }

  Future<void> _onShareDeepLink(
    ShareDeepLinkEvent event,
    Emitter<DeepLinkingState> emit,
  ) async {
    try {
      emit(DeepLinkingLoading());

      final link = _generateDeepLink(event.type, event.entityId);
      emit(DeepLinkGenerated(link: link));
    } catch (e) {
      emit(DeepLinkingError('Failed to generate link: ${e.toString()}'));
    }
  }

  String _generateDeepLink(String type, String entityId) {
    return 'mynotes://$type/$entityId';
  }
}
