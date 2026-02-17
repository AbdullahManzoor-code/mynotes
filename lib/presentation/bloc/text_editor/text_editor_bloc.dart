import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'text_editor_event.dart';
part 'text_editor_state.dart';

/// Text Editor BLoC for managing file editing operations
/// Handles loading, editing, and saving text files
class TextEditorBloc extends Bloc<TextEditorEvent, TextEditorState> {
  TextEditorBloc() : super(const TextEditorInitial()) {
    on<LoadFileContentEvent>(_onLoadFileContent);
    on<UpdateContentEvent>(_onUpdateContent);
    on<SaveFileEvent>(_onSaveFile);
    on<ClearEditorEvent>(_onClearEditor);
  }

  Future<void> _onLoadFileContent(
    LoadFileContentEvent event,
    Emitter<TextEditorState> emit,
  ) async {
    emit(const TextEditorLoading());
    try {
      final file = File(event.filePath);
      if (!await file.exists()) {
        emit(const TextEditorError(message: 'File not found'));
        return;
      }
      final content = await file.readAsString();
      emit(TextEditorLoaded(content: content));
    } catch (e) {
      emit(TextEditorError(message: 'Failed to load file: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateContent(
    UpdateContentEvent event,
    Emitter<TextEditorState> emit,
  ) async {
    final currentState = state;
    emit(currentState.copyWith(content: event.content));
  }

  Future<void> _onSaveFile(
    SaveFileEvent event,
    Emitter<TextEditorState> emit,
  ) async {
    emit(TextEditorSaving(content: event.content));
    try {
      final file = File(event.filePath);
      await file.writeAsString(event.content);
      emit(TextEditorSaveSuccess(content: event.content));
    } catch (e) {
      emit(TextEditorError(message: 'Failed to save file: ${e.toString()}'));
    }
  }

  Future<void> _onClearEditor(
    ClearEditorEvent event,
    Emitter<TextEditorState> emit,
  ) async {
    emit(const TextEditorInitial());
  }
}
