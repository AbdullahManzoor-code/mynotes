import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../app_colors.dart';
import '../../app_spacing.dart';

/// Main scaffold wrapper for all screens in the app
/// Provides consistent layout structure with optional app bar, bottom nav, and FAB
class AppScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool extendBodyBehindAppBar;
  final bool resizeToAvoidBottomInset;
  final Color? backgroundColor;
  final Widget? drawer;
  final Widget? endDrawer;
  final bool safeAreaTop;
  final bool safeAreaBottom;
  final bool safeAreaLeft;
  final bool safeAreaRight;

  const AppScaffold({
    Key? key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.extendBodyBehindAppBar = false,
    this.resizeToAvoidBottomInset = true,
    this.backgroundColor,
    this.drawer,
    this.endDrawer,
    this.safeAreaTop = true,
    this.safeAreaBottom = true,
    this.safeAreaLeft = true,
    this.safeAreaRight = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.background(context),
      appBar: appBar,
      drawer: drawer,
      endDrawer: endDrawer,
      body: SafeArea(
        top: safeAreaTop,
        bottom: safeAreaBottom,
        left: safeAreaLeft,
        right: safeAreaRight,
        child: body,
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }
}

/// Scaffold with gradient background (used in onboarding, etc)
class GradientScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final List<Color>? gradientColors;
  final AlignmentGeometry gradientBegin;
  final AlignmentGeometry gradientEnd;
  final bool safeAreaTop;
  final bool safeAreaBottom;
  final SystemUiOverlayStyle? systemOverlayStyle;

  const GradientScaffold({
    Key? key,
    required this.body,
    this.appBar,
    this.gradientColors,
    this.gradientBegin = Alignment.topLeft,
    this.gradientEnd = Alignment.bottomRight,
    this.safeAreaTop = true,
    this.safeAreaBottom = true,
    this.systemOverlayStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final List<Color> defaultGradientColors = isDark
        ? AppColors.darkGradient.colors
        : AppColors.lightGradient.colors;

    final List<Color> effectiveColors =
        (gradientColors ?? defaultGradientColors).cast<Color>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value:
          systemOverlayStyle ??
          (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: appBar,
        extendBodyBehindAppBar: true,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: gradientBegin,
              end: gradientEnd,
              colors: effectiveColors,
            ),
          ),
          child: SafeArea(
            top: safeAreaTop,
            bottom: safeAreaBottom,
            child: body,
          ),
        ),
      ),
    );
  }
}

/// Scaffold with blur background (frosted glass effect)
class BlurScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final bool safeAreaTop;
  final bool safeAreaBottom;

  const BlurScaffold({
    Key? key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.safeAreaTop = true,
    this.safeAreaBottom = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.background(context),
      appBar: appBar,
      extendBodyBehindAppBar: true,
      body: SafeArea(top: safeAreaTop, bottom: safeAreaBottom, child: body),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

/// Page container with consistent padding
class PageContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool useSafeArea;
  final Color? backgroundColor;

  const PageContainer({
    Key? key,
    required this.child,
    this.padding,
    this.useSafeArea = true,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding ?? EdgeInsets.all(AppSpacing.lg.w),
      color: backgroundColor,
      child: child,
    );

    if (useSafeArea) {
      return SafeArea(child: content);
    }
    return content;
  }
}

/// Scrollable page container with consistent padding
class ScrollablePageContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final ScrollController? controller;
  final bool shrinkWrap;

  const ScrollablePageContainer({
    Key? key,
    required this.child,
    this.padding,
    this.physics,
    this.controller,
    this.shrinkWrap = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: physics ?? const BouncingScrollPhysics(),
      controller: controller,
      padding: padding ?? EdgeInsets.all(AppSpacing.lg.w),
      child: child,
    );
  }
}
