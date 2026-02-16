import 'package:sqflite/sqflite.dart';
import '../dao/tables_reference.dart';

/// Database seed data for testing and development
class DatabaseSeed {
  /// Insert dummy data for testing
  static Future<void> insertTestData(Database db) async {
    final now = DateTime.now();
    final isoNow = now.toIso8601String();

    // 1. Insert Notes
    final notes = [
      {
        'id': 'note_1',
        'title': 'Welcome to MyNotes',
        'content': 'This is a sample note to get you started.',
        'color': 0,
        'category': 'Personal',
        'isPinned': 1,
        'isArchived': 0,
        'isFavorite': 1,
        'tags': 'Welcome,Sample',
        'priority': 2,
        'linkedReflectionId': null,
        'linkedTodoId': null,
        'createdAt': isoNow,
        'updatedAt': isoNow,
      },
      {
        'id': 'note_2',
        'title': 'Work Project',
        'content': 'Details about the current work project.',
        'color': 1,
        'category': 'Work',
        'isPinned': 0,
        'isArchived': 0,
        'isFavorite': 0,
        'tags': 'Work,Project',
        'priority': 3,
        'linkedReflectionId': null,
        'linkedTodoId': null,
        'createdAt': now.subtract(const Duration(days: 1)).toIso8601String(),
        'updatedAt': now.subtract(const Duration(days: 1)).toIso8601String(),
      },
      {
        'id': 'note_3',
        'title': 'Shopping List',
        'content': 'Milk, Eggs, Bread, Vegetables',
        'color': 2,
        'category': 'Personal',
        'isPinned': 0,
        'isArchived': 0,
        'isFavorite': 0,
        'tags': 'Shopping,Household',
        'priority': 1,
        'linkedReflectionId': null,
        'linkedTodoId': null,
        'createdAt': now.subtract(const Duration(days: 2)).toIso8601String(),
        'updatedAt': now.subtract(const Duration(days: 2)).toIso8601String(),
      },
      {
        'id': 'note_4',
        'title': 'App Ideas',
        'content': 'Ideas for improving the app UI and features.',
        'color': 3,
        'category': 'Ideas',
        'isPinned': 1,
        'isArchived': 0,
        'isFavorite': 1,
        'tags': 'App,Ideas,Development',
        'priority': 2,
        'linkedReflectionId': null,
        'linkedTodoId': null,
        'createdAt': now.subtract(const Duration(days: 3)).toIso8601String(),
        'updatedAt': now.subtract(const Duration(days: 3)).toIso8601String(),
      },
    ];

    for (var note in notes) {
      await db.insert(TablesReference.notesTable, note);
    }

    // 2. Insert Activity Tags
    final tags = [
      {
        'id': 'tag_1',
        'tagName': 'Work',
        'colorHex': '#FF6B6B',
        'frequency': 0,
        'createdAt': isoNow,
      },
      {
        'id': 'tag_2',
        'tagName': 'Health',
        'colorHex': '#4ECDC4',
        'frequency': 0,
        'createdAt': isoNow,
      },
      {
        'id': 'tag_3',
        'tagName': 'Learning',
        'colorHex': '#FFE66D',
        'frequency': 0,
        'createdAt': isoNow,
      },
      {
        'id': 'tag_4',
        'tagName': 'Coding',
        'colorHex': '#95E1D3',
        'frequency': 0,
        'createdAt': isoNow,
      },
    ];

    for (var tag in tags) {
      await db.insert(TablesReference.activityTagsTable, tag);
    }

    // 3. Reflection Questions - Loaded from ReflectionDatabase at runtime by the app
    // No seeding needed - built-in questions are provided by ReflectionDatabase class
    // Users answer these questions and answers are saved to the database

    // 4. Insert Todos
    final todos = [
      {
        'id': 'todo_1',
        'noteId': 'note_1',
        'title': 'Set up profile',
        'description': 'Complete your user profile.',
        'category': 'Personal',
        'priority': 1,
        'isCompleted': 0,
        'isImportant': 1,
        'hasReminder': 0,
        'reminderId': null,
        'dueDate': now.add(const Duration(days: 3)).toIso8601String(),
        'completedAt': null,
        'subtasksJson': '[]',
        'attachmentsJson': '[]',
        'createdAt': isoNow,
        'updatedAt': isoNow,
      },
      {
        'id': 'todo_2',
        'noteId': null,
        'title': 'Review documentation',
        'description': null,
        'category': 'Work',
        'priority': 2,
        'isCompleted': 0,
        'isImportant': 0,
        'hasReminder': 0,
        'reminderId': null,
        'dueDate': now.add(const Duration(days: 2)).toIso8601String(),
        'completedAt': null,
        'subtasksJson': '[]',
        'attachmentsJson': '[]',
        'createdAt': isoNow,
        'updatedAt': isoNow,
      },
      {
        'id': 'todo_3',
        'noteId': null,
        'title': 'Explore features',
        'description': 'Take a tour of all app features.',
        'category': 'Personal',
        'priority': 1,
        'isCompleted': 1,
        'isImportant': 0,
        'hasReminder': 0,
        'reminderId': null,
        'dueDate': now.subtract(const Duration(days: 1)).toIso8601String(),
        'completedAt': now.subtract(const Duration(hours: 2)).toIso8601String(),
        'subtasksJson': '[]',
        'attachmentsJson': '[]',
        'createdAt': now.subtract(const Duration(days: 2)).toIso8601String(),
        'updatedAt': now.subtract(const Duration(hours: 2)).toIso8601String(),
      },
    ];

    for (var todo in todos) {
      await db.insert(TablesReference.todosTable, todo);
    }

    // 5. Insert Reminders
    final reminders = [
      {
        'id': 'rem_1',
        'title': 'Evening Review',
        'message': 'Take 10 minutes to reflect on your day.',
        'scheduledTime': now.add(const Duration(hours: 8)).toIso8601String(),
        'recurrence': 'daily',
        'snoozeCount': 0,
        'isActive': 1,
        'hasVibration': 1,
        'hasSound': 1,
        'label': 'Wellness',
        'linkedNoteId': null,
        'createdAt': isoNow,
        'updatedAt': isoNow,
      },
      {
        'id': 'rem_2',
        'title': 'Hydrate',
        'message': 'Time to drink some water.',
        'scheduledTime': now.add(const Duration(hours: 1)).toIso8601String(),
        'recurrence': '2h',
        'snoozeCount': 0,
        'isActive': 1,
        'hasVibration': 1,
        'hasSound': 0,
        'label': 'Health',
        'linkedNoteId': null,
        'createdAt': isoNow,
        'updatedAt': isoNow,
      },
      {
        'id': 'rem_3',
        'title': 'Daily Standup',
        'message': 'Prep your notes for the standup meeting.',
        'scheduledTime': now.add(const Duration(days: 1)).toIso8601String(),
        'recurrence': 'daily',
        'snoozeCount': 0,
        'isActive': 1,
        'hasVibration': 1,
        'hasSound': 1,
        'label': 'Work',
        'linkedNoteId': null,
        'createdAt': isoNow,
        'updatedAt': isoNow,
      },
    ];

    for (var reminder in reminders) {
      await db.insert(TablesReference.remindersTable, reminder);
    }

    // 6. Insert Reflections & Moods
    final reflectionId = 'ref_1';
    await db.insert(TablesReference.reflectionsTable, {
      'id': reflectionId,
      'questionId': 'q_1',
      'answerText':
          'I am grateful for the progress I made on MyNotes and for my supportive colleagues.',
      'mood': 'Happy',
      'moodValue': 5,
      'energyLevel': 4,
      'sleepQuality': 3,
      'activityTags': 'Work,Coding',
      'isPrivate': 0,
      'linkedNoteId': null,
      'linkedTodoId': null,
      'draft': null,
      'isDeleted': 0,
      'reflectionDate': isoNow.split('T')[0],
      'createdAt': isoNow,
      'updatedAt': isoNow,
    });

    await db.insert(TablesReference.moodEntriesTable, {
      'id': 'mood_1',
      'reflectionId': reflectionId,
      'mood': 'Happy',
      'moodValue': 5,
      'recordedAt': isoNow,
    });

    // 7. Insert Focus Sessions
    await db.insert(TablesReference.focusSessionsTable, {
      'id': 'focus_1',
      'startTime': now.subtract(const Duration(hours: 2)).toIso8601String(),
      'endTime': now
          .subtract(const Duration(hours: 1, minutes: 35))
          .toIso8601String(),
      'durationSeconds': 1500, // 25 min
      'taskTitle': 'Work on Editor UI',
      'category': 'Coding',
      'isCompleted': 1,
      'rating': 5,
      'createdAt': isoNow,
      'updatedAt': isoNow,
    });

    // 8. Insert Note Links for Graph View
    await db.insert(TablesReference.noteLinksTable, {
      'sourceId': 'note_1',
      'targetId': 'note_2',
      'type': 'reference',
      'createdAt': isoNow,
    });

    await db.insert(TablesReference.noteLinksTable, {
      'sourceId': 'note_2',
      'targetId': 'note_4',
      'type': 'task',
      'createdAt': isoNow,
    });

    // 9. Insert Smart Collections
    await db.insert(TablesReference.smartCollectionsTable, {
      'id': 'coll_1',
      'name': 'Active Work',
      'description': 'Filters for Work category notes that are not archived.',
      'itemCount': 1,
      'lastUpdated': isoNow,
      'isActive': 1,
      'logic': 'AND',
    });

    await db.insert(TablesReference.collectionRulesTable, {
      'collectionId': 'coll_1',
      'type': 'category',
      'operator': 'equals',
      'value': 'Work',
    });

    // 10. Insert Location Data
    final locations = [
      {
        'id': 'loc_1',
        'name': 'Home',
        'latitude': 40.7128,
        'longitude': -74.0060,
        'address': 'New York, NY',
        'created_at': isoNow,
      },
      {
        'id': 'loc_2',
        'name': 'Work Office',
        'latitude': 34.0522,
        'longitude': -118.2437,
        'address': 'Los Angeles, CA',
        'created_at': isoNow,
      },
    ];
    for (var loc in locations) {
      await db.insert(TablesReference.savedLocationsTable, loc);
    }

    final locationReminders = [
      {
        'id': 'lrem_1',
        'message': 'Buy milk when arriving home',
        'latitude': 40.7128,
        'longitude': -74.0060,
        'radius': 100.0,
        'trigger_type': 'arrive',
        'place_name': 'Home',
        'place_address': 'New York, NY',
        'linked_note_id': 'note_4',
        'is_active': 1,
        'created_at': isoNow,
        'updated_at': isoNow,
      },
      {
        'id': 'lrem_2',
        'message': 'Submit report when leaving work',
        'latitude': 34.0522,
        'longitude': -118.2437,
        'radius': 200.0,
        'trigger_type': 'leave',
        'place_name': 'Work Office',
        'place_address': 'Los Angeles, CA',
        'linked_note_id': null,
        'is_active': 1,
        'created_at': isoNow,
        'updated_at': isoNow,
      },
    ];
    for (var lrem in locationReminders) {
      await db.insert(TablesReference.locationRemindersTable, lrem);
    }
  }

  /// Delete all data (for testing)
  static Future<void> clearAll(Database db) async {
    await db.delete(TablesReference.focusSessionsTable);
    await db.delete(TablesReference.moodEntriesTable);
    await db.delete(TablesReference.reflectionsTable);
    await db.delete(TablesReference.reflectionAnswersTable);
    await db.delete(TablesReference.reflectionDraftsTable);
    await db.delete(TablesReference.reflectionQuestionsTable);
    await db.delete(TablesReference.activityTagsTable);
    await db.delete(TablesReference.userSettingsTable);
    await db.delete(TablesReference.mediaTable);
    await db.delete(TablesReference.remindersTable);
    await db.delete(TablesReference.todosTable);
    await db.delete(TablesReference.noteLinksTable);
    await db.delete(TablesReference.notesFtsTable);
    await db.delete(TablesReference.notesTable);
    await db.delete(TablesReference.locationRemindersTable);
    await db.delete(TablesReference.savedLocationsTable);
    await db.delete(TablesReference.smartCollectionsTable);
    await db.delete(TablesReference.collectionRulesTable);
    await db.delete(TablesReference.reminderTemplatesTable);
  }
}
