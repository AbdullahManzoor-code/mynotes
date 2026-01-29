import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/create_todo_bottom_sheet.dart';
import '../bloc/todos_bloc.dart';
import '../../core/services/todo_service.dart';
import '../../domain/entities/todo_item.dart';

class TodosScreen extends StatefulWidget {
  const TodosScreen({super.key});

  @override
  State<TodosScreen> createState() => _TodosScreenState();
}

class _TodosScreenState extends State<TodosScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showFilters = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  void _showSortOptions(TodosLoaded state) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sort by',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...TodoSortOption.values.map((option) {
              final isSelected = state.currentSort == option;
              return ListTile(
                leading: Icon(
                  _getSortIcon(option),
                  color: isSelected ? Theme.of(context).primaryColor : null,
                ),
                title: Text(
                  _getSortLabel(option),
                  style: TextStyle(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Todos'),
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list : Icons.filter_list_off,
            ),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateTodo,
        label: const Text('Add Todo'),
        icon: const Icon(Icons.add),
      ),
    );
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
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search todos...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<TodosBloc>().add(SearchTodos(''));
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '${stats.completed}/${stats.total}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text('Completed'),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.3)),
          Expanded(
            child: Column(
              children: [
                Text(
                  stats.overdue.toString(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade600,
                  ),
                ),
                const Text('Overdue'),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.3)),
          Expanded(
            child: Column(
              children: [
                Text(
                  stats.dueToday.toString(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade600,
                  ),
                ),
                const Text('Due Today'),
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
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Error loading todos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(state.message),
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
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                state.searchQuery.isNotEmpty
                    ? 'No todos match your search'
                    : state.currentFilter == TodoFilter.all
                    ? 'No todos yet'
                    : 'No ${_getFilterLabel(state.currentFilter).toLowerCase()} todos',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                state.searchQuery.isNotEmpty
                    ? 'Try adjusting your search terms'
                    : state.currentFilter == TodoFilter.all
                    ? 'Tap the + button to create your first todo'
                    : 'Try changing the filter or create a new todo',
                style: const TextStyle(color: Colors.grey),
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

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.filteredTodos.length,
        itemBuilder: (context, index) {
          final todo = state.filteredTodos[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildTodoCard(todo),
          );
        },
      );
    }

    return const Center(child: Text('Unknown state'));
  }

  Widget _buildTodoCard(TodoItem todo) {
    return Card(
      child: ListTile(
        leading: Checkbox(
          value: todo.isCompleted,
          onChanged: (_) {
            context.read<TodosBloc>().add(ToggleTodo(todo.id));
          },
        ),
        title: Text(
          todo.text,
          style: TextStyle(
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${todo.category.name} • ${todo.priority.name}'),
            if (todo.dueDate != null)
              Text(
                'Due: ${todo.dueDate!.day}/${todo.dueDate!.month}/${todo.dueDate!.year}',
                style: TextStyle(
                  color:
                      todo.dueDate!.isBefore(DateTime.now()) &&
                          !todo.isCompleted
                      ? Colors.red
                      : null,
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              onTap: () => _editTodo(todo),
              child: const Row(
                children: [Icon(Icons.edit), SizedBox(width: 8), Text('Edit')],
              ),
            ),
            PopupMenuItem(
              onTap: () => _deleteTodoWithUndo(todo),
              child: const Row(
                children: [
                  Icon(Icons.delete),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editTodo(TodoItem todo) {
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

  void _deleteTodoWithUndo(TodoItem todo) {
    context.read<TodosBloc>().add(DeleteTodo(todo.id));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Todo "${todo.text}" deleted'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            context.read<TodosBloc>().add(UndoDeleteTodo(todo));
          },
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
