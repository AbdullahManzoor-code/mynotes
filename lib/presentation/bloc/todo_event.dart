import 'package:equatable/equatable.dart';
import '../../domain/entities/todo_item.dart';
import 'params/todo_params.dart';

abstract class TodoEvent extends Equatable {
  const TodoEvent();

  @override
  List<Object?> get props => [];
}

class LoadTodosEvent extends TodoEvent {
  const LoadTodosEvent();
}

/// Create new todo using Complete Param pattern
/// 📦 Pass the complete TodoParams object instead of individual parameters
class AddTodoEvent extends TodoEvent {
  final TodoParams params;

  /// Create with TodoParams (preferred way)
  const AddTodoEvent({required this.params});

  /// Convenience: from TodoItem entity
  factory AddTodoEvent.fromTodoItem(TodoItem todo) {
    return AddTodoEvent(params: TodoParams.fromTodoItem(todo));
  }

  @override
  List<Object?> get props => [params];
}

/// Update existing todo using Complete Param pattern
/// 📦 Use TodoParams instead of individual fields
class UpdateTodoEvent extends TodoEvent {
  final TodoParams params;

  /// Create with TodoParams (preferred way)
  const UpdateTodoEvent({required this.params});

  /// Convenience: from TodoItem entity
  factory UpdateTodoEvent.fromTodoItem(TodoItem todo) {
    return UpdateTodoEvent(params: TodoParams.fromTodoItem(todo));
  }

  @override
  List<Object?> get props => [params];
}

/// Toggle todo completion using Complete Param pattern
/// 📦 Use TodoParams instead of just todoId
class ToggleTodoEvent extends TodoEvent {
  final TodoParams params;

  /// Create with updated params
  const ToggleTodoEvent({required this.params});

  /// Convenience: directly toggle using the helper method
  factory ToggleTodoEvent.toggle(TodoParams params) {
    return ToggleTodoEvent(params: params.toggleCompletion());
  }

  @override
  List<Object?> get props => [params];
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

class SearchTodosEvent extends TodoEvent {
  final String query;

  const SearchTodosEvent({required this.query});

  @override
  List<Object?> get props => [query];
}

class UndoDeleteTodoEvent extends TodoEvent {
  const UndoDeleteTodoEvent();
}

/// Add tag to todo using Complete Param pattern
class AddTodoTagEvent extends TodoEvent {
  final TodoParams params;

  /// Create with tag already added
  const AddTodoTagEvent({required this.params});

  /// Convenience: create with tag added
  factory AddTodoTagEvent.withTag(TodoParams params, String tag) {
    return AddTodoTagEvent(params: params.withTag(tag));
  }

  @override
  List<Object?> get props => [params];
}

/// Remove tag from todo using Complete Param pattern
class RemoveTodoTagEvent extends TodoEvent {
  final TodoParams params;

  /// Create with tag already removed
  const RemoveTodoTagEvent({required this.params});

  /// Convenience: create with tag removed
  factory RemoveTodoTagEvent.withoutTag(TodoParams params, String tag) {
    return RemoveTodoTagEvent(params: params.withoutTag(tag));
  }

  @override
  List<Object?> get props => [params];
}

/// Change todo priority using Complete Param pattern
class ChangeTodoPriorityEvent extends TodoEvent {
  final TodoParams params;

  /// Create with priority updated
  const ChangeTodoPriorityEvent({required this.params});

  /// Convenience: change priority
  factory ChangeTodoPriorityEvent.toPriority(
    TodoParams params,
    TodoPriority priority,
  ) {
    return ChangeTodoPriorityEvent(params: params.withPriority(priority));
  }

  @override
  List<Object?> get props => [params];
}

/// Change todo category using Complete Param pattern
class ChangeTodoCategoryEvent extends TodoEvent {
  final TodoParams params;

  /// Create with category updated
  const ChangeTodoCategoryEvent({required this.params});

  /// Convenience: change category
  factory ChangeTodoCategoryEvent.toCategory(
    TodoParams params,
    TodoCategory category,
  ) {
    return ChangeTodoCategoryEvent(params: params.withCategory(category));
  }

  @override
  List<Object?> get props => [params];
}
