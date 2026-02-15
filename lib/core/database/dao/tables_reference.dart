/// Centralized reference to all table names for DAOs
/// This ensures consistency across the database layer
class TablesReference {
  static const String notesTable = 'notes';
  static const String todosTable = 'todos';
  static const String remindersTable = 'reminders';
  static const String mediaTable = 'media';
  static const String reflectionsTable = 'reflections';
  static const String reflectionAnswersTable = 'reflection_answers';
  static const String reflectionDraftsTable = 'reflection_drafts';
  static const String reflectionQuestionsTable = 'reflection_questions';
  static const String activityTagsTable = 'activity_tags';
  static const String moodEntriesTable = 'mood_entries';
  static const String userSettingsTable = 'user_settings';
  static const String locationRemindersTable = 'location_reminders';
  static const String savedLocationsTable = 'saved_locations';
  static const String focusSessionsTable = 'focus_sessions';
  static const String smartCollectionsTable = 'smart_collections';
  static const String collectionRulesTable = 'collection_rules';
  static const String reminderTemplatesTable = 'reminder_templates';
  static const String noteLinksTable = 'note_links';
  static const String notesFtsTable = 'notes_fts';
}
