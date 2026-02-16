import 'package:get_it/get_it.dart';
import 'package:mynotes/presentation/bloc/media/media_gallery/media_gallery_bloc.dart';
import 'package:mynotes/presentation/bloc/media/media_picker/media_picker_bloc.dart';
import 'package:mynotes/presentation/bloc/navigation/navigation_bloc.dart';
import 'package:mynotes/presentation/bloc/drawing_canvas/drawing_canvas_bloc.dart';
import 'package:mynotes/presentation/bloc/search/search_bloc.dart'
    show SearchBloc;
import 'package:mynotes/presentation/bloc/search/search_bloc.dart';
import 'package:sqflite/sqflite.dart';

import 'package:mynotes/data/datasources/local/media_local_datasource.dart';
import 'package:mynotes/data/datasources/local/media_local_datasource_impl.dart';
import 'package:mynotes/data/datasources/local/smart_collection_local_datasource.dart';
import 'package:mynotes/data/datasources/local/smart_collection_local_datasource_impl.dart';
import 'package:mynotes/data/datasources/local/smart_reminder_local_datasource.dart';
import 'package:mynotes/data/datasources/local/smart_reminder_local_datasource_impl.dart';
import 'package:mynotes/data/datasources/local/reminder_template_local_datasource.dart';
import 'package:mynotes/data/datasources/local/reminder_template_local_datasource_impl.dart';
import 'package:mynotes/core/services/link_parser_service.dart';
import 'package:mynotes/core/services/biometric_auth_service.dart';
import 'package:mynotes/core/services/location_service.dart';
import 'package:mynotes/core/services/speech_service.dart';
import 'package:mynotes/core/services/voice_command_service.dart';
import 'package:mynotes/core/services/audio_recorder_service.dart';
import 'package:mynotes/core/services/ocr_service.dart';
import 'package:mynotes/core/services/clipboard_service.dart';
import 'package:mynotes/core/services/backup_service.dart';
import 'package:mynotes/core/services/export_service.dart';
import 'package:mynotes/core/services/app_logger.dart';
import 'package:mynotes/core/services/media_processing_service.dart';
import 'package:mynotes/core/services/calendar_service.dart';
import 'package:mynotes/core/services/in_app_review_service.dart';

import 'package:mynotes/domain/repositories/media_repository.dart';
import 'package:mynotes/domain/repositories/smart_collection_repository.dart';
import 'package:mynotes/domain/repositories/smart_reminder_repository.dart';
import 'package:mynotes/domain/repositories/reminder_template_repository.dart';
import 'package:mynotes/data/repositories/media_repository_impl_v2.dart';
import 'package:mynotes/data/repositories/smart_collection_repository_impl.dart';
import 'package:mynotes/data/repositories/smart_reminder_repository_impl.dart';
import 'package:mynotes/data/repositories/reminder_template_repository_impl.dart';
import 'package:mynotes/presentation/bloc/media_viewer/media_viewer_bloc.dart';
import 'package:mynotes/presentation/bloc/smart_collections/smart_collections_bloc.dart';
import 'package:mynotes/presentation/bloc/smart_reminders/smart_reminders_bloc.dart';
import 'package:mynotes/presentation/bloc/unified_items/unified_items_bloc.dart';
import 'package:mynotes/presentation/bloc/reminder_templates/reminder_templates_bloc.dart';
import 'package:mynotes/presentation/bloc/advanced_search/advanced_search_bloc.dart';
import 'package:mynotes/presentation/bloc/biometric_auth/biometric_auth_bloc.dart';
import 'package:mynotes/presentation/bloc/calendar_integration/calendar_integration_bloc.dart';
import 'package:mynotes/presentation/bloc/smart_collection_wizard/smart_collection_wizard_bloc.dart';
import 'package:mynotes/presentation/bloc/rule_builder/rule_builder_bloc.dart';
import 'package:mynotes/presentation/bloc/graph/graph_bloc.dart';
import 'package:mynotes/presentation/bloc/pdf_annotation/pdf_annotation_bloc.dart';
import 'package:mynotes/domain/repositories/note_repository.dart';
import 'package:mynotes/domain/repositories/reflection_repository.dart';
import 'package:mynotes/domain/repositories/stats_repository.dart';
import 'package:mynotes/domain/services/ai_suggestion_engine.dart';
import 'package:mynotes/domain/services/rule_evaluation_engine.dart';
import 'package:mynotes/domain/repositories/todo_repository.dart';
import 'package:mynotes/domain/repositories/alarm_repository.dart';
import 'package:mynotes/data/repositories/note_repository_impl.dart';
import 'package:mynotes/data/repositories/reflection_repository_impl.dart';
import 'package:mynotes/data/repositories/stats_repository_impl.dart';
import 'package:mynotes/data/repositories/todo_repository_impl.dart';
import 'package:mynotes/data/repositories/alarm_repository_impl.dart';
import 'package:mynotes/core/database/core_database.dart';
import 'package:mynotes/core/services/global_ui_service.dart';
import 'package:mynotes/core/services/connectivity_service.dart';

