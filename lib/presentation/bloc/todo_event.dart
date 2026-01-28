import 'package:equatable/equatable.dart';

abstract class TodoEvent extends Equatable {
  const TodoEvent();

  @override
  List<Object?> get props => [];
}

class LoadTodosEvent extends TodoEvent {
  final String noteId;

  const LoadTodosEvent(this.noteId);

  @override
  List<Object?> get props => [noteId];
}

class AddTodoEvent extends TodoEvent {
  final String noteId;
  final String text;

  const AddTodoEvent({required this.noteId, required this.text});

  @override
  List<Object?> get props => [noteId, text];
}

class ToggleTodoEvent extends TodoEvent {
  final String noteId;
  final String todoId;

  const ToggleTodoEvent({required this.noteId, required this.todoId});

  @override
  List<Object?> get props => [noteId, todoId];
}

class DeleteTodoEvent extends TodoEvent {
  final String noteId;
  final String todoId;

  const DeleteTodoEvent({required this.noteId, required this.todoId});

  @override
  List<Object?> get props => [noteId, todoId];
}

class ReorderTodosEvent extends TodoEvent {
  final String noteId;
  final int oldIndex;
  final int newIndex;

  const ReorderTodosEvent({
    required this.noteId,
    required this.oldIndex,
    required this.newIndex,
  });

  @override
  List<Object?> get props => [noteId, oldIndex, newIndex];
}

class UpdateTodoTextEvent extends TodoEvent {
  final String noteId;
  final String todoId;
  final String newText;

  const UpdateTodoTextEvent({
    required this.noteId,
    required this.todoId,
    required this.newText,
  });

  @override
  List<Object?> get props => [noteId, todoId, newText];
}

