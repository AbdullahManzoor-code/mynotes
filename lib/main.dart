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

import 'package:mynotes/core/routes/app_routes.dart';
import 'package:mynotes/core/routes/app_router.dart';
import 'package:mynotes/core/notifications/notification_service.dart';
import 'package:mynotes/core/services/clipboard_service.dart';
import 'package:mynotes/core/constants/app_constants.dart';
import 'package:mynotes/core/themes/app_theme.dart';

import 'package:mynotes/domain/repositories/note_repository.dart';
import 'package:mynotes/domain/repositories/media_repository.dart';
import 'package:mynotes/domain/repositories/reflection_repository.dart';
import 'package:mynotes/domain/repositories/stats_repository.dart';

import 'package:mynotes/core/database/core_database.dart';

import 'package:mynotes/presentation/bloc/params/note_params.dart';
import 'package:mynotes/presentation/bloc/theme/theme_bloc.dart';
import 'package:mynotes/presentation/bloc/theme/theme_event.dart';
import 'package:mynotes/presentation/bloc/theme/theme_state.dart';
import 'package:mynotes/presentation/bloc/note/note_bloc.dart';
import 'package:mynotes/presentation/bloc/media/media_bloc.dart';
import 'package:mynotes/presentation/bloc/media/media_event.dart';
import 'package:mynotes/presentation/bloc/reflection/reflection_bloc.dart';
import 'package:mynotes/presentation/bloc/alarm/alarm_bloc.dart';
import 'package:mynotes/presentation/bloc/alarm/alarms_bloc.dart';
import 'package:mynotes/presentation/bloc/todo/todo_bloc.dart';
import 'package:mynotes/presentation/bloc/note/note_event.dart';
import 'package:mynotes/presentation/bloc/todos/todos_bloc.dart';
import 'package:mynotes/presentation/bloc/analytics/analytics_bloc.dart';
import 'package:mynotes/presentation/bloc/smart_collections/smart_collections_bloc.dart';
import 'package:mynotes/presentation/bloc/reminder_templates/reminder_templates_bloc.dart';
import 'package:mynotes/presentation/bloc/smart_reminders/smart_reminders_bloc.dart';
import 'package:mynotes/presentation/bloc/focus/focus_bloc.dart';
import 'package:mynotes/presentation/bloc/navigation/navigation_bloc.dart';
import 'package:mynotes/presentation/bloc/drawing_canvas/drawing_canvas_bloc.dart';
import 'package:mynotes/presentation/bloc/search/search_bloc.dart';
import 'package:mynotes/presentation/bloc/audio_recorder/audio_recorder_bloc.dart';
import 'package:mynotes/presentation/bloc/location_reminder/location_reminder_bloc.dart';
import 'package:mynotes/presentation/bloc/settings/settings_bloc.dart';
import 'package:mynotes/presentation/bloc/accessibility_features/accessibility_features_bloc.dart';
import 'package:mynotes/core/notifications/alarm_service.dart' as notifications;
import 'package:mynotes/presentation/widgets/global_error_handler_listener.dart';
import 'package:mynotes/presentation/widgets/global_overlay.dart';
import 'package:mynotes/core/services/global_ui_service.dart';
import 'package:mynotes/core/services/app_logger.dart';
import 'package:mynotes/injection_container.dart'
    show getIt, setupServiceLocator;

void main() async {
  AppLogger.i('App starting: main() entry point');
  WidgetsFlutterBinding.ensureInitialized();
  AppLogger.i('Flutter binding initialized');

  // Initialize database factory ONLY for desktop platforms (Windows/Linux/Mac)
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    AppLogger.i('Initializing database factory for desktop platform');
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Initialize dependency injection (service locator)
  AppLogger.i('Setting up service locator...');
  await setupServiceLocator();
  AppLogger.i('Service locator setup complete');

  // Initialize database
  AppLogger.i('Initializing CoreDatabase...');
  final database = CoreDatabase();

  // Get notification service from locator
  final notificationService = getIt<NotificationService>();

  // Initialize alarm notification service (for specific alarm handling)
  AppLogger.i('Initializing alarm notification service...');
  final alarmNotificationService = notifications.AlarmService();
  await alarmNotificationService.init(
    onActionReceived: (actionId, payload, input) {
      AppLogger.i('Notification action received: $actionId');
      if (actionId == 'quick_reply' && input != null && input.isNotEmpty) {
        AppLogger.i('Quick reply input received: $input');
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
          AppLogger.i('Alarm action payload parsed: ID=$alarmId');

          if (actionId == 'complete') {
            AppLogger.i('Marking alarm as completed: $alarmId');
            getIt<AlarmsBloc>().add(MarkAlarmCompleted(alarmId));
          } else if (actionId == 'snooze') {
            // Default snooze 10 mins
            AppLogger.i('Snoozing alarm: $alarmId');
            getIt<AlarmsBloc>().add(
              SnoozeAlarm(alarmId: alarmId, snoozeMinutes: 10),
            );
          }
        } catch (e, stack) {
          AppLogger.e('Error parsing payload for action: $e', e, stack);
        }
      }
    },
  );

  // AlarmsBloc is now registered via injection_container
  AppLogger.i('Loading initial alarms...');
  getIt<AlarmsBloc>().add(const LoadAlarms());

  AppLogger.i('Running MyNotesApp...');
  runApp(
    MyNotesApp(
      database: database,
      notificationService: notificationService,
      alarmNotificationService: alarmNotificationService,
    ),
  );
}

