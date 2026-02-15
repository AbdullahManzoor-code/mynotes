import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../design_system/design_system.dart';
import '../bloc/pin_setup/pin_setup_bloc.dart';
import '../../core/services/app_logger.dart';

/// PIN Setup Screen
/// Allows users to create, change, or reset their PIN for fallback authentication
class PinSetupScreen extends StatefulWidget {
  final bool isFirstSetup;
  final bool isChanging;

  const PinSetupScreen({
    super.key,
    this.isFirstSetup = false,
    this.isChanging = false,
  });

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen>
    with TickerProviderStateMixin {
  final TextEditingController _pinController = TextEditingController();
  late PinSetupBloc _bloc;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  static const int minPinLength = 4;
  static const int maxPinLength = 6;
  static const String _pinHashKey = 'pin_hash';
  static const String _pinEnabledKey = 'pin_enabled';

  @override
  void initState() {
    super.initState();
    AppLogger.i(
      'PinSetupScreen: initState (isFirstSetup: ${widget.isFirstSetup}, isChanging: ${widget.isChanging})',
    );
    _bloc = PinSetupBloc(
      isFirstSetup: widget.isFirstSetup,
      isChanging: widget.isChanging,
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).chain(CurveTween(curve: Curves.bounceInOut)).animate(_shakeController);
  }

  @override
  void dispose() {
    AppLogger.i('PinSetupScreen: dispose');
    _shakeController.dispose();
    _pinController.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<PinSetupBloc, PinSetupState>(
        listener: (context, state) {
          if (state.errorMessage.isNotEmpty) {
            AppLogger.e('PinSetupScreen: PIN error: ${state.errorMessage}');
            _shakeController.reset();
            _shakeController.forward();
            HapticFeedback.mediumImpact();
            _pinController.clear();
          }

          if (state.isSuccess) {
            AppLogger.i('PinSetupScreen: PIN setup successful');
            HapticFeedback.heavyImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.isChanging
                      ? 'PIN changed successfully!'
                      : 'PIN created successfully!',
                  style: AppTypography.bodyMedium(context, Colors.white),
                ),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          }

          if (state.isConfirming &&
              _pinController.text.length == 4 &&
              state.errorMessage.isEmpty) {
            AppLogger.i('PinSetupScreen: PIN entered, moving to confirmation');
            _pinController.clear();
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.surface(context),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.close, color: AppColors.textPrimary(context)),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                _getTitle(state),
                style: AppTypography.heading2(
                  context,
                  AppColors.textPrimary(context),
                ),
              ),
            ),
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    SizedBox(height: 40.h),

                    // Icon and description
                    Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Icon(
                        Icons.pin,
                        size: 48.w,
                        color: AppColors.primary,
                      ),
                    ),

                    SizedBox(height: 24.h),

                    Text(
                      _getSubtitle(state),
                      style: AppTypography.bodyLarge(
                        context,
                        AppColors.textPrimary(context),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    if (state.errorMessage.isNotEmpty) ...[
                      SizedBox(height: 16.h),
                      AnimatedBuilder(
                        animation: _shakeAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(_shakeAnimation.value, 0),
                            child: Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                state.errorMessage,
                                style: AppTypography.bodyMedium(
                                  context,
                                  Colors.red,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),
                    ],

                    SizedBox(height: 40.h),

                    // PIN Input using pin_code_fields
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: PinCodeTextField(
                        appContext: context,
                        controller: _pinController,
                        length: 4,
                        obscureText: true,
                        obscuringCharacter: '●',
                        animationType: AnimationType.fade,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(12.r),
                          fieldHeight: 60.h,
                          fieldWidth: 50.w,
                          activeFillColor: AppColors.primary.withOpacity(0.1),
                          inactiveFillColor: AppColors.surface(context),
                          selectedFillColor: AppColors.primary.withOpacity(
                            0.05,
                          ),
                          activeColor: AppColors.primary,
                          inactiveColor: AppColors.border(context),
                          selectedColor: AppColors.primary,
                        ),
                        animationDuration: const Duration(milliseconds: 300),
                        backgroundColor: Colors.transparent,
                        enableActiveFill: true,
                        keyboardType: TextInputType.number,
                        onCompleted: (v) {
                          _onPinEntered(v);
                        },
                        onChanged: (value) {
                          _bloc.add(const PinChanged());
                        },
                        beforeTextPaste: (text) => false,
                      ),
                    ),

                    const Spacer(),

                    // Helper text
                    Text(
                      'PIN should be $minPinLength-$maxPinLength digits',
                      style: AppTypography.captionLarge(
                        context,
                        AppColors.textSecondary(context),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getTitle(PinSetupState state) {
    if (state.isVerifyingCurrent) return 'Enter Current PIN';
    if (state.isChanging) return 'Change PIN';
    if (state.isConfirming) return 'Confirm PIN';
    return state.isFirstSetup ? 'Set Up PIN' : 'Create PIN';
  }

  String _getSubtitle(PinSetupState state) {
    if (state.isVerifyingCurrent) return 'Enter your current PIN to continue';
    if (state.isConfirming) return 'Enter your PIN again to confirm';
    return 'Create a $minPinLength-$maxPinLength digit PIN for secure access';
  }

  void _onPinEntered(String value) {
    HapticFeedback.lightImpact();
    _bloc.add(EnteredPin(value));
  }

  static Future<bool> isPinEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_pinEnabledKey) ?? false;
  }

  static Future<bool> verifyPin(String pin) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedHash = prefs.getString(_pinHashKey);
      if (storedHash == null) return false;

      final inputHash = sha256.convert(utf8.encode(pin)).toString();
      return inputHash == storedHash;
    } catch (e) {
      return false;
    }
  }

  static Future<void> disablePin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pinHashKey);
    await prefs.setBool(_pinEnabledKey, false);
  }
}
