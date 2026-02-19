import 'package:flutter/material.dart';
import 'package:mynotes/presentation/design_system/design_system.dart';

/// Standard filled button with consistent styling
class StandardButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final double? height;
  final IconData? icon;
  final bool isLoading;
  final bool enabled;
  final TextStyle? textStyle;
  final EdgeInsets? padding;

  const StandardButton({
    super.key,
    required this.label,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height,
    this.icon,
    this.isLoading = false,
    this.enabled = true,
    this.textStyle,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height ?? AppSpacing.buttonHeight,
      child: ElevatedButton(
        onPressed: (enabled && !isLoading) ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primaryColor,
          foregroundColor: foregroundColor ?? Colors.white,
          elevation: 2,
          padding:
              padding ??
              EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: AppSpacing.iconSizeMedium,
                width: AppSpacing.iconSizeMedium,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: AppSpacing.iconSizeMedium),
                    SizedBox(width: AppSpacing.sm),
                  ],
                  Text(
                    label,
                    style:
                        textStyle ??
                        const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Outlined button variant
class StandardOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? borderColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final IconData? icon;
  final bool enabled;
  final TextStyle? textStyle;
  final EdgeInsets? padding;

  const StandardOutlinedButton({
    super.key,
    required this.label,
    this.onPressed,
    this.borderColor,
    this.textColor,
    this.width,
    this.height,
    this.icon,
    this.enabled = true,
    this.textStyle,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: width,
      height: height ?? AppSpacing.buttonHeight,
      child: Material(
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color:
                    borderColor ??
                    (isDark ? AppColors.darkBorder : AppColors.borderLight),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
            ),
            padding:
                padding ??
                EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: AppSpacing.iconSizeMedium,
                    color:
                        textColor ??
                        (isDark ? AppColors.lightText : AppColors.darkText),
                  ),
                  SizedBox(width: AppSpacing.sm),
                ],
                Text(
                  label,
                  style:
                      textStyle ??
                      TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color:
                            textColor ??
                            (isDark ? AppColors.lightText : AppColors.darkText),
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

/// Text button variant (minimal style)
class StandardTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? textColor;
  final double? width;
  final IconData? icon;
  final bool enabled;
  final TextStyle? textStyle;

  const StandardTextButton({
    super.key,
    required this.label,
    this.onPressed,
    this.textColor,
    this.width,
    this.icon,
    this.enabled = true,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: AppSpacing.iconSizeMedium,
                    color: textColor ?? AppColors.primaryColor,
                  ),
                  SizedBox(width: AppSpacing.sm),
                ],
                Text(
                  label,
                  style:
                      textStyle ??
                      TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor ?? AppColors.primaryColor,
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

/// Floating Action Button with gradient
class GradientFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? heroTag;
  final double? size;
  final LinearGradient? gradient;
  final bool enabled;

  const GradientFAB({
    super.key,
    required this.onPressed,
    required this.icon,
    this.heroTag,
    this.size,
    this.gradient,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient ?? AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCircular),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: AppSpacing.shadowBlurLarge,
            offset: Offset(0, AppSpacing.shadowOffsetLarge),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCircular),
          child: SizedBox(
            width: size ?? 56,
            height: size ?? 56,
            child: Center(
              child: Icon(
                icon,
                color: Colors.white,
                size: AppSpacing.iconSizeLarge,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Button with semantic color (success, error, warning, info)
class SemanticButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final SemanticButtonType type;
  final double? width;
  final double? height;
  final IconData? icon;
  final bool isLoading;
  final bool enabled;
  final TextStyle? textStyle;

  const SemanticButton({
    super.key,
    required this.label,
    required this.type,
    this.onPressed,
    this.width,
    this.height,
    this.icon,
    this.isLoading = false,
    this.enabled = true,
    this.textStyle,
  });

  Color _getBackgroundColor() {
    switch (type) {
      case SemanticButtonType.success:
        return AppColors.successColor;
      case SemanticButtonType.error:
        return AppColors.errorColor;
      case SemanticButtonType.warning:
        return AppColors.warningColor;
      case SemanticButtonType.info:
        return AppColors.infoColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StandardButton(
      label: label,
      onPressed: onPressed,
      backgroundColor: _getBackgroundColor(),
      foregroundColor: Colors.white,
      width: width,
      height: height,
      icon: icon,
      isLoading: isLoading,
      enabled: enabled,
      textStyle: textStyle,
    );
  }
}

enum SemanticButtonType { success, error, warning, info }

/// Small action button (for list items, cards, etc.)
class ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? size;
  final bool enabled;
  final String? tooltip;

  const ActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size,
    this.enabled = true,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Tooltip(
      message: tooltip ?? '',
      child: Container(
        width: size ?? 40,
        height: size ?? 40,
        decoration: BoxDecoration(
          color:
              backgroundColor ??
              (isDark ? AppColors.darkCardBackgroundAlt : AppColors.grey100),
          borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
            child: Center(
              child: Icon(
                icon,
                color:
                    iconColor ??
                    (isDark ? AppColors.lightText : AppColors.darkText),
                size: AppSpacing.iconSizeMedium,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
