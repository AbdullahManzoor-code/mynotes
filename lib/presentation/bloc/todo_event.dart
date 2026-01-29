import 'package:equatable/equatable.dart';
import '../../domain/entities/todo_item.dart';

abstract class TodoEvent extends Equatable {
  const TodoEvent();

  @override
  List<Object?> get props => [];
}

class LoadTodosEvent extends TodoEvent {
  const LoadTodosEvent();
}

class AddTodoEvent extends TodoEvent {
  final TodoItem todo;

  const AddTodoEvent({required this.todo});

  @override
  List<Object?> get props => [todo];
}

class UpdateTodoEvent extends TodoEvent {
  final TodoItem todo;

  const UpdateTodoEvent({required this.todo});

  @override
  List<Object?> get props => [todo];
}

class ToggleTodoEvent extends TodoEvent {
  final String todoId;

  const ToggleTodoEvent({required this.todoId});

  @override
  List<Object?> get props => [todoId];
}

class DeleteTodoEvent extends TodoEvent {
  final String todoId;

  const DeleteTodoEvent({required this.todoId});

  @override
  List<Object?> get props => [todoId];
}

class FilterTodosEvent extends TodoEvent {
  final TodoFilter filter;

  const FilterTodosEvent({required this.filter});

  @override
  List<Object?> get props => [filter];
}

class SortTodosEvent extends TodoEvent {
  final TodoSortOption sortOption;
  final bool ascending;

  const SortTodosEvent({required this.sortOption, this.ascending = true});

  @override
  List<Object?> get props => [sortOption, ascending];
}

enum TodoFilter { all, active, completed, overdue, today, thisWeek }

enum TodoSortOption { dueDate, priority, category, createdDate, alphabetical }

class SearchTodosEvent extends TodoEvent {
  final String query;

  const SearchTodosEvent({required this.query});

  @override
  List<Object?> get props => [query];
}

class UndoDeleteTodoEvent extends TodoEvent {
  const UndoDeleteTodoEvent();
}
