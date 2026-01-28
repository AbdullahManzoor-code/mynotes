import 'dart:ui';
import 'package:flutter/material.dart';
import '../../app_colors.dart';
import '../../app_spacing.dart';

/// Base container for cards with glass effect
class CardContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final Color? borderColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double? blur;
  final double? width;
  final double? height;

  const CardContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.borderColor,
    this.backgroundColor,
    this.onTap,
    this.onLongPress,
    this.blur,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppSpacing.radiusLg;

    return Container(
      margin: margin,
      width: width,
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(radius),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blur ?? 12, sigmaY: blur ?? 12),
              child: Container(
                padding: padding ?? EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color:
                      backgroundColor ??
                      AppColors.surface(context).withOpacity(0.7),
                  borderRadius: BorderRadius.circular(radius),
                  border: Border.all(
                    color: borderColor ?? AppColors.divider(context),
                    width: 1,
                  ),
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
