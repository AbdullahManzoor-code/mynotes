import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'note_linking_event.dart';
part 'note_linking_state.dart';

/// Note Linking BLoC for managing note-to-note links and backlinks
class NoteLinkingBloc extends Bloc<NoteLinkingEvent, NoteLinkingState> {
  final Map<String, Set<String>> _noteLinks = {};
  final Map<String, Map<String, String>> _linkMetadata = {};

  NoteLinkingBloc() : super(const NoteLinkingInitial()) {
    on<LinkNotesEvent>(_onLinkNotes);
    on<UnlinkNotesEvent>(_onUnlinkNotes);
    on<LoadLinkedNotesEvent>(_onLoadLinkedNotes);
    on<LoadBacklinksEvent>(_onLoadBacklinks);
    on<UpdateLinkMetadataEvent>(_onUpdateLinkMetadata);
  }

  Future<void> _onLinkNotes(
    LinkNotesEvent event,
    Emitter<NoteLinkingState> emit,
  ) async {
    try {
      emit(const NoteLinkingLoading());

      // Create bidirectional link
      _noteLinks.putIfAbsent(event.sourceNoteId, () => {});
      _noteLinks[event.sourceNoteId]!.add(event.targetNoteId);

      final link = NoteLink(
        sourceNoteId: event.sourceNoteId,
        targetNoteId: event.targetNoteId,
        createdAt: DateTime.now(),
      );

      emit(NotesLinked(link));
    } catch (e) {
      emit(NoteLinkingError(e.toString()));
    }
  }

  Future<void> _onUnlinkNotes(
    UnlinkNotesEvent event,
    Emitter<NoteLinkingState> emit,
  ) async {
    try {
      emit(const NoteLinkingLoading());

      _noteLinks[event.sourceNoteId]?.remove(event.targetNoteId);
      final key = '${event.sourceNoteId}_${event.targetNoteId}';
      _linkMetadata.remove(key);

      emit(
        NotesUnlinked(
          sourceNoteId: event.sourceNoteId,
          targetNoteId: event.targetNoteId,
        ),
      );
    } catch (e) {
      emit(NoteLinkingError(e.toString()));
    }
  }

  Future<void> _onLoadLinkedNotes(
    LoadLinkedNotesEvent event,
    Emitter<NoteLinkingState> emit,
  ) async {
    try {
      emit(const NoteLinkingLoading());

      final linkedIds = _noteLinks[event.noteId] ?? {};
      final linkedNotes = linkedIds.map((id) {
        final key = '${event.noteId}_$id';
        return NoteLink(
          sourceNoteId: event.noteId,
          targetNoteId: id,
          metadata: _linkMetadata[key]?['description'],
          createdAt: DateTime.now(),
        );
      }).toList();

      emit(LinkedNotesLoaded(linkedNotes));
    } catch (e) {
      emit(NoteLinkingError(e.toString()));
    }
  }

  Future<void> _onLoadBacklinks(
    LoadBacklinksEvent event,
    Emitter<NoteLinkingState> emit,
  ) async {
    try {
      emit(const NoteLinkingLoading());

      // Find all notes that link to this note
      final backlinks = <NoteLink>[];
      _noteLinks.forEach((sourceId, targets) {
        if (targets.contains(event.noteId)) {
          final key = '${sourceId}_${event.noteId}';
          backlinks.add(
            NoteLink(
              sourceNoteId: sourceId,
              targetNoteId: event.noteId,
              metadata: _linkMetadata[key]?['description'],
              createdAt: DateTime.now(),
            ),
          );
        }
      });

      emit(BacklinksLoaded(backlinks));
    } catch (e) {
      emit(NoteLinkingError(e.toString()));
    }
  }

  Future<void> _onUpdateLinkMetadata(
    UpdateLinkMetadataEvent event,
    Emitter<NoteLinkingState> emit,
  ) async {
    try {
      emit(const NoteLinkingLoading());

      final key = '${event.sourceNoteId}_${event.targetNoteId}';
      _linkMetadata.putIfAbsent(key, () => {});
      _linkMetadata[key]!['description'] = event.metadata;

      emit(
        NotesLinked(
          NoteLink(
            sourceNoteId: event.sourceNoteId,
            targetNoteId: event.targetNoteId,
            metadata: event.metadata,
            createdAt: DateTime.now(),
          ),
        ),
      );
    } catch (e) {
      emit(NoteLinkingError(e.toString()));
    }
  }
}
