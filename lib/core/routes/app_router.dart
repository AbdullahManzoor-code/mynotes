import '../../presentation/pages/dashboard_screen.dart';
import 'package:flutter/material.dart';
import '../../presentation/pages/splash_screen.dart';
import '../../presentation/pages/onboarding_screen.dart';
import '../../presentation/pages/main_home_screen.dart';
import '../../presentation/pages/modern_home_screen.dart';
import '../../presentation/pages/notes_list_screen.dart';
import '../../presentation/pages/note_editor_page.dart';
import '../../presentation/pages/advanced_note_editor.dart';
import '../../presentation/pages/reminders_screen.dart';
import '../../presentation/pages/todos_list_screen.dart';
import '../../presentation/pages/todo_focus_screen.dart';
import '../../presentation/pages/advanced_todo_screen.dart';
import '../../presentation/pages/settings_screen.dart';
import '../../presentation/pages/analytics_dashboard.dart';
import '../../presentation/pages/global_search_screen.dart';
import '../../presentation/pages/media_viewer_screen.dart';
import '../../presentation/pages/pdf_preview_screen.dart';
import '../../presentation/pages/biometric_lock_screen.dart';
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
        return MaterialPageRoute(builder: (_) => const MainHomeScreen());

      case AppRoutes.todayDashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());

      case AppRoutes.notesList:
        return MaterialPageRoute(builder: (_) => const NotesListScreen());

      case AppRoutes.noteEditor:
        // Note: NoteEditorPage usually takes a Note as an argument
        final args = settings.arguments;
        return MaterialPageRoute(
          builder: (_) => NoteEditorPage(note: args is Note ? args : null),
        );

      case AppRoutes.advancedNoteEditor:
        final args = settings.arguments;
        return MaterialPageRoute(
          builder: (_) => AdvancedNoteEditor(note: args is Note ? args : null),
        );

      case AppRoutes.remindersList:
        return MaterialPageRoute(builder: (_) => const RemindersScreen());

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
        return MaterialPageRoute(builder: (_) => const AnalyticsDashboard());

      case AppRoutes.search:
        return MaterialPageRoute(builder: (_) => const GlobalSearchScreen());

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
