import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/todo_item.dart';
import '../../core/services/todo_service.dart';

// Events
abstract class TodosEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadTodos extends TodosEvent {}

class AddTodo extends TodosEvent {
  final TodoItem todo;

  AddTodo(this.todo);

  @override
  List<Object> get props => [todo];
}

class UpdateTodo extends TodosEvent {
  final TodoItem todo;

  UpdateTodo(this.todo);

  @override
  List<Object> get props => [todo];
}

class ToggleTodo extends TodosEvent {
  final String todoId;

  ToggleTodo(this.todoId);

  @override
  List<Object> get props => [todoId];
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

class UndoDeleteTodo extends TodosEvent {
  final TodoItem todo;

  UndoDeleteTodo(this.todo);

  @override
  List<Object> get props => [todo];
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

  TodosLoaded({
    required this.allTodos,
    required this.filteredTodos,
    this.currentFilter = TodoFilter.all,
    this.currentSort = TodoSortOption.createdDate,
    this.sortAscending = false,
    this.searchQuery = '',
    required this.stats,
    this.lastDeletedTodo,
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
  TodosBloc() : super(TodosInitial()) {
    on<LoadTodos>(_onLoadTodos);
    on<AddTodo>(_onAddTodo);
    on<UpdateTodo>(_onUpdateTodo);
    on<ToggleTodo>(_onToggleTodo);
    on<DeleteTodo>(_onDeleteTodo);
    on<FilterTodos>(_onFilterTodos);
    on<SortTodos>(_onSortTodos);
    on<SearchTodos>(_onSearchTodos);
    on<UndoDeleteTodo>(_onUndoDeleteTodo);
  }

  Future<void> _onLoadTodos(LoadTodos event, Emitter<TodosState> emit) async {
    try {
      emit(TodosLoading());

      final allTodos = await TodoService.loadTodos();
      final stats = TodoService.getStats(allTodos);

      // Apply current filters and sorting
      var filteredTodos = TodoService.filterTodos(allTodos, TodoFilter.all);
      filteredTodos = TodoService.sortTodos(
        filteredTodos,
        TodoSortOption.createdDate,
        false, // Most recent first
      );

      emit(
        TodosLoaded(
          allTodos: allTodos,
          filteredTodos: filteredTodos,
          stats: stats,
        ),
      );
    } catch (e) {
      emit(TodosError('Failed to load todos: $e'));
    }
  }

  Future<void> _onAddTodo(AddTodo event, Emitter<TodosState> emit) async {
    if (state is TodosLoaded) {
      try {
        final currentState = state as TodosLoaded;
        final allTodos = await TodoService.addTodo(event.todo);
        final stats = TodoService.getStats(allTodos);

        var filteredTodos = _applyFiltersAndSort(
          allTodos,
          currentState.currentFilter,
          currentState.currentSort,
          currentState.sortAscending,
          currentState.searchQuery,
        );

        emit(
          currentState.copyWith(
            allTodos: allTodos,
            filteredTodos: filteredTodos,
            stats: stats,
            clearLastDeleted: true,
          ),
        );
      } catch (e) {
        emit(TodosError('Failed to add todo: $e'));
      }
    }
  }

  Future<void> _onUpdateTodo(UpdateTodo event, Emitter<TodosState> emit) async {
    if (state is TodosLoaded) {
      try {
        final currentState = state as TodosLoaded;
        final allTodos = await TodoService.updateTodo(event.todo);
        final stats = TodoService.getStats(allTodos);

        var filteredTodos = _applyFiltersAndSort(
          allTodos,
          currentState.currentFilter,
          currentState.currentSort,
          currentState.sortAscending,
          currentState.searchQuery,
        );

        emit(
          currentState.copyWith(
            allTodos: allTodos,
            filteredTodos: filteredTodos,
            stats: stats,
          ),
        );
      } catch (e) {
        emit(TodosError('Failed to update todo: $e'));
      }
    }
  }

  Future<void> _onToggleTodo(ToggleTodo event, Emitter<TodosState> emit) async {
    if (state is TodosLoaded) {
      try {
        final currentState = state as TodosLoaded;
        final allTodos = await TodoService.toggleTodo(event.todoId);
        final stats = TodoService.getStats(allTodos);

        var filteredTodos = _applyFiltersAndSort(
          allTodos,
          currentState.currentFilter,
          currentState.currentSort,
          currentState.sortAscending,
          currentState.searchQuery,
        );

        emit(
          currentState.copyWith(
            allTodos: allTodos,
            filteredTodos: filteredTodos,
            stats: stats,
          ),
        );
      } catch (e) {
        emit(TodosError('Failed to toggle todo: $e'));
      }
    }
  }

  Future<void> _onDeleteTodo(DeleteTodo event, Emitter<TodosState> emit) async {
    if (state is TodosLoaded) {
      try {
        final currentState = state as TodosLoaded;

        // Find the todo to delete for undo functionality
        final todoToDelete = currentState.allTodos.firstWhere(
          (todo) => todo.id == event.todoId,
        );

        final allTodos = await TodoService.deleteTodo(event.todoId);
        final stats = TodoService.getStats(allTodos);

        var filteredTodos = _applyFiltersAndSort(
          allTodos,
          currentState.currentFilter,
          currentState.currentSort,
          currentState.sortAscending,
          currentState.searchQuery,
        );

        emit(
          currentState.copyWith(
            allTodos: allTodos,
            filteredTodos: filteredTodos,
            stats: stats,
            lastDeletedTodo: todoToDelete,
          ),
        );
      } catch (e) {
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

  Future<void> _onUndoDeleteTodo(
    UndoDeleteTodo event,
    Emitter<TodosState> emit,
  ) async {
    if (state is TodosLoaded) {
      try {
        final currentState = state as TodosLoaded;
        final allTodos = await TodoService.addTodo(event.todo);
        final stats = TodoService.getStats(allTodos);

        var filteredTodos = _applyFiltersAndSort(
          allTodos,
          currentState.currentFilter,
          currentState.currentSort,
          currentState.sortAscending,
          currentState.searchQuery,
        );

        emit(
          currentState.copyWith(
            allTodos: allTodos,
            filteredTodos: filteredTodos,
            stats: stats,
            clearLastDeleted: true,
          ),
        );
      } catch (e) {
        emit(TodosError('Failed to restore todo: $e'));
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
    var filtered = TodoService.filterTodos(todos, filter);

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
    return TodoService.sortTodos(filtered, sortOption, ascending);
  }
}
