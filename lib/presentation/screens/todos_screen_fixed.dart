import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/presentation/bloc/params/todo_params.dart';
import 'package:mynotes/presentation/bloc/todos_bloc.dart'
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
          backgroundColor: AppColors.background(context),
          appBar: AppBar(
            title: Text(
              'My Todos',
              style: AppTypography.heading2(context, Colors.white),
            ),
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: Icon(
                  (state is TodosLoaded && state.showFilters)
                      ? Icons.filter_list
                      : Icons.filter_list_off,
                ),
                onPressed: () => context.read<TodosBloc>().add(ToggleFilters()),
              ),
              if (state is TodosLoaded)
                IconButton(
                  icon: const Icon(Icons.sort),
                  onPressed: () => _showSortOptions(context, state),
                ),
            ],
          ),
          body: Column(
            children: [
              if (state is TodosLoaded && state.showFilters)
                _buildFilterChips(context, state),
              _buildSearchBar(context, state),
              if (state is TodosLoaded && state.stats.total > 0)
                _buildStatsBar(context, state.stats),
              Expanded(child: _buildTodosContent(context, state)),
            ],
          ),
          floatingActionButton: AnimatedScale(
            scale: 1.0,
            duration: const Duration(milliseconds: 300),
            child: FloatingActionButton.extended(
              onPressed: () => _showCreateTodo(context),
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              label: const Text(
                'Add Todo',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              icon: const Icon(Icons.add),
            ),
          ),
        );
      },
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
      backgroundColor: AppColors.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sort by',
              style: AppTypography.heading3(context, AppColors.primaryColor),
            ),
            const SizedBox(height: 16),
            ...TodoSortOption.values.map((option) {
              final isSelected = state.currentSort == option;
              return ListTile(
                leading: Icon(
                  _getSortIcon(option),
                  color: isSelected
                      ? AppColors.primaryColor
                      : AppColors.textSecondary(context),
                ),
                title: Text(
                  _getSortLabel(option),
                  style: AppTypography.bodyLarge(context).copyWith(
                    color: isSelected
                        ? AppColors.primaryColor
                        : AppColors.textPrimary(context),
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                trailing: isSelected
                    ? Icon(
                        state.sortAscending
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        color: AppColors.primaryColor,
                        size: 20,
                      )
                    : null,
                onTap: () {
                  final ascending = isSelected ? !state.sortAscending : true;
                  context.read<TodosBloc>().add(
                    SortTodos(option, ascending: ascending),
                  );
                  Navigator.pop(context);
                },
              );
            }),
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
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: TodoFilter.values.map((filter) {
          final isSelected = state.currentFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(_getFilterLabel(filter)),
              selected: isSelected,
              onSelected: (_) {
                context.read<TodosBloc>().add(FilterTodos(filter));
              },
              backgroundColor: AppColors.surface(context),
              selectedColor: AppColors.primaryColor.withOpacity(0.2),
              checkmarkColor: AppColors.primaryColor,
              labelStyle: AppTypography.bodyMedium(context).copyWith(
                color: isSelected
                    ? AppColors.primaryColor
                    : AppColors.textPrimary(context),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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
        return 'All';
      case TodoFilter.active:
        return 'Active';
      case TodoFilter.completed:
        return 'Completed';
      case TodoFilter.overdue:
        return 'Overdue';
      case TodoFilter.today:
        return 'Today';
      case TodoFilter.thisWeek:
        return 'This Week';
    }
  }

  Widget _buildSearchBar(BuildContext context, TodosState state) {
    final query = state is TodosLoaded ? state.searchQuery : '';
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) => context.read<TodosBloc>().add(SearchTodos(value)),
        decoration: InputDecoration(
          hintText: 'Search todos...',
          hintStyle: AppTypography.bodyMedium(
            context,
          ).copyWith(color: AppColors.textSecondary(context)),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.textSecondary(context),
          ),
          suffixIcon: query.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: AppColors.textSecondary(context),
                  ),
                  onPressed: () =>
                      context.read<TodosBloc>().add(SearchTodos('')),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppColors.surface(context),
        ),
      ),
    );
  }

  Widget _buildStatsBar(BuildContext context, TodoStats stats) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary(context).withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatItem(
            context,
            '${stats.completed}/${stats.total}',
            'Completed',
            AppColors.primaryColor,
          ),
          _buildDivider(context),
          _buildStatItem(
            context,
            '${stats.overdue}',
            'Overdue',
            AppColors.errorColor,
          ),
          _buildDivider(context),
          _buildStatItem(
            context,
            '${stats.today}',
            'Due Today',
            AppColors.warningColor,
          ),
        ],
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
    final header = Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(title, style: AppTypography.heading3(context, color)),
        ],
      ),
    );
    return isExpansion ? header : header;
  }

  Widget _buildTodoCard(BuildContext context, TodoItem todo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TodoCardWidget(
        todo: todo,
        onEdit: (t) => _onEditTodo(context, t),
        onToggleComplete: (t) => context.read<TodosBloc>().add(
          ToggleTodo(TodoParams.fromTodoItem(t)),
        ),
        onDelete: (t) => _deleteTodoWithUndo(context, t),
      ),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.errorColor),
          const SizedBox(height: 16),
          Text(message, style: AppTypography.bodyMedium(context)),
          ElevatedButton(
            onPressed: () => context.read<TodosBloc>().add(LoadTodos()),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, TodosLoaded state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: AppColors.textSecondary(context).withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            state.searchQuery.isNotEmpty
                ? 'No todos match your search'
                : 'All caught up!',
            style: AppTypography.heading3(context),
          ),
          if (state.searchQuery.isNotEmpty ||
              state.currentFilter != TodoFilter.all)
            TextButton(
              onPressed: () {
                context.read<TodosBloc>().add(SearchTodos(''));
                context.read<TodosBloc>().add(FilterTodos(TodoFilter.all));
              },
              child: const Text('Clear Filters'),
            ),
        ],
      ),
    );
  }
}
