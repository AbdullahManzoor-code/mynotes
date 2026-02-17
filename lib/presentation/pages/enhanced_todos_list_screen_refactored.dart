import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/core/extensions/context_extensions.dart';
import 'dart:ui' as ui;
import 'package:mynotes/presentation/bloc/todos/todos_bloc.dart';
import 'package:mynotes/presentation/bloc/params/todo_params.dart';
import 'package:mynotes/presentation/design_system/design_system.dart';
import 'package:mynotes/presentation/widgets/todo/todo_widgets.dart';
import 'package:mynotes/core/constants/app_strings.dart';
import 'package:mynotes/domain/entities/todo_item.dart';

/// ════════════════════════════════════════════════════════════════════════════
/// PHASE 2: TODOS FEATURE REFACTORING
/// Enhanced Todos List Screen - StatelessWidget with BLoC
/// Uses TodosBloc from application architecture
/// ════════════════════════════════════════════════════════════════════════════
///
/// IMPLEMENTATION PLAN:
/// ════════════════════════════════════════════════════════════════════════════
/// 1. STATE MANAGEMENT: All state handled by TodosBloc
///    - Todos list (active/completed)
///    - Search query and filtering
///    - Sort options (by priority, due date, created)
///    - View mode (list/grid)
///    - Loading/error states
///
/// 2. BLoC EVENTS DISPATCHED:
///    - LoadTodosEvent() - Load all active todos
///    - LoadCompletedTodosEvent() - Load completed todos
///    - SearchTodosEvent(query) - Search todos by title/description
///    - CreateTodoEvent(todo) - Create new todo
///    - UpdateTodoEvent(todo) - Update existing todo
///    - DeleteTodoEvent(id) - Delete todo
///    - CompleteTodoEvent(id) - Mark as complete
///    - UncompleteTodoEvent(id) - Mark as incomplete
///    - FilterByPriorityEvent(priority) - Filter by priority level
///    - SortTodosEvent(sortBy) - Sort todos
///
/// 3. MAIN BUILD STRUCTURE:
///    - BLocBuilder<TodosBloc> wraps entire content
///    - Handles: Loading, Error, Empty, Loaded states
///    - Passes appropriate data to child widgets
///
/// 4. WIDGET COMPOSITION:
///    - TodosListHeader - Search & filters (receives state)
///    - TodosTemplateSection - Template picker (StatelessWidget)
///    - TodosList - Todo display (receives todos + callbacks)
///
/// 5. RESPONSIVE DESIGN:
///    All widgets use flutter_screenutil (.w, .h, .r, .sp)
///    - Mobile: Single column, auto-layout
///    - Tablet: Grid view option, centered
///    - Desktop: Full width with constraints
///
/// 6. KEY DIFFERENCES FROM NOTES:
///    - Tab-based view (Active/Completed instead of Pinned/Unpinned)
///    - Priority-based coloring and badges
///    - Due date tracking with overdue warnings
///    - Completion percentage for todo lists
///    - Subtask support integration
/// ════════════════════════════════════════════════════════════════════════════

/// Enhanced Todos List Screen - StatelessWidget
class EnhancedTodosListScreenRefactored extends StatelessWidget {
  const EnhancedTodosListScreenRefactored({super.key});

