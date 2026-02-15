import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mynotes/core/services/app_logger.dart' show AppLogger;
import 'package:mynotes/injection_container.dart';
import 'package:mynotes/presentation/bloc/params/todo_params.dart';
import 'dart:convert';
import '../../../domain/entities/todo_item.dart';
import '../../../domain/repositories/todo_repository.dart';
import '../../../domain/repositories/alarm_repository.dart';

import '../../../domain/entities/alarm.dart';
import '../../../core/notifications/alarm_service.dart';

// Events
abstract class TodosEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadTodos extends TodosEvent {}

/// Create todo using Complete Param pattern
class AddTodo extends TodosEvent {
  final TodoParams params;

  AddTodo(this.params);

  /// Convenience: from TodoItem entity
  factory AddTodo.fromTodoItem(TodoItem todo) {
    return AddTodo(TodoParams.fromTodoItem(todo));
  }

  @override
  List<Object> get props => [params];
}

/// Update todo using Complete Param pattern
class UpdateTodo extends TodosEvent {
  final TodoParams params;

  UpdateTodo(this.params);

  /// Convenience: from TodoItem entity
  factory UpdateTodo.fromTodoItem(TodoItem todo) {
    return UpdateTodo(TodoParams.fromTodoItem(todo));
  }

  @override
  List<Object> get props => [params];
}

/// Toggle todo completion using Complete Param pattern
class ToggleTodo extends TodosEvent {
  final TodoParams params;

  ToggleTodo(this.params);

  /// Convenience: directly toggle
  factory ToggleTodo.toggle(TodoParams params) {
    return ToggleTodo(params.toggleCompletion());
  }

  @override
  List<Object> get props => [params];
}

class DeleteTodo extends TodosEvent {
  final String todoId;

  DeleteTodo(this.todoId);

  @override
  List<Object> get props => [todoId];
}

class FilterTodos extends TodosEvent {
  final TodoFilter filter;

  FilterTodos(this.filter);

  @override
  List<Object> get props => [filter];
}

class SortTodos extends TodosEvent {
  final TodoSortOption sortOption;
  final bool ascending;

  SortTodos(this.sortOption, {this.ascending = true});

  @override
  List<Object> get props => [sortOption, ascending];
}

class SearchTodos extends TodosEvent {
  final String query;

  SearchTodos(this.query);

  @override
  List<Object> get props => [query];
}

class SetListening extends TodosEvent {
  final bool isListening;

  SetListening(this.isListening);

  @override
  List<Object> get props => [isListening];
}

class ChangeCategory extends TodosEvent {
  final String category;

  ChangeCategory(this.category);

  @override
  List<Object> get props => [category];
}

class UndoDeleteTodo extends TodosEvent {
  final TodoItem todo;

  UndoDeleteTodo(this.todo);

  @override
  List<Object> get props => [todo];
}

class ToggleImportantTodo extends TodosEvent {
  final String todoId;

  ToggleImportantTodo(this.todoId);

  @override
  List<Object> get props => [todoId];
}

class UpdateSubtasks extends TodosEvent {
  final String todoId;
  final List<SubTask> subtasks;

  UpdateSubtasks(this.todoId, this.subtasks);

  @override
  List<Object> get props => [todoId, subtasks];
}

class ToggleFilters extends TodosEvent {}

class AddAlarmToTodo extends TodosEvent {
  final String todoId;
  final Alarm alarm;

  AddAlarmToTodo(this.todoId, this.alarm);

  @override
  List<Object> get props => [todoId, alarm];
}

class RemoveAlarmFromTodo extends TodosEvent {
  final String todoId;
  final String alarmId;

  RemoveAlarmFromTodo(this.todoId, this.alarmId);

  @override
  List<Object> get props => [todoId, alarmId];
}

// States
abstract class TodosState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TodosInitial extends TodosState {}

class TodosLoading extends TodosState {}

class TodosLoaded extends TodosState {
  final List<TodoItem> allTodos;
  final List<TodoItem> filteredTodos;
  final TodoFilter currentFilter;
  final TodoSortOption currentSort;
  final bool sortAscending;
  final String searchQuery;
  final TodoStats stats;
  final TodoItem? lastDeletedTodo;
  final bool showFilters;
  final bool isListening;
  final String selectedCategory;

  TodosLoaded({
    required this.allTodos,
    required this.filteredTodos,
    this.currentFilter = TodoFilter.all,
    this.currentSort = TodoSortOption.createdDate,
    this.sortAscending = false,
    this.searchQuery = '',
    required this.stats,
    this.lastDeletedTodo,
    this.showFilters = false,
    this.isListening = false,
    this.selectedCategory = 'All',
  });

