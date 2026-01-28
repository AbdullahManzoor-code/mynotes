import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../design_system/design_system.dart';
import '../../domain/entities/note.dart';

/// Universal Item Card
/// Adaptive card that handles Notes, Todos, and Reminders in one unified widget
/// Detects content type and displays appropriate UI elements
class UniversalItemCard extends StatefulWidget {
  final UniversalItem item;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Function(bool)? onTodoToggle;
  final VoidCallback? onReminderTap;
  final bool showActions;
  final bool isSelected;

  const UniversalItemCard({
    Key? key,
    required this.item,
    this.onTap,
    this.onLongPress,
    this.onTodoToggle,
    this.onReminderTap,
    this.showActions = true,
    this.isSelected = false,
  }) : super(key: key);

  @override
  State<UniversalItemCard> createState() => _UniversalItemCardState();
}

class _UniversalItemCardState extends State<UniversalItemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) {
              _animationController.forward();
              HapticFeedback.lightImpact();
            },
            onTapUp: (_) {
              _animationController.reverse();
            },
            onTapCancel: () {
              _animationController.reverse();
            },
            onTap: widget.onTap,
            onLongPress: widget.onLongPress,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.darkCardBackground,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: _getBorderColor(),
                  width: _getBorderWidth(),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                  if (widget.isSelected)
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    SizedBox(height: 12.h),
                    _buildContent(),
                    if (_shouldShowMetadata()) ...[
                      SizedBox(height: 12.h),
                      _buildMetadata(),
                    ],
                    if (widget.showActions && _hasActions()) ...[
                      SizedBox(height: 12.h),
                      _buildActions(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Todo checkbox (if it's a todo)
        if (widget.item.isTodo) ...[
          GestureDetector(
            onTap: () => widget.onTodoToggle?.call(!widget.item.isCompleted),
            child: Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                color: widget.item.isCompleted
                    ? AppColors.primary
                    : Colors.transparent,
                border: Border.all(
                  color: widget.item.isCompleted
                      ? AppColors.primary
                      : Colors.grey.shade500,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: widget.item.isCompleted
                  ? Icon(Icons.check, color: Colors.white, size: 16.sp)
                  : null,
            ),
          ),
          SizedBox(width: 12.w),
        ],

        // Priority indicator
        if (widget.item.priority != null)
          Container(
            width: 4.w,
            height: 24.h,
            decoration: BoxDecoration(
              color: _getPriorityColor(widget.item.priority!),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

        if (widget.item.priority != null) SizedBox(width: 12.w),

        // Title
        Expanded(
          child: Text(
            widget.item.title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: widget.item.isCompleted
                  ? Colors.grey.shade500
                  : Colors.white,
              decoration: widget.item.isCompleted
                  ? TextDecoration.lineThrough
                  : null,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // Type indicators
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.item.hasVoiceNote)
              Container(
                padding: EdgeInsets.all(4.w),
                margin: EdgeInsets.only(left: 8.w),
                decoration: BoxDecoration(
                  color: AppColors.accentPurple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Icon(
                  Icons.graphic_eq,
                  color: AppColors.accentPurple,
                  size: 14.sp,
                ),
              ),

            if (widget.item.hasImages)
              Container(
                padding: EdgeInsets.all(4.w),
                margin: EdgeInsets.only(left: 8.w),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Icon(
                  Icons.image,
                  color: AppColors.accentGreen,
                  size: 14.sp,
                ),
              ),

            if (widget.item.reminderTime != null)
              Container(
                padding: EdgeInsets.all(4.w),
                margin: EdgeInsets.only(left: 8.w),
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Icon(
                  Icons.access_time,
                  color: AppColors.accentBlue,
                  size: 14.sp,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (widget.item.content.isEmpty) return const SizedBox.shrink();

    return Text(
      widget.item.content,
      style: TextStyle(
        fontSize: 14.sp,
        color: Colors.grey.shade300,
        height: 1.4,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildMetadata() {
    return Row(
      children: [
        // Category tag
        if (widget.item.category.isNotEmpty)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: _getCategoryColor(widget.item.category).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: _getCategoryColor(widget.item.category).withOpacity(0.3),
              ),
            ),
            child: Text(
              widget.item.category,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
                color: _getCategoryColor(widget.item.category),
              ),
            ),
          ),

        if (widget.item.category.isNotEmpty) SizedBox(width: 12.w),

        // Last modified
        Expanded(
          child: Text(
            _getTimeText(),
            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
          ),
        ),

        // Reminder time
        if (widget.item.reminderTime != null)
          GestureDetector(
            onTap: widget.onReminderTap ?? () {},
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: _isReminderOverdue()
                    ? Colors.red.withOpacity(0.2)
                    : AppColors.accentBlue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isReminderOverdue() ? Icons.warning : Icons.schedule,
                    color: _isReminderOverdue()
                        ? Colors.red
                        : AppColors.accentBlue,
                    size: 12.sp,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    _getReminderTimeText(),
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      color: _isReminderOverdue()
                          ? Colors.red
                          : AppColors.accentBlue,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        if (!widget.item.isTodo)
          _buildActionButton(
            icon: Icons.check_circle_outline,
            label: 'Mark as Todo',
            onTap: () => widget.onTodoToggle?.call(true),
          ),

        SizedBox(width: 12.w),

        if (widget.item.reminderTime == null)
          _buildActionButton(
            icon: Icons.alarm_add,
            label: 'Add Reminder',
            onTap: widget.onReminderTap ?? () {},
          ),

        const Spacer(),

        // Quick actions
        IconButton(
          onPressed: () {}, // TODO: Implement share
          icon: Icon(Icons.share, color: Colors.grey.shade500, size: 20.sp),
        ),

        IconButton(
          onPressed: () {}, // TODO: Implement archive
          icon: Icon(Icons.archive, color: Colors.grey.shade500, size: 20.sp),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primary, size: 14.sp),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  Color _getBorderColor() {
    if (widget.isSelected) return AppColors.primary;
    if (widget.item.priority == ItemPriority.high)
      return Colors.red.withOpacity(0.5);
    if (_isReminderOverdue()) return Colors.red.withOpacity(0.3);
    return Colors.white.withOpacity(0.1);
  }

  double _getBorderWidth() {
    if (widget.isSelected) return 2;
    if (widget.item.priority == ItemPriority.high) return 1.5;
    return 1;
  }

  Color _getPriorityColor(ItemPriority priority) {
    switch (priority) {
      case ItemPriority.high:
        return Colors.red;
      case ItemPriority.medium:
        return Colors.orange;
      case ItemPriority.low:
        return Colors.blue;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return AppColors.accentBlue;
      case 'personal':
        return AppColors.accentGreen;
      case 'health':
        return AppColors.accentPurple;
      case 'shopping':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  bool _isReminderOverdue() {
    if (widget.item.reminderTime == null) return false;
    return widget.item.reminderTime!.isBefore(DateTime.now());
  }

  bool _shouldShowMetadata() {
    return widget.item.category.isNotEmpty || widget.item.reminderTime != null;
  }

  bool _hasActions() {
    return !widget.item.isTodo || widget.item.reminderTime == null;
  }

  String _getTimeText() {
    final now = DateTime.now();
    final diff = now.difference(widget.item.updatedAt);

    if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String _getReminderTimeText() {
    if (widget.item.reminderTime == null) return '';

    final now = DateTime.now();
    final reminder = widget.item.reminderTime!;
    final diff = reminder.difference(now);

    if (diff.isNegative) {
      return 'Overdue';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h';
    } else {
      return '${diff.inMinutes}m';
    }
  }
}

// Universal Item Model - Unified data model
class UniversalItem {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isTodo;
  final bool isCompleted;
  final DateTime? reminderTime;
  final ItemPriority? priority;
  final String category;
  final bool hasVoiceNote;
  final bool hasImages;
  final List<String>? tags;

  UniversalItem({
    required this.id,
    required this.title,
    this.content = '',
    required this.createdAt,
    required this.updatedAt,
    this.isTodo = false,
    this.isCompleted = false,
    this.reminderTime,
    this.priority,
    this.category = '',
    this.hasVoiceNote = false,
    this.hasImages = false,
    this.tags,
  });

  // Factory constructors for different types
  factory UniversalItem.fromNote(Note note) {
    return UniversalItem(
      id: note.id,
      title: note.title,
      content: note.content,
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
      category: 'Note',
    );
  }

  factory UniversalItem.todo({
    required String id,
    required String title,
    String content = '',
    DateTime? createdAt,
    DateTime? updatedAt,
    bool isCompleted = false,
    DateTime? reminderTime,
    ItemPriority? priority,
    String category = 'Todo',
    bool hasVoiceNote = false,
  }) {
    return UniversalItem(
      id: id,
      title: title,
      content: content,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
      isTodo: true,
      isCompleted: isCompleted,
      reminderTime: reminderTime,
      priority: priority,
      category: category,
      hasVoiceNote: hasVoiceNote,
    );
  }

  factory UniversalItem.reminder({
    required String id,
    required String title,
    required DateTime reminderTime,
    String content = '',
    DateTime? createdAt,
    DateTime? updatedAt,
    ItemPriority? priority,
    String category = 'Reminder',
  }) {
    return UniversalItem(
      id: id,
      title: title,
      content: content,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
      reminderTime: reminderTime,
      priority: priority,
      category: category,
    );
  }

  // Utility methods
  bool get isNote => !isTodo && reminderTime == null;
  bool get isReminder => reminderTime != null;
  bool get isOverdue => isReminder && reminderTime!.isBefore(DateTime.now());

  UniversalItem copyWith({
    String? title,
    String? content,
    bool? isTodo,
    bool? isCompleted,
    DateTime? reminderTime,
    ItemPriority? priority,
    String? category,
    bool? hasVoiceNote,
    bool? hasImages,
  }) {
    return UniversalItem(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isTodo: isTodo ?? this.isTodo,
      isCompleted: isCompleted ?? this.isCompleted,
      reminderTime: reminderTime ?? this.reminderTime,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      hasVoiceNote: hasVoiceNote ?? this.hasVoiceNote,
      hasImages: hasImages ?? this.hasImages,
      tags: tags,
    );
  }
}

enum ItemPriority { high, medium, low }
