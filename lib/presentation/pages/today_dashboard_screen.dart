import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:mynotes/core/routes/app_routes.dart';
import 'package:mynotes/domain/entities/alarm.dart';
import '../bloc/params/alarm_params.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/todo_item.dart';
import '../bloc/note/note_bloc.dart';
import '../bloc/note/note_event.dart';
import '../bloc/note/note_state.dart';
import '../bloc/alarm/alarms_bloc.dart';
import '../bloc/reflection/reflection_bloc.dart';
import '../bloc/reflection/reflection_event.dart';
import '../bloc/reflection/reflection_state.dart';
import '../bloc/todos/todos_bloc.dart';
import '../bloc/params/todo_params.dart';
import '../design_system/design_system.dart';
import '../widgets/quick_add_bottom_sheet.dart';
import '../widgets/global_command_palette.dart';

/// Today Dashboard Screen
/// Main overview showing stats, daily reflection prompt, and upcoming items
/// Based on template: today_dashboard_home_1/2
class TodayDashboardScreen extends StatelessWidget {
  const TodayDashboardScreen({super.key});

  void _loadDashboardData(BuildContext context) {
    context.read<NotesBloc>().add(const LoadNotesEvent());
    context.read<AlarmsBloc>().add(LoadAlarms());
    context.read<ReflectionBloc>().add(const InitializeReflectionEvent());
    context.read<TodosBloc>().add(LoadTodos());
  }

  @override
  Widget build(BuildContext context) {
    // Initial data load - triggering here instead of initState
    // We can use a Builder to ensure context is ready
    return Builder(
      builder: (context) {
        // Trigger initial load. In a real app, you might want more control
        // over how often this loads (e.g., using a dedicated DashboardBloc)
        // For now, mirroring the initState behavior.
        Future.microtask(() => _loadDashboardData(context));

        final now = DateTime.now();
        final greeting = _getGreeting(now.hour);

        return Shortcuts(
          shortcuts: {
            LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyK):
                const _ShowCommandPaletteIntent(),
            LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyK):
                const _ShowCommandPaletteIntent(),
          },
          child: Actions(
            actions: {
              _ShowCommandPaletteIntent:
                  CallbackAction<_ShowCommandPaletteIntent>(
                    onInvoke: (_) {
                      showGlobalCommandPalette(context);
                      return null;
                    },
                  ),
            },
            child: Scaffold(
              backgroundColor: AppColors.background(context),
              body: RefreshIndicator(
                onRefresh: () async {
                  _loadDashboardData(context);
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                color: AppColors.primary,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    // Top App Bar / Greeting Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenPaddingHorizontal,
                          vertical: AppSpacing.md,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    greeting,
                                    style: AppTypography.heading1(
                                      context,
                                      AppColors.textPrimary(context),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Here's your focus for today.",
                                    style: AppTypography.bodyMedium(
                                      context,
                                      AppColors.textSecondary(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Command Palette & Profile Actions
                            Row(
                              children: [
                                // Search / Command Palette
                                GestureDetector(
                                  onTap: () =>
                                      showGlobalCommandPalette(context),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.primary.withOpacity(
                                          0.2,
                                        ),
                                        width: 1,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.search,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                  ),
                                ),

                                // Profile / Settings
                                GestureDetector(
                                  onTap: () => Navigator.pushNamed(
                                    context,
                                    AppRoutes.settings,
                                  ),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface(context),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.border(context),
                                        width: 1,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.person_outline,
                                      color: AppColors.textPrimary(context),
                                      size: 20,
                                    ),
                                  ),
                                ),

                                // More Menu
                                PopupMenuButton<String>(
                                  icon: Icon(
                                    Icons.more_vert,
                                    color: AppColors.textSecondary(context),
                                  ),
                                  onSelected: (value) =>
                                      _handleTodayMenu(context, value),
                                  itemBuilder: (BuildContext context) => [
                                    const PopupMenuItem(
                                      value: 'analytics',
                                      child: Row(
                                        children: [
                                          Icon(Icons.analytics, size: 20),
                                          SizedBox(width: 12),
                                          Text('Analytics'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'reminders',
                                      child: Row(
                                        children: [
                                          Icon(Icons.notifications, size: 20),
                                          SizedBox(width: 12),
                                          Text('Reminders'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'highlights',
                                      child: Row(
                                        children: [
                                          Icon(Icons.star, size: 20),
                                          SizedBox(width: 12),
                                          Text('Daily Highlights'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'reflection',
                                      child: Row(
                                        children: [
                                          Icon(Icons.psychology, size: 20),
                                          SizedBox(width: 12),
                                          Text('Daily Reflection'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuDivider(),
                                    const PopupMenuItem(
                                      value: 'settings',
                                      child: Row(
                                        children: [
                                          Icon(Icons.settings, size: 20),
                                          SizedBox(width: 12),
                                          Text('Settings'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Stats Section
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenPaddingHorizontal,
                        ),
                        child: DashboardStats(),
                      ),
                    ),

                    // Quick Actions Section
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenPaddingHorizontal,
                        ),
                        child: const DashboardQuickActions(),
                      ),
                    ),

                    // Daily Highlight Section
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenPaddingHorizontal,
                        ),
                        child: DashboardHighlight(),
                      ),
                    ),

                    // Daily Reflection Prompt
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenPaddingHorizontal,
                        ),
                        child: DashboardReflection(),
                      ),
                    ),

                    // Section: Your Day
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenPaddingHorizontal,
                        ).copyWith(bottom: AppSpacing.md),
                        child: Text(
                          'Your Day',
                          style: AppTypography.heading2(
                            context,
                            AppColors.textPrimary(context),
                          ),
                        ),
                      ),
                    ),

                    // Next Reminders Card
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenPaddingHorizontal,
                        ),
                        child: DashboardReminders(),
                      ),
                    ),

                    // Todos Card
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenPaddingHorizontal,
                        ),
                        child: DashboardTodos(),
                      ),
                    ),

                    // Continue Writing (Recent Notes)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenPaddingHorizontal,
                        ),
                        child: DashboardNotes(),
                      ),
                    ),

                    // Mood Check-In
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenPaddingHorizontal,
                        ),
                        child: DashboardMoodCheckIn(),
                      ),
                    ),

