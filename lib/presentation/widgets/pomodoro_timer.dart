// ════════════════════════════════════════════════════════════════════════════
// [F009/F010] DISABLED: Duplicate Pomodoro timer system
// Reason: Use FocusSessionScreen + FocusBloc instead (includes stats integration)
// File kept for reference but disabled - commented out entire widget
// ════════════════════════════════════════════════════════════════════════════

/* DISABLED - START
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/pomodoro/pomodoro_bloc.dart';

/// Pomodoro timer display widget (POM-001)
class PomodoroTimer extends StatelessWidget {
  final VoidCallback? onSessionStart;
  final VoidCallback? onSessionEnd;

  const PomodoroTimer({super.key, this.onSessionStart, this.onSessionEnd});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PomodoroBloc, PomodoroState>(
      builder: (context, state) {
        if (state is PomodoroSessionActive) {
          return _buildActiveState(context, state.session);
        } else if (state is PomodoroSessionCompleted) {
          return _buildCompletedState(context, state);
        }
        return _buildIdleState(context);
      },
    );
  }

  Widget _buildIdleState(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(Icons.timer_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('25:00', style: Theme.of(context).textTheme.headlineLarge),
                SizedBox(height: 8),
                Text(
                  'Ready to focus?',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: Icon(Icons.play_arrow),
                  label: Text('Start Work Session'),
                  onPressed: () {
                    context.read<PomodoroBloc>().add(StartWorkSessionEvent());
                    onSessionStart?.call();
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveState(BuildContext context, PomodoroSession session) {
    return Column(
      children: [
        Card(
          color: session.statusColor.withOpacity(0.1),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  session.statusLabel,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: session.statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: CircularProgressIndicator(
                        value: session.progress,
                        strokeWidth: 8,
                        valueColor: AlwaysStoppedAnimation(session.statusColor),
                        backgroundColor: Colors.grey.withOpacity(0.2),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          session.formattedTime,
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: session.statusColor,
                              ),
                        ),
                        if (session.selectedTodoId != null)
                          Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              session.selectedTodoTitle,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey[600]),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 24),
                // Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (session.status == PomodoroStatus.paused)
                      ElevatedButton.icon(
                        icon: Icon(Icons.play_arrow),
                        label: Text('Resume'),
                        onPressed: () {
                          context.read<PomodoroBloc>().add(
                            ResumeSessionEvent(),
                          );
                        },
                      )
                    else
                      ElevatedButton.icon(
                        icon: Icon(Icons.pause),
                        label: Text('Pause'),
                        onPressed: () {
                          context.read<PomodoroBloc>().add(PauseSessionEvent());
                        },
                      ),
                    ElevatedButton.icon(
                      icon: Icon(Icons.stop),
                      label: Text('Stop'),
                      onPressed: () {
                        context.read<PomodoroBloc>().add(StopSessionEvent());
                        onSessionEnd?.call();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // Session info
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatChip(
                        'Sessions',
                        '${session.sessionsCompleted}',
                      ),
                      _buildStatChip(
                        'Total Focus',
                        '${session.sessionsCompleted * 25}m',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedState(
    BuildContext context,
    PomodoroSessionCompleted state,
  ) {
    return Column(
      children: [
        Card(
          color: Colors.green.withOpacity(0.1),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(Icons.check_circle, size: 64, color: Colors.green),
                SizedBox(height: 16),
                Text(
                  'Great Job!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Session completed',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      _buildStatChip(
                        'Total Sessions',
                        '${state.totalSessions}',
                      ),
                      SizedBox(height: 8),
                      _buildStatChip(
                        'Total Focus',
                        '${state.totalFocusMinutes}m',
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: Icon(Icons.play_arrow),
                  label: Text('Start New Session'),
                  onPressed: () {
                    context.read<PomodoroBloc>().add(StartWorkSessionEvent());
                    onSessionStart?.call();
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatChip(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
DISABLED - END */
