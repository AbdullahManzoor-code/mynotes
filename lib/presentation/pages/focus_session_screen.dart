import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../design_system/design_system.dart';
import 'focus_celebration_screen.dart';

/// Focus Session Active Screen
/// Pomodoro timer with immersive gradient design and circular progress
class FocusSessionScreen extends StatefulWidget {
  const FocusSessionScreen({super.key});

  @override
  State<FocusSessionScreen> createState() => _FocusSessionScreenState();
}

class _FocusSessionScreenState extends State<FocusSessionScreen>
    with TickerProviderStateMixin {
  Timer? _timer;
  int _secondsRemaining = 1500; // 25:00 (proper Pomodoro)
  int _totalSeconds = 1500; // Track total for progress
  bool _isPaused = false;
  bool _showSettings = false;

  // Session settings
  int _focusMinutes = 25;
  final int _shortBreakMinutes = 5;
  final int _longBreakMinutes = 15;
  final int _sessionsUntilLongBreak = 4;
  int _currentSessionCount = 0;
  bool _isBreakTime = false;

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

  final String _taskTitle = 'Finalize Project Proposal';
  String _focusMode = 'Pomodoro';
  final double _overallProgress = 0.8;

  late AnimationController _pulseController;
  late AnimationController _settingsController;
  late AnimationController _breathingController;

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

    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _initializeSession();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _settingsController.dispose();
    _breathingController.dispose();
    super.dispose();
  }

  void _initializeSession() {
    _totalSeconds = _focusMinutes * 60;
    _secondsRemaining = _totalSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && _secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else if (_secondsRemaining == 0) {
        _completeSession();
      }
    });
  }

  void _completeSession() {
    _timer?.cancel();
    HapticFeedback.heavyImpact();

    if (_currentSessionCount >= _sessionsUntilLongBreak && !_isBreakTime) {
      // Go to celebration screen after completing full pomodoro cycle
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FocusCelebrationScreen()),
      );
    } else if (_isBreakTime) {
      // Break completed, start next focus session
      _startNextFocusSession();
    } else {
      // Focus session completed, start break
      _startBreakSession();
    }
  }

  void _startBreakSession() {
    _currentSessionCount++;
    _isBreakTime = true;

    // Determine break type
    final isLongBreak = _currentSessionCount % _sessionsUntilLongBreak == 0;
    final breakMinutes = isLongBreak ? _longBreakMinutes : _shortBreakMinutes;

    setState(() {
      _focusMode = isLongBreak ? 'Long Break' : 'Short Break';
      _totalSeconds = breakMinutes * 60;
      _secondsRemaining = _totalSeconds;
    });

    _showBreakDialog(isLongBreak);
  }

  void _startNextFocusSession() {
    setState(() {
      _isBreakTime = false;
      _focusMode = 'Pomodoro';
      _totalSeconds = _focusMinutes * 60;
      _secondsRemaining = _totalSeconds;
    });

    _showFocusDialog();
  }

  void _showBreakDialog(bool isLongBreak) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkCardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          isLongBreak ? '🎉 Long Break Time!' : '☕ Break Time!',
          style: TextStyle(color: Colors.white, fontSize: 20.sp),
          textAlign: TextAlign.center,
        ),
        content: Text(
          isLongBreak
              ? 'Great work! Take a longer break to recharge.'
              : 'Time for a quick break. Stretch, hydrate, and relax.',
          style: TextStyle(color: Colors.grey.shade300),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startTimer();
            },
            child: Text(
              'Start Break',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showFocusDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkCardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          '🎯 Focus Time!',
          style: TextStyle(color: Colors.white, fontSize: 20.sp),
          textAlign: TextAlign.center,
        ),
        content: Text(
          'Break\'s over! Ready to dive back into focused work?',
          style: TextStyle(color: Colors.grey.shade300),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startTimer();
            },
            child: Text(
              'Start Focus',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _stopSession() {
    Navigator.pop(context);
  }

  String get _minutes => (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
  String get _seconds => (_secondsRemaining % 60).toString().padLeft(2, '0');

  double get _progress {
    return 1.0 - (_secondsRemaining / _totalSeconds);
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

  void _updateFocusTime(int minutes) {
    setState(() {
      _focusMinutes = minutes;
      if (!_isBreakTime) {
        _totalSeconds = _focusMinutes * 60;
        _secondsRemaining = _totalSeconds;
      }
    });
  }

  void _updateSound(String sound) {
    setState(() {
      _selectedSound = sound;
    });
    HapticFeedback.selectionClick();
    // In a real app, this would trigger actual sound playback
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.8, -0.8),
            radius: 1.5,
            colors: [
              const Color(0xFF1e1b4b), // deep violet
              const Color(0xFF0f172a), // midnight blue
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background blur orbs
            _buildBackgroundOrbs(),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Header
                  _buildHeader(),

                  // Timer and content
                  Expanded(child: _buildTimerSection()),

                  // Progress and controls
                  _buildBottomSection(),
                ],
              ),
            ),

            // Settings overlay
            if (_showSettings) _buildSettingsOverlay(),
          ],
        ),
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
                  const Color(0xFF4c1d95).withOpacity(0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 350.h,
          left: 50.w,
          child: Container(
            width: 600.w,
            height: 600.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF5b21b6).withOpacity(0.1),
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
                  const Color(0xFF1e3a8a).withOpacity(0.2),
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
          _buildGlassButton(Icons.keyboard_arrow_down_rounded, () {
            Navigator.pop(context);
          }),
          Text(
            'FOCUS SESSION',
            style: AppTypography.captionSmall(null).copyWith(
              color: Colors.white.withOpacity(0.6),
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
              fontSize: 10.sp,
            ),
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

  Widget _buildTimerSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Circular timer
          SizedBox(
            width: 320.w,
            height: 320.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background ring
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.05),
                      width: 8.w,
                    ),
                  ),
                ),

                // Progress ring
                CustomPaint(
                  size: Size(320.w, 320.w),
                  painter: TimerRingPainter(
                    progress: _progress,
                    color: const Color(0xFFa7f3d0),
                  ),
                ),

                // Timer digits
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          _minutes,
                          style: TextStyle(
                            fontSize: 72.sp,
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                        Text(
                          ':',
                          style: TextStyle(
                            fontSize: 64.sp,
                            fontWeight: FontWeight.w200,
                            color: Colors.white.withOpacity(0.2),
                            height: 1,
                          ),
                        ),
                        Text(
                          _seconds,
                          style: TextStyle(
                            fontSize: 72.sp,
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    _buildLiveIndicator(),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 56.h),

          // Focus mode badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.spa_outlined,
                  color: const Color(0xFFa7f3d0),
                  size: 14.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  _focusMode.toUpperCase(),
                  style: AppTypography.captionSmall(null).copyWith(
                    color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Task title
          Text(
            _taskTitle,
            textAlign: TextAlign.center,
            style: AppTypography.titleLarge(null, Colors.white).copyWith(
              fontSize: 30.sp,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),

          SizedBox(height: 16.h),

          // Subtitle
          Text(
            'Keep your momentum going',
            style: AppTypography.bodyMedium(null).copyWith(
              color: Colors.white.withOpacity(0.4),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FadeTransition(
          opacity: _pulseController,
          child: Container(
            width: 6.w,
            height: 6.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFa7f3d0),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          'LIVE SESSION',
          style: AppTypography.captionSmall(null).copyWith(
            color: const Color(0xFFa7f3d0).withOpacity(0.8),
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontSize: 10.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: EdgeInsets.fromLTRB(40.w, 0, 40.w, 56.h),
      child: Column(
        children: [
          // Overall Progress
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'OVERALL PROGRESS',
                    style: AppTypography.captionSmall(null).copyWith(
                      color: Colors.white.withOpacity(0.3),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      fontSize: 10.sp,
                    ),
                  ),
                  Text(
                    '${(_overallProgress * 100).toInt()}%',
                    style: AppTypography.captionSmall(null).copyWith(
                      color: const Color(0xFFa7f3d0),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: Container(
                  height: 4.h,
                  width: double.infinity,
                  color: Colors.white.withOpacity(0.05),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _overallProgress,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFa7f3d0), Color(0xFFa7f3d0)],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 32.h),

          // Control buttons
          Row(
            children: [
              Expanded(
                child: _buildControlButton(
                  icon: _isPaused
                      ? Icons.play_arrow_rounded
                      : Icons.pause_rounded,
                  label: _isPaused ? 'Resume' : 'Pause',
                  onTap: _togglePause,
                ),
              ),
              SizedBox(width: 16.w),
              _buildStopButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56.h,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24.sp),
            SizedBox(width: 12.w),
            Text(
              label,
              style: AppTypography.bodyLarge(
                null,
                Colors.white,
                FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStopButton() {
    return GestureDetector(
      onTap: _stopSession,
      child: Container(
        width: 80.w,
        height: 56.h,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
        ),
        child: Icon(Icons.stop_rounded, color: Colors.white, size: 24.sp),
      ),
    );
  }

  Widget _buildSettingsOverlay() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: _toggleSettings,
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () {}, // Prevent closing when tapping the panel
                child: SlideTransition(
                  position:
                      Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _settingsController,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                  child: Container(
                    width: 280.w,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.darkCardBackground,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24.r),
                        bottomLeft: Radius.circular(24.r),
                      ),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        // Header
                        Padding(
                          padding: EdgeInsets.all(24.w),
                          child: Row(
                            children: [
                              Icon(
                                Icons.settings_outlined,
                                color: AppColors.primary,
                                size: 24.sp,
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                'Settings',
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Focus Time Setting
                                Text(
                                  'Focus Time',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                Wrap(
                                  spacing: 8.w,
                                  runSpacing: 8.h,
                                  children: [15, 20, 25, 30, 45, 60].map((
                                    minutes,
                                  ) {
                                    final isSelected = _focusMinutes == minutes;
                                    return GestureDetector(
                                      onTap: () => _updateFocusTime(minutes),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12.w,
                                          vertical: 8.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.primary.withOpacity(
                                                  0.2,
                                                )
                                              : Colors.white.withOpacity(0.05),
                                          borderRadius: BorderRadius.circular(
                                            8.r,
                                          ),
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.primary
                                                : Colors.white.withOpacity(0.1),
                                          ),
                                        ),
                                        child: Text(
                                          '${minutes}m',
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w600,
                                            color: isSelected
                                                ? AppColors.primary
                                                : Colors.grey.shade400,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),

                                SizedBox(height: 32.h),

                                // Ambient Sounds
                                Text(
                                  'Ambient Sound',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                ..._ambientSounds.map((sound) {
                                  final isSelected = _selectedSound == sound;
                                  return GestureDetector(
                                    onTap: () => _updateSound(sound),
                                    child: Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(16.w),
                                      margin: EdgeInsets.only(bottom: 8.h),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.primary.withOpacity(0.1)
                                            : Colors.white.withOpacity(0.03),
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                        border: Border.all(
                                          color: isSelected
                                              ? AppColors.primary.withOpacity(
                                                  0.3,
                                                )
                                              : Colors.white.withOpacity(0.05),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            _getSoundIcon(sound),
                                            color: isSelected
                                                ? AppColors.primary
                                                : Colors.grey.shade400,
                                            size: 20.sp,
                                          ),
                                          SizedBox(width: 12.w),
                                          Expanded(
                                            child: Text(
                                              sound,
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w500,
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.grey.shade300,
                                              ),
                                            ),
                                          ),
                                          if (isSelected)
                                            Icon(
                                              Icons.check_circle,
                                              color: AppColors.primary,
                                              size: 20.sp,
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),

                                SizedBox(height: 32.h),

                                // Session Info
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(16.w),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.03),
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.05),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Session Progress',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        'Completed: $_currentSessionCount/$_sessionsUntilLongBreak',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                      Text(
                                        'Mode: $_focusMode',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getSoundIcon(String sound) {
    switch (sound) {
      case 'Rain':
        return Icons.grain;
      case 'Forest':
        return Icons.forest;
      case 'Ocean':
        return Icons.waves;
      case 'Coffee Shop':
        return Icons.local_cafe;
      case 'White Noise':
        return Icons.hearing;
      default:
        return Icons.volume_off;
    }
  }
}

class TimerRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  TimerRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 4;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * (1 - progress);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(TimerRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

