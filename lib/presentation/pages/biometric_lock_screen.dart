import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_auth/local_auth.dart';
import '../../core/constants/app_colors.dart';
import '../../injection_container.dart';
import '../bloc/biometric_auth/biometric_auth_bloc.dart';
import 'main_home_screen.dart' hide Icon;

class BiometricLockScreen extends StatefulWidget {
  final VoidCallback? onAuthenticated;

  const BiometricLockScreen({super.key, this.onAuthenticated});

  @override
  State<BiometricLockScreen> createState() => _BiometricLockScreenState();
}

class _BiometricLockScreenState extends State<BiometricLockScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  IconData _getBiometricIcon(List<BiometricType> availableBiometrics) {
    if (availableBiometrics.contains(BiometricType.face)) {
      return Icons.face;
    } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
      return Icons.fingerprint;
    }
    return Icons.lock;
  }

  String _getBiometricTypeName(List<BiometricType> types) {
    if (types.contains(BiometricType.face)) return 'FaceID';
    if (types.contains(BiometricType.fingerprint)) return 'TouchID';
    if (types.contains(BiometricType.iris)) return 'Iris Recognition';
    return 'Biometrics';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (context) => getIt<BiometricAuthBloc>()
        ..add(CheckBiometricsEvent())
        ..add(const AuthenticateEvent()),
      child: BlocConsumer<BiometricAuthBloc, BiometricAuthState>(
        listener: (context, state) async {
          if (state is BiometricAuthenticated) {
            await Future.delayed(const Duration(milliseconds: 300));
            if (!mounted) return;

            if (widget.onAuthenticated != null) {
              widget.onAuthenticated!();
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const MainHomeScreen()),
              );
            }
          }
        },
        builder: (context, state) {
          String authMessage = 'Tap to unlock';
          List<BiometricType> biometrics = [];
          bool isAuthenticating = false;

          if (state is BiometricAuthReady) {
            authMessage = state.message;
            biometrics = state.availableBiometrics;
            isAuthenticating = state.isAuthenticating;
          } else if (state is BiometricAuthenticated) {
            authMessage = 'Authenticated ✓';
            isAuthenticating = false;
          } else if (state is BiometricAuthFailure) {
            authMessage = state.message;
            biometrics = state.availableBiometrics;
            isAuthenticating = false;
          } else if (state is BiometricAuthChecking) {
            authMessage = 'Checking biometrics...';
            isAuthenticating = true;
          }

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
                      const Spacer(flex: 2),
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
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.grey600,
                        ),
                      ),

                      SizedBox(height: 80.h),

                      // Biometric Icon with Pulse Animation
                      GestureDetector(
                        onTap: isAuthenticating
                            ? null
                            : () => context.read<BiometricAuthBloc>().add(
                                const AuthenticateEvent(),
                              ),
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
                                  _getBiometricIcon(biometrics),
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
                        authMessage,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.lightText
                              : AppColors.darkText,
                        ),
                      ),

                      if (isAuthenticating) ...[
                        SizedBox(height: 20.h),
                        SizedBox(
                          width: 30.w,
                          height: 30.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ],

                      SizedBox(height: 60.h),

                      // Retry Button
                      if (!isAuthenticating && state is! BiometricAuthenticated)
                        TextButton.icon(
                          onPressed: () => context
                              .read<BiometricAuthBloc>()
                              .add(const AuthenticateEvent()),
                          icon: const Icon(
                            Icons.refresh,
                            color: AppColors.primaryColor,
                          ),
                          label: Text(
                            'Try Again',
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                      const Spacer(flex: 3),

                      // Info Text
                      if (biometrics.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(bottom: 30.h),
                          child: Text(
                            'Protected by ${_getBiometricTypeName(biometrics)}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.grey600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
