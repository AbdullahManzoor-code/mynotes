import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../design_system/design_system.dart';
import '../../core/constants/app_constants.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/services/clipboard_service.dart';
import '../../core/services/biometric_auth_service.dart';
import '../../core/routes/app_routes.dart';

/// Splash Screen
/// Initializes app services and shows loading animation
/// Navigates to onboarding (first launch) or home screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  String _initStatus = 'Initializing...';
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();
  }

  Future<void> _initializeApp() async {
    try {
      // Step 1: Check first launch
      setState(() {
        _initStatus = 'Checking preferences...';
        _progress = 0.2;
      });
      await Future.delayed(const Duration(milliseconds: 500));

      // Step 2: Initialize notification service
      setState(() {
        _initStatus = 'Setting up notifications...';
        _progress = 0.4;
      });
      try {
        await NotificationService().init();
      } catch (e) {
        debugPrint('Notification init error: $e');
      }

      // Step 3: Start clipboard monitoring
      final clipboardService = RepositoryProvider.of<ClipboardService>(context);
      await clipboardService.startMonitoring();

      // Step 4: Request permissions
      setState(() {
        _initStatus = 'Requesting permissions...';
        _progress = 0.7;
      });
      await Future.delayed(const Duration(milliseconds: 500));

      // Step 5: Preparing storage
      setState(() {
        _initStatus = 'Preparing storage...';
        _progress = 1.0;
      });
      await Future.delayed(const Duration(milliseconds: 500));

      // Check if first launch
      final isFirstLaunch = await _checkFirstLaunch();

      // Check if biometric is enabled
      final biometricService = BiometricAuthService();
      final isBiometricEnabled = await biometricService.isBiometricEnabled();

      // Navigate to appropriate screen
      if (!mounted) return;

      await _controller.reverse();

      if (isFirstLaunch) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
      } else if (isBiometricEnabled) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.biometricLock);
      } else {
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _initStatus = 'Error: ${e.toString()}';
        });
      }
    }
  }

  Future<bool> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('first_launch') ?? true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),

            // App Logo with animations
            FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: _buildLogo(),
              ),
            ),

            SizedBox(height: AppSpacing.xl),

            // App Name
            FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                AppConstants.appName,
                style: AppTypography.displayLarge(
                  context,
                ).copyWith(color: AppColors.primaryColor, letterSpacing: 2),
              ),
            ),

            SizedBox(height: AppSpacing.sm),

            // Tagline
            FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                'Capture moments, memories, and ideas',
                style: AppTypography.bodyMedium(
                  context,
                ).copyWith(color: AppColors.textSecondary(context)),
                textAlign: TextAlign.center,
              ),
            ),

            const Spacer(flex: 2),

            // Loading indicator
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 48.w),
              child: Column(
                children: [
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    child: LinearProgressIndicator(
                      value: _progress,
                      backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primaryColor,
                      ),
                      minHeight: 4,
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),

                  // Status text
                  Text(
                    _initStatus,
                    style: AppTypography.captionSmall(
                      context,
                    ).copyWith(color: AppColors.textTertiary(context)),
                  ),
                ],
              ),
            ),

            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 100.w,
      height: 100.h,
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.notes_rounded,
        size: 48.sp,
        color: AppColors.primaryColor,
      ),
    );
  }
}

