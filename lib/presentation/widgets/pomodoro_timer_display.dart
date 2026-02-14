import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mynotes/presentation/design_system/app_colors.dart';
import 'package:mynotes/presentation/design_system/app_typography.dart';

/// Simple Pomodoro timer display with visual countdown
class PomodoroTimerDisplay extends StatefulWidget {
  final int durationSeconds;
  final VoidCallback? onTimerComplete;
  final String? sessionLabel;

  const PomodoroTimerDisplay({
    Key? key,
    this.durationSeconds = 1500, // 25 minutes default
    this.onTimerComplete,
    this.sessionLabel,
  }) : super(key: key);

  @override
  State<PomodoroTimerDisplay> createState() => _PomodoroTimerDisplayState();
}

class _PomodoroTimerDisplayState extends State<PomodoroTimerDisplay> {
  late int _remainingSeconds;
  Timer? _timer;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.durationSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning) return;

    setState(() => _isRunning = true);
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds <= 0) {
          _timer?.cancel();
          _isRunning = false;
          widget.onTimerComplete?.call();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('🎉 Pomodoro session complete!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      });
    });
  }

  void _pauseTimer() {
    setState(() => _isRunning = false);
    _timer?.cancel();
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = widget.durationSeconds;
      _isRunning = false;
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = (_remainingSeconds / widget.durationSeconds).clamp(0.0, 1.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Session label
        if (widget.sessionLabel != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Text(
              widget.sessionLabel!,
              style: AppTypography.titleLarge(context).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

        // Circular progress timer
        Stack(
          alignment: Alignment.center,
          children: [
            // Progress ring
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.width * 0.7,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 12,
                backgroundColor: isDark
                    ? Colors.grey.shade700
                    : Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryColor,
                ),
              ),
            ),
            // Timer text
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(_remainingSeconds),
                  style: Theme.of(context).textTheme.displayLarge!.copyWith(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isRunning ? 'Running...' : 'Paused',
                  style: AppTypography.bodySmall(
                    context,
                    isDark
                        ? Colors.grey.shade400
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 40),

        // Control buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _isRunning ? null : _startTimer,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start'),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: _isRunning ? _pauseTimer : null,
              icon: const Icon(Icons.pause),
              label: const Text('Pause'),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: _resetTimer,
              icon: const Icon(Icons.restart_alt),
              label: const Text('Reset'),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Info text
        Text(
          'Focus on your task. Take breaks between sessions.',
          style: AppTypography.bodySmall(
            context,
            isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
