import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../design_system/design_system.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/app_logger.dart';

/// Onboarding Screen using introduction_screen package
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _finishOnboarding(BuildContext context) async {
    AppLogger.i('OnboardingScreen: Completing onboarding');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_launch', false);

    if (!context.mounted) return;

    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: 'Welcome to Calm Productivity',
          body:
              'A simpler way to capture notes, tasks, and reflections without the noise.',
          image: _buildImage(Icons.spa_rounded),
          decoration: _getPageDecoration(context),
        ),
        PageViewModel(
          title: 'Privacy by Design',
          body:
              'Your data is private and remains on your device. Secure it with your fingerprint.',
          image: _buildImage(Icons.security_rounded),
          decoration: _getPageDecoration(context),
        ),
        PageViewModel(
          title: 'Smart Capture',
          body:
              'Quickly add anything with smart inputs and voice extraction. Organized automatically.',
          image: _buildImage(Icons.auto_awesome_rounded),
          decoration: _getPageDecoration(context),
        ),
      ],
      onDone: () => _finishOnboarding(context),
      onSkip: () => _finishOnboarding(context),
      showSkipButton: true,
      skip: Text(
        'Skip',
        style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary),
      ),
      next: Icon(Icons.arrow_forward, color: AppColors.primary),
      done: Text(
        'Done',
        style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary),
      ),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: EdgeInsets.all(16.w),
      dotsDecorator: DotsDecorator(
        size: Size(10.w, 10.w),
        color: AppColors.primary.withOpacity(0.3),
        activeSize: Size(22.w, 10.w),
        activeColor: AppColors.primary,
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.r)),
        ),
      ),
    );
  }

  Widget _buildImage(IconData icon) {
    return Center(
      child: Container(
        width: 150.w,
        height: 150.w,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 80.sp, color: AppColors.primary),
      ),
    );
  }

  PageDecoration _getPageDecoration(BuildContext context) {
    return PageDecoration(
      titleTextStyle: AppTypography.heading2(
        context,
      ).copyWith(fontSize: 24.sp, fontWeight: FontWeight.bold),
      bodyTextStyle: AppTypography.bodyMedium(
        context,
      ).copyWith(fontSize: 16.sp, color: AppColors.textSecondary(context)),
      pageColor: AppColors.surface(context),
      imagePadding: EdgeInsets.only(top: 80.h),
      titlePadding: EdgeInsets.only(top: 40.h, bottom: 20.h),
    );
  }
}
