import 'package:mynotes/domain/entities/note.dart';
import 'package:mynotes/domain/entities/todo_item.dart';
import 'package:mynotes/domain/entities/alarm.dart';
import 'package:mynotes/domain/entities/media_item.dart';

/// Test data fixtures for unit tests
class TestFixtures {
  static final now = DateTime(2026, 2, 15, 10, 0);

  // ============================================================================
  // Notes
  // ============================================================================

  static final simpleNote = Note(
    id: 'note_1',
    title: 'Simple Note',
    content: 'This is a simple note',
    createdAt: now,
  );

  static final complexNote = Note(
    id: 'note_2',
    title: 'Complex Note',
    content: 'This is a complex note with multiple sections',
    createdAt: now,
    updatedAt: now.add(const Duration(hours: 1)),
    todos: [testTodo1, testTodo2, testTodo3],
    alarms: [testAlarm1, testAlarm2],
    media: [testMediaImage],
    tags: ['important', 'work'],
    category: 'Meetings',
    isPinned: true,
    isFavorite: true,
  );

  static final pinnedNote = Note(
    id: 'note_3',
    title: 'Pinned Note',
    content: 'This is a pinned note',
    createdAt: now,
    isPinned: true,
  );

  static final favoriteNote = Note(
    id: 'note_4',
    title: 'Favorite Note',
    content: 'This is a favorite note',
    createdAt: now,
    isFavorite: true,
  );

  static final workNote = Note(
    id: 'note_5',
    title: 'Work Project Plan',
    content: 'Q1 2026 project roadmap and milestones',
    createdAt: now,
    category: 'Work',
    tags: ['project', 'q1', 'planning'],
  );

  static final personalNote = Note(
    id: 'note_6',
    title: 'Personal Goals',
    content: 'Health, fitness, and learning goals',
    createdAt: now,
    category: 'Personal',
    tags: ['goals', 'health', '2026'],
  );

  static List<Note> get allNotes => [
    simpleNote,
    complexNote,
    pinnedNote,
    favoriteNote,
    workNote,
    personalNote,
  ];

  // ============================================================================
  // Todos
  // ============================================================================

  static final testTodo1 = TodoItem(
    id: 'todo_1',
    noteId: 'note_2',
    description: 'Design UI mockups',
    isCompleted: false,
    priority: 3,
    createdAt: now,
    category: 'Design',
  );

  static final testTodo2 = TodoItem(
    id: 'todo_2',
    noteId: 'note_2',
    description: 'Implement backend API',
    isCompleted: true,
    priority: 2,
    createdAt: now.add(const Duration(hours: 1)),
    completedAt: now.add(const Duration(hours: 2)),
    category: 'Development',
  );

  static final testTodo3 = TodoItem(
    id: 'todo_3',
    noteId: 'note_2',
    description: 'Write unit tests',
    isCompleted: false,
    priority: 2,
    createdAt: now.add(const Duration(hours: 2)),
    dueDate: now.add(const Duration(days: 3)),
    category: 'Testing',
  );

  static final completedTodo = TodoItem(
    id: 'todo_completed',
    noteId: 'note_5',
    description: 'Completed task',
    isCompleted: true,
    priority: 1,
    createdAt: now,
    completedAt: now.add(const Duration(hours: 3)),
  );

  static final highPriorityTodo = TodoItem(
    id: 'todo_high',
    noteId: 'note_5',
    description: 'Critical bug fix',
    isCompleted: false,
    priority: 5,
    createdAt: now,
  );

  static List<TodoItem> get allTodos => [
    testTodo1,
    testTodo2,
    testTodo3,
    completedTodo,
    highPriorityTodo,
  ];

  // ============================================================================
  // Alarms
  // ============================================================================

  static final testAlarm1 = Alarm(
    id: 'alarm_1',
    noteId: 'note_2',
    scheduledTime: now.add(const Duration(days: 1, hours: 9)),
    recurrence: AlarmRecurrence.daily,
    status: AlarmStatus.scheduled,
    createdAt: now,
    title: 'Morning Standup',
    description: '10:00 AM daily team sync',
  );

  static final testAlarm2 = Alarm(
    id: 'alarm_2',
    noteId: 'note_2',
    scheduledTime: now.add(const Duration(days: 7)),
    recurrence: AlarmRecurrence.weekly,
    status: AlarmStatus.scheduled,
    createdAt: now,
    title: 'Weekly Review',
    description: 'Friday end-of-week review',
  );

  static final singleOccurrenceAlarm = Alarm(
    id: 'alarm_single',
    noteId: 'note_1',
    scheduledTime: now.add(const Duration(hours: 2)),
    recurrence: AlarmRecurrence.none,
    status: AlarmStatus.scheduled,
    createdAt: now,
    title: 'One time reminder',
  );

