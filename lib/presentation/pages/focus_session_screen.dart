import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mynotes/core/constants/app_colors.dart';
import 'package:mynotes/presentation/bloc/focus/focus_bloc.dart';
import 'package:mynotes/presentation/bloc/note/note_bloc.dart';
import 'package:mynotes/presentation/bloc/note/note_state.dart';
import 'package:mynotes/presentation/bloc/note/note_event.dart';
import 'package:mynotes/core/services/app_logger.dart';
import 'package:mynotes/presentation/design_system/app_typography.dart';
import 'package:mynotes/presentation/widgets/focus/focus_lock_toggle.dart';
import 'package:mynotes/presentation/widgets/focus/dnd_permission_banner.dart';
import 'focus_celebration_screen.dart';

/// Focus Session Active Screen
/// Pomodoro timer with immersive gradient design and task selection
class FocusSessionScreen extends StatefulWidget {
  const FocusSessionScreen({super.key});

  @override
  State<FocusSessionScreen> createState() => _FocusSessionScreenState();
}

class _FocusSessionScreenState extends State<FocusSessionScreen> {
  @override
  void initState() {
    super.initState();
    // FIX F003: Moved from build() to initState() to prevent re-initialization on rebuild
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initFocusScreen(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FocusBloc, FocusState>(
      listener: (context, state) {
        if (state.status == FocusStatus.completed) {
          HapticFeedback.heavyImpact();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => FocusCelebrationScreen(
                minutesFocused:
                    state.initialMinutes *
                    (state.completedWorkSessions > 0
                        ? state.completedWorkSessions
                        : 1),
                streakDays: 1, // Placeholder for streak
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        // If we are in initial state and selection step is true, show selection
        if (state.status == FocusStatus.initial && state.isTaskSelectionStep) {
          return _buildTaskSelectionView(context);
        }

        final isPaused = state.status == FocusStatus.paused;
        final minutes = (state.secondsRemaining ~/ 60).toString().padLeft(
          2,
          '0',
        );
        final seconds = (state.secondsRemaining % 60).toString().padLeft(
          2,
          '0',
        );
        final progress = state.totalSeconds > 0
            ? 1.0 - (state.secondsRemaining / state.totalSeconds)
            : 0.0;

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.8, -0.8),
                radius: 1.5,
                colors: [
                  AppColors.focusDeepViolet,
                  AppColors.focusMidnightBlue,
                ],
              ),
            ),
            child: Stack(
              children: [
                _buildBackgroundOrbs(),
                _WakelockToggle(enabled: state.status == FocusStatus.active),
                SafeArea(
                  child: Column(
                    children: [
                      _buildHeader(context, state),
                      Expanded(
                        child: _buildTimerSection(
                          context,
                          minutes,
                          seconds,
                          progress,
                          state,
                        ),
                      ),
                      _buildBottomSection(context, state, isPaused),
                    ],
                  ),
                ),
                if (state.showSettings) _buildSettingsOverlay(context, state),
              ],
            ),
          ),
        );
      },
    );
  }

  void _initFocusScreen(BuildContext context) {
    AppLogger.i('FocusSessionScreen: _initFocusScreen called');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load auto-DND preference
      context.read<FocusBloc>().add(const LoadAutoDndPreferenceEvent());

      // Trigger load notes for selection if needed
      context.read<NotesBloc>().add(const LoadNotesEvent());

      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        if (args['todoTitle'] != null && args['todoId'] != null) {
          AppLogger.i(
            'FocusSessionScreen: Initializing with passed todo: ${args['todoTitle']}',
          );
          context.read<FocusBloc>().add(
            SelectTaskEvent(
              title: args['todoTitle'] as String,
              todoId: args['todoId'] as String?,
            ),
          );
        }
      } else {
        // No todo passed, show task selection first if initial
        final currentStatus = context.read<FocusBloc>().state.status;
        if (currentStatus == FocusStatus.initial) {
          AppLogger.i('FocusSessionScreen: Showing task selection');
          context.read<FocusBloc>().add(const ToggleTaskSelectionEvent(true));
        }
      }
    });
  }

  void _startSession(BuildContext context) async {
    AppLogger.i('FocusSessionScreen: Attempting to start session');
    final focusState = context.read<FocusBloc>().state;
    if (focusState.distractionFreeMode) {
      // Ask about auto-DND on first time if not asked before
      if (!focusState.autoDndAsked) {
        final enableAutoDnd = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.darkCardBackground,
            title: Text(
              'Auto-Enable Do Not Disturb?',
              style: AppTypography.heading3(
                context,
              ).copyWith(color: Colors.white),
            ),
            content: Text(
              'Would you like MyNotes to automatically enable "Do Not Disturb" mode on your device when you start a focus session? This will minimize distractions and help you stay focused.',
              style: AppTypography.bodyMedium(
                context,
              ).copyWith(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  AppLogger.i('FocusSessionScreen: Auto-DND declined');
                  context.read<FocusBloc>().add(
                    const SetAutoDndPreferenceEvent(false),
                  );
                  Navigator.pop(context, false);
                },
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () {
                  AppLogger.i('FocusSessionScreen: Auto-DND enabled');
                  context.read<FocusBloc>().add(
                    const SetAutoDndPreferenceEvent(true),
                  );
                  Navigator.pop(context, true);
                },
                child: Text(
                  'Yes',
                  style: TextStyle(color: AppColors.focusAccentGreen),
                ),
              ),
            ],
          ),
        );

        // Don't continue if dialog was dismissed
        if (enableAutoDnd == null) return;
      }

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.darkCardBackground,
          title: Text(
            'Enable Silent Mode?',
            style: AppTypography.heading3(
              context,
            ).copyWith(color: Colors.white),
          ),
          content: Text(
            focusState.autoDndEnabled
                ? 'Ready to focus? We\'ll automatically enable "Do Not Disturb" on your device.'
                : 'To ensure deep focus, please enable "Do Not Disturb" on your device settings manually. We will minimize in-app distractions.',
            style: AppTypography.bodyMedium(
              context,
            ).copyWith(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                AppLogger.i('FocusSessionScreen: Silent mode cancelled');
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                AppLogger.i('FocusSessionScreen: Silent mode confirmed');
                Navigator.pop(context, true);
              },
              child: Text(
                focusState.autoDndEnabled ? 'Start Session' : 'I enabled it',
                style: TextStyle(color: AppColors.focusAccentGreen),
              ),
            ),
          ],
        ),
      );

      if (confirmed != true) return;
    }

    AppLogger.i(
      'FocusSessionScreen: Starting session: ${focusState.initialTaskTitle}',
    );
    context.read<FocusBloc>().add(
      StartFocusSessionEvent(
        minutes: focusState.initialMinutes,
        taskTitle: focusState.initialTaskTitle,
        category: focusState.currentCategory,
        todoId: focusState.linkedTodoId,
      ),
    );

    // Hide task selection screen
    context.read<FocusBloc>().add(const ToggleTaskSelectionEvent(false));
  }

  void _selectTask(BuildContext context, String title, String? id) {
    AppLogger.i('FocusSessionScreen: _selectTask: $title');
    context.read<FocusBloc>().add(SelectTaskEvent(title: title, todoId: id));
  }

  void _togglePause(BuildContext context, FocusStatus status) {
    if (status == FocusStatus.active) {
      AppLogger.i('FocusSessionScreen: Pausing session');
      context.read<FocusBloc>().add(const PauseFocusSessionEvent());
    } else {
      AppLogger.i('FocusSessionScreen: Resuming session');
      context.read<FocusBloc>().add(const ResumeFocusSessionEvent());
    }
  }

  Future<void> _stopSession(BuildContext context) async {
    AppLogger.i('FocusSessionScreen: _stopSession called');
    bool? shouldStop = true;
    final currentState = context.read<FocusBloc>().state;
    if (currentState.status == FocusStatus.active ||
        currentState.status == FocusStatus.paused) {
      shouldStop = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.darkCardBackground,
          title: Text(
            'End Session?',
            style: AppTypography.titleMedium(
              context,
            ).copyWith(color: Colors.white),
          ),
          content: Text(
            'This will save your partial progress and end the current session.',
            style: AppTypography.bodyMedium(
              context,
            ).copyWith(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                AppLogger.i('FocusSessionScreen: End session cancelled');
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                AppLogger.i('FocusSessionScreen: End session confirmed');
                Navigator.pop(context, true);
              },
              child: const Text(
                'End Session',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );
    }

    if (shouldStop == true) {
      AppLogger.i('FocusSessionScreen: Stopping session');
      context.read<FocusBloc>().add(const StopFocusSessionEvent());
      Navigator.pop(context);
    }
  }

  void _toggleSettings(BuildContext context) {
    AppLogger.i('FocusSessionScreen: Toggling settings');
    context.read<FocusBloc>().add(const ToggleSettingsEvent());
  }

  Widget _buildTaskSelectionView(BuildContext context) {
    AppLogger.i('FocusSessionScreen: Building task selection view');
    return Scaffold(
      backgroundColor: AppColors.focusMidnightBlue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            AppLogger.i('FocusSessionScreen: Task selection close pressed');
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Select Focus Task',
          style: AppTypography.heading3(context).copyWith(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: GestureDetector(
              onTap: () => _selectTask(context, 'Focused Work Session', null),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 24.w),
                decoration: BoxDecoration(
                  color: AppColors.focusDeepViolet.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: AppColors.focusAccentGreen.withOpacity(0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.bolt,
                      color: AppColors.focusAccentGreen,
                      size: 24.sp,
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Text(
                        'Focus without specific task',
                        style: AppTypography.bodyLarge(context).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white54,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'OR SELECT A TODO',
                style: AppTypography.caption(context, Colors.white54),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<NotesBloc, NoteState>(
              builder: (context, state) {
                if (state is NotesLoaded) {
                  final todos = state.notes.where((n) => n.hasTodos).toList();
                  if (todos.isEmpty) {
                    return const Center(
                      child: Text(
                        'No active todos found',
                        style: TextStyle(color: Colors.white54),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: todos.length,
                    itemBuilder: (context, index) {
                      final todo = todos[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: ListTile(
                          title: Text(
                            todo.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: todo.tags.isNotEmpty
                              ? Text(
                                  todo.tags.join(', '),
                                  style: const TextStyle(color: Colors.white38),
                                )
                              : null,
                          trailing: const Icon(
                            Icons.play_circle_outline,
                            color: Colors.white,
                          ),
                          onTap: () =>
                              _selectTask(context, todo.title, todo.id),
                        ),
                      );
                    },
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundOrbs() {
    return Stack(
      children: [
        Positioned(
          top: -160.h,
          left: -160.w,
          child: Container(
            width: 500.w,
            height: 500.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.focusPurpleOrb.withOpacity(0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -160.h,
          right: -160.w,
          child: Container(
            width: 500.w,
            height: 500.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.focusBlueOrb.withOpacity(0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, FocusState state) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildGlassButton(
            Icons.keyboard_arrow_down_rounded,
            () => Navigator.pop(context),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'FOCUS SESSION',
                style: AppTypography.captionSmall(null).copyWith(
                  color: Colors.white.withOpacity(0.6),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                  fontSize: 10.sp,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'TODAY: ${state.todayTotalFocusMinutes}m',
                style: AppTypography.captionSmall(null).copyWith(
                  color: AppColors.focusAccentGreen.withOpacity(0.8),
                  fontWeight: FontWeight.bold,
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),
          _buildGlassButton(
            Icons.settings_outlined,
            () => _toggleSettings(context),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
        ),
        child: Icon(icon, color: Colors.white.withOpacity(0.8), size: 24.sp),
      ),
    );
  }

  Widget _buildTimerSection(
    BuildContext context,
    String minutes,
    String seconds,
    double progress,
    FocusState state,
  ) {
    final status = state.status;
    final taskTitle = state.currentTaskTitle ?? 'Untitled';
    final isBreak = state.isBreak;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 320.w,
            height: 320.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.05),
                      width: 8.w,
                    ),
                  ),
                ),
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8.w,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.focusAccentGreen,
                  ),
                  backgroundColor: Colors.transparent,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$minutes:$seconds',
                      style: TextStyle(
                        fontSize: 72.sp,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                        height: 1,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    if (status == FocusStatus.active) const _LiveIndicator(),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 32.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: isBreak
                  ? Colors.orange.withOpacity(0.15)
                  : AppColors.focusAccentGreen.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isBreak
                    ? Colors.orange.withOpacity(0.3)
                    : AppColors.focusAccentGreen.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              isBreak ? 'BREAK' : 'FOCUS',
              style: TextStyle(
                color: isBreak ? Colors.orange : AppColors.focusAccentGreen,
                fontWeight: FontWeight.bold,
                fontSize: 12.sp,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            taskTitle,
            textAlign: TextAlign.center,
            style: AppTypography.titleLarge(
              null,
              Colors.white,
            ).copyWith(fontSize: 24.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            'Session ${state.completedWorkSessions + 1} of ${state.sessionsBeforeLongBreak}',
            style: TextStyle(color: Colors.white54, fontSize: 14.sp),
          ),
          SizedBox(height: 16.h),
          const DndPermissionBanner(),
        ],
      ),
    );
  }

  Widget _buildBottomSection(
    BuildContext context,
    FocusState state,
    bool isPaused,
  ) {
    if (state.status == FocusStatus.initial) {
      return Padding(
        padding: EdgeInsets.only(bottom: 40.h, left: 32.w, right: 32.w),
        child: SizedBox(
          width: double.infinity,
          height: 56.h,
          child: ElevatedButton(
            onPressed: () => _startSession(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.focusAccentGreen,
              foregroundColor: AppColors.focusMidnightBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            child: const Text(
              'Start Session',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 40.h, left: 32.w, right: 32.w),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _ControlButton(
                  icon: isPaused ? Icons.play_arrow : Icons.pause,
                  label: isPaused ? 'Resume' : 'Pause',
                  onTap: () => _togglePause(context, state.status),
                ),
              ),
              SizedBox(width: 16.w),
              _ControlButton(
                icon: Icons.stop,
                label: 'Stop',
                onTap: () => _stopSession(context),
                isDestructive: true,
              ),
            ],
          ),
          if (state.isBreak) ...[
            SizedBox(height: 16.h),
            TextButton(
              onPressed: () {
                AppLogger.i('FocusSessionScreen: Skip Break pressed');
                context.read<FocusBloc>().add(const SkipBreakEvent());
              },
              child: const Text(
                'Skip Break',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSettingsOverlay(BuildContext context, FocusState state) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Container(
          margin: EdgeInsets.all(24.w),
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: AppColors.darkCardBackground,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Session Settings',
                    style: AppTypography.heading3(
                      context,
                    ).copyWith(color: Colors.white),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => _toggleSettings(context),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              _SettingsSlider(
                label: 'Focus Duration',
                value: state.initialMinutes,
                min: 15,
                max: 60,
                divisions: 9,
                onChanged: (val) {
                  AppLogger.i(
                    'FocusSessionScreen: Focus duration changed to $val',
                  );
                  context.read<FocusBloc>().add(
                    UpdateFocusSettingsEvent(minutes: val),
                  );
                },
              ),
              _SettingsSlider(
                label: 'Short Break',
                value: state.shortBreakMinutes,
                min: 3,
                max: 15,
                divisions: 12,
                onChanged: (val) {
                  AppLogger.i(
                    'FocusSessionScreen: Short break changed to $val',
                  );
                  context.read<FocusBloc>().add(
                    UpdateFocusSettingsEvent(shortBreakMinutes: val),
                  );
                },
              ),
              _SettingsSlider(
                label: 'Long Break',
                value: state.longBreakMinutes,
                min: 10,
                max: 45,
                divisions: 7,
                onChanged: (val) {
                  AppLogger.i('FocusSessionScreen: Long break changed to $val');
                  context.read<FocusBloc>().add(
                    UpdateFocusSettingsEvent(longBreakMinutes: val),
                  );
                },
              ),
              _SettingsSlider(
                label: 'Sessions per Cycle',
                value: state.sessionsBeforeLongBreak,
                min: 1,
                max: 8,
                divisions: 7,
                onChanged: (val) {
                  AppLogger.i(
                    'FocusSessionScreen: Sessions per cycle changed to $val',
                  );
                  context.read<FocusBloc>().add(
                    UpdateFocusSettingsEvent(sessionsBeforeLongBreak: val),
                  );
                },
              ),
              SwitchListTile(
                activeColor: AppColors.focusAccentGreen,
                title: const Text(
                  'Deep Focus Mode (Silent)',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  'Ask to enable DND before session',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                value: state.distractionFreeMode,
                onChanged: (val) {
                  AppLogger.i(
                    'FocusSessionScreen: Deep Focus Mode changed to $val',
                  );
                  context.read<FocusBloc>().add(
                    UpdateDistractionFreeModeEvent(val),
                  );
                },
              ),
              const FocusLockToggle(),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiveIndicator extends StatelessWidget {
  const _LiveIndicator();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      builder: (context, value, child) {
        return Opacity(opacity: value, child: child);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: AppColors.focusAccentGreen,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            'LIVE',
            style: TextStyle(
              color: AppColors.focusAccentGreen,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56.h,
        decoration: BoxDecoration(
          color: isDestructive
              ? Colors.red.withOpacity(0.2)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isDestructive
                ? Colors.red.withOpacity(0.5)
                : Colors.white.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 8.w),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSlider extends StatelessWidget {
  final String label;
  final int value;
  final double min;
  final double max;
  final int divisions;
  final Function(int) onChanged;

  const _SettingsSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70)),
            Text(
              '$value min',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Slider(
          value: value.toDouble(),
          min: min,
          max: max,
          divisions: divisions,
          activeColor: AppColors.focusAccentGreen,
          onChanged: (val) => onChanged(val.round()),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }
}

class _WakelockToggle extends StatelessWidget {
  final bool enabled;
  const _WakelockToggle({required this.enabled});

  @override
  Widget build(BuildContext context) {
    if (enabled) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }
    return const SizedBox.shrink();
  }
}
