import 'package:equatable/equatable.dart';
import '../../domain/entities/todo_item.dart';
import 'todo_event.dart';

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
  final List<TodoItem> filteredTodos;
  final TodoFilter currentFilter;
  final TodoSortOption sortOption;
  final bool sortAscending;

  const TodosLoaded({
    required this.todos,
    required this.filteredTodos,
    this.currentFilter = TodoFilter.all,
    this.sortOption = TodoSortOption.dueDate,
    this.sortAscending = true,
  });

  TodosLoaded copyWith({
    List<TodoItem>? todos,
    List<TodoItem>? filteredTodos,
    TodoFilter? currentFilter,
    TodoSortOption? sortOption,
    bool? sortAscending,
  }) {
    return TodosLoaded(
      todos: todos ?? this.todos,
      filteredTodos: filteredTodos ?? this.filteredTodos,
      currentFilter: currentFilter ?? this.currentFilter,
      sortOption: sortOption ?? this.sortOption,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }

  @override
  List<Object?> get props => [
    todos,
    filteredTodos,
    currentFilter,
    sortOption,
    sortAscending,
  ];
}

class TodoError extends TodoState {
  final String message;

  const TodoError(this.message);

  @override
  List<Object?> get props => [message];
}

class TodoOperationSuccess extends TodoState {
  final String message;
  final List<TodoItem> todos;

  const TodoOperationSuccess({required this.message, required this.todos});
  @override
  List<Object?> get props => [message, todos];
}
