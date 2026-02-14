/// Complete Param Models
/// 📦 Centralized data containers for BLoC operations
/// Each params class encapsulates all related data for a feature
///
/// Usage Pattern:
/// Instead of: bloc.add(CreateNoteEvent(title, content, color, tags, isPinned))
/// Use:        bloc.add(CreateNoteEvent(params: noteParams))
///
/// Benefits:
/// - Single object instead of multiple parameters
/// - Easy to add new fields without changing function signatures
/// - Built-in copyWith() for immutable updates
/// - Clean and scannable BLoC interfaces
/// - Better testability and mocking
library;

// Core Features
export 'note_params.dart';
export 'todo_params.dart';
export 'reminder_params.dart';
export 'alarm_params.dart';

// Settings & Configuration
export 'settings_params.dart';
export 'theme_params.dart';
export 'backup_params.dart';
export 'analytics_event_params.dart';

// Productivity & Organization
export 'pomodoro_session_params.dart';
export 'smart_collection_params.dart';

// Media & Content
export 'media_params.dart';
export 'drawing_params.dart';
export 'ocr_params.dart';

// Advanced Features
export 'voice_command_params.dart';
export 'calendar_event_params.dart';
export 'note_link_params.dart';
