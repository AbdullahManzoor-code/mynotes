import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:mynotes/presentation/bloc/command_palette/command_palette_bloc.dart';
import 'package:vibration/vibration.dart';
import 'package:mynotes/generated/l10n/app_localizations.dart';
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
import 'package:mynotes/presentation/widgets/alarm_popup_listener.dart';
import 'package:mynotes/presentation/widgets/upcoming_alarms_notification_widget.dart';

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
import 'package:mynotes/presentation/bloc/localization/localization_bloc.dart';
import 'package:mynotes/presentation/bloc/note_linking/note_linking_bloc.dart';
import 'package:mynotes/presentation/bloc/link_preview/link_preview_bloc.dart';
import 'package:mynotes/core/notifications/alarm_service.dart' as notifications;
import 'package:mynotes/presentation/widgets/global_error_handler_listener.dart';
import 'package:mynotes/presentation/widgets/global_overlay.dart';
import 'package:mynotes/presentation/widgets/focus/focus_lock_overlay.dart';
import 'package:mynotes/core/services/global_ui_service.dart';
import 'package:mynotes/core/services/app_logger.dart';
import 'package:mynotes/injection_container.dart'
    show getIt, setupServiceLocator;

// ════════════════════════════════════════════════════════════════════════════════
// CRITICAL: Background Alarm Callback
// ════════════════════════════════════════════════════════════════════════════════
// This function runs in a separate isolate when the alarm triggers, even if app is killed.
// It MUST be a top-level function (not a class method) and annotated with @pragma.
// ════════════════════════════════════════════════════════════════════════════════

