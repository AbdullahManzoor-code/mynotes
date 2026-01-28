import 'package:flutter/material.dart';
import 'app_routes.dart';

/// Route Generator
/// Handles navigation and route generation for the entire app

class RouteGenerator {
  RouteGenerator._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      // ==================== Onboarding & Auth ====================
      case AppRoutes.splash:
        return _buildRoute(
          // TODO: Import and use SplashScreen
          const Placeholder(), // Replace with SplashScreen()
          settings: settings,
        );

      case AppRoutes.onboarding:
        return _buildRoute(
          // TODO: Import and use OnboardingScreen
          const Placeholder(), // Replace with OnboardingScreen()
          settings: settings,
        );

      // ==================== Main Navigation ====================
      case AppRoutes.home:
        return _buildRoute(
          // TODO: Import and use HomeScreen
          const Placeholder(), // Replace with HomeScreen()
          settings: settings,
        );

      case AppRoutes.todayDashboard:
        return _buildRoute(
          // TODO: Import and use TodayDashboardScreen
          const Placeholder(), // Replace with TodayDashboardScreen()
          settings: settings,
        );

      case AppRoutes.search:
        return _buildRoute(
          // TODO: Import and use SearchScreen
          const Placeholder(), // Replace with SearchScreen()
          settings: settings,
        );

      case AppRoutes.settings:
        return _buildRoute(
          // TODO: Import and use SettingsScreen
          const Placeholder(), // Replace with SettingsScreen()
          settings: settings,
        );

      // ==================== Notes Module ====================
      case AppRoutes.notesList:
        return _buildRoute(
          // TODO: Import and use NotesListScreen
          const Placeholder(), // Replace with NotesListScreen()
          settings: settings,
        );

      case AppRoutes.noteEditor:
        return _buildRoute(
          // TODO: Import and use NoteEditorScreen
          const Placeholder(), // Replace with NoteEditorScreen(args)
          settings: settings,
        );

      case AppRoutes.noteDetail:
        return _buildRoute(
          // TODO: Import and use NoteDetailScreen
          const Placeholder(), // Replace with NoteDetailScreen(args)
          settings: settings,
        );

      // ==================== Reminders Module ====================
      case AppRoutes.remindersList:
        return _buildRoute(
          // TODO: Import and use RemindersListScreen
          const Placeholder(), // Replace with RemindersListScreen()
          settings: settings,
        );

      case AppRoutes.reminderEditor:
        return _buildRoute(
          // TODO: Import and use ReminderEditorScreen
          const Placeholder(), // Replace with ReminderEditorScreen(args)
          settings: settings,
        );

      // ==================== Todos Module ====================
      case AppRoutes.todosList:
        return _buildRoute(
          // TODO: Import and use TodosListScreen
          const Placeholder(), // Replace with TodosListScreen()
          settings: settings,
        );

      case AppRoutes.todoEditor:
        return _buildRoute(
          // TODO: Import and use TodoEditorScreen
          const Placeholder(), // Replace with TodoEditorScreen(args)
          settings: settings,
        );

      // ==================== Reflection Module ====================
      case AppRoutes.reflectionsList:
        return _buildRoute(
          // TODO: Import and use ReflectionsListScreen
          const Placeholder(), // Replace with ReflectionsListScreen()
          settings: settings,
        );

      case AppRoutes.reflectionEditor:
        return _buildRoute(
          // TODO: Import and use ReflectionEditorScreen
          const Placeholder(), // Replace with ReflectionEditorScreen(args)
          settings: settings,
        );

      case AppRoutes.reflectionInsights:
        return _buildRoute(
          // TODO: Import and use ReflectionInsightsScreen
          const Placeholder(), // Replace with ReflectionInsightsScreen()
          settings: settings,
        );

      // ==================== Quick Actions ====================
      case AppRoutes.quickAdd:
        return _buildRoute(
          // TODO: Import and use QuickAddScreen
          const Placeholder(), // Replace with QuickAddScreen()
          settings: settings,
          fullscreenDialog: true,
        );

      // ==================== Focus & Productivity ====================
      case AppRoutes.focusSession:
        return _buildRoute(
          // TODO: Import and use FocusSessionScreen
          const Placeholder(), // Replace with FocusSessionScreen()
          settings: settings,
        );

      // ==================== Error & Not Found ====================
      case AppRoutes.errorPage:
        return _buildRoute(
          _ErrorPage(error: args as String?),
          settings: settings,
        );

      case AppRoutes.notFound:
      default:
        return _buildRoute(const _NotFoundPage(), settings: settings);
    }
  }

  static MaterialPageRoute _buildRoute(
    Widget page, {
    required RouteSettings settings,
    bool fullscreenDialog = false,
  }) {
    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
      fullscreenDialog: fullscreenDialog,
    );
  }

  /// Navigate to a named route
  static Future<T?> navigateTo<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed<T>(context, routeName, arguments: arguments);
  }

  /// Replace current route with a named route
  static Future<T?> navigateAndReplace<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushReplacementNamed<T, void>(
      context,
      routeName,
      arguments: arguments,
    );
  }

  /// Clear stack and navigate to a named route
  static Future<T?> navigateAndRemoveUntil<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Go back
  static void goBack(BuildContext context, {Object? result}) {
    Navigator.pop(context, result);
  }

  /// Check if can go back
  static bool canGoBack(BuildContext context) {
    return Navigator.canPop(context);
  }
}

// ==================== Error Pages ====================

class _ErrorPage extends StatelessWidget {
  final String? error;

  const _ErrorPage({this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Oops! Something went wrong',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error ?? 'An unexpected error occurred',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                '404',
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Page not found',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              const Text(
                'The page you are looking for does not exist',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

