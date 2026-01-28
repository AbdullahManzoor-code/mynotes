import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';

/// Sound level indicator widget for voice input
class SoundLevelIndicator extends StatelessWidget {
  final double level; // 0.0 to 1.0
  final bool isVertical;
  final double? width;
  final double? height;
  final Color? activeColor;
  final Color? inactiveColor;

  const SoundLevelIndicator({
    Key? key,
    required this.level,
    this.isVertical = false,
    this.width,
    this.height,
    this.activeColor,
    this.inactiveColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final active = activeColor ?? AppColors.primaryColor;
    final inactive =
        inactiveColor ?? (isDark ? Colors.grey.shade700 : Colors.grey.shade300);

    if (isVertical) {
      return _buildVerticalIndicator(active, inactive);
    } else {
      return _buildHorizontalIndicator(active, inactive);
    }
  }

  Widget _buildHorizontalIndicator(Color active, Color inactive) {
    final bars = 20;
    final activeBars = (bars * level).round();

    return SizedBox(
      width: width ?? 200.w,
      height: height ?? 30.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(bars, (index) {
          final isActive = index < activeBars;
          Color barColor;

          if (isActive) {
            // Color gradient from green to yellow to red
            if (index < bars * 0.5) {
              barColor = Colors.green;
            } else if (index < bars * 0.75) {
              barColor = Colors.yellow;
            } else {
              barColor = Colors.red;
            }
          } else {
            barColor = inactive;
          }

          return Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.w),
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildVerticalIndicator(Color active, Color inactive) {
    final bars = 20;
    final activeBars = (bars * level).round();

    return SizedBox(
      width: width ?? 30.w,
      height: height ?? 200.h,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        verticalDirection: VerticalDirection.up,
        children: List.generate(bars, (index) {
          final isActive = index < activeBars;
          Color barColor;

          if (isActive) {
            // Color gradient from green to yellow to red
            if (index < bars * 0.5) {
              barColor = Colors.green;
            } else if (index < bars * 0.75) {
              barColor = Colors.yellow;
            } else {
              barColor = Colors.red;
            }
          } else {
            barColor = inactive;
          }

          return Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 1.h),
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Compact circular sound level indicator
class CircularSoundLevel extends StatelessWidget {
  final double level; // 0.0 to 1.0
  final double size;
  final Color? activeColor;

  const CircularSoundLevel({
    Key? key,
    required this.level,
    this.size = 40,
    this.activeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = activeColor ?? AppColors.primaryColor;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.1),
            ),
          ),
          // Active level circle
          Container(
            width: size * level,
            height: size * level,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.3 + (0.7 * level)),
            ),
          ),
          // Center dot
          Container(
            width: size * 0.2,
            height: size * 0.2,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
        ],
      ),
    );
  }
}

/// Waveform-style sound level indicator
class WaveformIndicator extends StatelessWidget {
  final double level; // 0.0 to 1.0
  final double width;
  final double height;
  final Color? activeColor;
  final int bars;

  const WaveformIndicator({
    Key? key,
    required this.level,
    this.width = 100,
    this.height = 40,
    this.activeColor,
    this.bars = 5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = activeColor ?? AppColors.primaryColor;

    return SizedBox(
      width: width,
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(bars, (index) {
          // Create waveform effect
          final barHeightFactor =
              ((index - bars / 2).abs() / (bars / 2)) * 0.5 + 0.5;
          final barHeight = height * barHeightFactor * level;

          return Container(
            width: width / (bars * 2),
            height: barHeight.clamp(height * 0.1, height),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4.r),
            ),
          );
        }),
      ),
    );
  }
}

