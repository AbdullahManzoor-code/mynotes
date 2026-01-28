import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../app_colors.dart';
import '../../app_spacing.dart';
import '../../app_typography.dart';

/// Frosted glass app bar with blur effect
/// Matches the design system's glass morphism style
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final double elevation;
  final bool centerTitle;
  final double? height;
  final SystemUiOverlayStyle? systemOverlayStyle;

  const GlassAppBar({
    Key? key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.elevation = 0,
    this.centerTitle = false,
    this.height,
    this.systemOverlayStyle,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(height ?? 56.h);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value:
          systemOverlayStyle ??
          (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            height: preferredSize.height,
            decoration: BoxDecoration(
              color:
                  backgroundColor ??
                  AppColors.surface(context).withOpacity(0.8),
              border: Border(
                bottom: BorderSide(color: AppColors.border(context), width: 1),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  if (leading != null)
                    leading!
                  else if (automaticallyImplyLeading &&
                      Navigator.canPop(context))
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: AppColors.textPrimary(context),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  if (centerTitle) const Spacer(),
                  if (titleWidget != null)
                    titleWidget!
                  else if (title != null)
                    Text(
                      title!,
                      style: AppTypography.heading3(context: context),
                    ),
                  if (centerTitle) const Spacer(),
                  if (!centerTitle) const Spacer(),
                  if (actions != null) ...actions!,
                  SizedBox(width: AppSpacing.xs.w),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Transparent app bar (used when body extends behind)
class TransparentAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Color? iconColor;
  final Color? textColor;
  final bool centerTitle;
  final double? height;

  const TransparentAppBar({
    Key? key,
    this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.iconColor,
    this.textColor,
    this.centerTitle = false,
    this.height,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(height ?? 56.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: centerTitle,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      iconTheme: IconThemeData(color: iconColor ?? Colors.white),
      title: title != null
          ? Text(
              title!,
              style: AppTypography.heading3().copyWith(
                color: textColor ?? Colors.white,
              ),
            )
          : null,
      actions: actions,
    );
  }
}

/// Collapsible app bar with blur effect
class CollapsibleGlassAppBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final double expandedHeight;
  final Widget? flexibleSpace;
  final bool pinned;
  final bool floating;

  const CollapsibleGlassAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.expandedHeight = 200.0,
    this.flexibleSpace,
    this.pinned = true,
    this.floating = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SliverAppBar(
      expandedHeight: expandedHeight.h,
      pinned: pinned,
      floating: floating,
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: leading,
      actions: actions,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.surface(context).withOpacity(0.9),
                  AppColors.surface(context).withOpacity(0.7),
                ],
              ),
              border: Border(
                bottom: BorderSide(color: AppColors.border(context), width: 1),
              ),
            ),
            child: FlexibleSpaceBar(
              title: Text(
                title,
                style: AppTypography.heading3(context: context),
              ),
              centerTitle: false,
              titlePadding: EdgeInsets.only(
                left: AppSpacing.lg.w,
                bottom: AppSpacing.md.h,
              ),
              background: flexibleSpace,
            ),
          ),
        ),
      ),
    );
  }
}

/// Simple app bar without blur
class SimpleAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final bool centerTitle;
  final double? height;

  const SimpleAppBar({
    Key? key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.centerTitle = false,
    this.height,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(height ?? 56.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? AppColors.surface(context),
      elevation: 0,
      centerTitle: centerTitle,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      title:
          titleWidget ??
          (title != null
              ? Text(title!, style: AppTypography.heading3(context: context))
              : null),
      actions: actions,
    );
  }
}
