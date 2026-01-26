import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/todo_item.dart';
import '../../domain/entities/note.dart';

/// Advanced Swipeable Todo Screen with Animations
class AdvancedTodoScreen extends StatefulWidget {
  final Note note;
  final Function(List<TodoItem>)? onTodosChanged;

  const AdvancedTodoScreen({Key? key, required this.note, this.onTodosChanged})
    : super(key: key);

  @override
  State<AdvancedTodoScreen> createState() => _AdvancedTodoScreenState();
}

class _AdvancedTodoScreenState extends State<AdvancedTodoScreen>
    with TickerProviderStateMixin {
  late List<TodoItem> _todos;
  final TextEditingController _newTodoController = TextEditingController();
  late AnimationController _addButtonController;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _todos = List.from(widget.note.todos ?? []);

    _addButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _updateProgress();
  }

  @override
  void dispose() {
    _newTodoController.dispose();
    _addButtonController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _updateProgress() {
    final progress = _completionPercentage;
    _progressController.animateTo(progress);
  }

  void _addTodo() {
    if (_newTodoController.text.trim().isEmpty) return;

    final newTodo = TodoItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: _newTodoController.text.trim(),
      isCompleted: false,
    );

    setState(() {
      _todos.add(newTodo);
      _newTodoController.clear();
    });

    _updateProgress();
    _notifyChanges();
  }

  void _toggleTodo(int index) {
    setState(() {
      _todos[index] = _todos[index].toggleComplete();
    });

    _updateProgress();
    _notifyChanges();
  }

  void _deleteTodo(int index) {
    setState(() {
      _todos.removeAt(index);
    });

    _updateProgress();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          // App Bar with Progress
          SliverAppBar(
            expandedHeight: 200.h,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryColor, AppColors.secondaryColor],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Task List',
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          widget.note.title,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        _buildProgressBar(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Todo List
          SliverPadding(
            padding: EdgeInsets.all(16.w),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return _buildTodoItem(_todos[index], index);
              }, childCount: _todos.length),
            ),
          ),

          // Empty State
          if (_todos.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 80.sp,
                      color: Colors.grey.withOpacity(0.3),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'No tasks yet',
                      style: TextStyle(fontSize: 18.sp, color: Colors.grey),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Add your first task below',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),

      // Bottom Input
      bottomNavigationBar: _buildBottomInput(isDark),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$_completedCount of $_totalCount completed',
              style: TextStyle(fontSize: 12.sp, color: Colors.white70),
            ),
            Text(
              '${(_completionPercentage * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        AnimatedBuilder(
          animation: _progressController,
          builder: (context, child) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: LinearProgressIndicator(
                value: _progressController.value,
                minHeight: 8.h,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTodoItem(TodoItem todo, int index) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Slidable(
        key: Key(todo.id),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
              onPressed: (_) => _deleteTodo(index),
              backgroundColor: AppColors.errorColor,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
              borderRadius: BorderRadius.circular(12.r),
            ),
          ],
        ),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (index * 50)),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _toggleTodo(index),
                borderRadius: BorderRadius.circular(12.r),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      // Checkbox
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 24.w,
                        height: 24.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: todo.isCompleted
                              ? AppColors.successColor
                              : Colors.transparent,
                          border: Border.all(
                            color: todo.isCompleted
                                ? AppColors.successColor
                                : Colors.grey.shade400,
                            width: 2,
                          ),
                        ),
                        child: todo.isCompleted
                            ? Icon(
                                Icons.check,
                                size: 16.sp,
                                color: Colors.white,
                              )
                            : null,
                      ),

                      SizedBox(width: 12.w),

                      // Text
                      Expanded(
                        child: Text(
                          todo.text,
                          style: TextStyle(
                            fontSize: 16.sp,
                            decoration: todo.isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            color: todo.isCompleted
                                ? Colors.grey.shade400
                                : Colors.black87,
                          ),
                        ),
                      ),

                      // Drag Handle
                      Icon(Icons.drag_indicator, color: Colors.grey.shade300),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomInput(bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkBackground
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(25.r),
                ),
                child: TextField(
                  controller: _newTodoController,
                  decoration: InputDecoration(
                    hintText: 'Add new task...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                  ),
                  onSubmitted: (_) => _addTodo(),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            FloatingActionButton(
              onPressed: _addTodo,
              mini: true,
              backgroundColor: AppColors.primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
