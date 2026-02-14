import 'package:equatable/equatable.dart';
import 'package:mynotes/presentation/widgets/note_template_selector.dart';
import 'package:mynotes/domain/entities/note.dart';
import 'package:mynotes/domain/entities/media_item.dart';
import 'package:mynotes/domain/entities/alarm.dart';
import 'package:mynotes/domain/entities/todo_item.dart';
import 'package:mynotes/core/utils/context_scanner.dart';

abstract class NoteEditorEvent extends Equatable {
  const NoteEditorEvent();

  @override
  List<Object?> get props => [];
}

class NoteEditorInitialized extends NoteEditorEvent {
  final Note? note;
  final dynamic template;
  final String? initialContent;

  const NoteEditorInitialized({this.note, this.template, this.initialContent});

  @override
  List<Object?> get props => [note, template, initialContent];
}

class TitleChanged extends NoteEditorEvent {
  final String title;
  const TitleChanged(this.title);

  @override
  List<Object?> get props => [title];
}

class ContentChanged extends NoteEditorEvent {
  final String content;
  const ContentChanged(this.content);

  @override
  List<Object?> get props => [content];
}

class TagAdded extends NoteEditorEvent {
  final String tag;
  const TagAdded(this.tag);

  @override
  List<Object?> get props => [tag];
}

class TagRemoved extends NoteEditorEvent {
  final String tag;
  const TagRemoved(this.tag);

  @override
  List<Object?> get props => [tag];
}

class ColorChanged extends NoteEditorEvent {
  final NoteColor color;
  const ColorChanged(this.color);

  @override
  List<Object?> get props => [color];
}

class PinToggled extends NoteEditorEvent {
  const PinToggled();
}

class MediaAdded extends NoteEditorEvent {
  final String filePath;
  final MediaType type;
  final String? name;
  final int? duration;

  const MediaAdded(this.filePath, this.type, {this.name, this.duration});

  @override
  List<Object?> get props => [filePath, type, name, duration];
}

class MediaRemoved extends NoteEditorEvent {
  final int index;
  const MediaRemoved(this.index);

  @override
  List<Object?> get props => [index];
}

class MediaUpdated extends NoteEditorEvent {
  final MediaItem oldMedia;
  final MediaItem newMedia;
  const MediaUpdated(this.oldMedia, this.newMedia);

  @override
  List<Object?> get props => [oldMedia, newMedia];
}

class VoiceInputToggled extends NoteEditorEvent {
  const VoiceInputToggled();
}

class ContextScannerTriggered extends NoteEditorEvent {
  final String text;
  const ContextScannerTriggered(this.text);

  @override
  List<Object?> get props => [text];
}

class SuggestionActionAccepted extends NoteEditorEvent {
  final ContextSuggestion suggestion;
  const SuggestionActionAccepted(this.suggestion);

  @override
  List<Object?> get props => [suggestion];
}

class StopVoiceInputRequested extends NoteEditorEvent {
  const StopVoiceInputRequested();
}

class SpeechResultReceived extends NoteEditorEvent {
  final String text;
  final bool isFinal;
  const SpeechResultReceived(this.text, {this.isFinal = false});

  @override
  List<Object?> get props => [text, isFinal];
}

class GenerateSummaryRequested extends NoteEditorEvent {
  const GenerateSummaryRequested();
}

class SaveNoteRequested extends NoteEditorEvent {
  const SaveNoteRequested();
}

class AlarmAdded extends NoteEditorEvent {
  final Alarm alarm;
  const AlarmAdded(this.alarm);

  @override
  List<Object?> get props => [alarm];
}

class TemplateApplied extends NoteEditorEvent {
  final NoteTemplate template;
  const TemplateApplied(this.template);

  @override
  List<Object?> get props => [template];
}

class TodoAdded extends NoteEditorEvent {
  final TodoItem todo;
  const TodoAdded(this.todo);

  @override
  List<Object?> get props => [todo];
}

class TextExtractionRequested extends NoteEditorEvent {
  final String filePath;
  const TextExtractionRequested(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class ErrorOccurred extends NoteEditorEvent {
  final String message;
  final String? code;
  const ErrorOccurred(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

class PromoteToTodoRequested extends NoteEditorEvent {
  const PromoteToTodoRequested();
}