                    // Bottom Spacing
                    SliverToBoxAdapter(child: SizedBox(height: 80)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getGreeting(int hour) {
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void _handleTodayMenu(context, String value) {
    switch (value) {
      case 'analytics':
        // Navigate to analytics
        break;
      case 'reminders':
        Navigator.pushNamed(context, AppRoutes.remindersList);
        break;
      case 'highlights':
        Navigator.pushNamed(context, AppRoutes.dailyHighlightSummary);
        break;
      case 'reflection':
        Navigator.pushNamed(context, AppRoutes.reflectionHome);
        break;
      case 'settings':
        Navigator.pushNamed(context, AppRoutes.settings);
        break;
    }
  }
}

// --- MODULAR DASHBOARD WIDGETS (Systemic Refactor) ---

class DashboardStats extends StatelessWidget {
  const DashboardStats({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotesBloc, NoteState>(
      builder: (context, noteState) {
        return BlocBuilder<TodosBloc, TodosState>(
          builder: (context, todosState) {
            return BlocBuilder<ReflectionBloc, ReflectionState>(
              builder: (context, reflectionState) {
                final stats = _calculateStats(
                  noteState,
                  todosState,
                  reflectionState,
                );

                return Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: AppColors.surface(context),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusXL,
                        ),
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.borderDark.withOpacity(0.2)
                              : AppColors.borderLight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                              Theme.of(context).brightness == Brightness.dark
                                  ? 0.3
                                  : 0.05,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Today\'s Progress',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 20.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              DashboardProgressRing(
                                title: 'Notes',
                                progress: stats.notesProgress,
                                color: AppColors.primary,
                                icon: Icons.note,
                              ),
                              DashboardProgressRing(
                                title: 'Todos',
                                progress: stats.todosProgress,
                                color: AppColors.accentGreen,
                                icon: Icons.check_circle,
                              ),
                              DashboardProgressRing(
                                title: 'Reflections',
                                progress: stats.reflectionsProgress,
                                color: AppColors.accentPurple,
                                icon: Icons.psychology,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: DashboardStatCard(
                            label: 'REFLECTION STREAK',
                            value: '${stats.streak} Days',
                            trend: 'Keep it up!',
                            trendColor: AppColors.successGreen,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DashboardStatCard(
                            label: 'TODOS DONE',
                            value:
                                '${stats.completedTodos}/${stats.totalTodos}',
                            trend: stats.totalTodos == 0
                                ? 'No todos'
                                : '${(stats.todosProgress * 100).toStringAsFixed(0)}% complete',
                            trendColor: AppColors.successGreen,
                          ),
                        ),
                      ],
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

  _DashboardStatsData _calculateStats(
    NoteState noteState,
    TodosState todosState,
    ReflectionState reflectionState,
  ) {
    double notesProgress = 0;
    double todosProgress = 0;
    int totalTodos = 0;
    int completedTodos = 0;

    if (noteState is NotesLoaded) {
      final todayNotes = noteState.notes
          .where(
            (note) =>
                note.createdAt.day == DateTime.now().day &&
                (note.todos?.isEmpty ?? true) &&
                !note.isArchived,
          )
          .length;
      notesProgress = todayNotes > 0 ? (todayNotes / 5).clamp(0.0, 1.0) : 0.0;
    }

    if (todosState is TodosLoaded) {
      totalTodos = todosState.filteredTodos.length;
      completedTodos = todosState.filteredTodos
          .where((t) => t.isCompleted)
          .length;
      todosProgress = totalTodos == 0
          ? 0.0
          : (completedTodos / totalTodos).clamp(0.0, 1.0);
    }

    final answers = reflectionState.allAnswers.isNotEmpty
        ? reflectionState.allAnswers
        : reflectionState.answers;

    int reflectedTodayCount = reflectionState.answeredToday > 0
        ? reflectionState.answeredToday
        : answers
              .where(
                (r) =>
                    r.createdAt.year == DateTime.now().year &&
                    r.createdAt.month == DateTime.now().month &&
                    r.createdAt.day == DateTime.now().day,
              )
              .length;

    double reflectionsProgress = (reflectedTodayCount / 3).clamp(0.0, 1.0);

    int streak = 0;
    if (answers.isNotEmpty) {
      final now = DateTime.now();
      for (int i = 0; i < 365; i++) {
        final date = now.subtract(Duration(days: i));
        final hasReflection = answers.any(
          (r) =>
              r.createdAt.year == date.year &&
              r.createdAt.month == date.month &&
              r.createdAt.day == date.day,
        );
        if (hasReflection) {
          streak++;
        } else {
          break;
        }
      }
    }

    return _DashboardStatsData(
      notesProgress: notesProgress,
      todosProgress: todosProgress,
      reflectionsProgress: reflectionsProgress,
      totalTodos: totalTodos,
      completedTodos: completedTodos,
      streak: streak,
    );
  }
}

class _DashboardStatsData {
  final double notesProgress;
  final double todosProgress;
  final double reflectionsProgress;
  final int totalTodos;
  final int completedTodos;
  final int streak;

  _DashboardStatsData({
    required this.notesProgress,
    required this.todosProgress,
    required this.reflectionsProgress,
    required this.totalTodos,
    required this.completedTodos,
    required this.streak,
  });
}

class DashboardProgressRing extends StatelessWidget {
  final String title;
  final double progress;
  final Color color;
  final IconData icon;

  const DashboardProgressRing({
    super.key,
    required this.title,
    required this.progress,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircularPercentIndicator(
          radius: 40.0.sp,
          lineWidth: 8.0,
          percent: progress.clamp(0.0, 1.0),
          center: Icon(icon, color: color, size: 28.sp),
          progressColor: color,
          backgroundColor: color.withOpacity(0.1),
          circularStrokeCap: CircularStrokeCap.round,
          animation: true,
          animationDuration: 1000,
        ),
        SizedBox(height: 8.h),
        Text(
          title,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          '${(progress * 100).toInt()}%',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary(context),
          ),
        ),
      ],
    );
  }
}

class DashboardStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String trend;
  final Color trendColor;

  const DashboardStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.trend,
    required this.trendColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.labelSmall(
              context,
              AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.numberMedium(
              context,
              AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 2),
          Text(trend, style: AppTypography.captionLarge(context, trendColor)),
        ],
      ),
    );
  }
}

class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _QuickActionButton(
            icon: Icons.note_add,
            label: 'New Note',
            onTap: () => Navigator.pushNamed(context, AppRoutes.noteEditor),
          ),
          const SizedBox(width: 12),
          _QuickActionButton(
            icon: Icons.assignment_outlined,
            label: 'New Task',
            onTap: () => QuickAddBottomSheet.show(context),
          ),
          const SizedBox(width: 12),
          _QuickActionButton(
            icon: Icons.timer_outlined,
            label: 'Focus',
            onTap: () => Navigator.pushNamed(context, AppRoutes.focusSession),
          ),
          const SizedBox(width: 12),
          _QuickActionButton(
            icon: Icons.notifications_active_outlined,
            label: 'Reminder',
            onTap: () => Navigator.pushNamed(context, AppRoutes.remindersList),
          ),
          const SizedBox(width: 12),
          _QuickActionButton(
            icon: Icons.scanner_outlined,
            label: 'Scan',
            onTap: () => Navigator.pushNamed(context, AppRoutes.documentScan),
          ),
          const SizedBox(width: 12),
          _QuickActionButton(
            icon: Icons.psychology,
            label: 'Reflect',
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.reflectionEditor),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80.w,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
          border: Border.all(
            color: isDark
                ? AppColors.borderDark.withOpacity(0.2)
                : AppColors.borderLight,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTypography.captionLarge(
                context,
                AppColors.textPrimary(context),
              ).copyWith(fontSize: 10.sp),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardTodos extends StatelessWidget {
  const DashboardTodos({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodosBloc, TodosState>(
      builder: (context, state) {
        final todos = state is TodosLoaded
            ? state.filteredTodos.where((t) => !t.isCompleted).toList()
            : <TodoItem>[];

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
            border: Border.all(color: AppColors.border(context), width: 1.w),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05,
                ),
                blurRadius: 8.r,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_box_outlined,
                      color: AppColors.accentGreen,
                      size: 20.sp,
                    ),
                    // 12.horizontalSpace,
                    Text(
                      "Today's Todos",
                      style: AppTypography.labelLarge(
                        context,
                        AppColors.textPrimary(context),
                      ),
                    ),
                    const Spacer(),
                    if (todos.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${todos.length} pending',
                          style: TextStyle(
                            color: AppColors.accentGreen,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (todos.isEmpty)
                _buildEmptyState(context, 'All clear! No pending tasks.')
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: todos.length > 5 ? 5 : todos.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: AppColors.border(context)),
                  itemBuilder: (context, index) =>
                      _TodoItemWidget(todo: todos[index]),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.done_all,
              size: 32,
              color: AppColors.accentGreen.withOpacity(0.3),
            ),
            const SizedBox(height: 8),
            Text(
              message,
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
}

class _TodoItemWidget extends StatelessWidget {
  final TodoItem todo;

  const _TodoItemWidget({required this.todo});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: todo.isCompleted,
        onChanged: (val) {
          context.read<TodosBloc>().add(
            ToggleTodo(TodoParams.fromTodoItem(todo)),
          );
        },
        activeColor: AppColors.accentGreen,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      title: Text(
        todo.text,
        style: todo.isCompleted
            ? AppTypography.bodyMedium(
                context,
                AppColors.textPrimary(context),
              ).copyWith(
                decoration: TextDecoration.lineThrough,
                color: Colors.grey,
              )
            : AppTypography.bodyMedium(context, AppColors.textPrimary(context)),
      ),
      trailing: todo.isImportant
          ? Icon(Icons.star, color: Colors.amber, size: 16.sp)
          : null,
      onTap: () =>
          Navigator.pushNamed(context, AppRoutes.advancedTodo, arguments: todo),
    );
  }
}

class DashboardNotes extends StatelessWidget {
  const DashboardNotes({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotesBloc, NoteState>(
      builder: (context, state) {
        final recentNotes = state is NotesLoaded
            ? state.notes.take(5).toList()
            : <Note>[];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'CONTINUE WRITING',
                style: AppTypography.labelSmall(
                  context,
                  AppColors.textSecondary(context),
                ),
              ),
            ),
            if (recentNotes.isEmpty)
              _buildEmptyState(context)
            else
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: recentNotes.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) =>
                      _NoteCardItem(note: recentNotes[index]),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.description_outlined,
              size: 32,
              color: AppColors.textSecondary(context).withOpacity(0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'No notes yet',
              style: AppTypography.bodyMedium(
                context,
                AppColors.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoteCardItem extends StatelessWidget {
  final Note note;

  const _NoteCardItem({required this.note});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, AppRoutes.noteEditor, arguments: note),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              note.title.isEmpty ? 'Untitled' : note.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelLarge(
                context,
                AppColors.textPrimary(context),
              ),
            ),
            Text(
              DateFormat('MMM d').format(note.updatedAt),
              style: AppTypography.captionSmall(
                context,
                AppColors.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardMoodCheckIn extends StatelessWidget {
  const DashboardMoodCheckIn({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
        border: Border.all(color: AppColors.border(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How are you feeling?',
            style: AppTypography.labelLarge(
              context,
              AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MoodEmojiItem(emoji: '😔', label: 'Sad', mood: 'Sad'),
              _MoodEmojiItem(emoji: '😐', label: 'Neutral', mood: 'Neutral'),
              _MoodEmojiItem(emoji: '🙂', label: 'Good', mood: 'Good'),
              _MoodEmojiItem(emoji: '😊', label: 'Happy', mood: 'Happy'),
              _MoodEmojiItem(emoji: '🤩', label: 'Awesome', mood: 'Awesome'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MoodEmojiItem extends StatelessWidget {
  final String emoji;
  final String label;
  final String mood;

  const _MoodEmojiItem({
    required this.emoji,
    required this.label,
    required this.mood,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<ReflectionBloc>().add(
          LogMoodEvent(mood: mood, timestamp: DateTime.now()),
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Logged: $mood')));
      },
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.captionSmall(
              context,
              AppColors.textSecondary(context),
            ),
          ),
        ],
      ).paddingAll,
    );
  }
}

class DashboardHighlight extends StatefulWidget {
  const DashboardHighlight({super.key});

  @override
  State<DashboardHighlight> createState() => _DashboardHighlightState();
}

class _DashboardHighlightState extends State<DashboardHighlight> {
  int _activeIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotesBloc, NoteState>(
      builder: (context, state) {
        List<Note> highlightNotes = [];
        if (state is NotesLoaded) {
          highlightNotes = state.notes
              .where(
                (note) =>
                    note.tags.contains('highlight') &&
                    note.createdAt.day == DateTime.now().day &&
                    !note.isArchived,
              )
              .toList();
        }

        if (highlightNotes.isEmpty) {
          return _buildSingleHighlight(
            context,
            "No focus set for today",
            "Tap to set your main priority",
          );
        }

        if (highlightNotes.length == 1) {
          return _buildSingleHighlight(
            context,
            highlightNotes.first.title.isNotEmpty
                ? highlightNotes.first.title
                : "Today's Focus",
            highlightNotes.first.content,
          );
        }

        return Column(
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: 160.h,
                viewportFraction: 1.0,
                enlargeCenterPage: false,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 5),
                onPageChanged: (index, reason) {
                  setState(() {
                    _activeIndex = index;
                  });
                },
              ),
              items: highlightNotes.map((note) {
                return Builder(
                  builder: (BuildContext context) {
                    return _buildSingleHighlight(
                      context,
                      note.title.isNotEmpty ? note.title : "Focus Item",
                      note.content,
                    );
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 8.h),
            AnimatedSmoothIndicator(
              activeIndex: _activeIndex,
              count: highlightNotes.length,
              effect: ExpandingDotsEffect(
                dotHeight: 6,
                dotWidth: 6,
                activeDotColor: AppColors.primary,
                dotColor: AppColors.primary.withOpacity(0.2),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSingleHighlight(
    BuildContext context,
    String title,
    String content,
  ) {
    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, AppRoutes.dailyHighlightSummary),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.1),
              AppColors.primary.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.star_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.labelLarge(
                          context,
                          AppColors.textPrimary(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "Your main focus for today",
                        style: AppTypography.captionLarge(
                          context,
                          AppColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.editDailyHighlight,
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              content.isNotEmpty ? content : "No content provided",
              style: AppTypography.bodyMedium(
                context,
                AppColors.textPrimary(context),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardReflection extends StatelessWidget {
  const DashboardReflection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReflectionBloc, ReflectionState>(
      builder: (context, state) {
        final hasQuestions = state.questions.isNotEmpty;
        final questionText = hasQuestions
            ? state.questions.first.questionText
            : "No reflection questions available today.";

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withOpacity(0.1),
                AppColors.primary.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
                    ),
                    child: const Icon(
                      Icons.self_improvement,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Daily Reflection',
                    style: AppTypography.heading3(
                      context,
                      AppColors.textPrimary(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                questionText,
                style: AppTypography.bodyLarge(
                  context,
                  AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (hasQuestions) {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.reflectionEditor,
                        arguments: state.questions.first,
                      );
                    } else {
                      Navigator.pushNamed(context, AppRoutes.reflectionHome);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Answer',
                    style: AppTypography.buttonMedium(context, Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class DashboardReminders extends StatelessWidget {
  const DashboardReminders({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlarmsBloc, AlarmsState>(
      builder: (context, state) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        List<AlarmParams> upcomingReminders = [];
        if (state is AlarmsLoaded) {
          final now = DateTime.now();
          upcomingReminders = state.alarms
              .where(
                (alarm) =>
                    alarm.status != AlarmStatus.completed &&
                    (alarm.scheduledTime.year == now.year &&
                            alarm.scheduledTime.month == now.month &&
                            alarm.scheduledTime.day == now.day ||
                        alarm.scheduledTime.isAfter(now)),
              )
              .toList();
          upcomingReminders.sort(
            (a, b) => a.scheduledTime.compareTo(b.scheduledTime),
          );
          upcomingReminders = upcomingReminders.take(3).toList();
        }

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
            border: Border.all(color: AppColors.border(context), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Next Reminders',
                      style: AppTypography.labelLarge(
                        context,
                        AppColors.textSecondary(context),
                      ),
                    ),
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.remindersList),
                      child: Text(
                        'See all',
                        style: AppTypography.labelMedium(
                          context,
                          AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (upcomingReminders.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColors.border(context)),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 32,
                          color: AppColors.textSecondary(
                            context,
                          ).withOpacity(0.5),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No upcoming reminders',
                          style: AppTypography.bodyMedium(
                            context,
                            AppColors.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Column(
                  children: upcomingReminders
                      .map((alarm) => _ReminderItem(alarm: alarm))
                      .toList(),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ReminderItem extends StatelessWidget {
  final AlarmParams alarm;
  const _ReminderItem({required this.alarm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border(context))),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
            ),
            child: Icon(Icons.schedule, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alarm.message,
                  style: AppTypography.labelLarge(
                    context,
                    AppColors.textPrimary(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDateTime(alarm.scheduledTime),
                  style: AppTypography.bodySmall(
                    context,
                    AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.remindersList),
            icon: Icon(
              Icons.notifications_paused,
              size: 20,
              color: AppColors.textPrimary(context),
            ),
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final alarmDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    if (alarmDate == today) {
      return 'Today at ${DateFormat.jm().format(dateTime)}';
    }
    return DateFormat('MMM d, h:mm a').format(dateTime);
  }
}

class _ShowCommandPaletteIntent extends Intent {
  const _ShowCommandPaletteIntent();
}

extension on Widget {
  Widget get paddingAll =>
      Padding(padding: const EdgeInsets.all(4), child: this);
}
