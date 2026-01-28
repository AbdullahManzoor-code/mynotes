import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../design_system/design_system.dart';
import '../pages/enhanced_note_editor_screen.dart';
import '../pages/focus_session_screen.dart';
import '../pages/backup_export_screen.dart';
import '../pages/daily_highlight_summary_screen.dart';
import 'quick_add_bottom_sheet.dart';

/// Command Palette Overlay
/// Quick command and search interface accessible via keyboard shortcut or gesture
class CommandPalette extends StatefulWidget {
  const CommandPalette({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      barrierDismissible: true,
      builder: (context) => const CommandPalette(),
    );
  }

  @override
  State<CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends State<CommandPalette> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  List<CommandAction> get _quickActions => [
    CommandAction(
      icon: Icons.add_rounded,
      title: 'New Note',
      subtitle: 'Create a blank canvas',
      color: Colors.cyan,
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const EnhancedNoteEditorScreen(),
          ),
        );
      },
    ),
    CommandAction(
      icon: Icons.timer_outlined,
      title: 'Focus Session',
      subtitle: '25-minute Pomodoro',
      color: Colors.purple,
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FocusSessionScreen()),
        );
      },
    ),
    CommandAction(
      icon: Icons.notifications_outlined,
      title: 'Add Reminder',
      subtitle: 'Schedule a notification',
      color: Colors.amber,
      onTap: () {
        Navigator.pop(context);
        QuickAddBottomSheet.show(context);
      },
    ),
    CommandAction(
      icon: Icons.auto_awesome,
      title: 'Daily Highlights',
      subtitle: 'Review your wins today',
      color: Colors.orange,
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DailyHighlightSummaryScreen(),
          ),
        );
      },
    ),
    CommandAction(
      icon: Icons.ios_share_outlined,
      title: 'Export Data',
      subtitle: 'Save as PDF or Markdown',
      color: Colors.green,
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BackupExportScreen()),
        );
      },
    ),
  ];

  final List<RecentItem> _recentItems = [
    RecentItem(
      icon: Icons.description_outlined,
      title: 'Project Alpha Brainstorm',
      subtitle: 'Edited 2h ago',
    ),
    RecentItem(
      icon: Icons.checklist_outlined,
      title: 'Weekly Grocery List',
      subtitle: 'Edited Yesterday',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Auto-focus search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 100.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            constraints: BoxConstraints(maxHeight: 600.h),
            decoration: BoxDecoration(
              color: const Color(0xFF101827).withOpacity(0.95),
              borderRadius: BorderRadius.circular(32.r),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
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
                _buildSearchHeader(),

                // Scrollable Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: 32.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Quick Actions Section
                        _buildSectionHeader('Quick Actions'),
                        _buildQuickActions(),

                        SizedBox(height: 24.h),

                        // Recent Items Section
                        _buildSectionHeader('Recent Items'),
                        _buildRecentItems(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 8.h),
      child: Container(
        height: 56.h,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            SizedBox(width: 16.w),
            Icon(
              Icons.search_rounded,
              color: Colors.white.withOpacity(0.4),
              size: 24.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocus,
                style: AppTypography.bodyLarge(
                  null,
                  Colors.white,
                  FontWeight.w300,
                ),
                decoration: InputDecoration(
                  hintText: 'Search actions or notes...',
                  hintStyle: AppTypography.bodyLarge(
                    null,
                    Colors.white.withOpacity(0.3),
                    FontWeight.w300,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(28.w, 12.h, 28.w, 12.h),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.captionSmall(null).copyWith(
          color: Colors.white.withOpacity(0.5),
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: _quickActions.map((action) {
        return GestureDetector(
          onTap: () {
            action.onTap();
            Navigator.pop(context);
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: action.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: action.color.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    action.icon,
                    color: action.color.withOpacity(0.8),
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action.title,
                        style: AppTypography.bodyMedium(
                          null,
                          Colors.white,
                          FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        action.subtitle,
                        style: AppTypography.captionSmall(
                          null,
                        ).copyWith(color: Colors.white.withOpacity(0.4)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentItems() {
    return Column(
      children: _recentItems.map((item) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            children: [
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
                  color: Colors.white.withOpacity(0.4),
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: AppTypography.bodyMedium(null, Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      item.subtitle,
                      style: AppTypography.captionSmall(
                        null,
                      ).copyWith(color: Colors.white.withOpacity(0.3)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class CommandAction {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  CommandAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}

class RecentItem {
  final IconData icon;
  final String title;
  final String subtitle;

  RecentItem({required this.icon, required this.title, required this.subtitle});
}
