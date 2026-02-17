import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/todo_item.dart';
import '../../../domain/repositories/note_repository.dart';
import 'todo_event.dart';
import 'todo_state.dart';

/// DEPRECATED: This bloc was for note-based todos.
/// Use TodosBloc for standalone todo management instead.
class TodoBloc extends Bloc<TodoEvent, TodoState> {
  TodoBloc({required NoteRepository noteRepository})
      : super(const TodoInitial()) {
    on<LoadTodosEvent>(_onLoadTodos);
    on<AddTodoEvent>(_onAddTodo);
    on<ToggleTodoEvent>(_onToggleTodo);
    on<DeleteTodoEvent>(_onDeleteTodo);
    on<UpdateTodoEvent>(_onUpdateTodo);
  }

  Future<void> _onLoadTodos(
    LoadTodosEvent event,
    Emitter<TodoState> emit,
  ) async {
    try {
      emit(const TodoLoading());
      emit(const TodosLoaded(todos: [], filteredTodos: []));
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      emit(TodoError(errorMsg));
    }
  }

  Future<void> _onAddTodo(AddTodoEvent event, Emitter<TodoState> emit) async {
    try {
      if (state is TodosLoaded) {
        final currentTodos = (state as TodosLoaded).todos;
        final newTodo = event.params.toTodoItem();
        final updatedTodos = List<TodoItem>.from(currentTodos)..add(newTodo);
        emit(TodosLoaded(todos: updatedTodos, filteredTodos: updatedTodos));
      }
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      emit(TodoError(errorMsg));
    }
  }

  Future<void> _onToggleTodo(
    ToggleTodoEvent event,
    Emitter<TodoState> emit,
  ) async {
    try {
      if (state is TodosLoaded) {
        final currentTodos = (state as TodosLoaded).todos;
        final updatedTodos = currentTodos.map((todo) {
          if (todo.id == event.params.todoId) {
            return todo.toggleComplete();
          }
          return todo;
        }).toList();

        emit(TodosLoaded(todos: updatedTodos, filteredTodos: updatedTodos));
      }
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      emit(TodoError(errorMsg));
    }
  }

  Future<void> _onDeleteTodo(
    DeleteTodoEvent event,
    Emitter<TodoState> emit,
  ) async {
    try {
      if (state is TodosLoaded) {
        final currentTodos = (state as TodosLoaded).todos;
        final updatedTodos = currentTodos
            .where((todo) => todo.id != event.todoId)
            .toList();

        emit(TodosLoaded(todos: updatedTodos, filteredTodos: updatedTodos));
      }
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      emit(TodoError(errorMsg));
    }
  }

  Future<void> _onUpdateTodo(
    UpdateTodoEvent event,
    Emitter<TodoState> emit,
  ) async {
    try {
      if (state is TodosLoaded) {
        final currentTodos = (state as TodosLoaded).todos;
        final updatedTodo = event.params.toTodoItem();
        final updatedTodos = currentTodos.map((todo) {
          if (todo.id == event.params.todoId) {
            return updatedTodo;
          }
          return todo;
        }).toList();

        emit(TodosLoaded(todos: updatedTodos, filteredTodos: updatedTodos));
      }
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      emit(TodoError(errorMsg));
    }
  }
}
