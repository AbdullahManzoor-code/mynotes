import 'package:flutter/material.dart';
import '../../presentation/pages/splash_screen.dart';
import '../../presentation/pages/onboarding_screen.dart';
import '../../presentation/pages/today_dashboard_screen.dart';
import '../../presentation/pages/main_home_screen.dart';
import '../../presentation/pages/enhanced_notes_list_screen.dart';
import '../../presentation/pages/enhanced_note_editor_screen.dart';
import '../../presentation/pages/enhanced_reminders_list_screen.dart';
import '../../presentation/pages/todos_list_screen.dart';
import '../../presentation/pages/todo_focus_screen.dart';
import '../../presentation/pages/advanced_todo_screen.dart';
import '../../presentation/pages/settings_screen.dart';
import '../../presentation/pages/analytics_dashboard_screen.dart';
import '../../presentation/pages/enhanced_global_search_screen.dart';
import '../../presentation/pages/search_filter_screen.dart';
import '../../presentation/pages/media_viewer_screen.dart';
import '../../presentation/pages/media_picker_screen.dart';
import '../../presentation/pages/audio_recorder_screen.dart';
import '../../presentation/pages/pdf_preview_screen.dart';
import '../../presentation/pages/biometric_lock_screen.dart';
import '../../presentation/pages/focus_session_screen.dart';
import '../../presentation/pages/focus_celebration_screen.dart';
import '../../presentation/pages/document_scan_screen.dart';
import '../../presentation/pages/backup_export_screen.dart';
import '../../presentation/pages/calendar_integration_screen.dart';
import '../../presentation/pages/voice_settings_screen.dart';
import '../../presentation/pages/edit_daily_highlight_screen_new.dart';
import '../../presentation/pages/daily_highlight_summary_screen.dart';
import '../../presentation/pages/empty_state_notes_help_screen.dart';
import '../../presentation/pages/empty_state_todos_help_screen.dart';
import '../../presentation/pages/location_reminder_coming_soon_screen.dart';
import '../../presentation/pages/recurring_todo_schedule_screen.dart';
import '../../presentation/pages/ocr_text_extraction_screen.dart';
import '../../presentation/screens/reflection_home_screen.dart';
import '../../presentation/pages/home_widgets_screen.dart';
import '../../presentation/widgets/quick_add_bottom_sheet.dart';
import '../../presentation/widgets/global_command_palette.dart';
import '../../domain/entities/note.dart';
import 'app_routes.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case AppRoutes.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());

      case AppRoutes.home:
      case AppRoutes.todayDashboard:
        return MaterialPageRoute(builder: (_) => const TodayDashboardScreen());

      case AppRoutes.mainHome:
        final args = settings.arguments;
        return MaterialPageRoute(
          builder: (_) => MainHomeScreen(initialIndex: args is int ? args : 0),
        );

      case AppRoutes.notesList:
        return MaterialPageRoute(
          builder: (_) => const EnhancedNotesListScreen(),
        );

      case AppRoutes.noteEditor:
        // Note: Enhanced editor with all features
        final args = settings.arguments;
        return MaterialPageRoute(
          builder: (_) =>
              EnhancedNoteEditorScreen(note: args is Note ? args : null),
        );

      // case AppRoutes.advancedNoteEditor:
      //   final args = settings.arguments;
      //   return MaterialPageRoute(
      //     builder: (_) => AdvancedNoteEditor(note: args is Note ? args : null),
      //   );

      case AppRoutes.remindersList:
        return MaterialPageRoute(
          builder: (_) => const EnhancedRemindersListScreen(),
        );

      case AppRoutes.todosList:
        return MaterialPageRoute(builder: (_) => const TodosListScreen());

      case AppRoutes.todoFocus:
        final args = settings.arguments;
        if (args is Note) {
          return MaterialPageRoute(builder: (_) => TodoFocusScreen(note: args));
        }
        return _errorRoute();

      case AppRoutes.advancedTodo:
        final args = settings.arguments;
        if (args is Note) {
          return MaterialPageRoute(
            builder: (_) => AdvancedTodoScreen(note: args),
          );
        }
        return _errorRoute();

      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      case AppRoutes.analytics:
        return MaterialPageRoute(
          builder: (_) => const AnalyticsDashboardScreen(),
        );

      case AppRoutes.search:
      case AppRoutes.globalSearch:
        return MaterialPageRoute(
          builder: (_) => const EnhancedGlobalSearchScreen(),
        );

      case AppRoutes.searchFilter:
        return MaterialPageRoute(builder: (_) => const SearchFilterScreen());

      case AppRoutes.mediaPicker:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => MediaPickerScreen(
            mediaType: args?['mediaType'] ?? 'all',
            multiSelect: args?['multiSelect'] ?? true,
            maxSelection: args?['maxSelection'] ?? 10,
          ),
        );

      case AppRoutes.audioRecorder:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => AudioRecorderScreen(noteId: args?['noteId']),
        );

      case AppRoutes.calendarIntegration:
        return MaterialPageRoute(
          builder: (_) => const CalendarIntegrationScreen(),
        );

      case AppRoutes.focusSession:
        return MaterialPageRoute(builder: (_) => const FocusSessionScreen());

      case AppRoutes.focusCelebration:
        return MaterialPageRoute(
          builder: (_) => const FocusCelebrationScreen(),
        );

      case AppRoutes.documentScan:
        return MaterialPageRoute(builder: (_) => const DocumentScanScreen());

      case AppRoutes.backupExport:
        return MaterialPageRoute(builder: (_) => const BackupExportScreen());

      case AppRoutes.appSettings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      case AppRoutes.voiceSettings:
        return MaterialPageRoute(builder: (_) => const VoiceSettingsScreen());

      case AppRoutes.editDailyHighlight:
        return MaterialPageRoute(
          builder: (_) => const EditDailyHighlightScreen(),
        );

      case AppRoutes.reflection:
      case AppRoutes.reflectionHome:
        return MaterialPageRoute(builder: (_) => const ReflectionHomeScreen());

      case AppRoutes.quickAdd:
        final args = settings.arguments as BuildContext?;
        return PageRouteBuilder(
          pageBuilder: (context, animation, _) => Container(), // Placeholder
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            if (args != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showModalBottomSheet(
                  context: args,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const QuickAddBottomSheet(),
                );
              });
            }
            return const SizedBox.shrink();
          },
        );

      case AppRoutes.commandPalette:
        final args = settings.arguments as BuildContext?;
        return PageRouteBuilder(
          pageBuilder: (context, animation, _) => Container(), // Placeholder
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            if (args != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showGlobalCommandPalette(args);
              });
            }
            return const SizedBox.shrink();
          },
        );

      case AppRoutes.mediaViewer:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => MediaViewerScreen(
            mediaItems: args['mediaItems'] ?? [],
            initialIndex: args['index'] ?? 0,
          ),
        );

      case AppRoutes.pdfPreview:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => PdfPreviewScreen(note: args['note']),
        );

      case AppRoutes.biometricLock:
        return MaterialPageRoute(builder: (_) => const BiometricLockScreen());

      case AppRoutes.dailyHighlightSummary:
        return MaterialPageRoute(
          builder: (_) => const DailyHighlightSummaryScreen(),
        );

      case AppRoutes.emptyStateNotesHelp:
        return MaterialPageRoute(
          builder: (_) => const EmptyStateNotesHelpScreen(),
        );

      case AppRoutes.emptyStateTodosHelp:
        return MaterialPageRoute(
          builder: (_) => const EmptyStateTodosHelpScreen(),
        );

      case AppRoutes.locationReminderComingSoon:
        return MaterialPageRoute(
          builder: (_) => const LocationReminderComingSoonScreen(),
        );

      case AppRoutes.recurringTodoSchedule:
        return MaterialPageRoute(
          builder: (_) => const RecurringTodoScheduleScreen(),
        );

      case AppRoutes.ocrExtraction:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => OcrTextExtractionScreen(
            documentImagePath: args?['documentImagePath'],
            extractedText: args?['extractedText'],
          ),
        );

      case AppRoutes.homeWidgets:
        return MaterialPageRoute(builder: (_) => const HomeWidgetsScreen());

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Page not found')),
      ),
    );
  }
}
