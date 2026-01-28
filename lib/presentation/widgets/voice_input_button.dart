import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';

/// Reusable voice input button widget with animations
class VoiceInputButton extends StatefulWidget {
  final bool isListening;
  final VoidCallback onPressed;
  final double? size;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool showWaves;
  final double soundLevel;

  const VoiceInputButton({
    Key? key,
    required this.isListening,
    required this.onPressed,
    this.size,
    this.activeColor,
    this.inactiveColor,
    this.showWaves = true,
    this.soundLevel = 0.0,
  }) : super(key: key);

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final buttonSize = widget.size ?? 48.w;
    final activeColor = widget.activeColor ?? Colors.red;
    final inactiveColor =
        widget.inactiveColor ??
        (isDark ? Colors.white70 : AppColors.primaryColor);

    return GestureDetector(
      onTap: widget.onPressed,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated waves when listening
          if (widget.isListening && widget.showWaves)
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Container(
                  width: buttonSize * _pulseAnimation.value * 1.5,
                  height: buttonSize * _pulseAnimation.value * 1.5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: activeColor.withOpacity(
                      0.2 * (1 - widget.soundLevel),
                    ),
                  ),
                );
              },
            ),

          // Second wave
          if (widget.isListening && widget.showWaves)
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Container(
                  width: buttonSize * _pulseAnimation.value * 1.2,
                  height: buttonSize * _pulseAnimation.value * 1.2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: activeColor.withOpacity(0.3),
                  ),
                );
              },
            ),

          // Main button
          Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.isListening ? activeColor : inactiveColor,
              boxShadow: [
                BoxShadow(
                  color: (widget.isListening ? activeColor : inactiveColor)
                      .withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              widget.isListening ? Icons.mic : Icons.mic_none,
              color: Colors.white,
              size: buttonSize * 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

