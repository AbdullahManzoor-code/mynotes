import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_utils.dart' as app_date;
import '../../domain/entities/todo_item.dart';
import '../../domain/entities/note.dart';

/// To-Do Focus Screen
/// Dedicated screen for managing tasks without distractions
/// Allows adding, editing, completing, and reordering tasks
class TodoFocusScreen extends StatefulWidget {
  final Note note;
  final Function(List<TodoItem>)? onTodosChanged;

  const TodoFocusScreen({super.key, required this.note, this.onTodosChanged});

  @override
  State<TodoFocusScreen> createState() => _TodoFocusScreenState();
}

class _TodoFocusScreenState extends State<TodoFocusScreen> {
  late List<TodoItem> _todos;
  final TextEditingController _newTodoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _todos = List.from(widget.note.todos ?? []);
  }

  @override
  void dispose() {
    _newTodoController.dispose();
    super.dispose();
  }

  void _addTodo() {
    if (_newTodoController.text.trim().isEmpty) return;

    final newTodo = TodoItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: _newTodoController.text.trim(),
      isCompleted: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setState(() {
      _todos.add(newTodo);
      _newTodoController.clear();
    });

    _notifyChanges();
  }

  void _toggleTodo(int index) {
    setState(() {
      _todos[index] = _todos[index].toggleComplete();
    });
    _notifyChanges();
  }

  void _deleteTodo(int index) {
    setState(() {
      _todos.removeAt(index);
    });
    _notifyChanges();
  }

  void _editTodo(int index, String newText) {
    setState(() {
      _todos[index] = _todos[index].copyWith(text: newText);
    });
    _notifyChanges();
  }

  void _reorderTodos(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _todos.removeAt(oldIndex);
      _todos.insert(newIndex, item);
    });
    _notifyChanges();
  }

  void _notifyChanges() {
    widget.onTodosChanged?.call(_todos);
  }

  int get _completedCount => _todos.where((t) => t.isCompleted).length;
  int get _totalCount => _todos.length;
  double get _completionPercentage =>
      _totalCount == 0 ? 0 : _completedCount / _totalCount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Checklist'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress header
          _buildProgressHeader(),

          Divider(height: 1.h),

          // Todo list
          Expanded(
            child: _todos.isEmpty
                ? _buildEmptyState()
                : ReorderableListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: _todos.length,
                    onReorder: _reorderTodos,
                    itemBuilder: (context, index) {
                      return _buildTodoItem(_todos[index], index);
                    },
                  ),
          ),

          Divider(height: 1.h),

          // Add new todo
          _buildAddTodoField(),
        ],
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor.withOpacity(0.1),
            AppColors.primaryColor.withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            widget.note.title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 16.h),

          // Progress indicator
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '$_completedCount of $_totalCount completed',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const Spacer(),
                        Text(
                          '${(_completionPercentage * 100).toInt()}%',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor,
                              ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: LinearProgressIndicator(
                        value: _completionPercentage,
                        backgroundColor: AppColors.grey200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _completionPercentage == 1.0
                              ? AppColors.successColor
                              : AppColors.primaryColor,
                        ),
                        minHeight: 8.h,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (_completionPercentage == 1.0 && _totalCount > 0) ...[
            SizedBox(height: 12.h),
            Row(
              children: [
                const Icon(
                  Icons.celebration,
                  color: AppColors.successColor,
                  size: 20,
                ),
                SizedBox(width: 8.w),
                Text(
                  'All tasks completed!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.successColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTodoItem(TodoItem todo, int index) {
    return Dismissible(
      key: Key(todo.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 16.w),
        color: AppColors.errorColor,
        child: Icon(Icons.delete, color: AppColors.onError),
      ),
      onDismissed: (_) => _deleteTodo(index),
      child: Card(
        margin: EdgeInsets.only(bottom: 12.h),
        child: ListTile(
          leading: Checkbox(
            value: todo.isCompleted,
            onChanged: (_) => _toggleTodo(index),
            activeColor: AppColors.successColor,
          ),
          title: Text(
            todo.text,
            style: TextStyle(
              decoration: todo.isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              color: todo.isCompleted ? AppColors.grey600 : null,
            ),
          ),
          subtitle: todo.dueDate != null
              ? Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: app_date.AppDateUtils.isPast(todo.dueDate!)
                          ? AppColors.errorColor
                          : AppColors.infoColor,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      app_date.AppDateUtils.formatDate(todo.dueDate!),
                      style: TextStyle(
                        color: app_date.AppDateUtils.isPast(todo.dueDate!)
                            ? AppColors.errorColor
                            : null,
                      ),
                    ),
                  ],
                )
              : null,
          trailing: ReorderableDragStartListener(
            index: index,
            child: const Icon(Icons.drag_handle),
          ),
          onTap: () => _showEditDialog(index),
        ),
      ),
    );
  }

  Widget _buildAddTodoField() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.05),
            blurRadius: 10.w,
            offset: Offset(0, -2.h),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _newTodoController,
                decoration: const InputDecoration(
                  hintText: 'Add a new task...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (_) => _addTodo(),
              ),
            ),
            SizedBox(width: 12.w),
            FloatingActionButton(
              onPressed: _addTodo,
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.checklist_rounded, size: 80.sp, color: AppColors.grey300),
          SizedBox(height: 16.h),
          Text(
            'No tasks yet',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppColors.grey600),
          ),
          SizedBox(height: 8.h),
          Text(
            'Add your first task below',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.grey500),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(int index) {
    final todo = _todos[index];
    final controller = TextEditingController(text: todo.text);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Task'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Task description'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                _editTodo(index, controller.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}