  @override
  List<Object?> get props => [
    allTodos,
    filteredTodos,
    currentFilter,
    currentSort,
    sortAscending,
    searchQuery,
    stats,
    lastDeletedTodo,
    showFilters,
    isListening,
    selectedCategory,
  ];

  TodosLoaded copyWith({
    List<TodoItem>? allTodos,
    List<TodoItem>? filteredTodos,
    TodoFilter? currentFilter,
    TodoSortOption? currentSort,
    bool? sortAscending,
    String? searchQuery,
    TodoStats? stats,
    TodoItem? lastDeletedTodo,
    bool? showFilters,
    bool? isListening,
    String? selectedCategory,
    bool clearLastDeleted = false,
  }) {
    return TodosLoaded(
      allTodos: allTodos ?? this.allTodos,
      filteredTodos: filteredTodos ?? this.filteredTodos,
      currentFilter: currentFilter ?? this.currentFilter,
      currentSort: currentSort ?? this.currentSort,
      sortAscending: sortAscending ?? this.sortAscending,
      searchQuery: searchQuery ?? this.searchQuery,
      stats: stats ?? this.stats,
      showFilters: showFilters ?? this.showFilters,
      isListening: isListening ?? this.isListening,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      lastDeletedTodo: clearLastDeleted
          ? null
          : (lastDeletedTodo ?? this.lastDeletedTodo),
    );
  }
}

class TodosError extends TodosState {
  final String message;

