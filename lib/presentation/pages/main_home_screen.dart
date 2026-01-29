import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design_system/design_system.dart';
import '../../core/routes/app_routes.dart';
import '../widgets/global_command_palette.dart';
import 'today_dashboard_screen.dart';
import 'enhanced_notes_list_screen.dart';
import 'todos_list_screen.dart';
import 'enhanced_reminders_list_screen.dart';
import '../screens/reflection_home_screen.dart';
import 'integrated_features_screen.dart';

/// Main Home Screen with Bottom Navigation
/// Central hub for all app features
class MainHomeScreen extends StatefulWidget {
  final int initialIndex;

  const MainHomeScreen({super.key, this.initialIndex = 0});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen>
    with SingleTickerProviderStateMixin {
  late int _currentIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);

    // Listen for keyboard shortcuts
    ServicesBinding.instance.keyboard.addHandler(_handleKeyEvent);
  }

  @override
  void dispose() {
    ServicesBinding.instance.keyboard.removeHandler(_handleKeyEvent);
    _pageController.dispose();
    super.dispose();
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      // Command/Ctrl + K to open command palette
      if ((event.logicalKey == LogicalKeyboardKey.keyK) &&
          (HardwareKeyboard.instance.isControlPressed ||
              HardwareKeyboard.instance.isMetaPressed)) {
        _openCommandPalette();
        return true;
      }
      // Command/Ctrl + N for new note
      if ((event.logicalKey == LogicalKeyboardKey.keyN) &&
          (HardwareKeyboard.instance.isControlPressed ||
              HardwareKeyboard.instance.isMetaPressed)) {
        Navigator.pushNamed(context, AppRoutes.noteEditor);
        return true;
      }
      // Command/Ctrl + T for new todo
      if ((event.logicalKey == LogicalKeyboardKey.keyT) &&
          (HardwareKeyboard.instance.isControlPressed ||
              HardwareKeyboard.instance.isMetaPressed)) {
        Navigator.pushNamed(context, AppRoutes.todosList);
        return true;
      }
      // Command/Ctrl + F for Features (Integrated Features)
      if ((event.logicalKey == LogicalKeyboardKey.keyF) &&
          (HardwareKeyboard.instance.isControlPressed ||
              HardwareKeyboard.instance.isMetaPressed)) {
        _onTabTapped(5); // Navigate to Features tab
        return true;
      }
    }
    return false;
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onTabTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const BouncingScrollPhysics(),
        children: const [
          TodayDashboardScreen(),
          EnhancedNotesListScreen(),
          TodosListScreen(),
          EnhancedRemindersListScreen(),
          ReflectionHomeScreen(),
          IntegratedFeaturesScreen(),
        ],
      ),
      bottomNavigationBar: GlassBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Today',
          ),
          BottomNavItem(
            icon: Icons.description_outlined,
            activeIcon: Icons.description,
            label: 'Notes',
          ),
          BottomNavItem(
            icon: Icons.check_box_outlined,
            activeIcon: Icons.check_box,
            label: 'Todos',
          ),
          BottomNavItem(
            icon: Icons.alarm_outlined,
            activeIcon: Icons.alarm,
            label: 'Reminders',
          ),
          BottomNavItem(
            icon: Icons.self_improvement_outlined,
            activeIcon: Icons.self_improvement,
            label: 'Reflect',
          ),
          BottomNavItem(
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard,
            label: 'Features',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCommandPalette,
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.search),
        label: Text(
          'Quick Actions',
          style: AppTypography.button(context, Colors.white),
        ),
        tooltip: 'Open Command Palette (Ctrl+K)',
      ),
    );
  }

  void _openCommandPalette() {
    showGlobalCommandPalette(context);
  }
}
