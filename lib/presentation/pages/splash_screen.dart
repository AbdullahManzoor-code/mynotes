import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/services/clipboard_service.dart';
import 'home_page.dart';
import 'onboarding_screen.dart';

/// Splash Screen
/// Initializes app services and shows loading animation
/// Navigates to onboarding (first launch) or home screen
class SplashScreen extends StatefulWidget {
  final ClipboardService? clipboardService;

  const SplashScreen({Key? key, this.clipboardService}) : super(key: key);

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

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
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
        print('Notification init error: $e');
      }

      // Step 3: Start clipboard monitoring
      if (widget.clipboardService != null) {
        await widget.clipboardService!.startMonitoring();
      }

      // Step 3: Request permissions
      setState(() {
        _initStatus = 'Requesting permissions...';
        _progress = 0.6;
      });
      await Future.delayed(const Duration(milliseconds: 500));

      // Step 4: Initialize database
      setState(() {
        _initStatus = 'Setting up database...';
        _progress = 0.8;
      });
      await Future.delayed(const Duration(milliseconds: 500));

      // Step 5: Create media folders
      setState(() {
        _initStatus = 'Preparing storage...';
        _progress = 1.0;
      });
      await Future.delayed(const Duration(milliseconds: 500));

      // Check if first launch
      final isFirstLaunch = await _checkFirstLaunch();

      // Navigate to appropriate screen
      if (!mounted) return;

      await _controller.reverse();

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) =>
              isFirstLaunch ? const OnboardingScreen() : const HomePage(),
        ),
      );
    } catch (e) {
      setState(() {
        _initStatus = 'Error: ${e.toString()}';
      });
    }
  }

  Future<bool> _checkFirstLaunch() async {
    // Check if this is the first launch by reading from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('first_launch') ?? true;
    return isFirstLaunch;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // App Logo with animations
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: _buildLogo(),
                ),
              ),

              SizedBox(height: 32.h),

              // App Name
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  AppConstants.appName,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SizedBox(height: 8.h),

              // Tagline
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Capture moments, memories, and ideas',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.whiteOpacity70,
                  ),
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
                      borderRadius: BorderRadius.circular(8.r),
                      child: LinearProgressIndicator(
                        value: _progress,
                        backgroundColor: AppColors.whiteOpacity24,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.onPrimary,
                        ),
                        minHeight: 6.h,
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Status text
                    Text(
                      _initStatus,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.whiteOpacity70,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 120.w,
      height: 120.h,
      decoration: BoxDecoration(
        color: AppColors.onPrimary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.2),
            blurRadius: 20.w,
            spreadRadius: 5.w,
          ),
        ],
      ),
      child: Icon(
        Icons.notes_rounded,
        size: 64.sp,
        color: AppColors.primaryColor,
      ),
    );
  }
}
