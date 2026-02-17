import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mynotes/domain/entities/todo_item.dart';
import 'package:mynotes/presentation/design_system/design_system.dart'
    hide TodoCard;
import 'package:mynotes/presentation/widgets/todo/todo_card.dart';
import 'package:mynotes/core/extensions/extensions.dart';

/// Todos list builder component
/// Handles display of todos in lists with completed/incomplete sections
/// STATE MANAGEMENT:
/// - Receives todos data from parent/BLoC
/// - Fires callbacks for user actions
/// - No internal state management (pure composition)
class TodosList extends StatelessWidget {
  final List<TodoItem> activeTodos;
  final List<TodoItem> completedTodos;
  final bool isGridView;
  final ValueChanged<TodoItem> onTodoTap;
  final ValueChanged<String>? onTodoDelete; // Todo ID
  final ValueChanged<String>? onTodoComplete; // Todo ID
  final ValueChanged<String>? onTodoEdit; // Todo ID

  const TodosList({
    super.key,
    required this.activeTodos,
    required this.completedTodos,
    this.isGridView = false,
    required this.onTodoTap,
    this.onTodoDelete,
    this.onTodoComplete,
    this.onTodoEdit,
  });

  @override
  Widget build(BuildContext context) {
    if (activeTodos.isEmpty && completedTodos.isEmpty) {
      return _buildEmptyState(context);
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active todos section
          if (activeTodos.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
              child: Text(
                'Active (${activeTodos.length})',
                style: AppTypography.heading3(
                  context,
                ).copyWith(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
            ),
            _buildTodosList(context, activeTodos),
            SizedBox(height: 16.h),
          ],

          // Completed todos section
          if (completedTodos.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
              child: Text(
                'Completed (${completedTodos.length})',
                style: AppTypography.heading3(context).copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            _buildTodosList(context, completedTodos),
            SizedBox(height: 16.h),
          ],
        ],
      ),
    );
  }

  Widget _buildTodosList(BuildContext context, List<TodoItem> todos) {
    if (isGridView) {
      return MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 12.w,
        crossAxisSpacing: 12.w,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: todos.length,
        itemBuilder: (context, index) => _buildTodoCard(context, todos[index]),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: todos.length,
      itemBuilder: (context, index) => _buildTodoCard(context, todos[index]),
    );
  }

  Widget _buildTodoCard(BuildContext context, TodoItem todo) {
    return TodoCard(
      todo: todo,
      onTap: () => onTodoTap(todo),
      onLongPress: () {},
      onEdit: onTodoEdit != null ? () => onTodoEdit!(todo.id) : null,
      onDelete: onTodoDelete != null ? () => onTodoDelete!(todo.id) : null,
      onComplete: onTodoComplete != null
          ? () => onTodoComplete!(todo.id)
          : null,
      onUncomplete: onTodoComplete != null
          ? () => onTodoComplete!(todo.id)
          : null,
      enableActions: true,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.checklist_outlined,
            size: 80.r,
            color: context.theme.disabledColor,
          ),
          SizedBox(height: 16.h),
          Text(
            'No todos yet',
            style: AppTypography.heading2(
              context,
            ).copyWith(fontSize: 18.sp, color: context.theme.disabledColor),
          ),
          SizedBox(height: 8.h),
          Text(
            'Create your first todo to get started',
            style: AppTypography.body2(context).copyWith(
              fontSize: 14.sp,
              color: context.theme.disabledColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