  static final List<TodoTemplate> _templates = [
    TodoTemplate(
      title: 'Shopping',
      icon: Icons.shopping_cart,
      color: AppColors.accentOrange,
      description: 'Grocery & shopping list',
      contentGenerator: _generateShoppingTemplate,
    ),
    TodoTemplate(
      title: 'Work Tasks',
      icon: Icons.work,
      color: AppColors.primary,
      description: 'Daily work tasks',
      contentGenerator: _generateWorkTemplate,
    ),
    TodoTemplate(
      title: 'Personal',
      icon: Icons.person,
      color: AppColors.accentGreen,
      description: 'Personal goals',
      contentGenerator: _generatePersonalTemplate,
    ),
    TodoTemplate(
      title: 'Fitness',
      icon: Icons.fitness_center,
      color: Colors.red,
      description: 'Workout routine',
      contentGenerator: _generateFitnessTemplate,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    AppLogger.i('Building EnhancedTodosListScreenRefactored');

    // Load todos on widget creation
    context.read<TodosBloc>().add(LoadTodos());

    return Scaffold(
      backgroundColor: AppColors.background(context),
      extendBodyBehindAppBar: true,
      floatingActionButton: _buildFAB(context),
      body: Stack(
        children: [
          // Background glow effect
          _buildBackgroundGlow(context),
          // Main content with BLoC builder
          _buildMainContent(context),
        ],
      ),
    );
  }

  /// ════════════════════════════════════════════════════════════════════════
  /// MAIN CONTENT BUILDER - Handles all BLoC state
  /// ════════════════════════════════════════════════════════════════════════
  Widget _buildMainContent(BuildContext context) {
    return Stack(
      children: [
        BlocBuilder<TodosBloc, TodosState>(
          builder: (context, state) {
            AppLogger.i('TodosBloc state: ${state.runtimeType}');

            // Handle different states
            if (state is TodosLoading) {
              return _buildLoadingState(context);
            } else if (state is TodosError) {
              return _buildErrorState(context, state);
            } else if (state is TodosInitial) {
              return _buildEmptyState(context);
            } else if (state is TodosLoaded) {
              return _buildTodosLoadedState(context, state);
            }

            return const SizedBox.shrink();
          },
        ),
        // ISSUE-012 FIX: Show undo snackbar when todo is deleted
        _buildUndoNotification(context),
      ],
    );
  }

  /// ════════════════════════════════════════════════════════════════════════
  /// ISSUE-012 FIX: Undo notification for deleted todos
  /// ════════════════════════════════════════════════════════════════════════
  Widget _buildUndoNotification(BuildContext context) {
    return BlocListener<TodosBloc, TodosState>(
      listenWhen: (previous, current) {
        // Show snackbar when a todo is deleted (lastDeletedTodo changes from null to non-null)
        if (previous is TodosLoaded && current is TodosLoaded) {
          return previous.lastDeletedTodo == null &&
              current.lastDeletedTodo != null;
        }
        return false;
      },
      listener: (context, state) {
        if (state is TodosLoaded && state.lastDeletedTodo != null) {
          final todo = state.lastDeletedTodo!;
          AppLogger.i('Showing undo snackbar for deleted todo: ${todo.id}');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Todo "${todo.text}" deleted'),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () {
                  AppLogger.i('Undo delete requested for todo: ${todo.id}');
                  context.read<TodosBloc>().add(UndoDeleteTodo(todo));
                },
              ),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      },
      child: const SizedBox.shrink(),
    );
  }

