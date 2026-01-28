/// Centralized route name constants for the MyNotes application.
class AppRoutes {
  AppRoutes._();

  // ==================== Onboarding & Auth ====================
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';

  // ==================== Main Navigation ====================
  static const String home = '/home';
  static const String todayDashboard = '/today';
  static const String search = '/search';
  static const String settings = '/settings';

  // ==================== Notes Module ====================
  static const String notesList = '/notes';
  static const String noteEditor = '/notes/editor';
  static const String advancedNoteEditor = '/notes/advanced-editor';

  // ==================== Reminders Module ====================
  static const String remindersList = '/reminders';

  // ==================== Todos Module ====================
  static const String todosList = '/todos';
  static const String todoFocus = '/todos/focus';
  static const String advancedTodo = '/todos/advanced';

  // ==================== Reflection Module ====================
  static const String analytics = '/analytics';
  static const String reflectionEditor = '/reflections/editor';

  // ==================== Media & Utility ====================
  static const String mediaViewer = '/media/viewer';
  static const String pdfPreview = '/pdf/preview';
  static const String biometricLock = '/security/lock';
}
