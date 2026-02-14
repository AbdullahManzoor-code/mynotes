import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:mynotes/domain/entities/alarm.dart';
import 'package:mynotes/domain/repositories/alarm_repository.dart';
import 'package:mynotes/presentation/bloc/reflection/reflection_event.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'core/routes/app_routes.dart';
import 'core/routes/app_router.dart';
import 'core/notifications/notification_service.dart';
import 'core/services/clipboard_service.dart';
import 'core/constants/app_constants.dart';
import 'core/themes/app_theme.dart';

import 'domain/repositories/note_repository.dart';
import 'domain/repositories/media_repository.dart';
import 'domain/repositories/reflection_repository.dart';
import 'domain/repositories/stats_repository.dart';

import 'data/datasources/local_database.dart';
import 'data/repositories/note_repository_impl.dart';
import 'data/repositories/media_repository_impl.dart';
import 'data/repositories/reflection_repository_impl.dart';
import 'data/repositories/stats_repository_impl.dart';

import 'presentation/bloc/params/note_params.dart';
import 'presentation/bloc/theme/theme_bloc.dart';
import 'presentation/bloc/theme/theme_event.dart';
import 'presentation/bloc/theme/theme_state.dart';
import 'presentation/bloc/note/note_bloc.dart';
import 'presentation/bloc/media/media_bloc.dart';
import 'presentation/bloc/reflection/reflection_bloc.dart';
import 'presentation/bloc/alarm/alarm_bloc.dart';
import 'presentation/bloc/alarm/alarms_bloc.dart';
import 'presentation/bloc/todo/todo_bloc.dart';
import 'presentation/bloc/note/note_event.dart';
import 'presentation/bloc/todos/todos_bloc.dart';
import 'presentation/bloc/analytics/analytics_bloc.dart';
import 'presentation/bloc/smart_collections/smart_collections_bloc.dart';
import 'presentation/bloc/reminder_templates/reminder_templates_bloc.dart';
import 'presentation/bloc/smart_reminders/smart_reminders_bloc.dart';
import 'presentation/bloc/focus/focus_bloc.dart';
import 'presentation/bloc/navigation/navigation_bloc.dart';
import 'presentation/bloc/drawing_canvas/drawing_canvas_bloc.dart';
import 'presentation/bloc/search/search_bloc.dart';
import 'presentation/bloc/audio_recorder/audio_recorder_bloc.dart';
import 'core/notifications/alarm_service.dart' as notifications;
import 'presentation/widgets/global_error_handler_listener.dart';
import 'presentation/widgets/global_overlay.dart';
import 'core/services/global_ui_service.dart';
import 'core/services/app_logger.dart';
import 'injection_container.dart' show getIt, setupServiceLocator;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database factory ONLY for desktop platforms (Windows/Linux/Mac)
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Initialize dependency injection (service locator)
  await setupServiceLocator();

  // Initialize database
  final database = NotesDatabase();

  // Initialize notification service
  final notificationService = LocalNotificationService();
  await notificationService.init();

  // Initialize alarm notification service (for specific alarm handling)
  final alarmNotificationService = notifications.AlarmService();
  await alarmNotificationService.init(
    onActionReceived: (actionId, payload, input) {
      if (actionId == 'quick_reply' && input != null && input.isNotEmpty) {
        // Save quick note/todo from notification
        getIt<NotesBloc>().add(
          CreateNoteEvent(
            params: NoteParams(
              title: 'Quick Note (from notification)',
              content: input,
              tags: ['quick-add'],
            ),
          ),
        );
        return;
      }

      if (payload != null) {
        try {
          final data = jsonDecode(payload);
          final String alarmId = data['id']; // We ensured payload has id

          if (actionId == 'complete') {
            getIt<AlarmsBloc>().add(MarkAlarmCompleted(alarmId));
          } else if (actionId == 'snooze') {
            // Default snooze 10 mins
            getIt<AlarmsBloc>().add(
              SnoozeAlarm(alarmId: alarmId, snoozeMinutes: 10),
            );
          }
        } catch (e) {
          AppLogger.e('Error parsing payload for action: $e');
        }
      }
    },
  );

  // AlarmsBloc is now registered via injection_container
  getIt<AlarmsBloc>().add(const LoadAlarms());

  runApp(
    MyNotesApp(
      database: database,
      notificationService: notificationService,
      alarmNotificationService: alarmNotificationService,
    ),
  );
}

class MyNotesApp extends StatelessWidget {
  final NotesDatabase database;
  final NotificationService notificationService;
  final notifications.AlarmService alarmNotificationService;
  final ClipboardService _clipboardService = ClipboardService();

