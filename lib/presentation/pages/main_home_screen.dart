import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/presentation/widgets/quick_add_bottom_sheet.dart';
import '../bloc/navigation/navigation_bloc.dart';
import '../design_system/design_system.dart';
import '../../core/routes/app_routes.dart';
import '../widgets/global_command_palette.dart';
import 'today_dashboard_screen.dart';
import 'enhanced_notes_list_screen.dart';
import '../screens/todos_screen_fixed.dart';
import 'enhanced_reminders_list_screen.dart';
import '../screens/reflection_home_screen.dart';
import 'integrated_features_screen.dart';

/// Main Home Screen with Bottom Navigation
/// Central hub for all app features
/// Refactored to use NavigationBloc for state management
class MainHomeScreen extends StatelessWidget {
  final int initialIndex;

  const MainHomeScreen({super.key, this.initialIndex = 0});

  void _onTabTapped(
    BuildContext context,
    PageController controller,
    int index,
  ) {
    context.read<NavigationBloc>().add(TabChanged(index));
    controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _openCommandPalette(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const GlobalCommandPalette(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        return _HomeLifecycleWrapper(
          initialPage: state.currentIndex,
          onCommandPalette: () => _openCommandPalette(context),
          onNewNote: () => Navigator.pushNamed(context, AppRoutes.noteEditor),
          onNewTodo: () => Navigator.pushNamed(context, AppRoutes.todosList),
          onNavigateFeatures: (controller) =>
              _onTabTapped(context, controller, 5),
          builder: (context, pageController) {
            return AppScaffold(
              body: PageView(
                controller: pageController,
                onPageChanged: (index) {
                  context.read<NavigationBloc>().add(TabChanged(index));
                },
                physics: const BouncingScrollPhysics(),
                children: const [
                  TodayDashboardScreen(),
                  EnhancedNotesListScreen(),
                  TodosScreen(),
                  EnhancedRemindersListScreen(),
                  ReflectionHomeScreen(),
                  IntegratedFeaturesScreen(),
                ],
              ),
              bottomNavigationBar: GlassBottomNavBar(
                currentIndex: state.currentIndex,
                onTap: (index) => _onTabTapped(context, pageController, index),
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
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              floatingActionButton: FloatingActionButton(
                heroTag: 'main_home_fab',
                onPressed: () => QuickAddBottomSheet.show(context),
                backgroundColor: AppColors.primaryColor,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            );
          },
        );
      },
    );
  }
}

class _HomeLifecycleWrapper extends StatefulWidget {
  final int initialPage;
  final VoidCallback onCommandPalette;
  final VoidCallback onNewNote;
  final VoidCallback onNewTodo;
  final Function(PageController) onNavigateFeatures;
  final Widget Function(BuildContext, PageController) builder;

  const _HomeLifecycleWrapper({
    required this.initialPage,
    required this.onCommandPalette,
    required this.onNewNote,
    required this.onNewTodo,
    required this.onNavigateFeatures,
    required this.builder,
  });

  @override
  State<_HomeLifecycleWrapper> createState() => _HomeLifecycleWrapperState();
}

class _HomeLifecycleWrapperState extends State<_HomeLifecycleWrapper> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialPage);
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
      final isControlOrMeta =
          HardwareKeyboard.instance.isControlPressed ||
          HardwareKeyboard.instance.isMetaPressed;

      if (isControlOrMeta) {
        if (event.logicalKey == LogicalKeyboardKey.keyK) {
          widget.onCommandPalette();
          return true;
        }
        if (event.logicalKey == LogicalKeyboardKey.keyN) {
          widget.onNewNote();
          return true;
        }
        if (event.logicalKey == LogicalKeyboardKey.keyT) {
          widget.onNewTodo();
          return true;
        }
        if (event.logicalKey == LogicalKeyboardKey.keyF) {
          widget.onNavigateFeatures(_pageController);
          return true;
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, _pageController);
}

//         foregroundColor: Colors.white,
//         tooltip: 'Quick Add',
//         child: const Icon(Icons.add),
//       ),
//     );
//   }

//   void _openCommandPalette() {
//     showGlobalCommandPalette(context);
//   }
// }
