import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../design_system/design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/focus/focus_bloc.dart';
import 'focus_session_screen.dart';
import '../widgets/lottie_animation_widget.dart';

/// Focus Session Celebration Screen
/// Shown after completing a focus session to celebrate achievement
class FocusCelebrationScreen extends StatefulWidget {
  final int minutesFocused;
  final int streakDays;

  const FocusCelebrationScreen({
    super.key,
    this.minutesFocused = 25,
    this.streakDays = 3,
  });

  @override
  State<FocusCelebrationScreen> createState() => _FocusCelebrationScreenState();
}

class _FocusCelebrationScreenState extends State<FocusCelebrationScreen>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    AppLogger.i('FocusCelebrationScreen: Initialized');
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 10),
    );
    _confettiController.play();
  }

  @override
  void dispose() {
    AppLogger.i('FocusCelebrationScreen: Disposed');
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.focusMidnightBlue,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Confetti particles
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: true,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
            ],
            createParticlePath: _drawStar,
          ),

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
                    AppColors.focusIndigoLight.withOpacity(0.2),
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

  /// A custom Path to paint stars.
  Path _drawStar(Size size) {
    // Method to convert degree to radians
    double degToRad(double deg) => deg * (math.pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(
        halfWidth + externalRadius * math.cos(step),
        halfWidth + externalRadius * math.sin(step),
      );
      path.lineTo(
        halfWidth + internalRadius * math.cos(step + halfDegreesPerStep),
        halfWidth + internalRadius * math.sin(step + halfDegreesPerStep),
      );
    }
    path.close();
    return path;
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
            onPressed: () {
              AppLogger.i('FocusCelebrationScreen: Close button pressed');
              Navigator.pop(context);
            },
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
          // Lottie celebration animation
          SizedBox(
            height: 120.h,
            child: LottieAnimationWidget(
              'celebration',
              width: 120.w,
              height: 120.h,
            ),
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
                          AppColors.focusIndigoLight.withOpacity(0.05),
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
                        color: AppColors.focusIndigoLight.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: AppColors.focusIndigoLight.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_fire_department_rounded,
                            color: AppColors.focusIndigoLight,
                            size: 14.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            '${widget.streakDays} DAY STREAK',
                            style: AppTypography.captionSmall(null).copyWith(
                              color: AppColors.focusIndigoLight,
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
          // Take Long Break Button
          SizedBox(
            width: double.infinity,
            height: 64.h,
            child: ElevatedButton(
              onPressed: () {
                AppLogger.i('FocusCelebrationScreen: Take Long Break pressed');
                context.read<FocusBloc>().add(const StartBreakSessionEvent());
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FocusSessionScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.focusMidnightBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                elevation: 0,
                shadowColor: AppColors.focusIndigoLight.withOpacity(0.3),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.coffee_outlined),
                  SizedBox(width: 8.w),
                  Text(
                    'Take Long Break (15m)',
                    style: AppTypography.bodyLarge(
                      null,
                      AppColors.focusMidnightBlue,
                      FontWeight.bold,
                    ).copyWith(fontSize: 16.sp),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // Done / Start New Button
          TextButton(
            onPressed: () {
              AppLogger.i('FocusCelebrationScreen: Done & Finish pressed');
              // Reset to initial state
              context.read<FocusBloc>().add(const StopFocusSessionEvent());
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white.withOpacity(0.8),
              padding: EdgeInsets.symmetric(vertical: 16.h),
            ),
            child: Text(
              'Done & Finish',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
          ),

          SizedBox(height: 8.h),

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
