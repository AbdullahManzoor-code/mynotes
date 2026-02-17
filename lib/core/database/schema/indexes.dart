import 'package:sqflite/sqflite.dart';

/// All database index creation
class DatabaseIndexes {
  /// Create all indexes for optimal query performance
  static Future<void> createAll(Database db) async {
    // Notes indexes
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_notes_created ON notes(createdAt)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_notes_category ON notes(category)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_notes_archived ON notes(isArchived)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_notes_pinned ON notes(isPinned)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_notes_favorite ON notes(isFavorite)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_notes_color ON notes(color)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_notes_priority ON notes(priority)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_notes_reflection ON notes(linkedReflectionId)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_notes_todo ON notes(linkedTodoId)',
    );

    // Todos indexes
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_todos_noteId ON todos(noteId)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_todos_completed ON todos(isCompleted)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_todos_dueDate ON todos(dueDate)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_todos_category ON todos(category)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_todos_priority ON todos(priority)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_todos_important ON todos(isImportant)',
    );

    // Reminders indexes
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_reminders_active ON reminders(isActive)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_reminders_scheduled ON reminders(scheduledTime)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_reminders_note ON reminders(linkedNoteId)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_reminders_todo ON reminders(linkedTodoId)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_reminders_status ON reminders(status)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_reminders_enabled ON reminders(isEnabled)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_reminders_snoozed ON reminders(snoozedUntil)',
    );

    // Media indexes
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_media_noteId ON media(noteId)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_media_type ON media(type)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_media_created ON media(createdAt)',
    );

    // Reflections indexes
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_reflections_date ON reflections(reflectionDate)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_reflections_question ON reflections(questionId)',
    );

    // Mood entries indexes
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_moods_reflection ON mood_entries(reflectionId)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_moods_recorded ON mood_entries(recordedAt)',
    );

    // Focus sessions indexes
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_focus_completed ON focus_sessions(isCompleted)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_focus_start ON focus_sessions(startTime)',
    );

    // Location reminders indexes
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_loc_reminders_active ON location_reminders(is_active)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_loc_reminders_coords ON location_reminders(latitude, longitude)',
    );

    // Smart collections indexes
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_smart_collections_active ON smart_collections(isActive)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_collection_rules_collId ON collection_rules(collectionId)',
    );

    // Note links indexes
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_note_links_source ON note_links(sourceId)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_note_links_target ON note_links(targetId)',
    );
  }
}
