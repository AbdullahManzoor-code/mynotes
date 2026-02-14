import 'package:rxdart/rxdart.dart';
import '../../injection_container.dart' show getIt;
import '../../domain/repositories/note_repository.dart';
import '../../domain/repositories/todo_repository.dart';
import '../../domain/repositories/alarm_repository.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/todo_item.dart';
import '../../domain/entities/alarm.dart';
import '../../domain/entities/universal_item.dart';

/// Unified Repository Facade
/// Centralizes access to Notes, Todos, and Alarms
class UnifiedRepository {
  UnifiedRepository._();
  static final UnifiedRepository instance = UnifiedRepository._();

  final _remindersSubject = BehaviorSubject<List<UniversalItem>>.seeded([]);
  Stream<List<UniversalItem>> get remindersStream => _remindersSubject.stream;

  Future<void> initialize() async {
    // Repositories are already initialized via GetIt
    await refreshReminders();
  }

  Future<void> refreshReminders() async {
    final reminders = await searchItems('', types: ['Reminder', 'Todo']);
    _remindersSubject.add(
      reminders.where((item) => item.reminderTime != null).toList(),
    );
  }

  Future<void> createItem(UniversalItem item) async {
    if (item.isTodo) {
      final todo = TodoItem(
        id: item.id,
        text: item.title,
        isCompleted: item.isCompleted,
        createdAt: item.createdAt,
        noteId: '',
        updatedAt: DateTime.now(), // Default or extract if needed
      );
      await getIt<TodoRepository>().createTodo(todo);

      if (item.isReminder && item.reminderTime != null) {
        final alarm = Alarm(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          message: item.title,
          scheduledTime: item.reminderTime!,
          isActive: true,
          isEnabled: true,
          linkedTodoId: item.id,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await getIt<AlarmRepository>().createAlarm(alarm);
      }
    } else if (item.isReminder && item.reminderTime != null) {
      final alarm = Alarm(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        message: item.title,
        scheduledTime: item.reminderTime!,
        isActive: true,
        isEnabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await getIt<AlarmRepository>().createAlarm(alarm);
    } else {
      final note = Note(
        id: item.id,
        title: item.title,
        content: item.content,
        createdAt: item.createdAt,
        updatedAt: item.updatedAt,
      );
      await getIt<NoteRepository>().createNote(note);
    }
    await refreshReminders();
  }

  Future<void> updateItem(UniversalItem item) async {
    if (item.isTodo) {
      final todo = TodoItem(
        id: item.id,
        text: item.title,
        isCompleted: item.isCompleted,
        createdAt: item.createdAt,
        updatedAt: DateTime.now(),
        noteId: '',
      );
      await getIt<TodoRepository>().updateTodo(todo);

      if (item.reminderTime != null) {
        // Find existing alarm or create new
        final alarms = await getIt<AlarmRepository>().getAlarms();
        final existingAlarm = alarms.firstWhere(
          (a) => a.linkedTodoId == item.id,
          orElse: () => Alarm(
            id: '',
            message: '',
            scheduledTime: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        if (existingAlarm.id.isNotEmpty) {
          await getIt<AlarmRepository>().updateAlarm(
            existingAlarm.copyWith(
              scheduledTime: item.reminderTime!,
              message: item.title,
              updatedAt: DateTime.now(),
            ),
          );
        } else {
          await getIt<AlarmRepository>().createAlarm(
            Alarm(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              message: item.title,
              scheduledTime: item.reminderTime!,
              isActive: true,
              isEnabled: true,
              linkedTodoId: item.id,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
        }
      }
    } else if (item.isReminder) {
      final alarm = Alarm(
        id: item.id,
        message: item.title,
        scheduledTime: item.reminderTime!,
        isActive: true,
        isEnabled: true,
        createdAt: item.createdAt,
        updatedAt: DateTime.now(),
      );
      await getIt<AlarmRepository>().updateAlarm(alarm);
    } else {
      final note = Note(
        id: item.id,
        title: item.title,
        content: item.content,
        createdAt: item.createdAt,
        updatedAt: item.updatedAt,
        isPinned: false,
        isArchived: false,
        tags: [],
        color: NoteColor.defaultColor,
      );
      await getIt<NoteRepository>().updateNote(note);
    }
    await refreshReminders();
  }

  Future<void> toggleTodoCompletion(String todoId) async {
    await getIt<TodoRepository>().toggleTodo(todoId);
    await refreshReminders();
  }

  Future<List<UniversalItem>> searchItems(
    String query, {
    List<String>? types,
    DateTime? startDate,
    DateTime? endDate,
    String? category,
    String? sortBy,
    bool sortDescending = true,
  }) async {
    final List<UniversalItem> results = [];

    // 1. Search Notes
    if (types == null || types.isEmpty || types.contains('Note')) {
      final notes = await getIt<NoteRepository>().searchNotes(query);
      results.addAll(notes.map((n) => UniversalItem.fromNote(n)));
    }

    // 2. Search Todos
    if (types == null || types.isEmpty || types.contains('Todo')) {
      final todos = await getIt<TodoRepository>().searchTodos(query);
      results.addAll(
        todos.map(
          (t) => UniversalItem.todo(
            id: t.id,
            title: t.text,
            isCompleted: t.isCompleted,
            createdAt: t.createdAt,
          ),
        ),
      );
    }

    // 3. Search Alarms/Reminders
    if (types == null || types.isEmpty || types.contains('Reminder')) {
      final alarms = await getIt<AlarmRepository>().searchAlarms(query);
      results.addAll(
        alarms.map(
          (a) => UniversalItem.reminder(
            id: a.id,
            title: a.message,
            reminderTime: a.scheduledTime,
          ),
        ),
      );
    }

    // Filter by date if provided
    var filteredResults = results;
    if (startDate != null) {
      filteredResults = filteredResults
          .where((item) => item.createdAt.isAfter(startDate))
          .toList();
    }
    if (endDate != null) {
      filteredResults = filteredResults
          .where((item) => item.createdAt.isBefore(endDate))
          .toList();
    }

    // Sort
    if (sortBy == 'date') {
      filteredResults.sort(
        (a, b) => sortDescending
            ? b.createdAt.compareTo(a.createdAt)
            : a.createdAt.compareTo(b.createdAt),
      );
    } else if (sortBy == 'alphabetical') {
      filteredResults.sort(
        (a, b) => sortDescending
            ? b.title.compareTo(a.title)
            : a.title.compareTo(b.title),
      );
    }

    return filteredResults;
  }
}
