// ════════════════════════════════════════════════════════════════════════════
// [F009/F010] DISABLED: Duplicate PomodoroTimerBloc widget
// Reason: Use FocusSessionScreen + FocusBloc instead (includes stats integration)
// File kept for reference but disabled - commented out entire widget
// ════════════════════════════════════════════════════════════════════════════

/* DISABLED - START
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/global_ui_service.dart';
import '../../injection_container.dart' show getIt;
import '../bloc/pomodoro/pomodoro_timer_bloc.dart';
import '../bloc/pomodoro/pomodoro_timer_event.dart';
import '../bloc/pomodoro/pomodoro_timer_state.dart';

/// Enhanced Pomodoro Timer Widget
/// 25-minute work sessions with 5-minute breaks
class PomodoroTimerWidget extends StatelessWidget {
  final String? taskName;
  final VoidCallback? onTimerComplete;

  const PomodoroTimerWidget({super.key, this.taskName, this.onTimerComplete});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PomodoroTimerBloc(),
      child: BlocListener<PomodoroTimerBloc, PomodoroTimerState>(
        listenWhen: (previous, current) {
          return previous.completionCount != current.completionCount;
        },
        listener: (context, state) {
          onTimerComplete?.call();
          _showNotification(state);
        },
        child: BlocBuilder<PomodoroTimerBloc, PomodoroTimerState>(
          builder: (context, state) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final isWorkSession = state.phase == PomodoroTimerPhase.work;
            final accentColor = isWorkSession
                ? AppColors.primaryColor
                : AppColors.successColor;

            return Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Session indicator
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isWorkSession
                              ? Icons.work_outline
                              : Icons.coffee_outlined,
                          size: 18.sp,
                          color: accentColor,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          _sessionLabel(state.phase),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Timer display with circular progress
                  SizedBox(
                    width: 200.w,
                    height: 200.w,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Progress circle
                        SizedBox(
                          width: 200.w,
                          height: 200.w,
                          child: CircularProgressIndicator(
                            value: state.progress,
                            strokeWidth: 8,
                            backgroundColor: isDark
                                ? Colors.grey.shade800
                                : Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation(accentColor),
                          ),
                        ),

                        // Time display
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatTime(state.secondsRemaining),
                              style: TextStyle(
                                fontSize: 48.sp,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            if (taskName != null) ...[
                              SizedBox(height: 8.h),
                              Text(
                                taskName!,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Sessions completed
                  Text(
                    'Sessions completed: ${state.sessionsCompleted}',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                  ),

                  SizedBox(height: 24.h),

                  // Control buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Reset button
                      IconButton(
                        icon: Icon(Icons.replay, size: 28.sp),
                        onPressed: () => context
                            .read<PomodoroTimerBloc>()
                            .add(const ResetTimerEvent()),
                        color: Colors.grey,
                      ),

                      SizedBox(width: 16.w),

                      // Play/Pause button
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accentColor,
                        ),
                        child: IconButton(
                          icon: Icon(
                            state.isRunning
                                ? Icons.pause
                                : Icons.play_arrow,
                            size: 36.sp,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            final bloc = context.read<PomodoroTimerBloc>();
                            if (state.isRunning) {
                              bloc.add(const PauseTimerEvent());
                            } else {
                              bloc.add(const StartTimerEvent());
                            }
                          },
                        ),
                      ),

                      SizedBox(width: 16.w),

                      // Skip button (only during work session)
                      IconButton(
                        icon: Icon(Icons.skip_next, size: 28.sp),
                        onPressed: isWorkSession
                            ? () => context
                                .read<PomodoroTimerBloc>()
                                .add(const SkipPhaseEvent())
                            : null,
                        color: isWorkSession
                            ? Colors.grey
                            : Colors.grey.shade300,
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  // Settings
                  TextButton.icon(
                    icon: const Icon(Icons.settings_outlined),
                    label: const Text('Customize Duration'),
                    onPressed: () => _showSettingsDialog(context),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _sessionLabel(PomodoroTimerPhase phase) {
    switch (phase) {
      case PomodoroTimerPhase.work:
        return 'Focus Session';
      case PomodoroTimerPhase.shortBreak:
        return 'Break Time';
      case PomodoroTimerPhase.longBreak:
        return 'Long Break';
    }
  }

  void _showNotification(PomodoroTimerState state) {
    if (state.lastCompletedPhase == PomodoroTimerPhase.work) {
      getIt<GlobalUiService>().showInfo(
        '⏰ Work session complete! Time for a break!',
      );
      return;
    }

    getIt<GlobalUiService>().showSuccess(
      '🎉 Break time complete! Ready to focus?',
    );
  }

  Future<void> _showSettingsDialog(BuildContext context) async {
    final bloc = context.read<PomodoroTimerBloc>();
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: bloc,
          child: AlertDialog(
            title: const Text('Pomodoro Settings'),
            content: BlocBuilder<PomodoroTimerBloc, PomodoroTimerState>(
              builder: (context, state) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: const Text('Work Duration'),
                      subtitle: Text('${state.workDuration ~/ 60} minutes'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              if (state.workDuration > 60) {
                                bloc.add(
                                  UpdateWorkDurationEvent(
                                    state.workDuration - 60,
                                  ),
                                );
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              bloc.add(
                                UpdateWorkDurationEvent(
                                  state.workDuration + 60,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      title: const Text('Break Duration'),
                      subtitle: Text('${state.breakDuration ~/ 60} minutes'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              if (state.breakDuration > 60) {
                                bloc.add(
                                  UpdateBreakDurationEvent(
                                    state.breakDuration - 60,
                                  ),
                                );
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              bloc.add(
                                UpdateBreakDurationEvent(
                                  state.breakDuration + 60,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }
}DISABLED - END */
