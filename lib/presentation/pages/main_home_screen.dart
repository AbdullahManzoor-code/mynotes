import 'package:flutter/material.dart';
import '../design_system/design_system.dart';
import 'today_dashboard_screen.dart';
import 'notes_list_screen.dart';
import 'todos_list_screen.dart';
import 'reflection_home_screen.dart';

/// Main Home Screen with Bottom Navigation
/// Central hub for all app features
class MainHomeScreen extends StatefulWidget {
  final int initialIndex;

  const MainHomeScreen({Key? key, this.initialIndex = 0}) : super(key: key);

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
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
          NotesListScreen(),
          TodosListScreen(),
          ReflectionHomeScreen(),
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
            icon: Icons.self_improvement_outlined,
            activeIcon: Icons.self_improvement,
            label: 'Reflect',
          ),
        ],
      ),
    );
  }
}
