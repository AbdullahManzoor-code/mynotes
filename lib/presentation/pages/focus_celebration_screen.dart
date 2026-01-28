import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../design_system/design_system.dart';

/// Focus Session Celebration Screen
/// Shown after completing a focus session to celebrate achievement
class FocusCelebrationScreen extends StatefulWidget {
  final int minutesFocused;
  final int streakDays;

  const FocusCelebrationScreen({
    Key? key,
    this.minutesFocused = 25,
    this.streakDays = 3,
  }) : super(key: key);

  @override
  State<FocusCelebrationScreen> createState() => _FocusCelebrationScreenState();
}

class _FocusCelebrationScreenState extends State<FocusCelebrationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0C10),
      body: Stack(
        children: [
          // Confetti particles
          _buildConfettiParticles(),

          // Bottom gradient glow
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height / 3,
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, 1),
                  radius: 1.5,
                  colors: [
                    const Color(0xFFA5B4FC).withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(),

                // Celebration content
                Expanded(child: _buildCelebrationContent()),

                // Done button
                _buildDoneButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfettiParticles() {
    final confetti = [
      _ConfettiParticle(
        top: 0.15,
        left: 0.10,
        color: Colors.pink.shade300,
        size: 8,
      ),
      _ConfettiParticle(
        top: 0.45,
        left: 0.85,
        color: Colors.pink.shade200,
        size: 6,
      ),
      _ConfettiParticle(
        top: 0.25,
        left: 0.75,
        color: Colors.blue.shade300,
        size: 8,
      ),
      _ConfettiParticle(
        top: 0.70,
        left: 0.15,
        color: Colors.blue.shade200,
        size: 6,
      ),
      _ConfettiParticle(
        top: 0.55,
        left: 0.40,
        color: Colors.green.shade200,
        size: 8,
      ),
      _ConfettiParticle(
        top: 0.10,
        left: 0.60,
        color: Colors.green.shade300,
        size: 10,
      ),
      _ConfettiParticle(
        top: 0.35,
        left: 0.25,
        color: Colors.purple.shade300,
        size: 8,
      ),
      _ConfettiParticle(
        top: 0.80,
        left: 0.65,
        color: Colors.purple.shade200,
        size: 6,
      ),
      _ConfettiParticle(
        top: 0.05,
        left: 0.35,
        color: Colors.yellow.shade100,
        size: 8,
      ),
    ];

    return Stack(
      children: confetti.map((particle) {
        return Positioned(
          top: MediaQuery.of(context).size.height * particle.top,
          left: MediaQuery.of(context).size.width * particle.left,
          child: Container(
            width: particle.size.w,
            height: particle.size.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: particle.color.withOpacity(0.6),
              boxShadow: [BoxShadow(color: particle.color, blurRadius: 8)],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              Icons.close_rounded,
              color: Colors.white.withOpacity(0.4),
              size: 24.sp,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'SESSION RESULTS',
            style: AppTypography.captionSmall(null).copyWith(
              color: Colors.white.withOpacity(0.3),
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              fontSize: 11.sp,
            ),
          ),
          SizedBox(width: 24.w),
        ],
      ),
    );
  }

  Widget _buildCelebrationContent() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with glow
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 112.w,
                height: 112.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFA5B4FC).withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              Container(
                width: 112.w,
                height: 112.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 56.sp,
                  color: const Color(0xFFA5B4FC),
                ),
              ),
            ],
          ),

          SizedBox(height: 48.h),

          // Title
          Text(
            'Deep Focus Achieved',
            textAlign: TextAlign.center,
            style: AppTypography.titleLarge(
              null,
              Colors.white,
              FontWeight.bold,
            ).copyWith(fontSize: 36.sp, height: 1.2),
          ),

          SizedBox(height: 16.h),

          // Subtitle
          Text(
            'Your mind stayed present and productive. A beautiful session.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium(
              null,
            ).copyWith(color: Colors.white.withOpacity(0.5), height: 1.5),
          ),

          SizedBox(height: 48.h),

          // Stats card
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                // Background glow
                Positioned(
                  top: -80.h,
                  right: -80.w,
                  child: Container(
                    width: 160.w,
                    height: 160.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFA5B4FC).withOpacity(0.05),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                Column(
                  children: [
                    Text(
                      'TOTAL TIME FOCUSED',
                      style: AppTypography.captionSmall(null).copyWith(
                        color: Colors.white.withOpacity(0.4),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        fontSize: 10.sp,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      '${widget.minutesFocused} minutes',
                      style: TextStyle(
                        fontSize: 48.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFA5B4FC).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: const Color(0xFFA5B4FC).withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_fire_department_rounded,
                            color: const Color(0xFFA5B4FC),
                            size: 14.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            '${widget.streakDays} DAY STREAK',
                            style: AppTypography.captionSmall(null).copyWith(
                              color: const Color(0xFFA5B4FC),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoneButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(32.w, 0, 32.w, 48.h),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 64.h,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0A0C10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                elevation: 0,
                shadowColor: const Color(0xFFA5B4FC).withOpacity(0.3),
              ),
              child: Text(
                'Done',
                style: AppTypography.bodyLarge(
                  null,
                  const Color(0xFF0A0C10),
                  FontWeight.bold,
                ).copyWith(fontSize: 18.sp),
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 1.h,
                width: 32.w,
                color: Colors.white.withOpacity(0.3),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  'END CELEBRATION',
                  style: AppTypography.captionSmall(null).copyWith(
                    color: Colors.white.withOpacity(0.3),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    fontSize: 10.sp,
                  ),
                ),
              ),
              Container(
                height: 1.h,
                width: 32.w,
                color: Colors.white.withOpacity(0.3),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConfettiParticle {
  final double top;
  final double left;
  final Color color;
  final double size;

  _ConfettiParticle({
    required this.top,
    required this.left,
    required this.color,
    required this.size,
  });
}
