import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../design_system/design_system.dart';

/// Quick Add Confirmation Screen
/// Shows confirmation after creating a note/todo with options for quick actions
/// Based on quick_add_confirmation_flow template
class QuickAddConfirmationScreen extends StatefulWidget {
  final String noteId;
  final String title;
  final String type; // 'note', 'todo', 'reminder'

  const QuickAddConfirmationScreen({
    super.key,
    required this.noteId,
    required this.title,
    required this.type,
  });

  @override
  State<QuickAddConfirmationScreen> createState() =>
      _QuickAddConfirmationScreenState();
}

class _QuickAddConfirmationScreenState extends State<QuickAddConfirmationScreen>
    with TickerProviderStateMixin {
  late AnimationController _confirmationController;
  late AnimationController _actionsController;
  late Animation<double> _checkAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  Timer? _autoCloseTimer;

  @override
  void initState() {
    super.initState();
    AppLogger.i(
      'QuickAddConfirmationScreen: Notification created - type: ${widget.type}, title: ${widget.title}',
    );

    _confirmationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _actionsController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _confirmationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _confirmationController,
            curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
          ),
        );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _actionsController, curve: Curves.easeOut),
    );

    // Start animations
    _startConfirmationSequence();
  }

  @override
  void dispose() {
    AppLogger.i('QuickAddConfirmationScreen: Disposed');
    _autoCloseTimer?.cancel();
    _confirmationController.dispose();
    _actionsController.dispose();
    super.dispose();
  }

  void _startConfirmationSequence() async {
    await _confirmationController.forward();

    // Start actions animation
    _actionsController.forward();

    // Auto close after 3 seconds
    _autoCloseTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _closeScreen();
      }
    });
  }

  void _closeScreen() {
    AppLogger.i('QuickAddConfirmationScreen: Manual close');
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _openNoteEditor() {
    AppLogger.i('QuickAddConfirmationScreen: Opening note editor');
    _autoCloseTimer?.cancel();

    Navigator.pushReplacementNamed(
      context,
      '/notes/editor/enhanced',
      arguments: {'noteId': widget.noteId},
    );
  }

  void _addAnotherNote() {
    AppLogger.i('QuickAddConfirmationScreen: Add another note');
    _autoCloseTimer?.cancel();

    Navigator.pushReplacementNamed(context, '/quick-add');
  }

  void _setReminder() {
    AppLogger.i('QuickAddConfirmationScreen: Set reminder');
    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildReminderBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.darkBackground,
                  AppColors.darkBackground,
                ],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Close button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: GestureDetector(
                      onTap: _closeScreen,
                      child: Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildConfirmationIcon(),
                        SizedBox(height: 32.h),
                        _buildConfirmationText(),
                        SizedBox(height: 48.h),
                        _buildActionButtons(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationIcon() {
    return AnimatedBuilder(
      animation: _checkAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _checkAnimation.value,
          child: Container(
            width: 120.w,
            height: 120.w,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(60.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(_getIconForType(), color: Colors.white, size: 60.sp),
          ),
        );
      },
    );
  }

  IconData _getIconForType() {
    switch (widget.type) {
      case 'todo':
        return Icons.check;
      case 'reminder':
        return Icons.notifications;
      default:
        return Icons.note;
    }
  }

  Widget _buildConfirmationText() {
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        children: [
          Text(
            _getSuccessMessage(),
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 8.h),

          Container(
            constraints: BoxConstraints(maxWidth: 280.w),
            child: Text(
              '"${widget.title}"',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey.shade300,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _getSuccessMessage() {
    switch (widget.type) {
      case 'todo':
        return 'Todo Added!';
      case 'reminder':
        return 'Reminder Set!';
      default:
        return 'Note Created!';
    }
  }

  Widget _buildActionButtons() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // Primary action - Edit note
          GestureDetector(
            onTap: _openNoteEditor,
            child: Container(
              width: 280.w,
              height: 56.h,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(28.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit, color: Colors.white, size: 20.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'Edit Details',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // Secondary actions row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Add another button
              _buildSecondaryButton(
                icon: Icons.add,
                label: 'Add Another',
                onTap: _addAnotherNote,
              ),

              SizedBox(width: 24.w),

              // Set reminder button (only for notes/todos)
              if (widget.type != 'reminder')
                _buildSecondaryButton(
                  icon: Icons.notifications_none,
                  label: 'Set Reminder',
                  onTap: _setReminder,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.darkCardBackground,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: Colors.grey.shade800, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18.sp),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderBottomSheet() {
    return Container(
      height: 400.h,
      decoration: BoxDecoration(
        color: AppColors.darkCardBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.symmetric(vertical: 16.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade600,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Set Reminder',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),

                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // Quick reminder options
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              children: [
                _buildReminderOption('In 1 hour', const Duration(hours: 1)),
                _buildReminderOption('This evening (6 PM)', null),
                _buildReminderOption('Tomorrow morning (9 AM)', null),
                _buildReminderOption('Next week', const Duration(days: 7)),
                _buildReminderOption('Custom...', null),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderOption(String title, Duration? duration) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        HapticFeedback.lightImpact();

        // TODO: Implement reminder setting
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reminder set for $title'),
            backgroundColor: AppColors.primary,
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade800, width: 1),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(fontSize: 16.sp, color: Colors.white),
        ),
      ),
    );
  }
}
