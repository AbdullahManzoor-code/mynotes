import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mynotes/core/constants/app_colors.dart';
import 'package:mynotes/presentation/bloc/focus/focus_bloc.dart';

/// Full-screen focus lock overlay that blocks navigation during sessions.
class FocusLockOverlay extends StatelessWidget {
  const FocusLockOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FocusBloc, FocusState>(
      buildWhen: (previous, current) {
        return previous.status != current.status ||
            previous.isLockEnabled != current.isLockEnabled ||
            previous.secondsRemaining != current.secondsRemaining ||
            previous.totalSeconds != current.totalSeconds ||
            previous.distractionFreeMode != current.distractionFreeMode ||
            previous.lockPin != current.lockPin ||
            previous.sessionType != current.sessionType;
      },
      builder: (context, state) {
        final isRunning =
            state.status == FocusStatus.active ||
            state.status == FocusStatus.paused;
        final shouldShow = state.isLockEnabled && isRunning;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: shouldShow
              ? _LockContent(key: const ValueKey('focus_lock'), state: state)
              : const SizedBox.shrink(),
        );
      },
    );
  }
}

class _LockContent extends StatelessWidget {
  final FocusState state;

  const _LockContent({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final progress = state.totalSeconds > 0
        ? 1 - (state.secondsRemaining / state.totalSeconds)
        : 0.0;
    final message = _pickMessage(state.secondsRemaining);
    final isDndActive =
        state.distractionFreeMode && state.sessionType == SessionType.work;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Focus session is active')),
          );
        }
      },
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black.withOpacity(0.92),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
              child: Column(
                children: [
                  if (isDndActive)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.focusAccentGreen.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: AppColors.focusAccentGreen.withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        'DND Active',
                        style: TextStyle(
                          color: AppColors.focusAccentGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                          letterSpacing: 0.5,
                        ),
                      ),
                    )
                  else
                    SizedBox(height: 24.h),
                  SizedBox(height: 16.h),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 220.w,
                            height: 220.w,
                            child: CustomPaint(
                              painter: _ProgressRingPainter(
                                progress: progress,
                                color: AppColors.focusAccentGreen,
                              ),
                              child: Center(
                                child: Text(
                                  _formatTime(state.secondsRemaining),
                                  style: TextStyle(
                                    fontSize: 48.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 24.h),
                          Text(
                            message,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _StopButton(
                    onPressed: () => _confirmStop(context, state.lockPin),
                  ),
                  SizedBox(height: 12.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _pickMessage(int secondsRemaining) {
    const messages = [
      'Stay focused. You got this!',
      'Small steps make big wins.',
      'Keep going, almost there.',
      'Breathe. Focus. Finish strong.',
      'Deep focus, deep progress.',
    ];
    final index = (secondsRemaining ~/ 10) % messages.length;
    return messages[index];
  }

  String _formatTime(int seconds) {
    final minutes = max(0, seconds) ~/ 60;
    final secs = max(0, seconds) % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _confirmStop(BuildContext context, String? pin) async {
    final shouldStop = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        String enteredPin = '';
        String? errorText;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.darkCardBackground,
              title: const Text(
                'End Session?',
                style: TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Are you sure you want to stop focusing?',
                    style: TextStyle(color: Colors.white70),
                  ),
                  if (pin != null && pin.isNotEmpty) ...[
                    SizedBox(height: 16.h),
                    TextField(
                      obscureText: true,
                      onChanged: (value) {
                        enteredPin = value;
                        if (errorText != null) {
                          setDialogState(() => errorText = null);
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Enter PIN',
                        errorText: errorText,
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Keep Going'),
                ),
                TextButton(
                  onPressed: () {
                    if (pin != null && pin.isNotEmpty && enteredPin != pin) {
                      setDialogState(() => errorText = 'Incorrect PIN');
                      return;
                    }
                    Navigator.pop(dialogContext, true);
                  },
                  child: const Text(
                    'Yes, Stop',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (shouldStop == true && context.mounted) {
      context.read<FocusBloc>().add(const StopFocusSessionEvent());
    }
  }
}

class _StopButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _StopButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: Colors.white70,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: BorderSide(color: Colors.white.withOpacity(0.2)),
          ),
        ),
        child: const Text('Stop Session'),
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ProgressRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 10.w;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth;
    final backgroundPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final foregroundPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, backgroundPaint);
    final sweep = 2 * pi * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweep,
      false,
      foregroundPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}


