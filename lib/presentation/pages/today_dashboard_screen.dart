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

/// Today Dashboard Screen (PREMIUM REFRESH)
/// Main overview showing stats, daily reflection prompt, and upcoming items
class TodayDashboardScreen extends StatelessWidget {
  const TodayDashboardScreen({super.key});

  void _loadDashboardData(BuildContext context) {
    AppLogger.i('Loading Dashboard Data...');
    context.read<NotesBloc>().add(const LoadNotesEvent());
    context.read<AlarmsBloc>().add(LoadAlarms());
    context.read<ReflectionBloc>().add(const InitializeReflectionEvent());
    context.read<TodosBloc>().add(LoadTodos());
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        Future.microtask(() {
          AppLogger.i('Dashboard built, triggering data load');
          _loadDashboardData(context);
        });

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
                  AppLogger.i('Dashboard manual refresh triggered');
                  HapticFeedback.mediumImpact();
                  _loadDashboardData(context);
                  await Future.delayed(const Duration(milliseconds: 800));
                },
                color: AppColors.primary,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    // --- PREMIUM HEADER ---
                    SliverToBoxAdapter(
                      child: AppAnimations.tapScale(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20.w, 60.h, 20.w, 20.h),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      greeting,
                                      style: AppTypography.heading1(context)
                                          .copyWith(
                                            fontSize: 28.sp,
                                            letterSpacing: -1,
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      DateFormat('EEEE, MMMM d').format(now),
                                      style: AppTypography.bodyMedium(context)
                                          .copyWith(
                                            color: AppColors.textSecondary(
                                              context,
                                            ),
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              _buildHeaderActions(context),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // --- STATS SECTION ---
                    SliverToBoxAdapter(
                      child: AppAnimations.slideIn(
                        // direction: Axis.vertical,
                        // offset: 30.0,
                        // delay: const Duration(milliseconds: 100),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: const DashboardStats(),
                        ),
                      ),
                    ),

                    // --- QUICK ACTIONS ---
                    SliverToBoxAdapter(
                      child: AppAnimations.slideIn(
                        // direction: Axis.vertical,
                        // offset: 30.0,
                        // delay: const Duration(milliseconds: 200),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.h),
                          child: const DashboardQuickActions(),
                        ),
                      ),
                    ),

                    // --- DAILY HIGHLIGHT ---
                    SliverToBoxAdapter(
                      child: AppAnimations.slideIn(
                        // direction: Axis.vertical,
                        // offset: 30.0,
                        // delay: const Duration(milliseconds: 300),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: const DashboardHighlight(),
                        ),
                      ),
                    ),

