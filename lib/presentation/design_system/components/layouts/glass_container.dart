import 'dart:ui';
import 'package:flutter/material.dart';
import '../../app_colors.dart';
import '../../app_spacing.dart';

/// Glass container with blur effect
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final double blur;
  final Color? color;
  final Border? border;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blur = 12,
    this.color,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          borderRadius ?? AppSpacing.radiusMd,
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: color ?? AppColors.surface(context).withOpacity(0.7),
              borderRadius: BorderRadius.circular(
                borderRadius ?? AppSpacing.radiusMd,
              ),
              border:
                  border ??
                  Border.all(color: AppColors.divider(context), width: 1),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
