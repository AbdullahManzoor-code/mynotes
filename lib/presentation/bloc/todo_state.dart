import 'package:equatable/equatable.dart';
import '../../domain/entities/todo_item.dart';

abstract class TodoState extends Equatable {
  const TodoState();

  @override
  List<Object?> get props => [];
}

class TodoInitial extends TodoState {
  const TodoInitial();
}

class TodoLoading extends TodoState {
  const TodoLoading();
}

class TodosLoaded extends TodoState {
  final List<TodoItem> todos;
  final String noteId;

  const TodosLoaded(this.todos, this.noteId);

  @override
  List<Object?> get props => [todos, noteId];
}

class TodoError extends TodoState {
  final String message;

  const TodoError(this.message);

  @override
  List<Object?> get props => [message];
}
