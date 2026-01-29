import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../design_system/design_system.dart';
import '../../core/routes/app_routes.dart';

/// Onboarding Screen
/// Shows feature introduction slides for first-time users
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageModel> _pages = [
    OnboardingPageModel(
      icon: Icons.spa_rounded,
      title: 'Welcome to Calm Productivity',
      description:
          'A simpler way to capture notes, tasks, and reflections without the noise.',
      color: AppColors.primaryColor,
    ),
    OnboardingPageModel(
      icon: Icons.security_rounded,
      title: 'Privacy by Design',
      description:
          'Your data is private and remains on your device. Secure it with your fingerprint.',
      color: AppColors.primaryColor,
    ),
    OnboardingPageModel(
      icon: Icons.auto_awesome_rounded,
      title: 'Smart Capture',
      description:
          'Quickly add anything with smart inputs and voice extraction. Organized automatically.',
      color: AppColors.primaryColor,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _skipOnboarding() {
    _finishOnboarding();
  }

  void _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_launch', false);

    if (!mounted) return;

    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: TextButton(
                  onPressed: _skipOnboarding,
                  child: Text(
                    'Skip',
                    style: AppTypography.bodySmall(context).copyWith(
                      color: AppColors.textSecondary(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // Page indicator
            _buildPageIndicator(),

            SizedBox(height: AppSpacing.xl),

            // Next/Get Started button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: PrimaryButton(
                text: _currentPage == _pages.length - 1
                    ? 'Get Started'
                    : 'Next',
                onPressed: _nextPage,
                isFullWidth: true,
              ),
            ),

            // Sign in option (as seen in templates)
            if (_currentPage == 0) ...[
              SizedBox(height: AppSpacing.md),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: SecondaryButton(
                  text: 'Sign In',
                  onPressed: () {
                    // Navigate to sign in (TBD)
                  },
                  isFullWidth: true,
                ),
              ),
            ],

            SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPageModel page) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon/Illustration placeholder
          Container(
            width: 200.w,
            height: 200.w,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(page.icon, size: 100.sp, color: AppColors.primaryColor),
          ),

          SizedBox(height: 48.h),

          // Title
          Text(
            page.title,
            style: AppTypography.displayLarge(
              context,
            ).copyWith(fontWeight: FontWeight.bold, fontSize: 28.sp),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: AppSpacing.md),

          // Description
          Text(
            page.description,
            style: AppTypography.bodyMedium(
              context,
            ).copyWith(color: AppColors.textSecondary(context), height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? AppColors.primaryColor
                : AppColors.primaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

/// Onboarding Page Model
class OnboardingPageModel {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  OnboardingPageModel({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

