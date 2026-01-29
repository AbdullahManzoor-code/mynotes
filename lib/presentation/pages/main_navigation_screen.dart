import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/theme_bloc.dart';
import '../bloc/theme_state.dart';
import '../design_system/design_system.dart';
import '../../core/routes/app_routes.dart';
import 'today_dashboard_screen.dart';
import 'enhanced_notes_list_screen.dart';
import 'enhanced_reminders_list_screen.dart';
import 'todos_list_screen.dart';
import 'settings_screen.dart';

/// Main Navigation Screen - App Shell
/// Central hub for bottom navigation and content switching
/// Manages 4-5 main screens with persistent state
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _fabController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _openQuickAdd() {
    Navigator.of(context).pushNamed(AppRoutes.universalQuickAdd);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return Scaffold(
          body: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              TodayDashboardScreen(), // Today
              EnhancedNotesListScreen(), // Notes
              EnhancedRemindersListScreen(), // Reminders
              TodosListScreen(), // Todos
              SettingsScreen(), // Settings
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabChanged,
            type: BottomNavigationBarType.fixed,
            elevation: 8.0,
            backgroundColor: themeState.isDarkMode
                ? const Color(0xFF1E1E1E)
                : Colors.white,
            selectedItemColor: themeState.isDarkMode
                ? AppColors.primary
                : AppColors.primary,
            unselectedItemColor: themeState.isDarkMode
                ? Colors.grey[600]
                : Colors.grey[400],
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.calendar_today),
                label: 'Today',
                tooltip: 'Today\'s Dashboard',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.note_outlined),
                label: 'Notes',
                tooltip: 'Notes List',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.alarm_outlined),
                label: 'Reminders',
                tooltip: 'Reminders List',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.check_circle_outline),
                label: 'Todos',
                tooltip: 'Todos List',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.settings_outlined),
                label: 'Settings',
                tooltip: 'Settings',
              ),
            ],
          ),
          floatingActionButton: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
            ),
            child: FloatingActionButton(
              onPressed: _openQuickAdd,
              tooltip: 'Quick Add (Note, Todo, Reminder)',
              elevation: 8.0,
              backgroundColor: themeState.isDarkMode
                  ? AppColors.primary
                  : AppColors.primary,
              child: const Icon(Icons.add, size: 28),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
        );
      },
    );
  }
}

