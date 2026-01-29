import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../widgets/todo_card_widget.dart';
import '../widgets/create_todo_bottom_sheet.dart';
import '../bloc/todos_bloc.dart';
import '../../core/services/todo_service.dart';
import '../design_system/design_system.dart';

class TodosScreen extends StatefulWidget {
  const TodosScreen({super.key});

  @override
  State<TodosScreen> createState() => _TodosScreenState();
}

class _TodosScreenState extends State<TodosScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _fabAnimationController;
  late AnimationController _filterAnimationController;
  late Animation<double> _fabAnimation;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fabAnimationController.dispose();
    _filterAnimationController.dispose();
    super.dispose();
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });

    if (_showFilters) {
      _filterAnimationController.forward();
    } else {
      _filterAnimationController.reverse();
    }
  }

  void _showCreateTodo() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateTodoBottomSheet(
        onTodoCreated: (todo) {
          context.read<TodosBloc>().add(AddTodo(todo));
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              _showFilters ? Icons.filter_list : Icons.filter_list_off,
            ),
            onPressed: _toggleFilters,
          ),
          BlocBuilder<TodosBloc, TodosState>(
            builder: (context, state) {
              if (state is TodosLoaded) {
                return IconButton(
                  icon: const Icon(Icons.sort),
                  onPressed: () => _showSortOptions(state),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<TodosBloc, TodosState>(
        builder: (context, state) {
          return Column(
            children: [
              if (_showFilters && state is TodosLoaded)
                _buildFilterChips(state),
              _buildSearchBar(),
              if (state is TodosLoaded && state.stats.total > 0)
                _buildStatsBar(state.stats),
              Expanded(child: _buildTodosList(state)),
            ],
          );
        },
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton.extended(
          onPressed: _showCreateTodo,
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
  }

  void _showSortOptions(TodosLoaded state) {
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
              style: AppTypography.heading3(context, AppColors.primaryColor,
              ),
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

  Widget _buildFilterChips(TodosLoaded state) {
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search todos...',
          hintStyle: AppTypography.bodyMedium(
            context,
          ).copyWith(color: AppColors.textSecondary(context)),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.textSecondary(context),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: AppColors.textSecondary(context),
                  ),
                  onPressed: () {
                    _searchController.clear();
                    context.read<TodosBloc>().add(SearchTodos(''));
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppColors.surface(context),
        ),
        onChanged: (query) {
          context.read<TodosBloc>().add(SearchTodos(query));
        },
      ),
    );
  }

  Widget _buildStatsBar(TodoStats stats) {
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${stats.completed}/${stats.total}',
                  style: AppTypography.heading3(context, AppColors.primaryColor,
                  ),
                ),
                Text(
                  'Completed',
                  style: AppTypography.bodyMedium(
                    context,
                  ).copyWith(color: AppColors.textSecondary(context)),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.textSecondary(context).withOpacity(0.2),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  stats.overdue.toString(),
                  style: AppTypography.heading3(context, AppColors.errorColor,
                  ),
                ),
                Text(
                  'Overdue',
                  style: AppTypography.bodyMedium(
                    context,
                  ).copyWith(color: AppColors.textSecondary(context)),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.textSecondary(context).withOpacity(0.2),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  stats.dueToday.toString(),
                  style: AppTypography.heading3(context, AppColors.warningColor,
                  ),
                ),
                Text(
                  'Due Today',
                  style: AppTypography.bodyMedium(
                    context,
                  ).copyWith(color: AppColors.textSecondary(context)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodosList(TodosState state) {
    if (state is TodosLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is TodosError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.errorColor.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading todos',
              style: AppTypography.heading3(context, AppColors.errorColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              style: AppTypography.bodyMedium(
                context,
              ).copyWith(color: AppColors.textSecondary(context)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<TodosBloc>().add(LoadTodos());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state is TodosLoaded) {
      if (state.filteredTodos.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                state.searchQuery.isNotEmpty
                    ? Icons.search_off
                    : Icons.check_circle_outline,
                size: 64,
                color: AppColors.textSecondary(context).withOpacity(0.4),
              ),
              const SizedBox(height: 16),
              Text(
                state.searchQuery.isNotEmpty
                    ? 'No todos match your search'
                    : state.currentFilter == TodoFilter.all
                    ? 'No todos yet'
                    : 'No ${_getFilterLabel(state.currentFilter).toLowerCase()} todos',
                style: AppTypography.heading3(
                  context,
                ).copyWith(color: AppColors.textSecondary(context)),
              ),
              const SizedBox(height: 8),
              Text(
                state.searchQuery.isNotEmpty
                    ? 'Try adjusting your search terms'
                    : state.currentFilter == TodoFilter.all
                    ? 'Tap the + button to create your first todo'
                    : 'Try changing the filter or create a new todo',
                style: AppTypography.bodyMedium(context).copyWith(
                  color: AppColors.textSecondary(context).withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),
              if (state.searchQuery.isNotEmpty ||
                  state.currentFilter != TodoFilter.all) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    _searchController.clear();
                    context.read<TodosBloc>().add(SearchTodos(''));
                    context.read<TodosBloc>().add(FilterTodos(TodoFilter.all));
                  },
                  child: const Text('Clear filters'),
                ),
              ],
            ],
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.all(16),
        child: AnimationLimiter(
          child: ListView.builder(
            itemCount: state.filteredTodos.length,
            itemBuilder: (context, index) {
              final todo = state.filteredTodos[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TodoCardWidget(
                        todo: todo,
                        onEdit: (editedTodo) {
                          context.read<TodosBloc>().add(UpdateTodo(editedTodo));
                        },
                        onToggleComplete: (toggledTodo) {
                          context.read<TodosBloc>().add(ToggleTodo(todo.id));
                        },
                        onDelete: (deletedTodo) {
                          _deleteTodoWithUndo(deletedTodo);
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    return const Center(child: Text('Unknown state'));
  }

  void _showEditTodo(dynamic todo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateTodoBottomSheet(
        onTodoCreated: (editedTodo) {
          context.read<TodosBloc>().add(UpdateTodo(editedTodo));
          Navigator.pop(context);
        },
        editTodo: todo,
      ),
    );
  }

  void _deleteTodoWithUndo(dynamic todo) {
    context.read<TodosBloc>().add(DeleteTodo(todo.id));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Todo "${todo.text}" deleted'),
        backgroundColor: AppColors.surface(context),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'UNDO',
          textColor: AppColors.primaryColor,
          onPressed: () {
            context.read<TodosBloc>().add(UndoDeleteTodo(todo));
          },
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

