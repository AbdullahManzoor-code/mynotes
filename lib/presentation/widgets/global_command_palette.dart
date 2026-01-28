import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../design_system/design_system.dart';
import '../pages/note_editor_page.dart';
import '../pages/focus_session_screen.dart';
import '../pages/reminders_screen.dart';
import '../pages/settings_screen.dart';
import '../pages/daily_highlight_summary_screen.dart';

/// Global Command Palette
/// Quick access to all app features and recent items
/// Based on template: global_command_palette_1
class GlobalCommandPalette extends StatefulWidget {
  const GlobalCommandPalette({Key? key}) : super(key: key);

  @override
  State<GlobalCommandPalette> createState() => _GlobalCommandPaletteState();
}

class _GlobalCommandPaletteState extends State<GlobalCommandPalette>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();

    // Auto-focus search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              color: Colors.black.withOpacity(0.7),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Center(
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: _buildCommandPalette(context),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCommandPalette(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
        maxWidth: 400.w,
      ),
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF101827),
        borderRadius: BorderRadius.circular(32.r),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.8),
            blurRadius: 64,
            offset: const Offset(0, 32),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Search Input
          _buildSearchInput(),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 8.w,
                right: 8.w,
                bottom: 32.h,
                top: 8.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Actions Section
                  _buildSectionHeader('QUICK ACTIONS'),
                  SizedBox(height: 4.h),
                  ..._buildQuickActions(),

                  SizedBox(height: 24.h),

                  // Recent Items Section
                  _buildSectionHeader('RECENT ITEMS'),
                  SizedBox(height: 4.h),
                  ..._buildRecentItems(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 8.h),
      child: Container(
        height: 56.h,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w300,
          ),
          decoration: InputDecoration(
            hintText: 'Search actions or notes...',
            hintStyle: TextStyle(
              color: const Color(0xFF64748B),
              fontSize: 18.sp,
              fontWeight: FontWeight.w300,
            ),
            prefixIcon: Container(
              padding: EdgeInsets.all(16.w),
              child: Icon(
                Icons.search,
                color: const Color(0xFF64748B),
                size: 24.sp,
              ),
            ),
            border: InputBorder.none,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            enabledBorder: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Text(
        title,
        style: TextStyle(
          color: const Color(0xFF64748B),
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.6,
        ),
      ),
    );
  }

  List<Widget> _buildQuickActions() {
    final actions = [
      _QuickAction(
        icon: Icons.add,
        title: 'New Note',
        subtitle: 'Create a blank canvas',
        colors: [
          const Color(0xFF164E63), // bg-cyan-900/30
          const Color(0xFFA5F3FC), // border and text color
        ],
        onTap: () {
          _closeAndNavigate(() {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NoteEditorPage()),
            );
          });
        },
      ),
      _QuickAction(
        icon: Icons.timer,
        title: 'Focus Session',
        subtitle: '25-minute Pomodoro',
        colors: [
          const Color(0xFF4C1D95), // bg-violet-900/30
          const Color(0xFFDDD6FE), // border and text color
        ],
        onTap: () {
          _closeAndNavigate(() {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FocusSessionScreen(),
              ),
            );
          });
        },
      ),
      _QuickAction(
        icon: Icons.notifications,
        title: 'Add Reminder',
        subtitle: 'Schedule a notification',
        colors: [
          const Color(0xFF92400E), // bg-yellow-900/30
          const Color(0xFFFEF08A), // border and text color
        ],
        onTap: () {
          _closeAndNavigate(() {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RemindersScreen()),
            );
          });
        },
      ),
      _QuickAction(
        icon: Icons.ios_share,
        title: 'Export Data',
        subtitle: 'Save as PDF or Markdown',
        colors: [
          const Color(0xFF064E3B), // bg-emerald-900/30
          const Color(0xFFBBF7D0), // border and text color
        ],
        onTap: () {
          _closeAndNavigate(() {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          });
        },
      ),
    ];

    return actions.map((action) => _buildActionItem(action)).toList();
  }

  List<Widget> _buildRecentItems() {
    final recentItems = [
      _RecentItem(
        icon: Icons.description,
        title: 'Project Alpha Brainstorm',
        subtitle: 'Edited 2h ago',
      ),
      _RecentItem(
        icon: Icons.checklist,
        title: 'Weekly Grocery List',
        subtitle: 'Edited Yesterday',
      ),
      _RecentItem(
        icon: Icons.auto_awesome,
        title: 'Daily Highlights',
        subtitle: 'Edited Today',
        onTap: () {
          _closeAndNavigate(() {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DailyHighlightSummaryScreen(),
              ),
            );
          });
        },
      ),
    ];

    return recentItems.map((item) => _buildRecentItemWidget(item)).toList();
  }

  Widget _buildActionItem(_QuickAction action) {
    return GestureDetector(
      onTap: action.onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            // Icon Container with Glow Effect
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: action.colors[0].withOpacity(0.3),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: action.colors[1].withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: action.colors[1].withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Icon(action.icon, color: action.colors[1], size: 20.sp),
            ),

            SizedBox(width: 16.w),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    action.subtitle,
                    style: TextStyle(
                      color: const Color(0xFF64748B),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentItemWidget(_RecentItem item) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Colors.white.withOpacity(0.05),
                  width: 1,
                ),
              ),
              child: Icon(
                item.icon,
                color: const Color(0xFF64748B),
                size: 20.sp,
              ),
            ),

            SizedBox(width: 16.w),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    item.subtitle,
                    style: TextStyle(
                      color: const Color(0xFF6B7280),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _closeAndNavigate(VoidCallback navigation) {
    _animationController.reverse().then((_) {
      Navigator.pop(context);
      navigation();
    });
  }
}

class _QuickAction {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> colors; // [background, accent]
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colors,
    required this.onTap,
  });
}

class _RecentItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _RecentItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });
}

// Helper function to show command palette
void showGlobalCommandPalette(BuildContext context) {
  showDialog(
    context: context,
    barrierColor: Colors.transparent,
    barrierDismissible: true,
    builder: (context) => const GlobalCommandPalette(),
  );
}
