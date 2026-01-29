part of 'deep_linking_bloc.dart';

abstract class DeepLinkingEvent extends Equatable {
  const DeepLinkingEvent();

  @override
  List<Object?> get props => [];
}

class ProcessDeepLinkEvent extends DeepLinkingEvent {
  final String deepLink;

  const ProcessDeepLinkEvent(this.deepLink);

  @override
  List<Object?> get props => [deepLink];
}

class ParseDeepLinkEvent extends DeepLinkingEvent {
  final String linkString;

  const ParseDeepLinkEvent(this.linkString);

  @override
  List<Object?> get props => [linkString];
}

class OpenNoteFromLinkEvent extends DeepLinkingEvent {
  final String noteId;
  final Map<String, dynamic> noteData;

  const OpenNoteFromLinkEvent(this.noteId, this.noteData);

  @override
  List<Object?> get props => [noteId, noteData];
}

class OpenTodoFromLinkEvent extends DeepLinkingEvent {
  final String todoId;
  final Map<String, dynamic> todoData;

  const OpenTodoFromLinkEvent(this.todoId, this.todoData);

  @override
  List<Object?> get props => [todoId, todoData];
}

class OpenReminderFromLinkEvent extends DeepLinkingEvent {
  final String reminderId;
  final Map<String, dynamic> reminderData;

  const OpenReminderFromLinkEvent(this.reminderId, this.reminderData);

  @override
  List<Object?> get props => [reminderId, reminderData];
}

class ShareDeepLinkEvent extends DeepLinkingEvent {
  final String type; // note, todo, reminder
  final String entityId;

  const ShareDeepLinkEvent(this.type, this.entityId);

  @override
  List<Object?> get props => [type, entityId];
}
