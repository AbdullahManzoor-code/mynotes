import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import '../design_system/design_system.dart';

/// Enhanced Focus Session Active Screen
/// Immersive focus timer with ambient background and controls
/// Based on focus_session_active_1 template
class FocusSessionActiveScreen extends StatefulWidget {
  final String taskName;
  final int durationMinutes;

  const FocusSessionActiveScreen({
    super.key,
    this.taskName = 'Deep Focus',
    this.durationMinutes = 25,
  });

  @override
  State<FocusSessionActiveScreen> createState() =>
      _FocusSessionActiveScreenState();
}

class _FocusSessionActiveScreenState extends State<FocusSessionActiveScreen>
    with TickerProviderStateMixin {
  late AnimationController _timerController;
  late AnimationController _pulseController;
  late AnimationController _breatheController;
  late AnimationController _backgroundController;

  late int _remainingSeconds;
  late int _totalSeconds;
  bool _isRunning = true;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();

    _totalSeconds = widget.durationMinutes * 60;
    _remainingSeconds = _totalSeconds;

    _timerController = AnimationController(
      duration: Duration(seconds: _totalSeconds),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _breatheController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _startTimer();

    // Set full screen mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    _timerController.dispose();
    _pulseController.dispose();
    _breatheController.dispose();
    _backgroundController.dispose();

    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _startTimer() {
    _timerController.addListener(() {
      setState(() {
        _remainingSeconds = (_totalSeconds * (1 - _timerController.value))
            .round();
      });

      if (_remainingSeconds <= 0) {
        _completeSession();
      }
    });

    _timerController.forward();
  }

  void _pauseResumeTimer() {
    setState(() {
      if (_isRunning) {
        _timerController.stop();
        _isRunning = false;
        _isPaused = true;
      } else {
        _timerController.forward();
        _isRunning = true;
        _isPaused = false;
      }
    });

    HapticFeedback.lightImpact();
  }

  void _completeSession() {
    HapticFeedback.heavyImpact();

    // Navigate to celebration screen
    Navigator.pushReplacementNamed(
      context,
      '/focus/celebration',
      arguments: {
        'taskName': widget.taskName,
        'duration': widget.durationMinutes,
      },
    );
  }

  void _exitSession() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkCardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'End Session?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to end this focus session?',
          style: TextStyle(color: Colors.white70, fontSize: 16.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white70, fontSize: 16.sp),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              'End Session',
              style: TextStyle(
                color: AppColors.error,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: _buildBackgroundDecoration(),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(child: _buildTimerSection()),
              _buildBottomControls(),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildBackgroundDecoration() {
    return BoxDecoration(
      gradient: RadialGradient(
        center: const Alignment(0.3, -0.7),
        radius: 1.2,
        colors: [const Color(0xFF1E1B4B), const Color(0xFF0F172A)],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: GestureDetector(
              onTap: _exitSession,
              child: Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white.withOpacity(0.8),
                  size: 24.sp,
                ),
              ),
            ),
          ),

          Text(
            'FOCUS SESSION',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.4,
              color: Colors.white.withOpacity(0.6),
            ),
          ),

          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Icon(
              Icons.more_horiz,
              color: Colors.white.withOpacity(0.8),
              size: 24.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Main timer circle
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (_pulseController.value * 0.02),
              child: Container(
                width: 320.w,
                height: 320.w,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background circle
                    Container(
                      width: 320.w,
                      height: 320.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.05),
                          width: 8.w,
                        ),
                      ),
                    ),

                    // Progress circle
                    AnimatedBuilder(
                      animation: _timerController,
                      builder: (context, child) {
                        return CustomPaint(
                          size: Size(320.w, 320.w),
                          painter: TimerCirclePainter(_timerController.value),
                        );
                      },
                    ),

                    // Time display
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _formatTime(_remainingSeconds),
                          style: TextStyle(
                            fontSize: 72.sp,
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                            height: 1.0,
                            letterSpacing: -2,
                          ),
                        ),

                        SizedBox(height: 8.h),

                        Text(
                          widget.taskName,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.7),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        SizedBox(height: 48.h),

        // Breathing guide
        AnimatedBuilder(
          animation: _breatheController,
          builder: (context, child) {
            final breatheScale = 1.0 + (_breatheController.value * 0.1);
            final breatheOpacity = 0.3 + (_breatheController.value * 0.4);

            return Transform.scale(
              scale: breatheScale,
              child: Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentGreen.withOpacity(breatheOpacity),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentGreen.withOpacity(0.3),
                      blurRadius: 20 + (_breatheController.value * 10),
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _breatheController.value > 0.5 ? 'Exhale' : 'Inhale',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: EdgeInsets.all(32.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Skip button
          GestureDetector(
            onTap: _completeSession,
            child: Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Icon(Icons.skip_next, color: Colors.white, size: 28.sp),
            ),
          ),

          // Pause/Play button
          GestureDetector(
            onTap: _pauseResumeTimer,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: _isPaused
                    ? AppColors.accentGreen
                    : Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
                boxShadow: _isPaused
                    ? [
                        BoxShadow(
                          color: AppColors.accentGreen.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                _isPaused ? Icons.play_arrow : Icons.pause,
                color: Colors.white,
                size: 36.sp,
              ),
            ),
          ),

          // Stop button
          GestureDetector(
            onTap: _exitSession,
            child: Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Icon(Icons.stop, color: Colors.white, size: 28.sp),
            ),
          ),
        ],
      ),
    );
  }
}

class TimerCirclePainter extends CustomPainter {
  final double progress;

  TimerCirclePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    final paint = Paint()
      ..color = AppColors.accentGreen
      ..strokeWidth = 8.w
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Add glow effect
    final glowPaint = Paint()
      ..color = AppColors.accentGreen.withOpacity(0.3)
      ..strokeWidth = 12.w
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;

    // Draw glow
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      glowPaint,
    );

    // Draw main arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