  /// ════════════════════════════════════════════════════════════════════════
  /// STATE: LOADING
  /// ════════════════════════════════════════════════════════════════════════
  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 50.r,
            height: 50.r,
            child: const CircularProgressIndicator(),
          ),
          SizedBox(height: 16.h),
          Text(
            AppStrings.loading,
            style: AppTypography.body1(context).copyWith(fontSize: 14.sp),
          ),
        ],
      ),
    );
  }

  /// ════════════════════════════════════════════════════════════════════════
  /// STATE: ERROR
  /// ════════════════════════════════════════════════════════════════════════
  Widget _buildErrorState(BuildContext context, TodosError error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60.r, color: context.errorColor),
          SizedBox(height: 16.h),
          Text(
            AppStrings.error,
            style: AppTypography.heading2(
              context,
            ).copyWith(fontSize: 18.sp, color: context.errorColor),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Text(
              error.message,
              textAlign: TextAlign.center,
              style: AppTypography.body2(context).copyWith(fontSize: 14.sp),
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () => context.read<TodosBloc>().add(LoadTodos()),
            child: Text(AppStrings.retry),
          ),
        ],
      ),
    );
  }

  /// ════════════════════════════════════════════════════════════════════════
  /// STATE: EMPTY
  /// ════════════════════════════════════════════════════════════════════════
  Widget _buildEmptyState(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: kToolbarHeight),
          Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.checklist_outlined,
                  size: 100.r,
                  color: context.theme.disabledColor,
                ),
                SizedBox(height: 24.h),
                Text(
                  'No Todos Yet',
                  style: AppTypography.heading2(context).copyWith(
                    fontSize: 20.sp,
                    color: context.theme.disabledColor,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Create your first todo to get started',
                  textAlign: TextAlign.center,
                  style: AppTypography.body2(context).copyWith(
                    fontSize: 14.sp,
                    color: context.theme.disabledColor.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: 32.h),
                TodosTemplateSection(
                  templates: _templates,
                  onTemplateSelected: _createFromTemplate,
                  isExpanded: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ════════════════════════════════════════════════════════════════════════
  /// STATE: LOADED - Main content layout
  /// ════════════════════════════════════════════════════════════════════════
  Widget _buildTodosLoadedState(BuildContext context, TodosLoaded state) {
    final displayedTodos = state.filteredTodos.isEmpty
        ? state.allTodos
        : state.filteredTodos;
    final activeTodos = displayedTodos.where((t) => !t.isCompleted).toList();
    final completedTodos = displayedTodos.where((t) => t.isCompleted).toList();

    final completion = activeTodos.isEmpty
        ? 100
        : (completedTodos.length /
                  (activeTodos.length + completedTodos.length) *
                  100)
              .round();

    return Column(
      children: [
        SizedBox(height: kToolbarHeight),
        // Progress indicator
        _buildProgressSection(context, completion, activeTodos.length),
        // Search & Filter Header
        _buildHeaderSection(context, state),
        // Template Section
        TodosTemplateSection(
          templates: _templates,
          onTemplateSelected: _createFromTemplate,
          isExpanded: activeTodos.isEmpty,
        ),
        // Todos List
        Expanded(
          child: TodosList(
            activeTodos: activeTodos,
            completedTodos: completedTodos,
            onTodoTap: (todo) {
              AppLogger.i('Todo tapped: ${todo.id}');
              Navigator.pushNamed(
                context,
                '/todo-editor',
                arguments: {'todo': todo},
              );
            },
            onTodoDelete: (todoId) {
              AppLogger.i('Todo delete requested: $todoId');
              context.read<TodosBloc>().add(DeleteTodo(todoId));
            },
            onTodoComplete: (todoId) {
              AppLogger.i('Todo completion toggled: $todoId');
              // Get the todo from the current loaded state and toggle it
              final currentState = context.read<TodosBloc>().state;
              if (currentState is TodosLoaded) {
                TodoItem? todo;
                try {
                  todo = currentState.allTodos.firstWhere(
                    (t) => t.id == todoId,
                  );
                } catch (e) {
                  // Todo not found, silently ignore
                  todo = null;
                }
                if (todo != null) {
                  final params = TodoParams.fromTodoItem(todo);
                  context.read<TodosBloc>().add(ToggleTodo(params));
                }
              }
            },
            onTodoEdit: (todoId) {
              AppLogger.i('Todo edit requested: $todoId');
              // Navigate to editor with todo
            },
          ),
        ),
      ],
    );
  }

  /// ════════════════════════════════════════════════════════════════════════
  /// PROGRESS SECTION - Shows completion percentage
  /// ════════════════════════════════════════════════════════════════════════
  Widget _buildProgressSection(
    BuildContext context,
    int completionPercent,
    int activeTodoCount,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: context.theme.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: context.theme.dividerColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: AppTypography.body1(
                  context,
                ).copyWith(fontSize: 12.sp, fontWeight: FontWeight.w600),
              ),
              Text(
                '$completionPercent%',
                style: AppTypography.body1(context).copyWith(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: context.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: completionPercent / 100,
              minHeight: 6.h,
              backgroundColor: context.theme.disabledColor.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation(
                completionPercent >= 100 ? Colors.green : context.primaryColor,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '$activeTodoCount active ${activeTodoCount == 1 ? 'task' : 'tasks'}',
            style: AppTypography.caption(
              context,
            ).copyWith(fontSize: 11.sp, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  /// ════════════════════════════════════════════════════════════════════════
  /// HEADER SECTION - Search, Filter, View Options
  /// ════════════════════════════════════════════════════════════════════════
  Widget _buildHeaderSection(BuildContext context, TodosLoaded state) {
    return TodosListHeader(
      searchQuery: state.searchQuery,
      onSearchChanged: (query) {
        AppLogger.i('Searching todos: $query');
        context.read<TodosBloc>().add(SearchTodos(query));
      },
      onFilterTap: () {
        AppLogger.i('Filter tapped');
        _showFilterBottomSheet(context);
      },
      onViewOptionsTap: () {
        AppLogger.i('View options tapped');
        _showViewOptionsBottomSheet(context);
      },
    );
  }

  /// ════════════════════════════════════════════════════════════════════════
  /// BACKGROUND GLOW
  /// ════════════════════════════════════════════════════════════════════════
  Widget _buildBackgroundGlow(BuildContext context) {
    return Positioned(
      top: -100.h,
      right: -100.w,
      child: Container(
        width: 300.w,
        height: 300.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withOpacity(0.08),
        ),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 100, sigmaY: 100),
          child: Container(color: Colors.transparent),
        ),
      ),
    );
  }

  /// ════════════════════════════════════════════════════════════════════════
  /// FLOATING ACTION BUTTON
  /// ════════════════════════════════════════════════════════════════════════
  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: 'todos_fab',
      onPressed: () {
        AppLogger.i('New Todo FAB pressed');
        Navigator.pushNamed(context, '/todos/editor');
      },
      backgroundColor: AppColors.primary,
      elevation: 8,
      label: Text(
        AppStrings.newTodo,
        style: AppTypography.buttonMedium(context, Colors.white),
      ),
      icon: const Icon(Icons.add_rounded, color: Colors.white),
    );
  }

  /// ════════════════════════════════════════════════════════════════════════
  /// HELPER METHODS
  /// ════════════════════════════════════════════════════════════════════════

  void _createFromTemplate(TodoTemplate template) {
    AppLogger.i('Creating todo from template: ${template.title}');
  }

  void _showFilterBottomSheet(BuildContext context) {
    AppLogger.i('Showing filter bottom sheet');

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return BlocBuilder<TodosBloc, TodosState>(
          builder: (context, state) {
            final selectedCat = (state is TodosLoaded)
                ? state.selectedCategory
                : 'All';

            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              builder: (BuildContext context, ScrollController scrollController) {
                return Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Filter by Category',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    // Categories
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        children: [
                          // "All Categories" option
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: FilterChip(
                              selected: selectedCat == 'All',
                              onSelected: (_) {
                                context.read<TodosBloc>().add(
                                  ChangeCategory('All'),
                                );
                                Navigator.pop(context);
                              },
                              label: const Text('All Categories'),
                            ),
                          ),
                          // Category chips
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final category in TodoCategory.values)
                                FilterChip(
                                  selected: selectedCat == category.name,
                                  onSelected: (_) {
                                    context.read<TodosBloc>().add(
                                      ChangeCategory(category.name),
                                    );
                                    Navigator.pop(context);
                                  },
                                  label: Text(
                                    '${category.icon} ${category.displayName}',
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _showViewOptionsBottomSheet(BuildContext context) {
    AppLogger.i('Showing view options bottom sheet');

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return BlocBuilder<TodosBloc, TodosState>(
          builder: (context, state) {
            if (state is! TodosLoaded) {
              return const Center(child: CircularProgressIndicator());
            }

            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                    return Column(
                      children: [
                        // Header
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Sort & View Options',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        ),
                        const Divider(),
                        // Sort Options
                        Expanded(
                          child: ListView(
                            controller: scrollController,
                            padding: const EdgeInsets.all(16),
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(
                                  'Sort By',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                              ),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (final sortOption
                                      in TodoSortOption.values)
                                    ChoiceChip(
                                      selected: state.currentSort == sortOption,
                                      onSelected: (_) {
                                        context.read<TodosBloc>().add(
                                          SortTodos(
                                            sortOption,
                                            ascending: state.sortAscending,
                                          ),
                                        );
                                      },
                                      label: Text(
                                        _getSortOptionLabel(sortOption),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              // Sort Direction Toggle
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(
                                  'Order',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  ChoiceChip(
                                    selected: state.sortAscending,
                                    onSelected: (_) {
                                      context.read<TodosBloc>().add(
                                        SortTodos(
                                          state.currentSort,
                                          ascending: true,
                                        ),
                                      );
                                    },
                                    label: const Text('Ascending'),
                                  ),
                                  ChoiceChip(
                                    selected: !state.sortAscending,
                                    onSelected: (_) {
                                      context.read<TodosBloc>().add(
                                        SortTodos(
                                          state.currentSort,
                                          ascending: false,
                                        ),
                                      );
                                    },
                                    label: const Text('Descending'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
            );
          },
        );
      },
    );
  }

  String _getSortOptionLabel(TodoSortOption option) {
    switch (option) {
      case TodoSortOption.dueDate:
        return 'Due Date';
      case TodoSortOption.priority:
        return 'Priority';
      case TodoSortOption.category:
        return 'Category';
      case TodoSortOption.createdDate:
        return 'Created Date';
      case TodoSortOption.alphabetical:
        return 'Alphabetical';
    }
  }

  /// ════════════════════════════════════════════════════════════════════════
  /// TEMPLATE CONTENT GENERATORS
  /// ════════════════════════════════════════════════════════════════════════

  static String _generateShoppingTemplate() => '''Shopping List

Groceries:
- 

Household:
- 

Other:
- 
''';

  static String _generateWorkTemplate() => '''Work Tasks

Daily:
- 

This Week:
- 

This Month:
- 
''';

  static String _generatePersonalTemplate() => '''Personal Goals

Health:
- 

Learning:
- 

Misc:
- 
''';

  static String _generateFitnessTemplate() => '''Fitness Routine

Warm-up:
- 

Main Workout:
- 

Cool-down:
- 
''';
}
