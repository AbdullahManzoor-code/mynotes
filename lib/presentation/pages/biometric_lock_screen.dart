import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lottie/lottie.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/biometric_auth_service.dart';
import 'main_home_screen.dart';

class BiometricLockScreen extends StatefulWidget {
  final VoidCallback? onAuthenticated;

  const BiometricLockScreen({super.key, this.onAuthenticated});

  @override
  State<BiometricLockScreen> createState() => _BiometricLockScreenState();
}

class _BiometricLockScreenState extends State<BiometricLockScreen>
    with SingleTickerProviderStateMixin {
  final BiometricAuthService _authService = BiometricAuthService();
  bool _isAuthenticating = false;
  String _authMessage = 'Tap to unlock';
  List<BiometricType> _availableBiometrics = [];
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _checkBiometrics();
    // Auto-trigger authentication on screen load
    Future.delayed(const Duration(milliseconds: 500), _authenticate);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometrics() async {
    final types = await _authService.getAvailableBiometrics();
    setState(() {
      _availableBiometrics = types;
    });
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;

    if (!mounted) return;
    setState(() {
      _isAuthenticating = true;
      _authMessage = 'Authenticating...';
    });

    final authenticated = await _authService.authenticate(
      reason: 'Unlock your notes',
      useErrorDialogs: true,
      stickyAuth: true,
    );

    if (!mounted) return;

    if (authenticated) {
      setState(() {
        _authMessage = 'Authenticated ✓';
      });

      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      // Call the callback if provided
      if (widget.onAuthenticated != null) {
        widget.onAuthenticated!();
      } else {
        // Navigate to main home screen by default
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainHomeScreen()),
        );
      }
    } else {
      setState(() {
        _isAuthenticating = false;
        _authMessage = 'Authentication failed. Tap to retry';
      });
    }
  }

  IconData _getBiometricIcon() {
    if (_availableBiometrics.contains(BiometricType.face)) {
      return Icons.face;
    } else if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return Icons.fingerprint;
    }
    return Icons.lock;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    AppColors.darkBackground,
                    AppColors.primaryColor.withOpacity(0.1),
                  ]
                : [
                    AppColors.lightBackground,
                    AppColors.primaryColor.withOpacity(0.05),
                  ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo/Title
                Text(
                  'MyNotes',
                  style: TextStyle(
                    fontSize: 36.sp,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..shader = LinearGradient(
                        colors: [
                          AppColors.primaryColor,
                          AppColors.secondaryColor,
                        ],
                      ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                  ),
                ),

                SizedBox(height: 8.h),

                Text(
                  'Your secure personal notebook',
                  style: TextStyle(fontSize: 14.sp, color: AppColors.grey600),
                ),

                SizedBox(height: 80.h),

                // Biometric Icon with Pulse Animation
                GestureDetector(
                  onTap: _authenticate,
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        width: 140.w,
                        height: 140.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primaryColor.withOpacity(0.3),
                              AppColors.secondaryColor.withOpacity(0.3),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryColor.withOpacity(
                                0.3 * _pulseController.value,
                              ),
                              blurRadius: 40.w,
                              spreadRadius: 10.w * _pulseController.value,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            _getBiometricIcon(),
                            size: 70.sp,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(height: 40.h),

                // Auth Message
                Text(
                  _authMessage,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.lightText : AppColors.darkText,
                  ),
                ),

                if (_isAuthenticating) ...[
                  SizedBox(height: 20.h),
                  SizedBox(
                    width: 30.w,
                    height: 30.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryColor,
                      ),
                    ),
                  ),
                ],

                SizedBox(height: 60.h),

                // Retry Button
                if (!_isAuthenticating)
                  TextButton.icon(
                    onPressed: _authenticate,
                    icon: Icon(Icons.refresh, color: AppColors.primaryColor),
                    label: Text(
                      'Try Again',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                const Spacer(),

                // Info Text
                Padding(
                  padding: EdgeInsets.only(bottom: 30.h),
                  child: Text(
                    'Protected by ${_authService.getBiometricTypeName(_availableBiometrics)}',
                    style: TextStyle(fontSize: 12.sp, color: AppColors.grey600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

