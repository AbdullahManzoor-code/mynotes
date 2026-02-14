import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mynotes/core/routes/app_routes.dart' show AppRoutes;
import 'package:mynotes/presentation/bloc/params/todo_params.dart';
import 'package:mynotes/presentation/bloc/todos/todos_bloc.dart'
    show
        TodosBloc,
        SortTodos,
        TodosLoaded,
        TodosState,
        FilterTodos,
        SearchTodos,
        TodosError,
        TodosLoading,
        LoadTodos,
        UndoDeleteTodo,
        DeleteTodo,
        AddTodo,
        ToggleFilters,
        ToggleTodo,
        UpdateTodo;
import '../../domain/entities/todo_item.dart'
    show TodoItem, TodoFilter, TodoSortOption, TodoStats;
import '../widgets/todo_card_widget.dart';
import '../widgets/create_todo_bottom_sheet.dart';
import '../design_system/design_system.dart';
import '../../injection_container.dart' show getIt;

class TodosScreen extends StatelessWidget {
  const TodosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodosBloc, TodosState>(
      builder: (context, state) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: AppColors.background(context),
          appBar: _buildPremiumAppBar(context, state),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withOpacity(0.05),
                  AppColors.background(context),
                ],
              ),
            ),
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top + 60.h),
                if (state is TodosLoaded && state.showFilters)
                  AppAnimations.slideIn(
                    // direction: Axis.vertical,
                    // offset: -20,
                    child: _buildFilterChips(context, state),
                  ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  child: _buildSearchBar(context, state),
                ),
                if (state is TodosLoaded && state.stats.total > 0)
                  AppAnimations.fadeIn(
                    child: _buildStatsBar(context, state.stats),
                  ),
                Expanded(child: _buildTodosContent(context, state)),
              ],
            ),
          ),
          floatingActionButton: _buildPremiumFAB(context),
        );
      },
    );
  }

  PreferredSizeWidget _buildPremiumAppBar(
    BuildContext context,
    TodosState state,
  ) {
    return AppBar(
      title: Text(
        'Action Center',
        style: AppTypography.heading2(context).copyWith(
          fontSize: 22.sp,
          letterSpacing: -0.5,
          fontWeight: FontWeight.w800,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      actions: [
        IconButton(
          icon: Icon(
            (state is TodosLoaded && state.showFilters)
                ? Icons.filter_list_rounded
                : Icons.filter_list_off_rounded,
            color: AppColors.primary,
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            context.read<TodosBloc>().add(ToggleFilters());
          },
        ),
        if (state is TodosLoaded)
          IconButton(
            icon: Icon(Icons.sort_rounded, color: AppColors.primary),
            onPressed: () {
              HapticFeedback.lightImpact();
              _showSortOptions(context, state);
            },
          ),
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildPremiumFAB(BuildContext context) {
    return AppAnimations.slideIn(
      // direction: Axis.vertical,
      // offset: 40,
      child: FloatingActionButton.extended(
        heroTag: 'todos_fixed_fab',
        onPressed: () {
          HapticFeedback.mediumImpact();
          _showCreateTodo(context);
        },
        backgroundColor: AppColors.primary,
        elevation: 4,
        highlightElevation: 0,
        label: Text(
          'New Task',
          style: AppTypography.buttonMedium(
            context,
            Colors.white,
          ).copyWith(fontWeight: FontWeight.w700),
        ),
        icon: const Icon(Icons.add_task_rounded, color: Colors.white),
      ),
    );
  }

  void _showCreateTodo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => CreateTodoBottomSheet(
        onTodoCreated: (todo) {
          final params = TodoParams.fromTodoItem(todo);
          context.read<TodosBloc>().add(AddTodo(params));
          Navigator.pop(sheetContext);
        },
      ),
    );
  }

  void _showSortOptions(BuildContext context, TodosLoaded state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassContainer(
        padding: EdgeInsets.all(24.r),
        // borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        blur: 20,
        // gradient: LinearGradient(
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        //   colors: [
        //     AppColors.surface(context).withOpacity(0.9),
        //     AppColors.surface(context).withOpacity(0.8),
        //   ],
        // ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary(context).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Sort Actions',
              style: AppTypography.heading2(
                context,
              ).copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5),
            ),
            SizedBox(height: 8.h),
            Text(
              'Organize your workflow',
              style: AppTypography.caption(
                context,
              ).copyWith(color: AppColors.textSecondary(context)),
            ),
            SizedBox(height: 24.h),
            ...TodoSortOption.values.map((option) {
              final isSelected = state.currentSort == option;
              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: GlassContainer(
                  borderRadius: 16.r,
                  blur: 5,
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.1)
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.3)
                        : Colors.transparent,
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.2)
                            : AppColors.surface(context).withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getSortIcon(option),
                        size: 20.sp,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary(context),
                      ),
                    ),
                    title: Text(
                      _getSortLabel(option),
                      style: AppTypography.bodyMedium(context).copyWith(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary(context),
                        fontWeight: isSelected
                            ? FontWeight.w800
                            : FontWeight.w500,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            state.sortAscending
                                ? Icons.arrow_upward_rounded
                                : Icons.arrow_downward_rounded,
                            color: AppColors.primary,
                            size: 20.sp,
                          )
                        : null,
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      final ascending = isSelected
                          ? !state.sortAscending
                          : true;
                      context.read<TodosBloc>().add(
                        SortTodos(option, ascending: ascending),
                      );
                      Navigator.pop(context);
                    },
                  ),
                ),
              );
            }),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  IconData _getSortIcon(TodoSortOption option) {
    switch (option) {
      case TodoSortOption.dueDate:
        return Icons.schedule;
      case TodoSortOption.priority:
        return Icons.priority_high;
      case TodoSortOption.category:
        return Icons.category;
      case TodoSortOption.createdDate:
        return Icons.access_time;
      case TodoSortOption.alphabetical:
        return Icons.sort_by_alpha;
    }
  }

  String _getSortLabel(TodoSortOption option) {
    switch (option) {
      case TodoSortOption.dueDate:
        return 'Due Date';
      case TodoSortOption.priority:
        return 'Priority';
      case TodoSortOption.category:
        return 'Category';
      case TodoSortOption.createdDate:
        return 'Date Created';
      case TodoSortOption.alphabetical:
        return 'Alphabetical';
    }
  }

  Widget _buildFilterChips(BuildContext context, TodosLoaded state) {
    return Container(
      height: 54.h,
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        physics: const BouncingScrollPhysics(),
        children: TodoFilter.values.map((filter) {
          final isSelected = state.currentFilter == filter;
          return Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: FilterChip(
                label: Text(_getFilterLabel(filter)),
                selected: isSelected,
                onSelected: (_) {
                  HapticFeedback.lightImpact();
                  context.read<TodosBloc>().add(FilterTodos(filter));
                },
                backgroundColor: AppColors.surface(context).withOpacity(0.3),
                selectedColor: AppColors.primary.withOpacity(0.2),
                checkmarkColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.4)
                        : Colors.transparent,
                  ),
                ),
                labelStyle: AppTypography.caption(context).copyWith(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary(context),
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getFilterLabel(TodoFilter filter) {
    switch (filter) {
      case TodoFilter.all:
        return 'All Tasks';
      case TodoFilter.active:
        return 'Active';
      case TodoFilter.completed:
        return 'Done';
      case TodoFilter.overdue:
        return 'Overdue';
      case TodoFilter.today:
        return 'Today';
      case TodoFilter.thisWeek:
        return 'Weekly';
    }
  }

  Widget _buildSearchBar(BuildContext context, TodosState state) {
    final query = state is TodosLoaded ? state.searchQuery : '';
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
      child: GlassContainer(
        borderRadius: 16.r,
        blur: 15,
        color: AppColors.surface(context).withOpacity(0.5),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
        child: TextField(
          onChanged: (value) =>
              context.read<TodosBloc>().add(SearchTodos(value)),
          style: AppTypography.bodyMedium(context),
          decoration: InputDecoration(
            hintText: 'Search actions...',
            hintStyle: AppTypography.bodyMedium(context).copyWith(
              color: AppColors.textSecondary(context).withOpacity(0.5),
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppColors.primary,
              size: 22.sp,
            ),
            suffixIcon: query.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: AppColors.textSecondary(context),
                      size: 20.sp,
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      context.read<TodosBloc>().add(SearchTodos(''));
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsBar(BuildContext context, TodoStats stats) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: GlassContainer(
        padding: EdgeInsets.all(20.r),
        borderRadius: 24.r,
        blur: 10,
        // gradient: LinearGradient(
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        //   colors: [
        //     AppColors.primary.withOpacity(0.15),
        //     AppColors.primary.withOpacity(0.05),
        //   ],
        // ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Productivity',
                      style: AppTypography.caption(context).copyWith(
                        color: AppColors.textSecondary(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${stats.completed} of ${stats.total} completed',
                      style: AppTypography.heading3(
                        context,
                      ).copyWith(fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '${(stats.completed * 100).toInt()}%',
                    style: AppTypography.caption(context).copyWith(
                      color: AppColors.accentGreen,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: LinearProgressIndicator(
                value: stats.total == 0 ? 0 : stats.completed / stats.total,
                minHeight: 8.h,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.accentGreen,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                _buildStatBadge(
                  context,
                  '${stats.today}',
                  'Due Today',
                  AppColors.accentBlue,
                ),
                SizedBox(width: 8.w),
                _buildStatBadge(
                  context,
                  '${stats.overdue}',
                  'Overdue',
                  AppColors.accentRed,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge(
    BuildContext context,
    String count,
    String label,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: AppTypography.bodyLarge(
                context,
              ).copyWith(color: color, fontWeight: FontWeight.w900),
            ),
            Text(
              label,
              style: AppTypography.captionSmall(context).copyWith(
                color: color.withOpacity(0.8),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    Color color,
  ) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: AppTypography.heading3(context, color)),
          Text(
            label,
            style: AppTypography.bodyMedium(
              context,
            ).copyWith(color: AppColors.textSecondary(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.textSecondary(context).withOpacity(0.2),
    );
  }

  Widget _buildTodosContent(BuildContext context, TodosState state) {
    if (state is TodosLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is TodosError) {
      return _buildErrorState(context, state.message);
    }
    if (state is TodosLoaded) {
      if (state.filteredTodos.isEmpty) {
        return _buildEmptyState(context, state);
      }
      return _buildSectionedList(context, state);
    }
    return const SizedBox.shrink();
  }

  Widget _buildSectionedList(BuildContext context, TodosLoaded state) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    final overdue = state.filteredTodos
        .where(
          (t) =>
              !t.isCompleted && t.dueDate != null && t.dueDate!.isBefore(today),
        )
        .toList();

    final todayTasks = state.filteredTodos
        .where(
          (t) =>
              !t.isCompleted &&
              t.dueDate != null &&
              t.dueDate!.isAfter(today.subtract(const Duration(seconds: 1))) &&
              t.dueDate!.isBefore(tomorrow),
        )
        .toList();

    final upcoming = state.filteredTodos
        .where(
          (t) =>
              !t.isCompleted &&
              t.dueDate != null &&
              t.dueDate!.isAfter(tomorrow.subtract(const Duration(seconds: 1))),
        )
        .toList();

    final anytime = state.filteredTodos
        .where((t) => !t.isCompleted && t.dueDate == null)
        .toList();

    final completed = state.filteredTodos.where((t) => t.isCompleted).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (overdue.isNotEmpty) ...[
          _buildSectionHeader(context, 'Overdue', AppColors.errorColor),
          ...overdue.map((t) => _buildTodoCard(context, t)),
        ],
        if (todayTasks.isNotEmpty) ...[
          _buildSectionHeader(context, 'Today', AppColors.primaryColor),
          ...todayTasks.map((t) => _buildTodoCard(context, t)),
        ],
        if (upcoming.isNotEmpty) ...[
          _buildSectionHeader(context, 'Upcoming', AppColors.accentPurple),
          ...upcoming.map((t) => _buildTodoCard(context, t)),
        ],
        if (anytime.isNotEmpty) ...[
          _buildSectionHeader(
            context,
            'Anytime',
            AppColors.textSecondary(context),
          ),
          ...anytime.map((t) => _buildTodoCard(context, t)),
        ],
        if (completed.isNotEmpty) ...[
          ExpansionTile(
            title: _buildSectionHeader(
              context,
              'Completed',
              AppColors.successGreen,
              isExpansion: true,
            ),
            children: completed.map((t) => _buildTodoCard(context, t)).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    Color color, {
    bool isExpansion = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: 24.h, bottom: 12.h, left: 4.w),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.h,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 8.r,
                  spreadRadius: 1.r,
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            title.toUpperCase(),
            style: AppTypography.caption(context).copyWith(
              color: color,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Container(
              height: 1.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.3), color.withOpacity(0.0)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoCard(BuildContext context, TodoItem todo) {
    return TodoCardWidget(
      todo: todo,
      onEdit: (t) => _onEditTodo(context, t),
      onToggleComplete: (t) =>
          context.read<TodosBloc>().add(ToggleTodo(TodoParams.fromTodoItem(t))),
      onDelete: (t) => _deleteTodoWithUndo(context, t),
      onStartFocus: (t) {
        HapticFeedback.heavyImpact();
        Navigator.pushNamed(
          context,
          AppRoutes.focusSession,
          arguments: {'todoId': t.id, 'todoTitle': t.text},
        );
      },
    );
  }

  void _onEditTodo(BuildContext context, TodoItem todo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => CreateTodoBottomSheet(
        onTodoCreated: (editedTodo) {
          final params = TodoParams.fromTodoItem(editedTodo);
          context.read<TodosBloc>().add(UpdateTodo(params));
          Navigator.pop(sheetContext);
        },
        editTodo: todo,
      ),
    );
  }

  void _deleteTodoWithUndo(BuildContext context, TodoItem todo) {
    context.read<TodosBloc>().add(DeleteTodo(todo.id));
    getIt<GlobalUiService>().showInfo(
      'Todo "${todo.text}" deleted',
      // action: SnackBarAction(
      // label: 'UNDO',
      // onPressed: () => context.read<TodosBloc>().add(UndoDeleteTodo(todo)),
      // ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: GlassContainer(
        margin: EdgeInsets.all(32.r),
        padding: EdgeInsets.all(32.r),
        borderRadius: 32.r,
        blur: 10,
        color: AppColors.surface(context).withOpacity(0.5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: AppColors.errorColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                size: 48.sp,
                color: AppColors.errorColor,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Workspace Sync Issue',
              style: AppTypography.heading3(
                context,
              ).copyWith(fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium(
                context,
              ).copyWith(color: AppColors.textSecondary(context)),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                context.read<TodosBloc>().add(LoadTodos());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              child: const Text('Reload Workspace'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, TodosLoaded state) {
    final isSearching =
        state.searchQuery.isNotEmpty || state.currentFilter != TodoFilter.all;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120.w,
            height: 120.h,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSearching
                  ? Icons.search_off_rounded
                  : Icons.auto_awesome_rounded,
              size: 56.sp,
              color: AppColors.primary.withOpacity(0.4),
            ),
          ),
          SizedBox(height: 32.h),
          Text(
            isSearching ? 'No match found' : 'All clear for today',
            style: AppTypography.heading2(context).copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary(context),
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 48.w),
            child: Text(
              isSearching
                  ? 'Try adjusting your filters or search terms'
                  : 'Your roadmap is clear. Time to innovate!',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium(
                context,
              ).copyWith(color: AppColors.textSecondary(context)),
            ),
          ),
          if (isSearching) ...[
            SizedBox(height: 24.h),
            TextButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                context.read<TodosBloc>().add(SearchTodos(''));
                context.read<TodosBloc>().add(FilterTodos(TodoFilter.all));
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reset Action Center'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                // textStyle: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
