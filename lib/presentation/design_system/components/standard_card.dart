import 'package:flutter/material.dart';
import 'package:mynotes/presentation/design_system/design_system.dart';

/// Standard reusable card component with consistent styling
/// Used throughout the app for notes, todos, reminders, etc.
class StandardCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? elevation;
  final double? borderRadius;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enabled;
  final GestureTapCallback? onSecondaryTap;

  const StandardCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.elevation,
    this.borderRadius,
    this.onTap,
    this.onLongPress,
    this.onSecondaryTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: margin ?? EdgeInsets.zero,
      child: Card(
        elevation: elevation ?? (isDark ? 2 : 1),
        color:
            backgroundColor ??
            (isDark ? AppColors.darkCardBackground : AppColors.lightSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            borderRadius ?? AppSpacing.radiusCard,
          ),
          side: BorderSide(
            color:
                borderColor ??
                (isDark ? AppColors.darkBorder : AppColors.borderLight),
            width: 0.5,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onTap : null,
            onLongPress: enabled ? onLongPress : null,
            onSecondaryTap: enabled ? onSecondaryTap : null,
            borderRadius: BorderRadius.circular(
              borderRadius ?? AppSpacing.radiusCard,
            ),
            child: Padding(
              padding: padding ?? EdgeInsets.all(AppSpacing.cardPadding),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Elevated card variant - Higher elevation for focus
class ElevatedCard extends StandardCard {
  const ElevatedCard({
    super.key,
    required super.child,
    super.padding,
    super.margin,
    super.backgroundColor,
    super.borderColor,
    super.borderRadius,
    super.onTap,
    super.onLongPress,
    super.onSecondaryTap,
    super.enabled = true,
  }) : super(elevation: 4);
}

/// Outlined card variant - No shadow, just border
class OutlinedCard extends StandardCard {
  const OutlinedCard({
    super.key,
    required super.child,
    super.padding,
    super.margin,
    super.backgroundColor,
    super.borderColor,
    super.borderRadius,
    super.onTap,
    super.onLongPress,
    super.onSecondaryTap,
    super.enabled = true,
  }) : super(elevation: 0);
}

/// Gradient card variant - With gradient background
class GradientCard extends StatelessWidget {
  final Widget child;
  final LinearGradient gradient;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? borderRadius;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enabled;

  const GradientCard({
    super.key,
    required this.child,
    required this.gradient,
    this.padding,
    this.margin,
    this.borderRadius,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.zero,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(
          borderRadius ?? AppSpacing.radiusCard,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: AppSpacing.shadowBlurMedium,
            offset: Offset(0, AppSpacing.shadowOffsetSmall),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          onLongPress: enabled ? onLongPress : null,
          borderRadius: BorderRadius.circular(
            borderRadius ?? AppSpacing.radiusCard,
          ),
          child: Padding(
            padding: padding ?? EdgeInsets.all(AppSpacing.cardPadding),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Status card with colored left border
class StatusCard extends StatelessWidget {
  final Widget child;
  final Color statusColor;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? borderRadius;
  final VoidCallback? onTap;
  final bool enabled;

  const StatusCard({
    super.key,
    required this.child,
    required this.statusColor,
    this.padding,
    this.margin,
    this.borderRadius,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: margin ?? EdgeInsets.zero,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          borderRadius ?? AppSpacing.radiusCard,
        ),
        border: Border(
          left: BorderSide(color: statusColor, width: 4),
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.borderLight,
            width: 0.5,
          ),
          right: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.borderLight,
            width: 0.5,
          ),
          bottom: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.borderLight,
            width: 0.5,
          ),
        ),
        color: isDark ? AppColors.darkCardBackground : AppColors.lightSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: AppSpacing.shadowBlurSmall,
            offset: Offset(0, AppSpacing.shadowOffsetSmall),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(
            borderRadius ?? AppSpacing.radiusCard,
          ),
          child: Padding(
            padding: padding ?? EdgeInsets.all(AppSpacing.cardPadding),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Shimmer loading card (placeholder)
class ShimmerCard extends StatefulWidget {
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? borderRadius;
  final double height;

  const ShimmerCard({
    super.key,
    this.padding,
    this.margin,
    this.borderRadius,
    this.height = 100,
  });

  @override
  State<ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<ShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: widget.margin ?? EdgeInsets.zero,
      child: Card(
        elevation: 1,
        color: isDark ? AppColors.darkCardBackground : AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            widget.borderRadius ?? AppSpacing.radiusCard,
          ),
          side: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.borderLight,
            width: 0.5,
          ),
        ),
        child: Padding(
          padding: widget.padding ?? EdgeInsets.all(AppSpacing.cardPadding),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                height: widget.height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: isDark
                      ? AppColors.shimmerGradientDark
                      : AppColors.shimmerGradientLight,
                  backgroundBlendMode: BlendMode.lighten,
                ),
                transform: Matrix4.translationValues(
                  (_controller.value - 0.5) * 200,
                  0,
                  0,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