  MyNotesApp({
    super.key,
    required this.database,
    required this.notificationService,
    required this.alarmNotificationService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Provide repositories and services
        RepositoryProvider<NoteRepository>(
          create: (context) => NoteRepositoryImpl(database: database),
        ),
        RepositoryProvider<MediaRepository>(
          create: (context) => MediaRepositoryImpl(database: database),
        ),
        RepositoryProvider<ReflectionRepository>(
          create: (context) => ReflectionRepositoryImpl(database),
        ),
        RepositoryProvider<ClipboardService>(
          create: (context) => _clipboardService,
        ),
        RepositoryProvider<StatsRepository>(
          create: (context) => StatsRepositoryImpl(database),
        ),
        RepositoryProvider<NotificationService>(
          create: (context) => notificationService,
        ),
        RepositoryProvider<AlarmRepository>(
          create: (context) => getIt<AlarmRepository>(),
        ),

        // Provide BLoCs
        BlocProvider<ThemeBloc>(
          create: (context) => ThemeBloc()..add(const LoadThemeEvent()),
        ),
        BlocProvider<NotesBloc>(
          create: (context) =>
              NotesBloc(noteRepository: context.read<NoteRepository>())
                ..add(const LoadNotesEvent()),
        ),
        BlocProvider<MediaBloc>(
          create: (context) =>
              MediaBloc(repository: context.read<MediaRepository>()),
        ),
        BlocProvider<ReflectionBloc>(
          create: (context) => ReflectionBloc(
            repository: context.read<ReflectionRepository>(),
            notificationService: context.read<NotificationService>(),
          )..add(const InitializeReflectionEvent()),
        ),
        BlocProvider<AlarmsBloc>(create: (context) => getIt<AlarmsBloc>()),
        BlocProvider<TodoBloc>(
          create: (context) =>
              TodoBloc(noteRepository: context.read<NoteRepository>()),
        ),
        BlocProvider<TodosBloc>(
          create: (context) => TodosBloc()..add(LoadTodos()),
        ),
        BlocProvider<AnalyticsBloc>(
          create: (context) =>
              AnalyticsBloc(repository: context.read<StatsRepository>())
                ..add(const LoadAnalyticsEvent()),
        ),
        BlocProvider<SmartCollectionsBloc>(
          create: (context) =>
              getIt<SmartCollectionsBloc>()
                ..add(const LoadSmartCollectionsEvent()),
        ),
        BlocProvider<ReminderTemplatesBloc>(
          create: (context) => getIt<ReminderTemplatesBloc>(),
        ),
        BlocProvider<SmartRemindersBloc>(
          create: (context) => getIt<SmartRemindersBloc>(),
        ),
        BlocProvider<FocusBloc>(
          create: (context) =>
              FocusBloc(repository: context.read<StatsRepository>())
                ..add(const LoadFocusHistoryEvent()),
        ),
        BlocProvider<NavigationBloc>(
          create: (context) => getIt<NavigationBloc>(),
        ),
        BlocProvider<DrawingCanvasBloc>(
          create: (context) => getIt<DrawingCanvasBloc>(),
        ),
        BlocProvider<SearchBloc>(create: (context) => getIt<SearchBloc>()),
        BlocProvider<AudioRecorderBloc>(
          create: (context) => AudioRecorderBloc(),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return _TextScalingWrapper(
                child: GlobalErrorHandlerListener(
                  child: GlobalOverlay(
                    child: MaterialApp(
                      title: AppConstants.appName,
                      debugShowCheckedModeBanner: false,
                      theme: AppTheme.lightTheme,
                      darkTheme: AppTheme.darkTheme,
                      themeMode: _parseThemeMode(themeState.themeMode),
                      navigatorKey: AppRouter.navigatorKey,
                      scaffoldMessengerKey:
                          getIt<GlobalUiService>().messengerKey,
                      initialRoute: AppRoutes.splash,
                      onGenerateRoute: AppRouter.onGenerateRoute,
                      // Accessibility features
                      showSemanticsDebugger: false,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Convert string theme mode to ThemeMode enum
ThemeMode? _parseThemeMode(String? themeMode) {
  if (themeMode == null) return null;
  switch (themeMode.toLowerCase()) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    case 'system':
      return ThemeMode.system;
    default:
      return ThemeMode.system;
  }
}

/// Wrapper widget to support text scaling up to 200%
class _TextScalingWrapper extends StatelessWidget {
  final Widget child;

  const _TextScalingWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaleFactor: MediaQuery.of(context).textScaleFactor > 2.0
            ? 2.0
            : MediaQuery.of(context).textScaleFactor,
      ),
      child: child,
    );
  }
}
