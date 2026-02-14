import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'note_versioning_event.dart';
part 'note_versioning_state.dart';

/// Note Versioning BLoC for managing version history and restoration
class NoteVersioningBloc
    extends Bloc<NoteVersioningEvent, NoteVersioningState> {
  final Map<String, List<NoteVersion>> _noteVersions = {};
  static const int _maxVersionsPerNote = 50;

  NoteVersioningBloc() : super(const NoteVersioningInitial()) {
    on<SaveNoteVersionEvent>(_onSaveNoteVersion);
    on<LoadNoteVersionsEvent>(_onLoadNoteVersions);
    on<RestoreNoteVersionEvent>(_onRestoreNoteVersion);
    on<DeleteNoteVersionEvent>(_onDeleteNoteVersion);
    on<ClearNoteVersionsEvent>(_onClearNoteVersions);
  }

  Future<void> _onSaveNoteVersion(
    SaveNoteVersionEvent event,
    Emitter<NoteVersioningState> emit,
  ) async {
    try {
      emit(const NoteVersioningLoading());

      final version = NoteVersion(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        noteId: event.noteId,
        title: event.title,
        content: event.content,
        reason: event.reason,
        createdAt: DateTime.now(),
        size: (event.content.length + event.title.length),
      );

      _noteVersions.putIfAbsent(event.noteId, () => []);
      _noteVersions[event.noteId]!.insert(0, version);

      // Keep only max versions
      if (_noteVersions[event.noteId]!.length > _maxVersionsPerNote) {
        _noteVersions[event.noteId]!.removeLast();
      }

      emit(NoteVersionSaved(version));
    } catch (e) {
      emit(NoteVersioningError(e.toString()));
    }
  }

  Future<void> _onLoadNoteVersions(
    LoadNoteVersionsEvent event,
    Emitter<NoteVersioningState> emit,
  ) async {
    try {
      emit(const NoteVersioningLoading());

      final versions = _noteVersions[event.noteId] ?? [];
      emit(NoteVersionsLoaded(versions));
    } catch (e) {
      emit(NoteVersioningError(e.toString()));
    }
  }

  Future<void> _onRestoreNoteVersion(
    RestoreNoteVersionEvent event,
    Emitter<NoteVersioningState> emit,
  ) async {
    try {
      emit(const NoteVersioningLoading());

      final versions = _noteVersions[event.noteId];
      if (versions == null || event.versionIndex >= versions.length) {
        throw Exception('Version not found');
      }

      final versionToRestore = versions[event.versionIndex];
      emit(NoteVersionRestored(versionToRestore));
    } catch (e) {
      emit(NoteVersioningError(e.toString()));
    }
  }

  Future<void> _onDeleteNoteVersion(
    DeleteNoteVersionEvent event,
    Emitter<NoteVersioningState> emit,
  ) async {
    try {
      emit(const NoteVersioningLoading());

      final versions = _noteVersions[event.noteId];
      if (versions != null && event.versionIndex < versions.length) {
        versions.removeAt(event.versionIndex);
        emit(NoteVersionsLoaded(versions));
      }
    } catch (e) {
      emit(NoteVersioningError(e.toString()));
    }
  }

  Future<void> _onClearNoteVersions(
    ClearNoteVersionsEvent event,
    Emitter<NoteVersioningState> emit,
  ) async {
    try {
      emit(const NoteVersioningLoading());

      _noteVersions.remove(event.noteId);
      emit(const NoteVersionsLoaded([]));
    } catch (e) {
      emit(NoteVersioningError(e.toString()));
    }
  }
}
