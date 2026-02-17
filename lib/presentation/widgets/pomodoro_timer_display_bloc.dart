import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/presentation/design_system/app_colors.dart';
import 'package:mynotes/presentation/design_system/app_typography.dart';
import '../bloc/pomodoro/pomodoro_timer_bloc.dart';
import '../bloc/pomodoro/pomodoro_timer_event.dart';
import '../bloc/pomodoro/pomodoro_timer_state.dart';

/// Simple Pomodoro timer display with visual countdown
/// Uses PomodoroTimerBloc for centralized state management
class PomodoroTimerDisplay extends StatelessWidget {
  final int durationSeconds;
  final VoidCallback? onTimerComplete;
  final String? sessionLabel;

  const PomodoroTimerDisplay({
    super.key,
    this.durationSeconds = 1500, // 25 minutes default
    this.onTimerComplete,
    this.sessionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PomodoroTimerBloc, PomodoroTimerState>(
      builder: (context, state) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final progress = (state.secondsRemaining / state.totalDuration).clamp(
          0.0,
          1.0,
        );

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Session label
            if (sessionLabel != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text(
                  sessionLabel!,
                  style: AppTypography.titleLarge(
                    context,
                  ).copyWith(fontWeight: FontWeight.bold),
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
                      _formatTime(state.secondsRemaining),
                      style: Theme.of(context).textTheme.displayLarge!.copyWith(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.isRunning ? 'Running...' : 'Paused',
                      style: AppTypography.bodySmall(
                        context,
                        isDark ? Colors.grey.shade400 : Colors.grey.shade600,
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
                // Start/Resume button
                ElevatedButton.icon(
                  onPressed: () {
                    if (state.isRunning) {
                      context.read<PomodoroTimerBloc>().add(
                        const PauseTimerEvent(),
                      );
                    } else {
                      if (state.secondsRemaining == state.totalDuration) {
                        context.read<PomodoroTimerBloc>().add(
                          const StartTimerEvent(),
                        );
                      } else {
                        context.read<PomodoroTimerBloc>().add(
                          const ResumeTimerEvent(),
                        );
                      }
                    }
                  },
                  icon: Icon(state.isRunning ? Icons.pause : Icons.play_arrow),
                  label: Text(state.isRunning ? 'Pause' : 'Start'),
                ),
                const SizedBox(width: 16),
                // Reset button
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<PomodoroTimerBloc>().add(
                      const ResetTimerEvent(),
                    );
                  },
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Reset'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
