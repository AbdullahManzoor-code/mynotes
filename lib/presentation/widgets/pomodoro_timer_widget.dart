import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';

/// Enhanced Pomodoro Timer Widget
/// 25-minute work sessions with 5-minute breaks
class PomodoroTimerWidget extends StatefulWidget {
  final String? taskName;
  final VoidCallback? onTimerComplete;

  const PomodoroTimerWidget({super.key, this.taskName, this.onTimerComplete});

  @override
  State<PomodoroTimerWidget> createState() => _PomodoroTimerWidgetState();
}

class _PomodoroTimerWidgetState extends State<PomodoroTimerWidget> {
  Timer? _timer;
  int _workDuration = 25 * 60; // 25 minutes in seconds
  int _breakDuration = 5 * 60; // 5 minutes in seconds
  final int _longBreakDuration = 15 * 60; // 15 minutes
  int _secondsRemaining = 25 * 60;
  bool _isRunning = false;
  bool _isWorkSession = true;
  int _sessionsCompleted = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _handleTimerComplete();
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _secondsRemaining = _isWorkSession ? _workDuration : _breakDuration;
    });
  }

  void _handleTimerComplete() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      if (_isWorkSession) {
        _sessionsCompleted++;
        // Long break after 4 sessions
        if (_sessionsCompleted % 4 == 0) {
          _secondsRemaining = _longBreakDuration;
        } else {
          _secondsRemaining = _breakDuration;
        }
        _isWorkSession = false;
      } else {
        _secondsRemaining = _workDuration;
        _isWorkSession = true;
      }
    });

    widget.onTimerComplete?.call();
    _showNotification();
  }

  void _showNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isWorkSession
              ? '🎉 Break time complete! Ready to focus?'
              : '⏰ Work session complete! Time for a break!',
        ),
        backgroundColor: AppColors.successColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _skipToBreak() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isWorkSession = false;
      _secondsRemaining = _breakDuration;
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  double get _progress {
    final totalDuration = _isWorkSession ? _workDuration : _breakDuration;
    return 1 - (_secondsRemaining / totalDuration);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: _isWorkSession
                  ? AppColors.primaryColor.withOpacity(0.1)
                  : AppColors.successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isWorkSession ? Icons.work_outline : Icons.coffee_outlined,
                  size: 18.sp,
                  color: _isWorkSession
                      ? AppColors.primaryColor
                      : AppColors.successColor,
                ),
                SizedBox(width: 8.w),
                Text(
                  _isWorkSession ? 'Focus Session' : 'Break Time',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: _isWorkSession
                        ? AppColors.primaryColor
                        : AppColors.successColor,
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
                    value: _progress,
                    strokeWidth: 8,
                    backgroundColor: isDark
                        ? Colors.grey.shade800
                        : Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(
                      _isWorkSession
                          ? AppColors.primaryColor
                          : AppColors.successColor,
                    ),
                  ),
                ),

                // Time display
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(_secondsRemaining),
                      style: TextStyle(
                        fontSize: 48.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    if (widget.taskName != null) ...[
                      SizedBox(height: 8.h),
                      Text(
                        widget.taskName!,
                        style: TextStyle(fontSize: 14.sp, color: Colors.grey),
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
            'Sessions completed: $_sessionsCompleted',
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
                onPressed: _resetTimer,
                color: Colors.grey,
              ),

              SizedBox(width: 16.w),

              // Play/Pause button
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isWorkSession
                      ? AppColors.primaryColor
                      : AppColors.successColor,
                ),
                child: IconButton(
                  icon: Icon(
                    _isRunning ? Icons.pause : Icons.play_arrow,
                    size: 36.sp,
                    color: Colors.white,
                  ),
                  onPressed: _isRunning ? _pauseTimer : _startTimer,
                ),
              ),

              SizedBox(width: 16.w),

              // Skip button (only during work session)
              IconButton(
                icon: Icon(Icons.skip_next, size: 28.sp),
                onPressed: _isWorkSession ? _skipToBreak : null,
                color: _isWorkSession ? Colors.grey : Colors.grey.shade300,
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Settings
          TextButton.icon(
            icon: const Icon(Icons.settings_outlined),
            label: const Text('Customize Duration'),
            onPressed: () => _showSettingsDialog(),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pomodoro Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Work Duration'),
              subtitle: Text('${_workDuration ~/ 60} minutes'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      if (_workDuration > 60) {
                        setState(() => _workDuration -= 60);
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      setState(() => _workDuration += 60);
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              title: const Text('Break Duration'),
              subtitle: Text('${_breakDuration ~/ 60} minutes'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      if (_breakDuration > 60) {
                        setState(() => _breakDuration -= 60);
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      setState(() => _breakDuration += 60);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