  static final monthlyAlarm = Alarm(
    id: 'alarm_monthly',
    noteId: 'note_3',
    scheduledTime: DateTime(2026, 3, 15, 14, 0),
    recurrence: AlarmRecurrence.monthly,
    status: AlarmStatus.scheduled,
    createdAt: now,
    title: 'Monthly report',
  );

  static final yearlyAlarm = Alarm(
    id: 'alarm_yearly',
    noteId: 'note_4',
    scheduledTime: DateTime(2027, 2, 15, 8, 0),
    recurrence: AlarmRecurrence.yearly,
    status: AlarmStatus.scheduled,
    createdAt: now,
    title: 'Annual review',
  );

  static List<Alarm> get allAlarms => [
    testAlarm1,
    testAlarm2,
    singleOccurrenceAlarm,
    monthlyAlarm,
    yearlyAlarm,
  ];

  // ============================================================================
  // Media
  // ============================================================================

  static final testMediaImage = MediaItem(
    id: 'media_image_1',
    noteId: 'note_2',
    filePath: '/storage/emulated/0/Pictures/screenshot_001.jpg',
    type: MediaType.image,
    size: 2048576,
    width: 1920,
    height: 1080,
    createdAt: now,
  );

  static final testMediaVideo = MediaItem(
    id: 'media_video_1',
    noteId: 'note_2',
    filePath: '/storage/emulated/0/Movies/demo_001.mp4',
    type: MediaType.video,
    size: 104857600,
    duration: 300,
    createdAt: now,
  );

  static final testMediaAudio = MediaItem(
    id: 'media_audio_1',
    noteId: 'note_2',
    filePath: '/storage/emulated/0/Recordings/voice_memo_001.m4a',
    type: MediaType.audio,
    size: 5242880,
    duration: 120,
    createdAt: now,
  );

  static final testMediaDocument = MediaItem(
    id: 'media_doc_1',
    noteId: 'note_5',
    filePath: '/storage/emulated/0/Documents/roadmap.pdf',
    type: MediaType.document,
    size: 1048576,
    createdAt: now,
  );

  static List<MediaItem> get allMedia => [
    testMediaImage,
    testMediaVideo,
    testMediaAudio,
    testMediaDocument,
  ];

  // ============================================================================
  // Bulk Test Data
  // ============================================================================

  /// Generate N notes with random data
  static List<Note> generateNotes(int count) {
    return List.generate(
      count,
      (index) => Note(
        id: 'note_gen_$index',
        title: 'Generated Note $index',
        content:
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. $index',
        createdAt: now.add(Duration(hours: index)),
        isPinned: index % 5 == 0,
        isFavorite: index % 3 == 0,
        category: ['Work', 'Personal', 'Ideas', 'Learning'][index % 4],
        tags: ['tag${index % 2}', 'tag${index % 3}', 'tag${index % 5}'],
      ),
    );
  }

  /// Generate N todos
  static List<TodoItem> generateTodos(String noteId, int count) {
    return List.generate(
      count,
      (index) => TodoItem(
        id: 'todo_gen_${noteId}_$index',
        noteId: noteId,
        description: 'Generated Todo $index',
        isCompleted: index % 3 == 0,
        priority: (index % 5) + 1,
        createdAt: now.add(Duration(minutes: index)),
        category: ['Work', 'Personal', 'Shopping'][index % 3],
      ),
    );
  }

  /// Generate N alarms with different recurrence patterns
  static List<Alarm> generateAlarms(String noteId, int count) {
    final recurrences = [
      AlarmRecurrence.none,
      AlarmRecurrence.daily,
      AlarmRecurrence.weekly,
      AlarmRecurrence.monthly,
      AlarmRecurrence.yearly,
    ];

    return List.generate(
      count,
      (index) => Alarm(
        id: 'alarm_gen_${noteId}_$index',
        noteId: noteId,
        scheduledTime: now.add(Duration(days: index, hours: 9)),
        recurrence: recurrences[index % recurrences.length],
        status: index % 2 == 0 ? AlarmStatus.scheduled : AlarmStatus.snoozed,
        createdAt: now.add(Duration(hours: index)),
        title: 'Generated Alarm $index',
      ),
    );
  }

  /// Complete note with all related data
  static Note completeNoteWithData(
    int todoCount,
    int alarmCount,
    int mediaCount,
  ) {
    final noteId = 'complete_note_${DateTime.now().millisecondsSinceEpoch}';

    return Note(
      id: noteId,
      title: 'Complete Note with All Data',
      content: 'This note contains todos, alarms, and media',
      createdAt: now,
      todos: generateTodos(noteId, todoCount),
      alarms: generateAlarms(noteId, alarmCount),
      media: List.generate(
        mediaCount,
        (index) => MediaItem(
          id: 'media_${noteId}_$index',
          noteId: noteId,
          filePath: '/path/to/media_$index.jpg',
          type: MediaType.image,
          createdAt: now,
        ),
      ),
      tags: ['test', 'complete', 'fixture'],
      category: 'Testing',
      isPinned: true,
    );
  }
}
