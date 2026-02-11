import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mynotes/core/constants/app_colors.dart';
import 'package:mynotes/domain/entities/note.dart';
import 'package:mynotes/presentation/bloc/focus_bloc.dart';
import 'package:mynotes/presentation/bloc/note_bloc.dart';
import 'package:mynotes/presentation/bloc/note_state.dart';
import 'package:mynotes/presentation/bloc/note_event.dart';
import 'package:mynotes/presentation/design_system/app_typography.dart';
import 'focus_celebration_screen.dart';

/// Focus Session Active Screen
/// Pomodoro timer with immersive gradient design and task selection
class FocusSessionScreen extends StatefulWidget {
  const FocusSessionScreen({super.key});

  @override
  State<FocusSessionScreen> createState() => _FocusSessionScreenState();
}

class _FocusSessionScreenState extends State<FocusSessionScreen>
    with TickerProviderStateMixin {
  bool _isTaskSelectionStep = false;
  bool _showSettings = false;
  bool _distractionFreeMode = false;

  // Session settings
  int _focusMinutes = 25;
  int _shortBreakMinutes = 5;
  int _longBreakMinutes = 15;
  int _sessionsBeforeLongBreak = 4;

  String _selectedCategory = 'Focus';
  final List<String> _categories = [
    'Focus',
    'Work',
    'Study',
    'Personal',
    'Other',
  ];

  // Ambient sound
  String _selectedSound = 'None';
  final List<String> _ambientSounds = [
    'None',
    'Rain',
    'Forest',
    'Ocean',
    'Coffee Shop',
    'White Noise',
  ];

  String _taskTitle = 'Focused Work Session';
  String? _todoId;

  late AnimationController _pulseController;
  late AnimationController _settingsController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _settingsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Trigger load notes for selection if needed
    context.read<NotesBloc>().add(const LoadNotesEvent());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      if (args['todoTitle'] != null) {
        _taskTitle = args['todoTitle'] as String;
      }
      if (args['todoId'] != null) {
        _todoId = args['todoId'] as String;
      }
      // If we have a todo, we skip selection
      _isTaskSelectionStep = false;
    } else {
      // No todo passed, show selection first
      // But only if we are in initial status
      final currentStatus = context.read<FocusBloc>().state.status;
      if (currentStatus == FocusStatus.initial) {
        _isTaskSelectionStep = true;
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _settingsController.dispose();
    super.dispose();
  }

  void _startSession() async {
    if (_distractionFreeMode) {
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
            'To ensure deep focus, please enable "Do Not Disturb" on your device settings. We will minimize in-app distractions.',
            style: AppTypography.bodyMedium(
              context,
            ).copyWith(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false), // Cancel
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true), // Proceed
              child: Text(
                'I enabled it',
                style: TextStyle(color: AppColors.focusAccentGreen),
              ),
            ),
          ],
        ),
      );

      if (confirmed != true) return;
    }

    if (!mounted) return;

    context.read<FocusBloc>().add(
      StartFocusSessionEvent(
        minutes: _focusMinutes,
        taskTitle: _taskTitle,
        category: _selectedCategory,
        todoId: _todoId,
      ),
    );

    // Update settings in bloc
    context.read<FocusBloc>().add(
      UpdateFocusSettingsEvent(
        shortBreakMinutes: _shortBreakMinutes,
        longBreakMinutes: _longBreakMinutes,
        sessionsBeforeLongBreak: _sessionsBeforeLongBreak,
      ),
    );

    setState(() {
      _isTaskSelectionStep = false;
    });
  }

  void _selectTask(String title, String? id) {
    setState(() {
      _taskTitle = title;
      _todoId = id;
      _isTaskSelectionStep = false;
    });
    // Auto start or let user review? Let's just go to timer view ready to start
  }

  void _togglePause(FocusStatus status) {
    if (status == FocusStatus.active) {
      context.read<FocusBloc>().add(const PauseFocusSessionEvent());
    } else {
      context.read<FocusBloc>().add(const ResumeFocusSessionEvent());
    }
  }

  Future<void> _stopSession() async {
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
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
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
      if (!mounted) return;
      context.read<FocusBloc>().add(const StopFocusSessionEvent());
      Navigator.pop(context);
    }
  }

  void _toggleSettings() {
    setState(() {
      _showSettings = !_showSettings;
    });
    if (_showSettings) {
      _settingsController.forward();
    } else {
      _settingsController.reverse();
    }
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
        if (state.status == FocusStatus.initial && _isTaskSelectionStep) {
          return _buildTaskSelectionView();
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

        // Sync local state if initial
        if (state.status == FocusStatus.initial) {
          _focusMinutes = state.initialMinutes;
          // Don't overwrite title if we just selected it
          // _taskTitle = state.initialTaskTitle;
        }

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
                SafeArea(
                  child: Column(
                    children: [
                      _buildHeader(),
                      Expanded(
                        child: _buildTimerSection(
                          minutes,
                          seconds,
                          progress,
                          state,
                        ),
                      ),
                      _buildBottomSection(state, isPaused),
                    ],
                  ),
                ),
                if (_showSettings) _buildSettingsOverlay(state.status),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTaskSelectionView() {
    return Scaffold(
      backgroundColor: AppColors.focusMidnightBlue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
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
              onTap: () {
                setState(() {
                  _taskTitle = 'Focused Work Session';
                  _todoId = null;
                  _isTaskSelectionStep = false;
                });
              },
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
                    return Center(
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
                                  style: TextStyle(color: Colors.white38),
                                )
                              : null,
                          trailing: const Icon(
                            Icons.play_circle_outline,
                            color: Colors.white,
                          ),
                          onTap: () => _selectTask(todo.title, todo.id),
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

  Widget _buildHeader() {
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
                'TODAY: ${context.read<FocusBloc>().state.todayTotalFocusMinutes}m',
                style: AppTypography.captionSmall(null).copyWith(
                  color: AppColors.focusAccentGreen.withOpacity(0.8),
                  fontWeight: FontWeight.bold,
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),
          _buildGlassButton(Icons.settings_outlined, _toggleSettings),
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
    String minutes,
    String seconds,
    double progress,
    FocusState state,
  ) {
    final status = state.status;
    final taskTitle = state.currentTaskTitle ?? 'Untitled';
    final isBreak = state.isBreak;
    final sessionType = state.sessionType;

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

                // Alternative Timer Ring Painter could go here if implemented
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
                    if (status == FocusStatus.active) _buildLiveIndicator(),
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
        ],
      ),
    );
  }

  Widget _buildLiveIndicator() {
    return FadeTransition(
      opacity: _pulseController,
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

  Widget _buildBottomSection(FocusState state, bool isPaused) {
    if (state.status == FocusStatus.initial) {
      return Padding(
        padding: EdgeInsets.only(bottom: 40.h, left: 32.w, right: 32.w),
        child: SizedBox(
          width: double.infinity,
          height: 56.h,
          child: ElevatedButton(
            onPressed: _startSession,
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
                child: _buildControlButton(
                  icon: isPaused ? Icons.play_arrow : Icons.pause,
                  label: isPaused ? 'Resume' : 'Pause',
                  onTap: () => _togglePause(state.status),
                ),
              ),
              SizedBox(width: 16.w),
              _buildControlButton(
                icon: Icons.stop,
                label: 'Stop',
                onTap: _stopSession,
                isDestructive: true,
              ),
            ],
          ),
          if (state.isBreak) ...[
            SizedBox(height: 16.h),
            TextButton(
              onPressed: () =>
                  context.read<FocusBloc>().add(const SkipBreakEvent()),
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

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
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

  Widget _buildSettingsOverlay(FocusStatus status) {
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
                    onPressed: _toggleSettings,
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              _buildSettingSlider('Focus Duration', _focusMinutes, 15, 60, 5, (
                val,
              ) {
                setState(() => _focusMinutes = val);
                if (status == FocusStatus.initial) {
                  context.read<FocusBloc>().add(
                    UpdateFocusSettingsEvent(minutes: val),
                  );
                }
              }),
              _buildSettingSlider(
                'Short Break',
                _shortBreakMinutes,
                3,
                15,
                1,
                (val) => setState(() => _shortBreakMinutes = val),
              ),
              _buildSettingSlider(
                'Long Break',
                _longBreakMinutes,
                10,
                45,
                5,
                (val) => setState(() => _longBreakMinutes = val),
              ),
              _buildSettingSlider(
                'Sessions per Cycle',
                _sessionsBeforeLongBreak,
                1,
                8,
                1,
                (val) => setState(() => _sessionsBeforeLongBreak = val),
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
                value: _distractionFreeMode,
                onChanged: (val) => setState(() => _distractionFreeMode = val),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingSlider(
    String label,
    int value,
    double min,
    double max,
    int divisions,
    Function(int) onChanged,
  ) {
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
          divisions: ((max - min) / divisions).round(),
          activeColor: AppColors.focusAccentGreen,
          onChanged: (val) => onChanged(val.round()),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }
}