  TodosError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class TodosBloc extends Bloc<TodosEvent, TodosState> {
  final TodoRepository _todoRepository;
  final AlarmRepository _alarmRepository;
  final AlarmService _alarmNotificationService;

  TodosBloc({
    TodoRepository? todoRepository,
    AlarmRepository? alarmRepository,
    AlarmService? alarmNotificationService,
  }) : _todoRepository = todoRepository ?? getIt<TodoRepository>(),
       _alarmRepository = alarmRepository ?? getIt<AlarmRepository>(),
       _alarmNotificationService = alarmNotificationService ?? AlarmService(),
       super(TodosInitial()) {
    on<LoadTodos>(_onLoadTodos);
    on<AddTodo>(_onAddTodo);
    on<UpdateTodo>(_onUpdateTodo);
    on<ToggleTodo>(_onToggleTodo);
    on<DeleteTodo>(_onDeleteTodo);
    on<FilterTodos>(_onFilterTodos);
    on<SortTodos>(_onSortTodos);
    on<SearchTodos>(_onSearchTodos);
    on<UndoDeleteTodo>(_onUndoDeleteTodo);
    on<ToggleImportantTodo>(_onToggleImportantTodo);
    on<UpdateSubtasks>(_onUpdateSubtasks);
    on<ToggleFilters>(_onToggleFilters);
    on<AddAlarmToTodo>(_onAddAlarmToTodo);
    on<RemoveAlarmFromTodo>(_onRemoveAlarmFromTodo);
    on<SetListening>(_onSetListening);
    on<ChangeCategory>(_onChangeCategory);
  }

  void _onSetListening(SetListening event, Emitter<TodosState> emit) {
    if (state is TodosLoaded) {
      emit((state as TodosLoaded).copyWith(isListening: event.isListening));
    }
  }

  void _onChangeCategory(ChangeCategory event, Emitter<TodosState> emit) {
    if (state is TodosLoaded) {
      final currentState = state as TodosLoaded;

      // Also apply categorical filter if needed, but for now we'll just update the state
      // so the UI can filter or show the selected category
      emit(currentState.copyWith(selectedCategory: event.category));
    }
  }

  Future<void> _onLoadTodos(LoadTodos event, Emitter<TodosState> emit) async {
    AppLogger.i('Loading todos...');
    try {
      emit(TodosLoading());

      final allTodos = await _todoRepository.getTodos();
      final stats = allTodos.stats;
      AppLogger.i('Loaded ${allTodos.length} todos');

      // Apply current filters and sorting
      var filteredTodos = allTodos.filter(TodoFilter.all);
      filteredTodos = filteredTodos.sortBy(
        TodoSortOption.createdDate,
        false, // Most recent first
      );

      emit(
        TodosLoaded(
          allTodos: allTodos,
          filteredTodos: filteredTodos,
          stats: stats,
          showFilters: false,
        ),
      );
    } catch (e, stack) {
      AppLogger.e('Failed to load todos: $e', e, stack);
      emit(TodosError('Failed to load todos: $e'));
    }
  }

  void _onToggleFilters(ToggleFilters event, Emitter<TodosState> emit) {
    if (state is TodosLoaded) {
      final current = state as TodosLoaded;
      AppLogger.i('Toggling filters visibility: ${!current.showFilters}');
      emit(current.copyWith(showFilters: !current.showFilters));
    }
  }

  Future<void> _onAddTodo(AddTodo event, Emitter<TodosState> emit) async {
    AppLogger.i('Adding todo: ${event.params.text}');
    if (state is TodosLoaded) {
      try {
        final currentState = state as TodosLoaded;

        // Convert params to TodoItem entity
        final todo = event.params.toTodoItem();
        await _todoRepository.createTodo(todo);
        final allTodos = await _todoRepository.getTodos();
        final stats = allTodos.stats;

        var filteredTodos = _applyFiltersAndSort(
          allTodos,
          currentState.currentFilter,
          currentState.currentSort,
          currentState.sortAscending,
          currentState.searchQuery,
        );

        AppLogger.i('Todo added successfully');
        emit(
          currentState.copyWith(
            allTodos: allTodos,
            filteredTodos: filteredTodos,
            stats: stats,
            clearLastDeleted: true,
          ),
        );
      } catch (e, stack) {
        AppLogger.e('Failed to add todo: $e', e, stack);
        emit(TodosError('Failed to add todo: $e'));
      }
    }
  }

  Future<void> _onUpdateTodo(UpdateTodo event, Emitter<TodosState> emit) async {
    AppLogger.i('Updating todo: ${event.params.todoId}');
    if (state is TodosLoaded) {
      try {
        final currentState = state as TodosLoaded;

        // Convert params to TodoItem entity with updated timestamp
        final todo = event.params
            .copyWith(updatedAt: DateTime.now())
            .toTodoItem();

        await _todoRepository.updateTodo(todo);
        final allTodos = await _todoRepository.getTodos();
        final stats = allTodos.stats;

        var filteredTodos = _applyFiltersAndSort(
          allTodos,
          currentState.currentFilter,
          currentState.currentSort,
          currentState.sortAscending,
          currentState.searchQuery,
        );

        AppLogger.i('Todo updated successfully');
        emit(
          currentState.copyWith(
            allTodos: allTodos,
            filteredTodos: filteredTodos,
            stats: stats,
          ),
        );
      } catch (e, stack) {
        AppLogger.e('Failed to update todo: $e', e, stack);
        emit(TodosError('Failed to update todo: $e'));
      }
    }
  }

  Future<void> _onToggleTodo(ToggleTodo event, Emitter<TodosState> emit) async {
    AppLogger.i('Toggling todo status: ${event.params.todoId}');
    if (state is TodosLoaded) {
      try {
        final currentState = state as TodosLoaded;

        // Find the todo
        final todo = currentState.allTodos.firstWhere(
          (t) => t.id == event.params.todoId,
        );

        final updatedTodo = todo.toggleComplete();
        await _todoRepository.updateTodo(updatedTodo);
        final allTodos = await _todoRepository.getTodos();
        final stats = allTodos.stats;

        var filteredTodos = _applyFiltersAndSort(
          allTodos,
          currentState.currentFilter,
          currentState.currentSort,
          currentState.sortAscending,
          currentState.searchQuery,
        );

        AppLogger.i('Todo status toggled successfully');
        emit(
          currentState.copyWith(
            allTodos: allTodos,
            filteredTodos: filteredTodos,
            stats: stats,
          ),
        );
      } catch (e, stack) {
        AppLogger.e('Failed to toggle todo status: $e', e, stack);
        emit(TodosError('Failed to toggle todo: $e'));
      }
    }
  }

  Future<void> _onDeleteTodo(DeleteTodo event, Emitter<TodosState> emit) async {
    AppLogger.i('Deleting todo: ${event.todoId}');
    if (state is TodosLoaded) {
      try {
        final currentState = state as TodosLoaded;

        // Find the todo to delete for undo functionality
        final todoToDelete = currentState.allTodos.firstWhere(
          (todo) => todo.id == event.todoId,
        );

        await _todoRepository.deleteTodo(event.todoId);
        final allTodos = await _todoRepository.getTodos();
        final stats = allTodos.stats;

        var filteredTodos = _applyFiltersAndSort(
          allTodos,
          currentState.currentFilter,
          currentState.currentSort,
          currentState.sortAscending,
          currentState.searchQuery,
        );

        AppLogger.i('Todo deleted successfully');
        emit(
          currentState.copyWith(
            allTodos: allTodos,
            filteredTodos: filteredTodos,
            stats: stats,
            lastDeletedTodo: todoToDelete,
          ),
        );
      } catch (e, stack) {
        AppLogger.e('Failed to delete todo: $e', e, stack);
        emit(TodosError('Failed to delete todo: $e'));
      }
    }
  }

  Future<void> _onFilterTodos(
    FilterTodos event,
    Emitter<TodosState> emit,
  ) async {
    if (state is TodosLoaded) {
      final currentState = state as TodosLoaded;

      var filteredTodos = _applyFiltersAndSort(
        currentState.allTodos,
        event.filter,
        currentState.currentSort,
        currentState.sortAscending,
        currentState.searchQuery,
      );

      emit(
        currentState.copyWith(
          currentFilter: event.filter,
          filteredTodos: filteredTodos,
        ),
      );
    }
  }

  Future<void> _onSortTodos(SortTodos event, Emitter<TodosState> emit) async {
    if (state is TodosLoaded) {
      final currentState = state as TodosLoaded;

      var filteredTodos = _applyFiltersAndSort(
        currentState.allTodos,
        currentState.currentFilter,
        event.sortOption,
        event.ascending,
        currentState.searchQuery,
      );

      emit(
        currentState.copyWith(
          currentSort: event.sortOption,
          sortAscending: event.ascending,
          filteredTodos: filteredTodos,
        ),
      );
    }
  }

  Future<void> _onSearchTodos(
    SearchTodos event,
    Emitter<TodosState> emit,
  ) async {
    if (state is TodosLoaded) {
      final currentState = state as TodosLoaded;

      var filteredTodos = _applyFiltersAndSort(
        currentState.allTodos,
        currentState.currentFilter,
        currentState.currentSort,
        currentState.sortAscending,
        event.query,
      );

      emit(
        currentState.copyWith(
          searchQuery: event.query,
          filteredTodos: filteredTodos,
        ),
      );
    }
  }

  Future<void> _onToggleImportantTodo(
    ToggleImportantTodo event,
    Emitter<TodosState> emit,
  ) async {
    AppLogger.i('Toggling todo importance: ${event.todoId}');
    if (state is TodosLoaded) {
      try {
        final currentState = state as TodosLoaded;
        final todo = currentState.allTodos.firstWhere(
          (t) => t.id == event.todoId,
        );
        final updatedTodo = todo.toggleImportant();
        await _todoRepository.updateTodo(updatedTodo);
        final allTodos = await _todoRepository.getTodos();
        final stats = allTodos.stats;

        var filteredTodos = _applyFiltersAndSort(
          allTodos,
          currentState.currentFilter,
          currentState.currentSort,
          currentState.sortAscending,
          currentState.searchQuery,
        );

        AppLogger.i('Todo importance toggled successfully');
        emit(
          currentState.copyWith(
            allTodos: allTodos,
            filteredTodos: filteredTodos,
            stats: stats,
          ),
        );
      } catch (e, stack) {
        AppLogger.e('Failed to toggle importance: $e', e, stack);
        emit(TodosError('Failed to toggle importance: $e'));
      }
    }
  }

  Future<void> _onUpdateSubtasks(
    UpdateSubtasks event,
    Emitter<TodosState> emit,
  ) async {
    AppLogger.i('Updating subtasks for todo: ${event.todoId}');
    if (state is TodosLoaded) {
      try {
        final currentState = state as TodosLoaded;
        final todo = currentState.allTodos.firstWhere(
          (t) => t.id == event.todoId,
        );
        final updatedTodo = todo.copyWith(
          subtasks: event.subtasks,
          updatedAt: DateTime.now(),
        );
        await _todoRepository.updateTodo(updatedTodo);
        final allTodos = await _todoRepository.getTodos();
        final stats = allTodos.stats;

        var filteredTodos = _applyFiltersAndSort(
          allTodos,
          currentState.currentFilter,
          currentState.currentSort,
          currentState.sortAscending,
          currentState.searchQuery,
        );

        AppLogger.i('Subtasks updated successfully');
        emit(
          currentState.copyWith(
            allTodos: allTodos,
            filteredTodos: filteredTodos,
            stats: stats,
          ),
        );
      } catch (e, stack) {
        AppLogger.e('Failed to update subtasks: $e', e, stack);
        emit(TodosError('Failed to update subtasks: $e'));
      }
    }
  }

  Future<void> _onUndoDeleteTodo(
    UndoDeleteTodo event,
    Emitter<TodosState> emit,
  ) async {
    AppLogger.i('Restoring deleted todo: ${event.todo.id}');
    if (state is TodosLoaded) {
      try {
        final currentState = state as TodosLoaded;
        await _todoRepository.createTodo(event.todo);
        final allTodos = await _todoRepository.getTodos();
        final stats = allTodos.stats;

        var filteredTodos = _applyFiltersAndSort(
          allTodos,
          currentState.currentFilter,
          currentState.currentSort,
          currentState.sortAscending,
          currentState.searchQuery,
        );

        AppLogger.i('Todo restored successfully');
        emit(
          currentState.copyWith(
            allTodos: allTodos,
            filteredTodos: filteredTodos,
            stats: stats,
            clearLastDeleted: true,
          ),
        );
      } catch (e, stack) {
        AppLogger.e('Failed to restore todo: $e', e, stack);
        emit(TodosError('Failed to restore todo: $e'));
      }
    }
  }

  Future<void> _onAddAlarmToTodo(
    AddAlarmToTodo event,
    Emitter<TodosState> emit,
  ) async {
    AppLogger.i('Adding alarm to todo: ${event.todoId}');
    if (state is TodosLoaded) {
      try {
        final currentState = state as TodosLoaded;
        final todo = currentState.allTodos.firstWhere(
          (t) => t.id == event.todoId,
        );

        // Update alarm with linked todo ID
        final alarm = event.alarm.copyWith(linkedTodoId: todo.id);

        // Add to global reminders list (Persistence)
        await _alarmRepository.createAlarm(alarm);

        // Schedule notification
        await _alarmNotificationService.scheduleAlarm(
          dateTime: alarm.scheduledTime,
          id: alarm.id,
          title: 'Reminder: ${todo.text}',
          payload: jsonEncode({
            'type': 'todo',
            'id': alarm.id,
            'linkedTodoId': todo.id,
          }),
        );

        // Update todo
        final updatedTodo = todo.copyWith(
          hasReminder: true,
          reminderId: alarm.id,
          updatedAt: DateTime.now(),
        );

        await _todoRepository.updateTodo(updatedTodo);
        final allTodos = await _todoRepository.getTodos();
        final stats = allTodos.stats;

        var filteredTodos = _applyFiltersAndSort(
          allTodos,
          currentState.currentFilter,
          currentState.currentSort,
          currentState.sortAscending,
          currentState.searchQuery,
        );

        AppLogger.i('Alarm added to todo successfully');
        emit(
          currentState.copyWith(
            allTodos: allTodos,
            filteredTodos: filteredTodos,
            stats: stats,
          ),
        );
      } catch (e, stack) {
        AppLogger.e('Failed to add alarm to todo: $e', e, stack);
        emit(TodosError('Failed to add alarm to todo: $e'));
      }
    }
  }

  Future<void> _onRemoveAlarmFromTodo(
    RemoveAlarmFromTodo event,
    Emitter<TodosState> emit,
  ) async {
    AppLogger.i('Removing alarm from todo: ${event.todoId}');
    if (state is TodosLoaded) {
      try {
        final currentState = state as TodosLoaded;
        final todo = currentState.allTodos.firstWhere(
          (t) => t.id == event.todoId,
        );

        // Cancel notification
        await _alarmNotificationService.cancelAlarm(event.alarmId);

        // Remove from global persistence
        await _alarmRepository.deleteAlarm(event.alarmId);

        // Update todo
        final updatedTodo = todo.copyWith(
          clearReminder: true,
          updatedAt: DateTime.now(),
        );

        await _todoRepository.updateTodo(updatedTodo);
        final allTodos = await _todoRepository.getTodos();
        final stats = allTodos.stats;

        var filteredTodos = _applyFiltersAndSort(
          allTodos,
          currentState.currentFilter,
          currentState.currentSort,
          currentState.sortAscending,
          currentState.searchQuery,
        );

        AppLogger.i('Alarm removed from todo successfully');
        emit(
          currentState.copyWith(
            allTodos: allTodos,
            filteredTodos: filteredTodos,
            stats: stats,
          ),
        );
      } catch (e, stack) {
        AppLogger.e('Failed to remove alarm from todo: $e', e, stack);
        emit(TodosError('Failed to remove alarm from todo: $e'));
      }
    }
  }

  List<TodoItem> _applyFiltersAndSort(
    List<TodoItem> todos,
    TodoFilter filter,
    TodoSortOption sortOption,
    bool ascending,
    String searchQuery,
  ) {
    // Apply filter
    var filtered = todos.filter(filter);

    // Apply search
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered
          .where(
            (todo) =>
                todo.text.toLowerCase().contains(query) ||
                (todo.notes?.toLowerCase().contains(query) ?? false) ||
                todo.category.name.toLowerCase().contains(query),
          )
          .toList();
    }

    // Apply sort
    return filtered.sortBy(sortOption, ascending);
  }
}
