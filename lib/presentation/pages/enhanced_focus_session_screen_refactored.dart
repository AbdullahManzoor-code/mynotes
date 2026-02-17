// ════════════════════════════════════════════════════════════════════════════
// [F009/F010] DISABLED: Duplicate focus screen using PomodoroBloc
// Reason: Use FocusSessionScreen + FocusBloc instead (includes stats integration)
// File kept for reference but disabled - commented out entire screen
// ════════════════════════════════════════════════════════════════════════════

/* DISABLED - START
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/core/extensions/context_extensions.dart';
import 'dart:ui' as ui;
import 'package:mynotes/presentation/design_system/design_system.dart';
import 'package:mynotes/presentation/bloc/pomodoro/pomodoro_bloc.dart';

/// ════════════════════════════════════════════════════════════════════════════
/// PHASE 6: FOCUS & POMODORO
/// Enhanced Focus Session Screen - PomodoroBloc Integrated
/// ════════════════════════════════════════════════════════════════════════════

class EnhancedFocusSessionScreenRefactored extends StatelessWidget {
  const EnhancedFocusSessionScreenRefactored({super.key});

  @override
  Widget build(BuildContext context) {
    AppLogger.i(
      'Building EnhancedFocusSessionScreenRefactored with PomodoroBloc',
    );

    return BlocListener<PomodoroBloc, PomodoroState>(
      listener: (context, state) {
        if (state is PomodoroError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
        }
        if (state is PomodoroSessionCompleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Session completed! Great work!')),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [_buildBackgroundGlow(context), _buildMainContent(context)],
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return BlocBuilder<PomodoroBloc, PomodoroState>(
      builder: (context, state) {
        final isRunning = state is PomodoroSessionActive;
        final isPaused = state is PomodoroSessionPaused;
        final duration =
            (state is PomodoroSessionActive || state is PomodoroSessionPaused)
            ? (state as dynamic).session.totalDuration -
                  (state as dynamic).session.elapsedTime
            : const Duration(minutes: 25);

        return SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: kToolbarHeight + 16.h),
              // Timer display
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: _buildTimerCard(context, duration, isRunning, isPaused),
              ),
              SizedBox(height: 24.h),
              // Session notes
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: _buildSessionNotes(context),
              ),
              SizedBox(height: 24.h),
              // History
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: _buildSessionHistory(context),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimerCard(
    BuildContext context,
    Duration duration,
    bool isRunning,
    bool isPaused,
  ) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: context.theme.dividerColor, width: 0.5),
      ),
      child: Column(
        children: [
          // Large timer display
          Stack(
            alignment: Alignment.center,
            children: [
              // Circular progress
              SizedBox(
                width: 200.w,
                height: 200.w,
                child: CircularProgressIndicator(
                  value:
                      1.0 - (duration.inSeconds / 1500), // 25 minutes default
                  strokeWidth: 8.w,
                  backgroundColor: context.theme.dividerColor,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isRunning ? AppColors.success : AppColors.primary,
                  ),
                ),
              ),
              // Time text
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                    style: AppTypography.heading1(context).copyWith(
                      fontSize: 48.sp,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    isRunning
                        ? 'Focus Time'
                        : isPaused
                        ? 'Paused'
                        : 'Ready',
                    style: AppTypography.body2(context).copyWith(
                      fontSize: 12.sp,
                      color: context.theme.disabledColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 32.h),
          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: isRunning
                    ? () {
                        AppLogger.i('Pause timer');
                        context.read<PomodoroBloc>().add(PauseSessionEvent());
                      }
                    : () {
                        AppLogger.i('Start timer');
                        context.read<PomodoroBloc>().add(
                          StartWorkSessionEvent(),
                        );
                      },
                icon: Icon(isRunning ? Icons.pause : Icons.play_arrow),
                label: Text(isRunning ? 'Pause' : 'Start'),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  AppLogger.i('Stop timer');
                  context.read<PomodoroBloc>().add(StopSessionEvent());
                },
                icon: const Icon(Icons.stop),
                label: const Text('Stop'),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  AppLogger.i('Skip session');
                  context.read<PomodoroBloc>().add(CompleteSessionEvent());
                },
                icon: const Icon(Icons.skip_next),
                label: const Text('Skip'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSessionNotes(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: context.theme.dividerColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What to Focus On?',
            style: AppTypography.body1(
              context,
            ).copyWith(fontSize: 13.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          TextField(
            maxLines: 3,
            onChanged: (notes) {
              context.read<PomodoroBloc>().add(UpdateTimerEvent());
            },
            decoration: InputDecoration(
              hintText: 'Write your focus goals...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              contentPadding: EdgeInsets.all(8.w),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionHistory(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: context.theme.dividerColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Sessions',
            style: AppTypography.body1(
              context,
            ).copyWith(fontSize: 13.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12.h),
          ...[
            _buildHistoryItem(context, 'Session 1', '09:00 - 09:25', '✅'),
            SizedBox(height: 8.h),
            _buildHistoryItem(context, 'Break', '09:25 - 09:30', '✅'),
            SizedBox(height: 8.h),
            _buildHistoryItem(context, 'Session 2', '09:30 - 09:55', '✅'),
            SizedBox(height: 8.h),
            _buildHistoryItem(
              context,
              'Session 3',
              '10:00 - 10:25',
              '⏳ Running',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryItem(
    BuildContext context,
    String name,
    String time,
    String status,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: AppTypography.body2(
                context,
              ).copyWith(fontSize: 11.sp, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 2.h),
            Text(
              time,
              style: AppTypography.caption(
                context,
              ).copyWith(fontSize: 9.sp, color: context.theme.disabledColor),
            ),
          ],
        ),
        Text(
          status,
          style: AppTypography.caption(context).copyWith(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: status.contains('✅') ? Colors.green : Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildBackgroundGlow(BuildContext context) {
    return Positioned(
      top: -100.h,
      right: -100.w,
      child: Container(
        width: 300.w,
        height: 300.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withOpacity(0.08),
        ),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 100, sigmaY: 100),
          child: Container(color: Colors.transparent),
        ),
      ),
    );
  }
}DISABLED - END */