/// GetIt service locator instance
import 'package:mynotes/presentation/bloc/alarm/alarm_bloc.dart';
import 'package:mynotes/presentation/bloc/note/note_bloc.dart';
import 'package:mynotes/presentation/bloc/media/media_bloc.dart';
import 'package:mynotes/presentation/bloc/todo/todo_bloc.dart';
import 'package:mynotes/presentation/bloc/todos/todos_bloc.dart';
import 'package:mynotes/presentation/bloc/analytics/analytics_bloc.dart';
import 'package:mynotes/presentation/bloc/reflection/reflection_bloc.dart';
import 'package:mynotes/presentation/bloc/focus/focus_bloc.dart';
import 'package:mynotes/presentation/bloc/theme/theme_bloc.dart';
import 'package:mynotes/presentation/bloc/audio_recorder/audio_recorder_bloc.dart';
import 'package:mynotes/presentation/bloc/location_reminder/location_reminder_bloc.dart';
import 'package:mynotes/data/repositories/location_reminder_repository.dart';
import 'package:mynotes/presentation/bloc/settings/settings_bloc.dart';
import 'package:mynotes/presentation/bloc/accessibility_features/accessibility_features_bloc.dart';

import 'package:mynotes/core/notifications/notification_service.dart';
import 'package:mynotes/core/notifications/alarm_service.dart';

final getIt = GetIt.instance;