                    // --- REFLECTION ---
                    SliverToBoxAdapter(
                      child: AppAnimations.slideIn(
                        // direction: Axis.vertical,
                        // offset: 30.0,
                        // delay: const Duration(milliseconds: 400),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0),
                          child: const DashboardReflection(),
                        ),
                      ),
                    ),

                    // --- UPCOMING HEADER ---
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 16.h),
                        child: Text(
                          'Your Schedule',
                          style: AppTypography.heading3(
                            context,
                          ).copyWith(fontSize: 18.sp, letterSpacing: -0.5),
                        ),
                      ),
                    ),

                    // --- REMINDERS & TODOS ---
                    SliverToBoxAdapter(
                      child: AppAnimations.fadeIn(
                        // delay: const Duration(milliseconds: 500),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: const DashboardReminders(),
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: AppAnimations.fadeIn(
                        // delay: const Duration(milliseconds: 600),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
                          child: const DashboardTodos(),
                        ),
                      ),
                    ),

                    // --- RECENT NOTES & MOOD ---
                    SliverToBoxAdapter(
                      child: AppAnimations.fadeIn(
                        // delay: const Duration(milliseconds: 700),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20.w, 32.h, 20.w, 0),
                          child: const DashboardNotes(),
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: AppAnimations.fadeIn(
                        // delay: const Duration(milliseconds: 800),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 100).h,
                          child: const DashboardMoodCheckIn(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderActions(BuildContext context) {
    return Row(
      children: [
        _buildCircleIconButton(
          context,
          icon: Icons.search_rounded,
          onTap: () {
            HapticFeedback.lightImpact();
            showGlobalCommandPalette(context);
          },
        ),
        SizedBox(width: 12.w),
        _buildCircleIconButton(
          context,
          icon: Icons.person_outline_rounded,
          onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
        ),
      ],
    );
  }

  Widget _buildCircleIconButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        // width: 44.w,
        // height: 44.w,
        borderRadius: 22.r,
        blur: 15,
        // borderOpacity: 0.1,
        color: AppColors.primary.withOpacity(0.08),
        child: Icon(icon, color: AppColors.primary, size: 22.sp),
      ),
    );
  }

  String _getGreeting(int hour) {
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
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
                    GlassContainer(
                      padding: EdgeInsets.all(20.w),
                      borderRadius: AppSpacing.radiusXL,
                      blur: 15,
                      color: AppColors.surface(context).withOpacity(0.7),
                      child: Column(
                        children: [
                          Text(
                            'Today\'s Progress',
                            style: AppTypography.caption(context).copyWith(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary(context),
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
                                icon: Icons.edit_note_rounded,
                              ),
                              DashboardProgressRing(
                                title: 'Todos',
                                progress: stats.todosProgress,
                                color: AppColors.accentGreen,
                                icon: Icons.check_circle_rounded,
                              ),
                              DashboardProgressRing(
                                title: 'Mind',
                                progress: stats.reflectionsProgress,
                                color: AppColors.accentPurple,
                                icon: Icons.psychology_rounded,
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
                        SizedBox(width: 16.w),
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
          radius: 38.0.sp,
          lineWidth: 6.0.w,
          percent: progress.clamp(0.0, 1.0),
          center: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24.sp),
          ),
          progressColor: color,
          backgroundColor: color.withOpacity(0.05),
          circularStrokeCap: CircularStrokeCap.round,
          animation: true,
          animationDuration: 1500,
          curve: Curves.easeOutQuint,
        ),
        SizedBox(height: 10.h),
        Text(
          title,
          style: AppTypography.bodySmall(context).copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 11.sp,
            color: AppColors.textSecondary(context),
          ),
        ),
        Text(
          '${(progress * 100).toInt()}%',
          style: AppTypography.bodySmall(context).copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 13.sp,
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
    return GlassContainer(
      padding: EdgeInsets.all(16.w),
      borderRadius: 20.r,
      blur: 10,
      color: AppColors.surface(context).withOpacity(0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.caption(context).copyWith(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: AppColors.textSecondary(context).withOpacity(0.6),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: AppTypography.heading2(
              context,
            ).copyWith(fontSize: 20.sp, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Icon(Icons.trending_up_rounded, color: trendColor, size: 12.sp),
              SizedBox(width: 4.w),
              Text(
                trend,
                style: AppTypography.caption(
                  context,
                ).copyWith(color: trendColor, fontWeight: FontWeight.w600),
              ),
            ],
          ),
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
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          _QuickActionButton(
            icon: Icons.add_rounded,
            label: 'Note',
            color: const Color(0xFF60A5FA),
            onTap: () => Navigator.pushNamed(context, AppRoutes.noteEditor),
          ),
          SizedBox(width: 16.w),
          _QuickActionButton(
            icon: Icons.search_rounded,
            label: 'Search',
            color: const Color(0xFF818CF8),
            onTap: () => Navigator.pushNamed(context, AppRoutes.globalSearch),
          ),
          SizedBox(width: 16.w),
          _QuickActionButton(
            icon: Icons.check_circle_outline_rounded,
            label: 'Task',
            color: const Color(0xFF34D399),
            onTap: () => QuickAddBottomSheet.show(context),
          ),
          SizedBox(width: 16.w),
          _QuickActionButton(
            icon: Icons.timer_outlined,
            label: 'Focus',
            color: const Color(0xFFFBBF24),
            onTap: () => Navigator.pushNamed(context, AppRoutes.focusSession),
          ),
          SizedBox(width: 16.w),
          _QuickActionButton(
            icon: Icons.notifications_active_outlined,
            label: 'Alert',
            color: const Color(0xFFF87171),
            onTap: () => Navigator.pushNamed(context, AppRoutes.remindersList),
          ),
          SizedBox(width: 16.w),
          _QuickActionButton(
            icon: Icons.document_scanner_rounded,
            label: 'Scan',
            color: const Color(0xFFA78BFA),
            onTap: () => Navigator.pushNamed(context, AppRoutes.documentScan),
          ),
          SizedBox(width: 16.w),
          _QuickActionButton(
            icon: Icons.psychology_rounded,
            label: 'Mind',
            color: const Color(0xFFF472B6),
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
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Column(
        children: [
          GlassContainer(
            // width: 64.w,
            // height: 64.w,
            borderRadius: 20.r,
            blur: 15,
            // borderOpacity: 0.1,
            color: color.withOpacity(0.12),
            child: Center(
              child: Icon(icon, color: color, size: 28.sp),
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            label,
            style: AppTypography.caption(context).copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(context).withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
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

        return GlassContainer(
          borderRadius: 24.r,
          blur: 15,
          color: AppColors.surface(context).withOpacity(0.5),
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: AppColors.accentGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.check_box_outlined,
                        color: AppColors.accentGreen,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Text(
                      "Daily Tasks",
                      style: AppTypography.heading3(
                        context,
                      ).copyWith(fontSize: 16.sp),
                    ),
                    const Spacer(),
                    if (todos.isNotEmpty)
                      GlassContainer(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        borderRadius: 10.r,
                        color: AppColors.accentGreen.withOpacity(0.1),
                        child: Text(
                          '${todos.length} left',
                          style: TextStyle(
                            color: AppColors.accentGreen,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (todos.isEmpty)
                _buildEmptyState(
                  context,
                  'You\'ve cleared all tasks for today!',
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: todos.length > 4 ? 4 : todos.length,
                  separatorBuilder: (_, _) => Divider(
                    height: 1,
                    color: AppColors.textPrimary(context).withOpacity(0.05),
                    indent: 60.w,
                  ),
                  itemBuilder: (context, index) =>
                      _TodoItemWidget(todo: todos[index]),
                ),
              if (todos.length > 4)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Text(
                    '+ ${todos.length - 4} more tasks',
                    style: AppTypography.caption(
                      context,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 32.h),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.done_all_rounded,
                size: 32.sp,
                color: AppColors.accentGreen.withOpacity(0.4),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              style: AppTypography.bodySmall(context).copyWith(
                color: AppColors.textSecondary(context),
                fontWeight: FontWeight.w500,
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
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pushNamed(context, AppRoutes.advancedTodo, arguments: todo);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        child: Row(
          children: [
            Checkbox(
              value: todo.isCompleted,
              onChanged: (val) {
                HapticFeedback.mediumImpact();
                context.read<TodosBloc>().add(
                  ToggleTodo(TodoParams.fromTodoItem(todo)),
                );
              },
              activeColor: AppColors.accentGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.r),
              ),
            ),
            Expanded(
              child: Text(
                todo.text,
                style: AppTypography.bodyMedium(context).copyWith(
                  decoration: todo.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                  color: todo.isCompleted
                      ? AppColors.textSecondary(context)
                      : null,
                  fontWeight: todo.isImportant
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (todo.isImportant)
              Icon(Icons.star_rounded, color: Colors.amber, size: 18.sp),
            SizedBox(width: 8.w),
          ],
        ),
      ),
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
              padding: EdgeInsets.only(left: 4.w, bottom: 16.h),
              child: Text(
                'CONTINUE WRITING',
                style: AppTypography.caption(context).copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: AppColors.textSecondary(context).withOpacity(0.5),
                ),
              ),
            ),
            if (recentNotes.isEmpty)
              _buildEmptyState(context)
            else
              SizedBox(
                height: 140.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: recentNotes.length,
                  separatorBuilder: (_, _) => SizedBox(width: 16.w),
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
    return GlassContainer(
      // width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 40.h),
      borderRadius: 24.r,
      child: Column(
        children: [
          Icon(
            Icons.edit_note_rounded,
            size: 32.sp,
            color: AppColors.primary.withOpacity(0.2),
          ),
          SizedBox(height: 12.h),
          Text(
            'Your thoughts are waiting...',
            style: AppTypography.bodySmall(
              context,
            ).copyWith(color: AppColors.textSecondary(context)),
          ),
        ],
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
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pushNamed(context, AppRoutes.noteEditor, arguments: note);
      },
      child: GlassContainer(
        // width: 180.w,
        padding: EdgeInsets.all(16.w),
        borderRadius: 20.r,
        blur: 10,
        color: AppColors.surface(context).withOpacity(0.4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      DateFormat('MMM d').format(note.updatedAt),
                      style: AppTypography.caption(
                        context,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  note.title.isEmpty ? 'Untitled Brainstorm' : note.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.heading3(context).copyWith(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 16.sp,
                  color: AppColors.primary,
                ),
              ],
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
    return GlassContainer(
      padding: EdgeInsets.all(24.w),
      borderRadius: 28.r,
      blur: 20,
      color: AppColors.primary.withOpacity(0.03),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.primary,
                size: 18.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Pulse Check',
                style: AppTypography.heading3(
                  context,
                ).copyWith(fontSize: 16.sp),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'How is your energy level today?',
            style: AppTypography.bodySmall(context),
          ),
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MoodEmojiItem(emoji: '😔', label: 'Low', mood: 'Sad'),
              _MoodEmojiItem(emoji: '😐', label: 'Steady', mood: 'Neutral'),
              _MoodEmojiItem(emoji: '🙂', label: 'Good', mood: 'Good'),
              _MoodEmojiItem(emoji: '😊', label: 'High', mood: 'Happy'),
              _MoodEmojiItem(emoji: '🤩', label: 'Great', mood: 'Awesome'),
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
        HapticFeedback.heavyImpact();
        context.read<ReflectionBloc>().add(
          LogMoodEvent(mood: mood, timestamp: DateTime.now()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Energy logged: $mood'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            backgroundColor: AppColors.primary,
          ),
        );
      },
      child: Column(
        children: [
          Text(emoji, style: TextStyle(fontSize: 32.sp)),
          SizedBox(height: 8.h),
          Text(
            label,
            style: AppTypography.caption(
              context,
            ).copyWith(fontWeight: FontWeight.w600, fontSize: 10.sp),
          ),
        ],
      ),
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
            "No active focus set",
            "Set your cornerstone goal for today to stay aligned.",
          );
        }

        if (highlightNotes.length == 1) {
          return _buildSingleHighlight(
            context,
            highlightNotes.first.title.isNotEmpty
                ? highlightNotes.first.title
                : "Daily Cornerstone",
            highlightNotes.first.content,
          );
        }

        return Column(
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: 180.h,
                viewportFraction: 1.0,
                enlargeCenterPage: false,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 6),
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
            SizedBox(height: 12.h),
            AnimatedSmoothIndicator(
              activeIndex: _activeIndex,
              count: highlightNotes.length,
              effect: ExpandingDotsEffect(
                dotHeight: 4.h,
                dotWidth: 8.w,
                activeDotColor: AppColors.primary,
                dotColor: AppColors.primary.withOpacity(0.1),
                expansionFactor: 3,
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
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pushNamed(context, AppRoutes.dailyHighlightSummary);
      },
      child: GlassContainer(
        // width: double.infinity,
        padding: EdgeInsets.all(24.w),
        borderRadius: 28.r,
        blur: 20,
        color: AppColors.primary.withOpacity(0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.heading3(
                          context,
                        ).copyWith(fontSize: 16.sp, letterSpacing: -0.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "PRIORITY HIGHLIGHT",
                        style: AppTypography.caption(context).copyWith(
                          fontSize: 10.sp,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildEditButton(context),
              ],
            ),
            SizedBox(height: 20.h),
            Text(
              content.isNotEmpty
                  ? content
                  : "Define your purpose for the next 24 hours.",
              style: AppTypography.bodySmall(context).copyWith(
                height: 1.5,
                color: AppColors.textPrimary(context).withOpacity(0.8),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.mediumImpact();
        Navigator.pushNamed(context, AppRoutes.editDailyHighlight);
      },
      child: Container(
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.edit_note_rounded,
          color: AppColors.primary,
          size: 22.sp,
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
            : "Reflect on your achievements and lessons learned today.";

        return GlassContainer(
          padding: EdgeInsets.all(24.w),
          borderRadius: 28.r,
          blur: 15,
          color: const Color(0xFFC084FC).withOpacity(0.05), // Soft purple tint
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC084FC),
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFC084FC).withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.psychology_rounded,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Text(
                    'Inner Journey',
                    style: AppTypography.heading3(
                      context,
                    ).copyWith(fontSize: 16.sp),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Text(
                questionText,
                style: AppTypography.bodyMedium(
                  context,
                ).copyWith(height: 1.4, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
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
                    backgroundColor: const Color(0xFFC084FC),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Begin Reflection',
                    style: AppTypography.buttonMedium(
                      context,
                      Colors.white,
                    ).copyWith(letterSpacing: 0.5),
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

        return GlassContainer(
          borderRadius: 24.r,
          blur: 15,
          color: AppColors.surface(context).withOpacity(0.5),
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 12.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            Icons.notifications_active_rounded,
                            color: AppColors.primary,
                            size: 20.sp,
                          ),
                        ),
                        SizedBox(width: 14.w),
                        Text(
                          'Upcoming Reminders',
                          style: AppTypography.heading3(
                            context,
                          ).copyWith(fontSize: 16.sp),
                        ),
                      ],
                    ),
                    _buildSeeAllButton(context),
                  ],
                ),
              ),
              if (upcomingReminders.isEmpty)
                _buildEmptyState(context)
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

  Widget _buildSeeAllButton(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pushNamed(context, AppRoutes.remindersList);
      },
      child: Text(
        'See all',
        style: AppTypography.caption(context).copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 32.h),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 32.sp,
              color: AppColors.textSecondary(context).withOpacity(0.2),
            ),
            SizedBox(height: 12.h),
            Text(
              'No alerts for now',
              style: AppTypography.bodySmall(
                context,
              ).copyWith(color: AppColors.textSecondary(context)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderItem extends StatelessWidget {
  final AlarmParams alarm;
  const _ReminderItem({required this.alarm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.textPrimary(context).withOpacity(0.05),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              Icons.schedule_rounded,
              color: AppColors.primary,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alarm.message,
                  style: AppTypography.bodyMedium(
                    context,
                  ).copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  _formatDateTime(alarm.scheduledTime),
                  style: AppTypography.caption(
                    context,
                  ).copyWith(color: AppColors.textSecondary(context)),
                ),
              ],
            ),
          ),
          _buildActionButton(context),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pushNamed(context, AppRoutes.remindersList);
      },
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(
          Icons.chevron_right_rounded,
          size: 20.sp,
          color: AppColors.textPrimary(context).withOpacity(0.5),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    if (dateTime.day == now.day &&
        dateTime.month == now.month &&
        dateTime.year == now.year) {
      return 'Today at ${DateFormat.jm().format(dateTime)}';
    }
    return DateFormat('MMM d, h:mm a').format(dateTime);
  }
}

class _ShowCommandPaletteIntent extends Intent {
  const _ShowCommandPaletteIntent();
}
