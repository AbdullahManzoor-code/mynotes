import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design_system/design_system.dart';
import '../../domain/entities/todo_item.dart';
import '../../core/routes/app_routes.dart';
import '../../injection_container.dart' show getIt;

/// Todo Card Widget with completion animations (TD-002, TD-003, TD-004)
/// Features: checkbox toggle, strikethrough animation, swipe to delete
class TodoCardWidget extends StatefulWidget {
  final TodoItem todo;
  final Function(TodoItem) onToggleComplete;
  final Function(TodoItem) onEdit;
  final Function(TodoItem) onDelete;
  final Function(TodoItem)? onStartFocus;
  final bool showCategory;
  final bool isCompact;
  final bool showFocusButton;

  const TodoCardWidget({
    super.key,
    required this.todo,
    required this.onToggleComplete,
    required this.onEdit,
    required this.onDelete,
    this.onStartFocus,
    this.showCategory = true,
    this.isCompact = false,
    this.showFocusButton = true,
  });

  @override
  State<TodoCardWidget> createState() => _TodoCardWidgetState();
}

class _TodoCardWidgetState extends State<TodoCardWidget>
    with TickerProviderStateMixin {
  late AnimationController _checkboxController;
  late AnimationController _strikethroughController;
  late AnimationController _scaleController;
  late Animation<double> _checkboxAnimation;
  late Animation<double> _strikethroughAnimation;
  late Animation<double> _scaleAnimation;

  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();

    _checkboxController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _strikethroughController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _checkboxAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkboxController, curve: Curves.elasticOut),
    );

    _strikethroughAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _strikethroughController,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    // Initialize animation state based on todo completion
    if (widget.todo.isCompleted) {
      _checkboxController.value = 1.0;
      _strikethroughController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _checkboxController.dispose();
    _strikethroughController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _toggleComplete() async {
    if (_isCompleting) return;

    setState(() => _isCompleting = true);

    HapticFeedback.mediumImpact();

    if (widget.todo.isCompleted) {
      // Uncompleting
      _strikethroughController.reverse();
      await Future.delayed(const Duration(milliseconds: 200));
      _checkboxController.reverse();
    } else {
      // Completing
      _checkboxController.forward();
      await Future.delayed(const Duration(milliseconds: 100));
      _strikethroughController.forward();
    }

    widget.onToggleComplete(widget.todo);
    setState(() => _isCompleting = false);
  }

  void _onTap() {
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });
    widget.onEdit(widget.todo);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(scale: _scaleAnimation.value, child: child);
      },
      child: Dismissible(
        key: Key(widget.todo.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.delete, color: Colors.white, size: 24),
        ),
        confirmDismiss: (direction) async {
          // Show 3-second undo snackbar (TD-004)
          getIt<GlobalUiService>().showInfo(
            'Todo deleted: ${widget.todo.text}',
            // action: SnackBarAction(
            //   label: 'Undo',
            //   onPressed: () {
            //     // Undo deletion - handled by parent
            //   },
            // ),
          );
          return true;
        },
        onDismissed: (direction) {
          widget.onDelete(widget.todo);
        },
        child: GestureDetector(
          onTap: _onTap,
          child: Container(
            margin: EdgeInsets.only(bottom: widget.isCompact ? 8 : 12),
            padding: EdgeInsets.all(widget.isCompact ? 12 : 16),
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.border(context).withOpacity(0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Checkbox with animation
                _buildAnimatedCheckbox(),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Todo text with strikethrough animation
                      _buildAnimatedText(),

                      if (!widget.isCompact) ...[
                        const SizedBox(height: 8),
                        _buildMetadata(),
                      ],
                    ],
                  ),
                ),

                // Priority indicator
                _buildPriorityIndicator(),

                // Focus button (only for incomplete tasks)
                if (widget.showFocusButton && !widget.todo.isCompleted) ...[
                  const SizedBox(width: 8),
                  _buildFocusButton(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedCheckbox() {
    return GestureDetector(
      onTap: _toggleComplete,
      child: AnimatedBuilder(
        animation: _checkboxAnimation,
        builder: (context, child) {
          return Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _checkboxAnimation.value > 0.5
                  ? AppColors.primary
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _checkboxAnimation.value > 0.5
                    ? AppColors.primary
                    : AppColors.border(context),
                width: 2,
              ),
            ),
            child: _checkboxAnimation.value > 0.5
                ? Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          );
        },
      ),
    );
  }

  Widget _buildAnimatedText() {
    return AnimatedBuilder(
      animation: _strikethroughAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            Text(
              widget.todo.text,
              style: AppTypography.bodyMedium(
                context,
                widget.todo.isCompleted
                    ? AppColors.textSecondary(context).withOpacity(0.6)
                    : AppColors.textPrimary(context),
                FontWeight.w500,
              ),
              maxLines: widget.isCompact ? 1 : 3,
              overflow: TextOverflow.ellipsis,
            ),
            // Strikethrough line
            if (_strikethroughAnimation.value > 0)
              Positioned.fill(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: 1,
                    width:
                        MediaQuery.of(context).size.width *
                        0.6 *
                        _strikethroughAnimation.value,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildMetadata() {
    return Row(
      children: [
        // Category
        if (widget.showCategory) ...[
          Icon(
            _getCategoryIcon(),
            size: 14,
            color: AppColors.textSecondary(context),
          ),
          const SizedBox(width: 4),
          Text(
            widget.todo.category.displayName,
            style: AppTypography.caption(
              context,
              AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(width: 12),
        ],

        // Due date
        if (widget.todo.dueDate != null) ...[
          Icon(Icons.schedule, size: 14, color: _getDueDateColor()),
          const SizedBox(width: 4),
          Text(
            _formatDueDate(widget.todo.dueDate!),
            style: AppTypography.caption(context, _getDueDateColor()),
          ),
        ],

        const Spacer(),

        // Completion timestamp
        if (widget.todo.isCompleted && widget.todo.completedAt != null) ...[
          Icon(Icons.check_circle_outline, size: 14, color: Colors.green),
          const SizedBox(width: 4),
          Text(
            _formatCompletionTime(widget.todo.completedAt!),
            style: AppTypography.caption(context, Colors.green),
          ),
        ],
      ],
    );
  }

  Widget _buildPriorityIndicator() {
    final color = _getPriorityColor(widget.todo.priority);
    return Container(
      width: 4,
      height: widget.isCompact ? 32 : 40,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildFocusButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (widget.onStartFocus != null) {
          widget.onStartFocus!(widget.todo);
        } else {
          // Navigate to focus session with todo context
          Navigator.pushNamed(
            context,
            AppRoutes.focusSession,
            arguments: {
              'todoId': widget.todo.id,
              'todoTitle': widget.todo.text,
            },
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.timer_outlined,
          size: 18,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }

  IconData _getCategoryIcon() {
    switch (widget.todo.category) {
      case TodoCategory.personal:
        return Icons.person;
      case TodoCategory.work:
        return Icons.work;
      case TodoCategory.shopping:
        return Icons.shopping_cart;
      case TodoCategory.health:
        return Icons.health_and_safety;
      case TodoCategory.finance:
        return Icons.attach_money;
      case TodoCategory.education:
        return Icons.school;
      case TodoCategory.home:
        return Icons.home;
      case TodoCategory.other:
        return Icons.more_horiz;
    }
  }

  Color _getPriorityColor(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.low:
        return Colors.green;
      case TodoPriority.medium:
        return Colors.yellow[700]!;
      case TodoPriority.high:
        return Colors.orange;
      case TodoPriority.urgent:
        return Colors.red;
    }
  }

  Color _getDueDateColor() {
    if (widget.todo.dueDate == null) return AppColors.textSecondary(context);

    final now = DateTime.now();
    final due = widget.todo.dueDate!;
    final difference = due.difference(now).inHours;

    if (difference < 0) return Colors.red; // Overdue
    if (difference < 24) return Colors.orange; // Due soon
    return AppColors.textSecondary(context); // Normal
  }

  String _formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);

    if (dueDay.isAtSameMomentAs(today)) {
      return 'Today ${dueDate.hour.toString().padLeft(2, '0')}:${dueDate.minute.toString().padLeft(2, '0')}';
    } else if (dueDay.isAtSameMomentAs(tomorrow)) {
      return 'Tomorrow ${dueDate.hour.toString().padLeft(2, '0')}:${dueDate.minute.toString().padLeft(2, '0')}';
    } else if (dueDate.isBefore(now)) {
      return 'Overdue';
    } else {
      return '${dueDate.day}/${dueDate.month} ${dueDate.hour.toString().padLeft(2, '0')}:${dueDate.minute.toString().padLeft(2, '0')}';
    }
  }

  String _formatCompletionTime(DateTime completedAt) {
    final now = DateTime.now();
    final difference = now.difference(completedAt).inMinutes;

    if (difference < 1) return 'Just now';
    if (difference < 60) return '${difference}m ago';
    if (difference < 1440) return '${(difference / 60).round()}h ago';
    return '${(difference / 1440).round()}d ago';
  }
}