/// Initialize all dependencies for dependency injection
Future<void> setupServiceLocator() async {
  AppLogger.i('Initializing Service Locator...');
  // ==================== Global Services ====================
  AppLogger.i('Registering GlobalUiService...');
  getIt.registerSingleton<GlobalUiService>(GlobalUiService());

  // ==================== Notifications ====================
  AppLogger.i('Registering AlarmService...');
  final alarmService = AlarmService();
  await alarmService.init();
  getIt.registerSingleton<AlarmService>(alarmService);
  AppLogger.i('✅ AlarmService registered for background alarms');

  AppLogger.i('Registering NotificationService with AlarmService...');
  final notificationService = LocalNotificationService();
  await notificationService.init(alarmService: alarmService);
  getIt.registerSingleton<NotificationService>(notificationService);
  AppLogger.i('✅ NotificationService registered with AlarmService integration');

  AppLogger.i('Registering ConnectivityService...');
  final connectivityService = ConnectivityService();
  connectivityService.initialize();
  getIt.registerSingleton<ConnectivityService>(connectivityService);

  // ==================== Database ====================
  AppLogger.i('Registering Database...');
  final coreDatabase = CoreDatabase();
  getIt.registerSingleton<CoreDatabase>(coreDatabase);

  final database = await coreDatabase.database;
  getIt.registerSingleton<Database>(database);

  // ==================== LocalDataSources ====================

  /// Media LocalDataSource
  getIt.registerSingleton<MediaLocalDataSource>(
    MediaLocalDataSourceImpl(database: getIt<Database>()),
  );

  /// Smart Collection LocalDataSource
  getIt.registerSingleton<SmartCollectionLocalDataSource>(
    SmartCollectionLocalDataSourceImpl(database: getIt<Database>()),
  );

  /// Smart Reminder LocalDataSource
  getIt.registerSingleton<SmartReminderLocalDataSource>(
    SmartReminderLocalDataSourceImpl(database: getIt<Database>()),
  );

  /// Reminder Template LocalDataSource
  getIt.registerSingleton<ReminderTemplateLocalDataSource>(
    ReminderTemplateLocalDataSourceImpl(database: getIt<Database>()),
  );

  /// Link Parser Service
  getIt.registerSingleton<LinkParserService>(LinkParserService());

  /// Biometric Auth Service
  getIt.registerSingleton<BiometricAuthService>(BiometricAuthService());

  /// Location Service
  getIt.registerSingleton<LocationService>(LocationService.instance);

  /// Speech Service
  getIt.registerSingleton<SpeechService>(SpeechService());

  /// Voice Command Service
  getIt.registerSingleton<VoiceCommandService>(VoiceCommandService());

  /// Audio Recorder Service
  getIt.registerSingleton<AudioRecorderService>(AudioRecorderService());

  /// OCR Service
  getIt.registerSingleton<OCRService>(OCRService());

  /// Clipboard Service
  getIt.registerSingleton<ClipboardService>(ClipboardService());

  /// Backup Service
  getIt.registerSingleton<BackupService>(BackupService());

  /// Export Service
  getIt.registerSingleton<ExportService>(ExportService());

  /// Media Processing Service
  getIt.registerSingleton<MediaProcessingService>(MediaProcessingService());

  /// Calendar Service
  getIt.registerSingleton<CalendarService>(CalendarService());

  /// In-App Review Service
  getIt.registerSingleton<InAppReviewService>(InAppReviewService());

  /// App Logger
  getIt.registerSingleton<AppLogger>(AppLogger());

  // ==================== Repositories ====================

  /// Media Repository
  getIt.registerSingleton<MediaRepository>(
    MediaRepositoryImpl(localDataSource: getIt<MediaLocalDataSource>()),
  );

  /// Smart Collection Repository
  getIt.registerSingleton<SmartCollectionRepository>(
    SmartCollectionRepositoryImpl(
      localDataSource: getIt<SmartCollectionLocalDataSource>(),
    ),
  );

  /// Smart Reminder Repository
  getIt.registerSingleton<SmartReminderRepository>(
    SmartReminderRepositoryImpl(
      localDataSource: getIt<SmartReminderLocalDataSource>(),
    ),
  );

  /// Reminder Template Repository
  getIt.registerSingleton<ReminderTemplateRepository>(
    ReminderTemplateRepositoryImpl(
      localDataSource: getIt<ReminderTemplateLocalDataSource>(),
    ),
  );

  /// Note Repository
  getIt.registerSingleton<NoteRepository>(
    NoteRepositoryImpl(database: getIt<CoreDatabase>()),
  );

  /// Todo Repository
  getIt.registerSingleton<TodoRepository>(
    TodoRepositoryImpl(database: getIt<CoreDatabase>()),
  );

  /// Alarm Repository
  getIt.registerSingleton<AlarmRepository>(
    AlarmRepositoryImpl(database: getIt<CoreDatabase>()),
  );

  /// Reflection Repository
  getIt.registerSingleton<ReflectionRepository>(
    ReflectionRepositoryImpl(getIt<CoreDatabase>()),
  );

  /// Stats Repository
  getIt.registerSingleton<StatsRepository>(StatsRepositoryImpl());

  /// Location Reminder Repository
  getIt.registerSingleton<LocationReminderRepository>(
    LocationReminderRepository(),
  );

  // ==================== BLoCs ====================

  /// Theme BLoC
  getIt.registerSingleton<ThemeBloc>(ThemeBloc());

  /// Audio Recorder BLoC
  getIt.registerFactory<AudioRecorderBloc>(() => AudioRecorderBloc());

  /// Media BLoC
  getIt.registerSingleton<MediaBloc>(
    MediaBloc(repository: getIt<MediaRepository>()),
  );

  /// Focus BLoC
  getIt.registerSingleton<FocusBloc>(
    FocusBloc(repository: getIt<StatsRepository>()),
  );

  /// Media Gallery BLoC
  getIt.registerSingleton<MediaGalleryBloc>(
    MediaGalleryBloc(mediaRepository: getIt<MediaRepository>()),
  );

  /// Media Picker BLoC
  getIt.registerFactory<MediaPickerBloc>(() => MediaPickerBloc());

  /// Biometric Auth BLoC
  getIt.registerFactory<BiometricAuthBloc>(
    () => BiometricAuthBloc(authService: getIt<BiometricAuthService>()),
  );

  /// Navigation BLoC
  getIt.registerSingleton<NavigationBloc>(NavigationBloc());

  /// Drawing Canvas BLoC
  getIt.registerFactory<DrawingCanvasBloc>(() => DrawingCanvasBloc());

  /// PDF Annotation BLoC
  getIt.registerFactory<PdfAnnotationBloc>(() => PdfAnnotationBloc());

  /// Media Viewer BLoC
  getIt.registerFactory<MediaViewerBloc>(() => MediaViewerBloc());

  /// Search BLoC
  getIt.registerFactory<SearchBloc>(
    () => SearchBloc(noteRepository: getIt<NoteRepository>()),
  );

  /// Notes BLoC
  getIt.registerSingleton<NotesBloc>(
    NotesBloc(noteRepository: getIt<NoteRepository>()),
  );

  /// Todo BLoC
  getIt.registerSingleton<TodoBloc>(
    TodoBloc(noteRepository: getIt<NoteRepository>()),
  );

  /// Todos BLoC
  getIt.registerSingleton<TodosBloc>(
    TodosBloc(
      todoRepository: getIt<TodoRepository>(),
      alarmRepository: getIt<AlarmRepository>(),
    ),
  );

  /// Analytics BLoC
  getIt.registerSingleton<AnalyticsBloc>(
    AnalyticsBloc(repository: getIt<StatsRepository>()),
  );

  /// Reflection BLoC
  getIt.registerSingleton<ReflectionBloc>(
    ReflectionBloc(
      repository: getIt<ReflectionRepository>(),
      notificationService: getIt<NotificationService>(),
    ),
  );

  /// Smart Collections BLoC
  getIt.registerSingleton<SmartCollectionsBloc>(
    SmartCollectionsBloc(
      smartCollectionRepository: getIt<SmartCollectionRepository>(),
    ),
  );

  /// Smart Reminders BLoC
  getIt.registerSingleton<SmartRemindersBloc>(
    SmartRemindersBloc(
      smartReminderRepository: getIt<SmartReminderRepository>(),
      noteRepository: getIt<NoteRepository>(),
      aiSuggestionEngine: AISuggestionEngine(),
    ),
  );

  /// Unified Items BLoC
  getIt.registerSingleton<UnifiedItemsBloc>(UnifiedItemsBloc());

  /// Graph BLoC
  getIt.registerFactory<GraphBloc>(
    () => GraphBloc(
      noteRepository: getIt<NoteRepository>(),
      todoRepository: getIt<TodoRepository>(),
      alarmRepository: getIt<AlarmRepository>(),
    ),
  );

  /// Reminder Templates BLoC
  getIt.registerSingleton<ReminderTemplatesBloc>(
    ReminderTemplatesBloc(
      reminderTemplateRepository: getIt<ReminderTemplateRepository>(),
    ),
  );

  /// Advanced Search BLoC
  getIt.registerSingleton<AdvancedSearchBloc>(AdvancedSearchBloc());
  getIt.registerSingleton<SmartCollectionWizardBloc>(
    SmartCollectionWizardBloc(),
  );
  getIt.registerSingleton<RuleBuilderBloc>(
    RuleBuilderBloc(ruleEngine: RuleEvaluationEngine()),
  );

  /// Alarms BLoC
  getIt.registerSingleton<AlarmsBloc>(
    AlarmsBloc(
      alarmRepository: getIt<AlarmRepository>(),
      noteRepository: getIt<NoteRepository>(),
      notificationService: getIt<NotificationService>(),
    ),
  );

  /// Calendar Integration BLoC
  getIt.registerSingleton<CalendarIntegrationBloc>(
    CalendarIntegrationBloc(calendarService: getIt<CalendarService>()),
  );

  /// Location Reminder BLoC
  getIt.registerSingleton<LocationReminderBloc>(
    LocationReminderBloc(repository: getIt<LocationReminderRepository>()),
  );

  /// Settings BLoC
  getIt.registerSingleton<SettingsBloc>(SettingsBloc());

  /// Accessibility Features BLoC
  getIt.registerSingleton<AccessibilityFeaturesBloc>(
    AccessibilityFeaturesBloc(),
  );
}

