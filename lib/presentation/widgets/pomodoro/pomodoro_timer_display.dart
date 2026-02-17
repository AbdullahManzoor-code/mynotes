import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mynotes/core/extensions/context_extensions.dart';
import 'package:mynotes/presentation/design_system/design_system.dart';

/// ════════════════════════════════════════════════════════════════════════════
/// PHASE 6: FOCUS & POMODORO
/// Pomodoro Timer Display - Focus session timer widget
/// ════════════════════════════════════════════════════════════════════════════

enum PomodoroSessionType { focus, shortBreak, longBreak }

class PomodoroTimer {
  final String id;
  final String name;
  final int focusMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final int sessionsBeforeLongBreak;
  Duration remainingTime;
  PomodoroSessionType currentSession;
  bool isRunning;
  int completedSessions;

  PomodoroTimer({
    required this.id,
    required this.name,
    this.focusMinutes = 25,
    this.shortBreakMinutes = 5,
    this.longBreakMinutes = 15,
    this.sessionsBeforeLongBreak = 4,
    required this.remainingTime,
    this.currentSession = PomodoroSessionType.focus,
    this.isRunning = false,
    this.completedSessions = 0,
  });
}

class PomodoroTimerDisplay extends StatelessWidget {
  final PomodoroTimer timer;
  final Function()? onStart;
  final Function()? onPause;
  final Function()? onResume;
  final Function()? onStop;
  final Function()? onAdvanceSession;

  const PomodoroTimerDisplay({
    super.key,
    required this.timer,
    this.onStart,
    this.onPause,
    this.onResume,
    this.onStop,
    this.onAdvanceSession,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: context.theme.dividerColor, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    timer.name,
                    style: AppTypography.heading2(
                      context,
                    ).copyWith(fontSize: 16.sp, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _getSessionLabel(timer.currentSession),
                    style: AppTypography.body2(context).copyWith(
                      fontSize: 11.sp,
                      color: _getSessionColor(context, timer.currentSession),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  'Sessions: ${timer.completedSessions}',
                  style: AppTypography.caption(context).copyWith(
                    fontSize: 10.sp,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          // Timer display
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Circular progress
                SizedBox(
                  width: 160.r,
                  height: 160.r,
                  child: CircularProgressIndicator(
                    value: _getProgressValue(),
                    strokeWidth: 6.r,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getSessionColor(context, timer.currentSession),
                    ),
                    backgroundColor: context.theme.dividerColor.withOpacity(
                      0.2,
                    ),
                  ),
                ),
                // Time display
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formatTime(timer.remainingTime),
                      style: AppTypography.heading1(context).copyWith(
                        fontSize: 48.sp,
                        fontWeight: FontWeight.w600,
                        color: _getSessionColor(context, timer.currentSession),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      timer.isRunning ? '⏱️ Running' : '⏸️ Paused',
                      style: AppTypography.body2(context).copyWith(
                        fontSize: 11.sp,
                        color: context.theme.disabledColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingActionButton(
                mini: true,
                onPressed: timer.isRunning ? null : onStart ?? onResume,
                backgroundColor: timer.isRunning
                    ? Colors.grey
                    : AppColors.primary,
                child: Icon(timer.isRunning ? Icons.pause : Icons.play_arrow),
              ),
              FloatingActionButton(
                mini: true,
                onPressed: onStop,
                backgroundColor: Colors.red,
                child: const Icon(Icons.stop),
              ),
              FloatingActionButton(
                mini: true,
                onPressed: onAdvanceSession,
                backgroundColor: Colors.blue,
                child: const Icon(Icons.skip_next),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _getSessionLabel(PomodoroSessionType type) {
    switch (type) {
      case PomodoroSessionType.focus:
        return 'Focus Time';
      case PomodoroSessionType.shortBreak:
        return 'Short Break';
      case PomodoroSessionType.longBreak:
        return 'Long Break';
    }
  }

  Color _getSessionColor(BuildContext context, PomodoroSessionType type) {
    switch (type) {
      case PomodoroSessionType.focus:
        return Colors.red;
      case PomodoroSessionType.shortBreak:
        return Colors.green;
      case PomodoroSessionType.longBreak:
        return Colors.blue;
    }
  }

  double _getProgressValue() {
    final total = switch (timer.currentSession) {
      PomodoroSessionType.focus => timer.focusMinutes * 60,
      PomodoroSessionType.shortBreak => timer.shortBreakMinutes * 60,
      PomodoroSessionType.longBreak => timer.longBreakMinutes * 60,
    };

    return 1 - (timer.remainingTime.inSeconds / total);
  }
}
