import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../design_system/design_system.dart';

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
  String _pin = '';
  String _confirmPin = '';
  String _currentPin = '';
  bool _isConfirming = false;
  bool _isVerifyingCurrent = false;
  String _errorMessage = '';

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  static const int minPinLength = 4;
  static const int maxPinLength = 6;
  static const String _pinHashKey = 'pin_hash';
  static const String _pinEnabledKey = 'pin_enabled';

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).chain(CurveTween(curve: Curves.bounceInOut)).animate(_shakeController);

    if (widget.isChanging) {
      _isVerifyingCurrent = true;
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          _getTitle(),
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
                child: Icon(Icons.pin, size: 48.w, color: AppColors.primary),
              ),

              SizedBox(height: 24.h),

              Text(
                _getSubtitle(),
                style: AppTypography.bodyLarge(
                  context,
                  AppColors.textPrimary(context),
                ),
                textAlign: TextAlign.center,
              ),

              if (_errorMessage.isNotEmpty) ...[
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
                          _errorMessage,
                          style: AppTypography.bodyMedium(context, Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
              ],

              SizedBox(height: 40.h),

              // PIN dots display
              _buildPinDisplay(),

              SizedBox(height: 40.h),

              // Number pad
              _buildNumberPad(),

              const Spacer(),

              // Helper text
              Text(
                'PIN should be ${minPinLength}-${maxPinLength} digits',
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
  }

  String _getTitle() {
    if (_isVerifyingCurrent) return 'Enter Current PIN';
    if (widget.isChanging) return 'Change PIN';
    if (_isConfirming) return 'Confirm PIN';
    return widget.isFirstSetup ? 'Set Up PIN' : 'Create PIN';
  }

  String _getSubtitle() {
    if (_isVerifyingCurrent) return 'Enter your current PIN to continue';
    if (_isConfirming) return 'Enter your PIN again to confirm';
    return 'Create a ${minPinLength}-${maxPinLength} digit PIN for secure access';
  }

  Widget _buildPinDisplay() {
    String currentInput;
    if (_isVerifyingCurrent) {
      currentInput = _currentPin;
    } else if (_isConfirming) {
      currentInput = _confirmPin;
    } else {
      currentInput = _pin;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(maxPinLength, (index) {
        bool isFilled = index < currentInput.length;
        bool isActive = index == currentInput.length;

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 8.w),
          width: 16.w,
          height: 16.w,
          decoration: BoxDecoration(
            color: isFilled
                ? AppColors.primary
                : (isActive
                      ? AppColors.primary.withOpacity(0.3)
                      : Colors.transparent),
            border: Border.all(
              color: isFilled
                  ? AppColors.primary
                  : AppColors.primary.withOpacity(0.3),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8.w),
          ),
        );
      }),
    );
  }

  Widget _buildNumberPad() {
    return Column(
      children: [
        // Rows 1-3
        for (int row = 0; row < 3; row++)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (int col = 1; col <= 3; col++)
                _buildNumberButton((row * 3) + col),
            ],
          ),
        // Bottom row: 0 and backspace
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 80), // Empty space
            _buildNumberButton(0),
            _buildBackspaceButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberButton(int number) {
    return GestureDetector(
      onTap: () => _onNumberPressed(number),
      child: Container(
        margin: EdgeInsets.all(8.w),
        width: 80.w,
        height: 80.w,
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(40.w),
          border: Border.all(color: AppColors.border(context)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            number.toString(),
            style: AppTypography.heading1(
              context,
              AppColors.textPrimary(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return GestureDetector(
      onTap: _onBackspacePressed,
      child: Container(
        margin: EdgeInsets.all(8.w),
        width: 80.w,
        height: 80.w,
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(40.w),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Center(
          child: Icon(
            Icons.backspace_outlined,
            color: AppColors.textPrimary(context),
            size: 24.w,
          ),
        ),
      ),
    );
  }

  void _onNumberPressed(int number) {
    HapticFeedback.lightImpact();
    setState(() {
      _errorMessage = '';

      if (_isVerifyingCurrent) {
        if (_currentPin.length < maxPinLength) {
          _currentPin += number.toString();
          if (_currentPin.length >= minPinLength) {
            _verifyCurrentPin();
          }
        }
      } else if (_isConfirming) {
        if (_confirmPin.length < maxPinLength) {
          _confirmPin += number.toString();
          if (_confirmPin.length >= minPinLength &&
              _confirmPin.length == _pin.length) {
            _confirmPinSetup();
          }
        }
      } else {
        if (_pin.length < maxPinLength) {
          _pin += number.toString();
          if (_pin.length >= minPinLength) {
            // Auto-proceed to confirmation after minimum length
            Future.delayed(const Duration(milliseconds: 300), () {
              if (_pin.length >= minPinLength) {
                setState(() {
                  _isConfirming = true;
                });
              }
            });
          }
        }
      }
    });
  }

  void _onBackspacePressed() {
    HapticFeedback.lightImpact();
    setState(() {
      _errorMessage = '';

      if (_isVerifyingCurrent && _currentPin.isNotEmpty) {
        _currentPin = _currentPin.substring(0, _currentPin.length - 1);
      } else if (_isConfirming && _confirmPin.isNotEmpty) {
        _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
      } else if (!_isConfirming && _pin.isNotEmpty) {
        _pin = _pin.substring(0, _pin.length - 1);
      }
    });
  }

  Future<void> _verifyCurrentPin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedHash = prefs.getString(_pinHashKey);

      if (storedHash == null) {
        setState(() {
          _errorMessage = 'No PIN found. Please contact support.';
        });
        return;
      }

      final inputHash = _hashPin(_currentPin);
      if (inputHash == storedHash) {
        setState(() {
          _isVerifyingCurrent = false;
          _currentPin = '';
        });
      } else {
        _showError('Incorrect PIN. Please try again.');
        setState(() {
          _currentPin = '';
        });
      }
    } catch (e) {
      _showError('Verification failed. Please try again.');
    }
  }

  Future<void> _confirmPinSetup() async {
    if (_pin != _confirmPin) {
      _showError('PINs do not match. Please try again.');
      setState(() {
        _isConfirming = false;
        _pin = '';
        _confirmPin = '';
      });
      return;
    }

    try {
      await _savePinHash(_pin);

      if (mounted) {
        HapticFeedback.heavyImpact();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isChanging
                  ? 'PIN changed successfully!'
                  : 'PIN created successfully!',
              style: AppTypography.bodyMedium(context, Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true);
      }
    } catch (e) {
      _showError('Failed to save PIN. Please try again.');
    }
  }

  void _showError(String message) {
    HapticFeedback.mediumImpact();
    setState(() {
      _errorMessage = message;
    });
    _shakeController.reset();
    _shakeController.forward();
  }

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _savePinHash(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final hash = _hashPin(pin);
    await prefs.setString(_pinHashKey, hash);
    await prefs.setBool(_pinEnabledKey, true);
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

