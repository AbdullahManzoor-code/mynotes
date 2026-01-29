part of 'deep_linking_bloc.dart';

abstract class DeepLinkingState extends Equatable {
  const DeepLinkingState();

  @override
  List<Object?> get props => [];
}

class DeepLinkingInitial extends DeepLinkingState {
  const DeepLinkingInitial();
}

class DeepLinkingLoading extends DeepLinkingState {
  const DeepLinkingLoading();
}

class DeepLinkParsed extends DeepLinkingState {
  final String type;
  final String entityId;
  final Map<String, String> metadata;

  const DeepLinkParsed({
    required this.type,
    required this.entityId,
    required this.metadata,
  });

  @override
  List<Object?> get props => [type, entityId, metadata];
}

class NoteDeepLinkOpened extends DeepLinkingState {
  final String noteId;
  final Map<String, dynamic> note;

  const NoteDeepLinkOpened({required this.noteId, required this.note});

  @override
  List<Object?> get props => [noteId, note];
}

class TodoDeepLinkOpened extends DeepLinkingState {
  final String todoId;
  final Map<String, dynamic> todoData;

  const TodoDeepLinkOpened({required this.todoId, required this.todoData});

  @override
  List<Object?> get props => [todoId, todoData];
}

class ReminderDeepLinkOpened extends DeepLinkingState {
  final String reminderId;
  final Map<String, dynamic> reminderData;

  const ReminderDeepLinkOpened({
    required this.reminderId,
    required this.reminderData,
  });

  @override
  List<Object?> get props => [reminderId, reminderData];
}

class DeepLinkGenerated extends DeepLinkingState {
  final String link;

  const DeepLinkGenerated({required this.link});

  @override
  List<Object?> get props => [link];
}

class DeepLinkingError extends DeepLinkingState {
  final String message;

  const DeepLinkingError(this.message);

  @override
  List<Object?> get props => [message];
}
