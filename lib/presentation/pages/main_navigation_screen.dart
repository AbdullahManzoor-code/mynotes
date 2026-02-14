import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:badges/badges.dart' as badges;
import '../bloc/theme/theme_bloc.dart';
import '../bloc/theme/theme_state.dart';
import '../bloc/navigation/navigation_bloc.dart';
import '../bloc/smart_reminders/smart_reminders_bloc.dart';
import '../design_system/design_system.dart';
import '../../core/routes/app_routes.dart';
import 'today_dashboard_screen.dart';
import 'enhanced_notes_list_screen.dart';
import 'enhanced_reminders_list_screen.dart';
import 'todos_list_screen.dart';
import 'settings_screen.dart';

/// Main Navigation Screen - App Shell
/// Central hub for bottom navigation and content switching
/// Refactored to use NavigationBloc for state management
class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  void _onTabChanged(BuildContext context, PageController controller, int index) {
    context.read<NavigationBloc>().add(TabChanged(index));
    controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _openQuickAdd(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.universalQuickAdd);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, navState) {
        return _NavigationLifecycleWrapper(
          initialPage: navState.currentIndex,
          builder: (context, pageController) {
            return BlocBuilder<ThemeBloc, ThemeState>(
              builder: (context, themeState) {
                return Scaffold(
                  body: BlocListener<NavigationBloc, NavigationState>(
                    listenWhen: (prev, curr) => prev.currentIndex != curr.currentIndex,
                    listener: (context, state) {
                      if (pageController.hasClients &&
                          pageController.page?.round() != state.currentIndex) {
                        pageController.animateToPage(
                          state.currentIndex,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: PageView(
                      controller: pageController,
                      onPageChanged: (index) {
                        context.read<NavigationBloc>().add(TabChanged(index));
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
                  ),
                  bottomNavigationBar:
                      BlocBuilder<SmartRemindersBloc, SmartRemindersState>(
                        builder: (context, remindersState) {
                          int reminderCount = 0;
                          if (remindersState is SmartRemindersLoaded) {
                            reminderCount = remindersState.reminders
                                .where((r) => r['isCompleted'] != true)
                                .length;
                          }

                          return BottomNavigationBar(
                            currentIndex: navState.currentIndex,
                            onTap: (index) => _onTabChanged(context, pageController, index),
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
                                icon: badges.Badge(
                                  showBadge: reminderCount > 0,
                                  badgeContent: Text(
                                    reminderCount.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                  ),
                                  child: const Icon(Icons.alarm_outlined),
                                ),
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
                          );
                        },
                      ),
                  floatingActionButton: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.8, end: 1.0),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: FloatingActionButton(
                      onPressed: () => _openQuickAdd(context),
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
          },
        );
      },
    );
  }
}

class _NavigationLifecycleWrapper extends StatefulWidget {
  final int initialPage;
  final Widget Function(BuildContext, PageController) builder;

  const _NavigationLifecycleWrapper({
    required this.initialPage,
    required this.builder,
  });

  @override
  State<_NavigationLifecycleWrapper> createState() =>
      _NavigationLifecycleWrapperState();
}

class _NavigationLifecycleWrapperState
    extends State<_NavigationLifecycleWrapper> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _pageController);
}