class MyNotesApp extends StatelessWidget {
  final CoreDatabase database;
  final NotificationService notificationService;
  final notifications.AlarmService alarmNotificationService;

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
          create: (context) => getIt<NoteRepository>(),
        ),
        RepositoryProvider<MediaRepository>(
          create: (context) => getIt<MediaRepository>(),
        ),
        RepositoryProvider<ReflectionRepository>(
          create: (context) => getIt<ReflectionRepository>(),
        ),
        RepositoryProvider<ClipboardService>(
          create: (context) => getIt<ClipboardService>(),
        ),
        RepositoryProvider<StatsRepository>(
          create: (context) => getIt<StatsRepository>(),
        ),
        RepositoryProvider<NotificationService>(
          create: (context) => notificationService,
        ),
        RepositoryProvider<AlarmRepository>(
          create: (context) => getIt<AlarmRepository>(),
        ),

        // Provide BLoCs
        BlocProvider<ThemeBloc>(
          create: (context) => getIt<ThemeBloc>()..add(const LoadThemeEvent()),
        ),
        BlocProvider<NotesBloc>(
          create: (context) => getIt<NotesBloc>()..add(const LoadNotesEvent()),
        ),
        BlocProvider<MediaBloc>(
          create: (context) => getIt<MediaBloc>()..add(const LoadMediaEvent()),
        ),
        BlocProvider<ReflectionBloc>(
          create: (context) =>
              getIt<ReflectionBloc>()..add(const InitializeReflectionEvent()),
        ),
        BlocProvider<AlarmsBloc>(create: (context) => getIt<AlarmsBloc>()),
        BlocProvider<TodoBloc>(create: (context) => getIt<TodoBloc>()),
        BlocProvider<TodosBloc>(
          create: (context) => getIt<TodosBloc>()..add(LoadTodos()),
        ),
        BlocProvider<AnalyticsBloc>(
          create: (context) =>
              getIt<AnalyticsBloc>()..add(const LoadAnalyticsEvent()),
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
              getIt<FocusBloc>()..add(const LoadFocusHistoryEvent()),
        ),
        BlocProvider<NavigationBloc>(
          create: (context) => getIt<NavigationBloc>(),
        ),
        BlocProvider<DrawingCanvasBloc>(
          create: (context) => getIt<DrawingCanvasBloc>(),
        ),
        BlocProvider<SearchBloc>(create: (context) => getIt<SearchBloc>()),
        BlocProvider<AudioRecorderBloc>(
          create: (context) => getIt<AudioRecorderBloc>(),
        ),
        BlocProvider<LocationReminderBloc>(
          create: (context) => getIt<LocationReminderBloc>(),
        ),
        BlocProvider<SettingsBloc>(
          create: (context) =>
              getIt<SettingsBloc>()..add(const LoadSettingsEvent()),
        ),
        BlocProvider<AccessibilityFeaturesBloc>(
          create: (context) =>
              getIt<AccessibilityFeaturesBloc>()
                ..add(const LoadAccessibilitySettingsEvent()),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return MaterialApp(
                title: AppConstants.appName,
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: _parseThemeMode(themeState.themeMode),
                navigatorKey: AppRouter.navigatorKey,
                scaffoldMessengerKey: getIt<GlobalUiService>().messengerKey,
                initialRoute: AppRoutes.splash,
                onGenerateRoute: AppRouter.onGenerateRoute,
                // Accessibility features
                showSemanticsDebugger: false,
                builder: (context, materialAppChild) {
                  return _TextScalingWrapper(
                    child: GlobalErrorHandlerListener(
                      child: GlobalOverlay(child: materialAppChild!),
                    ),
                  );
                },
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
