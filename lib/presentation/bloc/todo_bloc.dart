import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/todo_item.dart';
import '../../domain/repositories/note_repository.dart';
import 'todo_event.dart';
import 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final NoteRepository _noteRepository;

  TodoBloc({required NoteRepository noteRepository})
    : _noteRepository = noteRepository,
      super(const TodoInitial()) {
    on<LoadTodosEvent>(_onLoadTodos);
    on<AddTodoEvent>(_onAddTodo);
    on<ToggleTodoEvent>(_onToggleTodo);
    on<DeleteTodoEvent>(_onDeleteTodo);
    on<ReorderTodosEvent>(_onReorderTodos);
    on<UpdateTodoTextEvent>(_onUpdateTodoText);
  }

  Future<void> _onLoadTodos(
    LoadTodosEvent event,
    Emitter<TodoState> emit,
  ) async {
    try {
      emit(const TodoLoading());
      final note = await _noteRepository.getNoteById(event.noteId);
      if (note != null) {
        emit(TodosLoaded(note.todos ?? [], event.noteId));
      } else {
        emit(const TodoError('Note not found'));
      }
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      emit(TodoError(errorMsg));
    }
  }

  Future<void> _onAddTodo(AddTodoEvent event, Emitter<TodoState> emit) async {
    try {
      if (state is TodosLoaded) {
        final currentTodos = (state as TodosLoaded).todos;
        final newTodo = TodoItem(
          id: const Uuid().v4(),
          text: event.text,
          isCompleted: false,
        );

        final updatedTodos = List<TodoItem>.from(currentTodos)..add(newTodo);

        // Update DB
        final note = await _noteRepository.getNoteById(event.noteId);
        if (note != null) {
          final updatedNote = note.copyWith(todos: updatedTodos);
          await _noteRepository.updateNote(updatedNote);
          emit(TodosLoaded(updatedTodos, event.noteId));
        }
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
          if (todo.id == event.todoId) {
            return todo.toggleComplete();
          }
          return todo;
        }).toList();

        final note = await _noteRepository.getNoteById(event.noteId);
        if (note != null) {
          final updatedNote = note.copyWith(todos: updatedTodos);
          await _noteRepository.updateNote(updatedNote);
          emit(TodosLoaded(updatedTodos, event.noteId));
        }
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

        final note = await _noteRepository.getNoteById(event.noteId);
        if (note != null) {
          final updatedNote = note.copyWith(todos: updatedTodos);
          await _noteRepository.updateNote(updatedNote);
          emit(TodosLoaded(updatedTodos, event.noteId));
        }
      }
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      emit(TodoError(errorMsg));
    }
  }

  Future<void> _onReorderTodos(
    ReorderTodosEvent event,
    Emitter<TodoState> emit,
  ) async {
    try {
      if (state is TodosLoaded) {
        final currentTodos = List<TodoItem>.from((state as TodosLoaded).todos);

        var newIndex = event.newIndex;
        if (newIndex > event.oldIndex) newIndex--;

        final item = currentTodos.removeAt(event.oldIndex);
        currentTodos.insert(newIndex, item);

        final note = await _noteRepository.getNoteById(event.noteId);
        if (note != null) {
          final updatedNote = note.copyWith(todos: currentTodos);
          await _noteRepository.updateNote(updatedNote);
          emit(TodosLoaded(currentTodos, event.noteId));
        }
      }
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      emit(TodoError(errorMsg));
    }
  }

  Future<void> _onUpdateTodoText(
    UpdateTodoTextEvent event,
    Emitter<TodoState> emit,
  ) async {
    try {
      if (state is TodosLoaded) {
        final currentTodos = (state as TodosLoaded).todos;
        final updatedTodos = currentTodos.map((todo) {
          if (todo.id == event.todoId) {
            return todo.copyWith(text: event.newText);
          }
          return todo;
        }).toList();

        final note = await _noteRepository.getNoteById(event.noteId);
        if (note != null) {
          final updatedNote = note.copyWith(todos: updatedTodos);
          await _noteRepository.updateNote(updatedNote);
          emit(TodosLoaded(updatedTodos, event.noteId));
        }
      }
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      emit(TodoError(errorMsg));
    }
  }
}

