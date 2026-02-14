import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:avatar_glow/avatar_glow.dart';
import '../../core/constants/app_colors.dart';

/// Reusable voice input button widget with AvatarGlow animation
class VoiceInputButton extends StatelessWidget {
  final bool isListening;
  final VoidCallback onPressed;
  final double? size;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool showWaves;
  final double soundLevel;

  const VoiceInputButton({
    super.key,
    required this.isListening,
    required this.onPressed,
    this.size,
    this.activeColor,
    this.inactiveColor,
    this.showWaves = true,
    this.soundLevel = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final buttonSize = size ?? 48.w;
    final primaryActiveColor = activeColor ?? Colors.red;
    final primaryInactiveColor =
        inactiveColor ?? (isDark ? Colors.white70 : AppColors.primaryColor);

    return AvatarGlow(
      animate: isListening && showWaves,
      glowColor: primaryActiveColor,
      duration: const Duration(milliseconds: 2000),
      repeat: true,
      glowRadiusFactor: 0.7,
      child: Material(
        elevation: isListening ? 12.0 : 4.0,
        shape: const CircleBorder(),
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isListening ? primaryActiveColor : primaryInactiveColor,
              boxShadow: isListening
                  ? [
                      BoxShadow(
                        color: primaryActiveColor.withOpacity(0.4),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              isListening ? Icons.mic : Icons.mic_none,
              color: Colors.white,
              size: buttonSize * 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