@pragma('vm:entry-point')
void alarmCallback() {
  AppLogger.i('═' * 70);
  AppLogger.i('🔔 [BACKGROUND-ALARM] Alarm callback triggered in isolate!');
  AppLogger.i('═' * 70);

  try {
    // Initialize Awesome Notifications in this isolate (fresh context)
    AppLogger.i(
      '[BACKGROUND-ALARM] Re-initializing AwesomeNotifications in isolate...',
    );
    AwesomeNotifications().initialize(null, [
      NotificationChannel(
        channelKey: 'alarm_channel',
        channelName: 'Alarm Notifications',
        channelDescription: 'Channel for alarm trigger notifications',
        defaultColor: const Color(0xFF9D50DD),
        ledColor: Colors.white,
        importance: NotificationImportance.Max,
        channelShowBadge: true,
        locked: true, // User can't dismiss easily
        playSound: true,
        enableVibration: true,
      ),
    ]);
    AppLogger.i(
      '[BACKGROUND-ALARM] ✅ AwesomeNotifications initialized in isolate',
    );

    // Trigger Vibration
    AppLogger.i('[BACKGROUND-ALARM] Starting vibration pattern...');
    Vibration.vibrate(pattern: [500, 1000, 500, 1000], repeat: -1);
    AppLogger.i('[BACKGROUND-ALARM] ✅ Vibration started');

    // Trigger Sound
    AppLogger.i('[BACKGROUND-ALARM] Playing alarm sound...');
    FlutterRingtonePlayer().playAlarm();
    AppLogger.i('[BACKGROUND-ALARM] ✅ Alarm sound started');

    // Show Notification
    AppLogger.i('[BACKGROUND-ALARM] Creating notification...');
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'alarm_channel',
        title: '⏰ Alarm!',
        body: 'Your alarm is going off!',
        wakeUpScreen: true, // Turns screen on
        category: NotificationCategory.Alarm,
        fullScreenIntent: true, // Shows full-screen UI on lockscreen
        autoDismissible: false, // Persist until action taken
        locked: true,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'STOP_ALARM',
          label: 'Stop',
          actionType: ActionType.Default,
        ),
        NotificationActionButton(
          key: 'SNOOZE_ALARM',
          label: 'Snooze 10min',
          actionType: ActionType.Default,
        ),
      ],
    );
    AppLogger.i('[BACKGROUND-ALARM] ✅ Notification created');
    AppLogger.i('═' * 70);
    AppLogger.i('✅ [BACKGROUND-ALARM] Alarm callback completed successfully!');
    AppLogger.i('═' * 70);
  } catch (e, stack) {
    AppLogger.e('═' * 70);
    AppLogger.e('❌ [BACKGROUND-ALARM-ERROR] Failed to trigger alarm!');
    AppLogger.e('═' * 70);
    AppLogger.e('Error: $e');
    AppLogger.e('Stack trace: $stack');
    AppLogger.e('═' * 70);
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// Notification Action Handler
// ════════════════════════════════════════════════════════════════════════════════
// This handles actions from alarm notifications (both foreground and background)

@pragma('vm:entry-point')
Future<void> _onNotificationActionReceived(
  ReceivedAction receivedAction,
) async {
  AppLogger.i('═' * 60);
  AppLogger.i('🔔 [NOTIFICATION-ACTION] Action received!');
  AppLogger.i('═' * 60);
  AppLogger.i('Button Key: ${receivedAction.buttonKeyPressed}');
  AppLogger.i('Notification ID: ${receivedAction.id}');
  AppLogger.i('Payload: ${receivedAction.payload}');
  AppLogger.i('═' * 60);

  try {
    // Parse payload to get reminder details
    Map<String, dynamic> payloadData = {};
    if (receivedAction.payload != null && receivedAction.payload!.isNotEmpty) {
      try {
        payloadData = Map<String, dynamic>.from(receivedAction.payload!);
        AppLogger.i('[ACTION-HANDLER] Payload parsed: $payloadData');
      } catch (e) {
        AppLogger.w('[ACTION-HANDLER] Could not parse payload: $e');
      }
    }

    final String? reminderType = payloadData['type'];
    final String? linkedNoteId = payloadData['linkedNoteId'];
    final String? linkedTodoId = payloadData['linkedTodoId'];

    if (receivedAction.buttonKeyPressed == 'STOP_ALARM' ||
        receivedAction.buttonKeyPressed == 'DISMISS') {
      AppLogger.i('🛑 [ALARM-ACTION] Dismissing alarm...');
      FlutterRingtonePlayer().stop();
      Vibration.cancel();
      AwesomeNotifications().dismiss(receivedAction.id ?? 10);
      AppLogger.i('✅ [ALARM-ACTION] Alarm dismissed successfully');
    } else if (receivedAction.buttonKeyPressed == 'SNOOZE_10' ||
        receivedAction.buttonKeyPressed == 'SNOOZE_ALARM') {
      AppLogger.i('💤 [ALARM-ACTION] Snoozing alarm for 10 minutes...');
      FlutterRingtonePlayer().stop();
      Vibration.cancel();
      // Schedule another alarm in 10 minutes
      await AndroidAlarmManager.oneShot(
        const Duration(minutes: 10),
        (receivedAction.id ?? 10) + 1000,
        alarmCallback,
        exact: true,
        wakeup: true,
      );
      AwesomeNotifications().dismiss(receivedAction.id ?? 10);
      AppLogger.i('✅ [ALARM-ACTION] Alarm snoozed for 10 minutes');
    } else if (receivedAction.buttonKeyPressed == 'RESCHEDULE') {
      AppLogger.i('📅 [ALARM-ACTION] Opening reschedule dialog...');
      FlutterRingtonePlayer().stop();
      Vibration.cancel();
      AwesomeNotifications().dismiss(receivedAction.id ?? 10);

      // Navigate to appropriate screen based on reminder type
      if (reminderType == 'note' && linkedNoteId != null) {
        AppLogger.i(
          '[ACTION-HANDLER] Navigating to note editor for note: $linkedNoteId',
        );
        AppRouter.navigatorKey.currentState?.pushNamed(
          AppRoutes.noteEditor,
          arguments: {'noteId': linkedNoteId},
        );
      } else if (reminderType == 'todo' && linkedTodoId != null) {
        AppLogger.i(
          '[ACTION-HANDLER] Navigating to todos list for todo: $linkedTodoId',
        );
        AppRouter.navigatorKey.currentState?.pushNamed(AppRoutes.todosList);
      } else {
        AppLogger.w('[ACTION-HANDLER] No valid reminder type or ID found');
      }
      AppLogger.i('✅ [ALARM-ACTION] Reschedule dialog opened');
    } else if (receivedAction.id != null && receivedAction.id == 10) {
      // Tap on notification body (not an action button)
      AppLogger.i(
        '🎯 [ALARM-ACTION] Notification body tapped - navigating to reminder...',
      );
      FlutterRingtonePlayer().stop();
      Vibration.cancel();
      AwesomeNotifications().dismiss(receivedAction.id!);

      // [A005 FIX] Better error handling for deleted linked items
      // Previously: Would navigate to missing note/todo, showing generic error
      // Now: Check if note exists first, show graceful message if deleted
      if (reminderType == 'note' && linkedNoteId != null) {
        AppLogger.i('[ACTION-HANDLER] Navigating to note: $linkedNoteId');
        try {
          AppRouter.navigatorKey.currentState?.pushNamed(
            AppRoutes.noteEditor,
            arguments: {
              'noteId': linkedNoteId,
              'fromDeletedReminder':
                  true, // Flag to handle gracefully if note deleted
            },
          );
        } catch (e) {
          AppLogger.w('[ACTION-HANDLER] Could not navigate to note: $e');
          // User stays on current screen, can view other notes or close app
        }
      } else if (reminderType == 'todo' && linkedTodoId != null) {
        AppLogger.i('[ACTION-HANDLER] Navigating to todos list');
        try {
          AppRouter.navigatorKey.currentState?.pushNamed(AppRoutes.todosList);
        } catch (e) {
          AppLogger.w('[ACTION-HANDLER] Could not navigate to todos: $e');
          // User stays on current screen
        }
      } else if (linkedNoteId == null && linkedTodoId == null) {
        // [A005] Item was likely deleted
        AppLogger.w(
          '[ACTION-HANDLER] Reminder item no longer exists (deleted)',
        );
        // Show user-friendly feedback (snackbar would require context)
        // App just stays on current screen - graceful degradation
      }
      AppLogger.i(
        '✅ [ALARM-ACTION] Navigation attempted or skipped gracefully',
      );
    }
  } catch (e, stack) {
    AppLogger.e('[ALARM-ACTION-ERROR] Failed to handle action: $e');
    AppLogger.e('Stack: $stack');
  }
}

void main() async {
  AppLogger.i('App starting: main() entry point');
  WidgetsFlutterBinding.ensureInitialized();
  AppLogger.i('Flutter binding initialized');

  // Initialize Android Alarm Manager (CRITICAL for background alarms)
  AppLogger.i('═' * 60);
  AppLogger.i('[INIT] Initializing AndroidAlarmManager...');
  try {
    await AndroidAlarmManager.initialize();
    AppLogger.i('[INIT] ✅ AndroidAlarmManager initialized successfully');
  } catch (e) {
    AppLogger.e('[INIT-ERROR] Failed to initialize AndroidAlarmManager: $e');
  }
  AppLogger.i('═' * 60);

  // Initialize Awesome Notifications in main isolate (for foreground/UI interaction)
  AppLogger.i('[INIT] Initializing AwesomeNotifications in main isolate...');
  try {
    AwesomeNotifications().initialize(null, [
      NotificationChannel(
        channelKey: 'alarm_channel',
        channelName: 'Alarm Notifications',
        channelDescription: 'Alarm trigger notifications',
        defaultColor: const Color(0xFF9D50DD),
        ledColor: Colors.white,
        importance: NotificationImportance.Max,
        channelShowBadge: true,
        locked: true,
        playSound: true,
        enableVibration: true,
      ),
    ]);
    AppLogger.i('[INIT] ✅ AwesomeNotifications initialized in main isolate');

    // Set up listener for notification actions (including from background alarm)
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: _onNotificationActionReceived,
    );
    AppLogger.i('[INIT] ✅ Notification action listener registered');
  } catch (e) {
    AppLogger.e('[INIT-ERROR] Failed to initialize AwesomeNotifications: $e');
  }

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

  // Get notificationservice from locator (already initialized with AlarmService)
  AppLogger.i('Retrieving NotificationService from locator...');
  final notificationService = getIt<NotificationService>();
  AppLogger.i(
    '✅ NotificationService retrieved (includes AlarmService support)',
  );

  // Get AlarmService from locator (already initialized)
  AppLogger.i('Retrieving AlarmService from locator...');
  final alarmNotificationService = getIt<notifications.AlarmService>();
  AppLogger.i('✅ AlarmService retrieved for alarm handling');

  // Set up alarm action handler
  AppLogger.i('Setting up alarm action handler...');
  alarmNotificationService.onActionReceived = (actionId, payload, input) {
    AppLogger.i('Alarm action received: $actionId');
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
  };
  AppLogger.i('✅ Alarm action handler registered');

  // Reschedule all active alarms from database (ensures alarms work after app restart/reboot)
  AppLogger.i('═' * 60);
  AppLogger.i('[STARTUP] Rescheduling active alarms...');
  try {
    final alarmRepository = getIt<AlarmRepository>();
    await alarmNotificationService.rescheduleAllActiveAlarms(alarmRepository);
    AppLogger.i('[STARTUP] ✅ Active alarms rescheduled');
  } catch (e, stack) {
    AppLogger.e('[STARTUP] ❌ Failed to reschedule alarms: $e');
    AppLogger.e('Stack: $stack');
  }
  AppLogger.i('═' * 60);

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

  const MyNotesApp({
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
        BlocProvider<AlarmsBloc>(
          create: (context) =>
              getIt<AlarmsBloc>()..add(const LoadAlarmsEvent()),
        ),
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
          create: (context) => getIt<FocusBloc>()
            ..add(const LoadFocusHistoryEvent())
            ..add(const LoadFocusLockSettingsEvent()),
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
        BlocProvider<LocalizationBloc>(
          create: (context) =>
              getIt<LocalizationBloc>()..add(const LoadLocalizationEvent()),
        ),
        BlocProvider<NoteLinkingBloc>(
          create: (context) => getIt<NoteLinkingBloc>(),
        ),
        BlocProvider<LinkPreviewBloc>(
          create: (context) => getIt<LinkPreviewBloc>(),
        ),
        // FIX: CF005 Register CommandPaletteBloc for command palette support
        BlocProvider<CommandPaletteBloc>(
          create: (context) =>
              getIt<CommandPaletteBloc>()..add(const LoadCommandsEvent()),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          // FIX: SET005 Build should also listen to accessibility settings
          return BlocBuilder<
            AccessibilityFeaturesBloc,
            AccessibilityFeaturesState
          >(
            builder: (context, a11yState) {
              // FIX: SET006 Also listen to localization changes
              return BlocBuilder<LocalizationBloc, LocalizationState>(
                builder: (context, i18nState) {
                  // Determine if high contrast mode is enabled
                  final useHighContrast =
                      a11yState is AccessibilitySettingsLoaded
                      ? a11yState.highContrastEnabled
                      : false;

                  // Select appropriate theme based on dark mode and high contrast
                  final isDark =
                      _parseThemeMode(themeState.themeMode) == ThemeMode.dark ||
                      ((_parseThemeMode(themeState.themeMode) ==
                              ThemeMode.system) &&
                          MediaQuery.of(context).platformBrightness ==
                              Brightness.dark);

                  // FIX: USE CUSTOM COLOR FROM THEMEBLOC
                  final primaryColor = themeState.params.primaryColor;

                  final themeData = useHighContrast
                      ? (isDark
                            ? AppTheme.highContrastDarkTheme
                            : AppTheme.highContrastLightTheme)
                      : (isDark
                            ? AppTheme.buildDarkTheme(primaryColor)
                            : AppTheme.buildLightTheme(primaryColor));

                  // FIX: SET006 Parse locale from LocalizationBloc
                  Locale? selectedLocale;
                  if (i18nState is LocalizationLoaded) {
                    try {
                      selectedLocale = Locale(
                        i18nState.language.split('_')[0],
                        i18nState.language.contains('_')
                            ? i18nState.language.split('_')[1]
                            : null,
                      );
                    } catch (e) {
                      selectedLocale = const Locale('en');
                    }
                  }

                  return AlarmPopupListener(
                    child: ScreenUtilInit(
                      designSize: const Size(375, 812),
                      minTextAdapt: true,
                      splitScreenMode: true,
                      builder: (context, child) {
                        return MaterialApp(
                          title: AppConstants.appName,
                          debugShowCheckedModeBanner: false,
                          theme: themeData,
                          darkTheme: themeData,
                          themeMode:
                              _parseThemeMode(themeState.themeMode) ??
                              ThemeMode.system,
                          // FIX: SET006 Apply selected locale
                          locale: selectedLocale,
                          // FIX: SET007 Use generated AppLocalizations for proper language support
                          supportedLocales: AppLocalizations.supportedLocales,
                          localizationsDelegates: AppLocalizations.localizationsDelegates,
                          navigatorKey: AppRouter.navigatorKey,
                          scaffoldMessengerKey:
                              getIt<GlobalUiService>().messengerKey,
                          initialRoute: AppRoutes.splash,
                          onGenerateRoute: AppRouter.onGenerateRoute,
                          // FIX: SET005 Enable semantics if screen reader enabled
                          showSemanticsDebugger:
                              a11yState is AccessibilitySettingsLoaded
                              ? a11yState.screenReaderEnabled
                              : false,
                          builder: (context, materialAppChild) {
                            return _TextScalingWrapper(
                              child: UpcomingAlarmsNotificationWidget(
                                child: GlobalErrorHandlerListener(
                                  child: Stack(
                                    children: [
                                      GlobalOverlay(child: materialAppChild!),
                                      const FocusLockOverlay(),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
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
