import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../design_system/design_system.dart';
import '../bloc/note_bloc.dart';
import '../bloc/note_state.dart';
import '../bloc/todos_bloc.dart';
import '../bloc/alarms_bloc.dart';
import '../../domain/entities/note.dart';
import '../../core/routes/app_routes.dart';
import '../bloc/params/todo_params.dart';
import '../bloc/unified_items_bloc.dart';
import '../bloc/params/unified_items_params.dart';

/// Unified Items Screen - Displays notes, todos, and reminders in one place
/// Allows filtering by type, priority, and due date
class UnifiedItemsScreen extends StatelessWidget {
  const UnifiedItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UnifiedItemsBloc(),
      child: const _UnifiedItemsView(),
    );
  }
}

class _UnifiedItemsView extends StatelessWidget {
  const _UnifiedItemsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildSearchAndFilterBar(context),
          _buildFilterChips(context),
          Expanded(child: _buildUnifiedItemsList(context)),
        ],
      ),
      floatingActionButton: _buildFAB(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background(context),
      elevation: 0,
      title: Text(
        'All Items',
        style: AppTypography.heading2(context, AppColors.textPrimary(context)),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 16.w),
          child: Center(
            child: GestureDetector(
              onTap: () => _showSortOptions(context),
              child: Icon(
                Icons.sort,
                color: AppColors.textPrimary(context),
                size: 24.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilterBar(BuildContext context) {
    // We use a local controller to manage the text but sync it with BLoC
    final TextEditingController searchController = TextEditingController();

    return BlocBuilder<UnifiedItemsBloc, UnifiedItemsState>(
      buildWhen: (p, c) => p.params.searchQuery != c.params.searchQuery,
      builder: (context, state) {
        // Synchronize controller text with state
        if (state.params.searchQuery != searchController.text) {
          searchController.text = state.params.searchQuery;
          // Set selection to end to avoid cursor jumping
          searchController.selection = TextSelection.fromPosition(
            TextPosition(offset: searchController.text.length),
          );
        }

        return Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              TextField(
                controller: searchController,
                style: AppTypography.bodyMedium(
                  context,
                  AppColors.textPrimary(context),
                ),
                decoration: InputDecoration(
                  hintText: 'Search notes, todos, reminders...',
                  hintStyle: AppTypography.bodyMedium(
                    context,
                    AppColors.textSecondary(context),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                  suffixIcon: state.params.searchQuery.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            context.read<UnifiedItemsBloc>().add(
                              const UpdateSearchQueryEvent(''),
                            );
                          },
                          child: Icon(
                            Icons.close,
                            color: AppColors.textSecondary(context),
                            size: 20.sp,
                          ),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: AppColors.textSecondary(context).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 12.h,
                  ),
                  filled: true,
                  fillColor: AppColors.surface(context),
                ),
                onChanged: (value) {
                  context.read<UnifiedItemsBloc>().add(
                    UpdateSearchQueryEvent(value),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    return BlocBuilder<UnifiedItemsBloc, UnifiedItemsState>(
      builder: (context, state) {
        final params = state.params;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              _buildFilterChip(context, 'All', 'all', params.selectedFilter),
              SizedBox(width: 8.w),
              _buildFilterChip(
                context,
                'Notes',
                'notes',
                params.selectedFilter,
              ),
              SizedBox(width: 8.w),
              _buildFilterChip(
                context,
                'Todos',
                'todos',
                params.selectedFilter,
              ),
              SizedBox(width: 8.w),
              _buildFilterChip(
                context,
                'Reminders',
                'reminders',
                params.selectedFilter,
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: () {
                  context.read<UnifiedItemsBloc>().add(
                    const TogglePinnedFilterEvent(),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: params.showOnlyPinned
                        ? AppColors.primary.withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: params.showOnlyPinned
                          ? AppColors.primary
                          : AppColors.textSecondary(context).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.push_pin,
                        size: 14.sp,
                        color: params.showOnlyPinned
                            ? AppColors.primary
                            : AppColors.textSecondary(context),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Pinned',
                        style: AppTypography.labelSmall(
                          context,
                          params.showOnlyPinned
                              ? AppColors.primary
                              : AppColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    String value,
    String selectedFilter,
  ) {
    final isSelected = selectedFilter == value;
    return GestureDetector(
      onTap: () {
        context.read<UnifiedItemsBloc>().add(ChangeFilterEvent(value));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.textSecondary(context).withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall(
            context,
            isSelected ? AppColors.primary : AppColors.textSecondary(context),
          ),
        ),
      ),
    );
  }

  Widget _buildUnifiedItemsList(BuildContext context) {
    return BlocBuilder<UnifiedItemsBloc, UnifiedItemsState>(
      builder: (context, unifiedState) {
        final params = unifiedState.params;

        return ListView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          children: [
            // Notes section
            if (params.selectedFilter == 'all' ||
                params.selectedFilter == 'notes')
              BlocBuilder<NotesBloc, NoteState>(
                builder: (context, state) {
                  if (state is NotesLoaded) {
                    var notes = state.notes;

                    // Apply search filter
                    if (params.searchQuery.isNotEmpty) {
                      notes = notes
                          .where(
                            (note) =>
                                note.title.toLowerCase().contains(
                                  params.searchQuery.toLowerCase(),
                                ) ||
                                note.content.toLowerCase().contains(
                                  params.searchQuery.toLowerCase(),
                                ),
                          )
                          .toList();
                    }

                    // Apply pinned filter
                    if (params.showOnlyPinned) {
                      notes = notes.where((note) => note.isPinned).toList();
                    }

                    // Apply sorting based on sortBy
                    if (params.sortBy == 'recent') {
                      notes = notes.toList()
                        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
                    }

                    if (notes.isEmpty && params.selectedFilter == 'notes') {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.w),
                          child: Text(
                            'No notes found',
                            style: AppTypography.bodyMedium(
                              context,
                              AppColors.textSecondary(context),
                            ),
                          ),
                        ),
                      );
                    }

                    if (notes.isEmpty) return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (params.selectedFilter == 'all') ...[
                          Text(
                            'Notes',
                            style: AppTypography.heading3(
                              context,
                              AppColors.textSecondary(context),
                            ),
                          ),
                          SizedBox(height: 8.h),
                        ],
                        ...notes.map((note) => _buildNoteItem(context, note)),
                        if (params.selectedFilter == 'all')
                          SizedBox(height: 20.h),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

            // Todos section
            if (params.selectedFilter == 'all' ||
                params.selectedFilter == 'todos')
              BlocBuilder<TodosBloc, TodosState>(
                builder: (context, state) {
                  if (state is TodosLoaded) {
                    var todos = state.filteredTodos;

                    // Apply search filter
                    if (params.searchQuery.isNotEmpty) {
                      todos = todos
                          .where(
                            (todo) => todo.text.toLowerCase().contains(
                              params.searchQuery.toLowerCase(),
                            ),
                          )
                          .toList();
                    }

                    if (todos.isEmpty && params.selectedFilter == 'todos') {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.w),
                          child: Text(
                            'No todos found',
                            style: AppTypography.bodyMedium(
                              context,
                              AppColors.textSecondary(context),
                            ),
                          ),
                        ),
                      );
                    }

                    if (todos.isEmpty) return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (params.selectedFilter == 'all') ...[
                          Text(
                            'Todos',
                            style: AppTypography.heading3(
                              context,
                              AppColors.textSecondary(context),
                            ),
                          ),
                          SizedBox(height: 8.h),
                        ],
                        ...todos.map((todo) => _buildTodoItem(context, todo)),
                        if (params.selectedFilter == 'all')
                          SizedBox(height: 20.h),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

            // Reminders section
            if (params.selectedFilter == 'all' ||
                params.selectedFilter == 'reminders')
              BlocBuilder<AlarmsBloc, AlarmsState>(
                builder: (context, state) {
                  if (state is AlarmsLoaded) {
                    var alarms = state.filteredAlarms;

                    // Apply search filter
                    if (params.searchQuery.isNotEmpty) {
                      alarms = alarms
                          .where(
                            (alarm) => alarm.message.toLowerCase().contains(
                              params.searchQuery.toLowerCase(),
                            ),
                          )
                          .toList();
                    }

                    if (alarms.isEmpty &&
                        params.selectedFilter == 'reminders') {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.w),
                          child: Text(
                            'No reminders found',
                            style: AppTypography.bodyMedium(
                              context,
                              AppColors.textSecondary(context),
                            ),
                          ),
                        ),
                      );
                    }

                    if (alarms.isEmpty) return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (params.selectedFilter == 'all') ...[
                          Text(
                            'Reminders',
                            style: AppTypography.heading3(
                              context,
                              AppColors.textSecondary(context),
                            ),
                          ),
                          SizedBox(height: 8.h),
                        ],
                        ...alarms.map(
                          (alarm) => _buildReminderItem(context, alarm),
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildNoteItem(BuildContext context, Note note) {
    final noteColor = note.color is Color
        ? note.color as Color
        : AppColors.primary.withOpacity(0.1);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.noteEditor, arguments: note);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: noteColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppColors.textSecondary(context).withOpacity(0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    note.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyLarge(
                      context,
                      AppColors.textPrimary(context),
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                if (note.isPinned)
                  Icon(Icons.push_pin, size: 14.sp, color: AppColors.primary),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              note.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySmall(
                context,
                AppColors.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodoItem(BuildContext context, dynamic todo) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.textSecondary(context).withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: todo.isCompleted ?? false,
            onChanged: (val) {
              context.read<TodosBloc>().add(
                ToggleTodo.toggle(TodoParams.fromTodoItem(todo)),
              );
            },
            fillColor: WidgetStateProperty.all(AppColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  todo.text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      AppTypography.bodyLarge(
                        context,
                        AppColors.textPrimary(context),
                      ).copyWith(
                        decoration: (todo.isCompleted ?? false)
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                ),
                if (todo.dueDate != null)
                  Text(
                    'Due: ${todo.dueDate!.day}/${todo.dueDate!.month}',
                    style: AppTypography.caption(
                      context,
                      AppColors.textSecondary(context),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderItem(BuildContext context, dynamic reminder) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.alarm, color: AppColors.primary, size: 18.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.message,
                  style: AppTypography.bodyLarge(
                    context,
                    AppColors.textPrimary(context),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${reminder.scheduledTime.day}/${reminder.scheduledTime.month} ${reminder.scheduledTime.hour}:${reminder.scheduledTime.minute.toString().padLeft(2, '0')}',
                  style: AppTypography.caption(
                    context,
                    AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: BlocProvider.value(
          value: context.read<UnifiedItemsBloc>(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.border(context),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Text(
                  'Sort By',
                  style: AppTypography.heading3(
                    context,
                    AppColors.textPrimary(context),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.schedule,
                  color: AppColors.textPrimary(context),
                ),
                title: Text(
                  'Most Recent',
                  style: AppTypography.bodyLarge(
                    context,
                    AppColors.textPrimary(context),
                  ),
                ),
                onTap: () {
                  context.read<UnifiedItemsBloc>().add(
                    const ChangeSortEvent('recent'),
                  );
                  Navigator.pop(modalContext);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.priority_high,
                  color: AppColors.textPrimary(context),
                ),
                title: Text(
                  'Priority',
                  style: AppTypography.bodyLarge(
                    context,
                    AppColors.textPrimary(context),
                  ),
                ),
                onTap: () {
                  context.read<UnifiedItemsBloc>().add(
                    const ChangeSortEvent('priority'),
                  );
                  Navigator.pop(modalContext);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.date_range,
                  color: AppColors.textPrimary(context),
                ),
                title: Text(
                  'Due Date',
                  style: AppTypography.bodyLarge(
                    context,
                    AppColors.textPrimary(context),
                  ),
                ),
                onTap: () {
                  context.read<UnifiedItemsBloc>().add(
                    const ChangeSortEvent('due-date'),
                  );
                  Navigator.pop(modalContext);
                },
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: AppColors.primary,
      onPressed: () {
        Navigator.pushNamed(context, AppRoutes.quickAdd);
      },
      child: Icon(Icons.add, color: Colors.white, size: 24.sp),
    );
  }
}