/// Get registered BLoCs
/// Usage: Use in main.dart or MultiRepositoryProvider/MultiBlocProvider

/// Media Gallery BLoC getter
MediaGalleryBloc getMediaGalleryBloc() => getIt<MediaGalleryBloc>();

/// Smart Collections BLoC getter
SmartCollectionsBloc getSmartCollectionsBloc() => getIt<SmartCollectionsBloc>();

/// Smart Reminders BLoC getter
SmartRemindersBloc getSmartRemindersBloc() => getIt<SmartRemindersBloc>();

/// Reminder Templates BLoC getter
ReminderTemplatesBloc getReminderTemplatesBloc() =>
    getIt<ReminderTemplatesBloc>();

/// Advanced Search BLoC getter
AdvancedSearchBloc getAdvancedSearchBloc() => getIt<AdvancedSearchBloc>();

/// Get registered Repositories
/// Usage: Can use these directly if needed

/// Media Repository getter
MediaRepository getMediaRepository() => getIt<MediaRepository>();

/// Smart Collection Repository getter
SmartCollectionRepository getSmartCollectionRepository() =>
    getIt<SmartCollectionRepository>();

/// Smart Reminder Repository getter
SmartReminderRepository getSmartReminderRepository() =>
    getIt<SmartReminderRepository>();

/// Reminder Template Repository getter
ReminderTemplateRepository getReminderTemplateRepository() =>
    getIt<ReminderTemplateRepository>();
