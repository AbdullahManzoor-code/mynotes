import 'package:flutter/material.dart';

/// Design System Animations & Transitions extracted from HTML templates
/// Micro-animations for smooth, delightful user experience
class AppAnimations {
  AppAnimations._();

  // ==================== Duration Constants ====================

  /// Fast animation (150ms) - Quick feedback
  static const Duration fast = Duration(milliseconds: 150);

  /// Normal animation (200ms) - Default duration
  static const Duration normal = Duration(milliseconds: 200);

  /// Medium animation (300ms) - Most UI transitions
  static const Duration medium = Duration(milliseconds: 300);

  /// Slow animation (500ms) - Page transitions
  static const Duration slow = Duration(milliseconds: 500);

  /// Extra slow animation (800ms) - Complex animations
  static const Duration extraSlow = Duration(milliseconds: 800);

  // ==================== Curve Constants ====================

  /// Ease in out - Smooth start and end
  static const Curve easeInOut = Curves.easeInOut;

  /// Ease out - Quick start, slow end
  static const Curve easeOut = Curves.easeOut;

  /// Ease in - Slow start, quick end
  static const Curve easeIn = Curves.easeIn;

  /// Bounce - Bouncy effect
  static const Curve bounce = Curves.bounceOut;

  /// Elastic - Spring effect
  static const Curve elastic = Curves.elasticOut;

  /// Decelerate - Material standard
  static const Curve decelerate = Curves.decelerate;

  /// Fast out slow in - Material emphasis
  static const Curve fastOutSlowIn = Curves.fastOutSlowIn;

  // ==================== Scale Animations ====================

  /// Active scale (0.98) - Tap feedback
  static const double activeScale = 0.98;

  /// Pressed scale (0.95) - Button press
  static const double pressedScale = 0.95;

  /// Hover scale (1.02) - Hover effect
  static const double hoverScale = 1.02;

  /// Pop scale (1.05) - Pop-in effect
  static const double popScale = 1.05;

  // ==================== Opacity Values ====================

  /// Disabled opacity (0.5)
  static const double disabledOpacity = 0.5;

  /// Inactive opacity (0.6)
  static const double inactiveOpacity = 0.6;

  /// Hover opacity (0.8)
  static const double hoverOpacity = 0.8;

  /// Pressed opacity (0.7)
  static const double pressedOpacity = 0.7;

  // ==================== Blur Values ====================

  /// Small blur (4px) - Subtle blur
  static const double blurSmall = 4.0;

  /// Medium blur (12px) - Glass effect
  static const double blurMedium = 12.0;

  /// Large blur (40px) - iOS blur
  static const double blurLarge = 40.0;

  // ==================== Page Transitions ====================

  /// Slide from right (Material standard)
  static PageRouteBuilder<T> slideFromRight<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: medium,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        final tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  /// Slide from bottom (Modal style)
  static PageRouteBuilder<T> slideFromBottom<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: medium,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeOut;

        final tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  /// Fade transition
  static PageRouteBuilder<T> fade<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: fast,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  /// Scale transition (zoom in)
  static PageRouteBuilder<T> scale<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: medium,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.8;
        const end = 1.0;
        const curve = Curves.easeOut;

        final tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return ScaleTransition(
          scale: animation.drive(tween),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }

  // ==================== Modal Bottom Sheet Transitions ====================

  /// Show bottom sheet with slide animation
  static Future<T?> showAppBottomSheet<T>({
    required BuildContext context,
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? backgroundColor,
    double? elevation,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: backgroundColor ?? Colors.transparent,
      elevation: elevation ?? 0,
      isScrollControlled: true,
      transitionAnimationController: AnimationController(
        vsync: Navigator.of(context),
        duration: medium,
      ),
      builder: (context) => child,
    );
  }

  // ==================== List Item Animations ====================

  /// Staggered list animation delay calculator
  static Duration staggerDelay(int index, {int delayMs = 50}) {
    return Duration(milliseconds: index * delayMs);
  }

  /// Create staggered animation for list item
  static Widget staggeredListItem({
    required int index,
    required Widget child,
    Duration? delay,
    Curve curve = Curves.easeOut,
  }) {
    final itemDelay = delay ?? staggerDelay(index);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: medium,
      curve: curve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  // ==================== Loading Animations ====================

  /// Shimmer animation duration
  static const Duration shimmerDuration = Duration(milliseconds: 1500);

  /// Pulse animation duration
  static const Duration pulseDuration = Duration(milliseconds: 1000);

  /// Create shimmer gradient
  static LinearGradient shimmerGradient({
    required Color baseColor,
    required Color highlightColor,
  }) {
    return LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [baseColor, highlightColor, baseColor],
      stops: const [0.0, 0.5, 1.0],
    );
  }

  // ==================== Micro-Interaction Animations ====================

  /// Tap scale animation
  static Widget tapScale({
    required Widget child,
    VoidCallback? onTap,
    double scale = 0.98,
    Duration duration = const Duration(milliseconds: 100),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 1.0),
      duration: duration,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: GestureDetector(
        onTapDown: (_) {
          // Trigger scale animation
        },
        onTapUp: (_) {
          // Reset scale
          if (onTap != null) onTap();
        },
        onTapCancel: () {
          // Reset scale
        },
        child: child,
      ),
    );
  }

  /// Ripple effect duration
  static const Duration rippleDuration = Duration(milliseconds: 300);

  /// Splash color opacity
  static const double splashOpacity = 0.1;

  // ==================== Icon Animations ====================

  /// Icon fill animation (Material Symbols)
  /// Animates from outline to filled
  static Widget animatedIcon({
    required IconData icon,
    required bool isFilled,
    Color? color,
    double? size,
    Duration duration = const Duration(milliseconds: 200),
  }) {
    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: (child, animation) {
        return ScaleTransition(scale: animation, child: child);
      },
      child: Icon(
        icon,
        key: ValueKey(isFilled),
        color: color,
        size: size,
        // Note: Material Symbols use font-variation-settings
        // This would need custom implementation
      ),
    );
  }

  // ==================== Text Animations ====================

  /// Animated text fade
  static Widget animatedText({
    required String text,
    required TextStyle style,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: Text(text, key: ValueKey(text), style: style),
    );
  }

  // ==================== Container Animations ====================

  /// Animated container with default duration
  static AnimatedContainer animatedBox({
    Key? key,
    AlignmentGeometry? alignment,
    EdgeInsetsGeometry? padding,
    Color? color,
    Decoration? decoration,
    Decoration? foregroundDecoration,
    double? width,
    double? height,
    BoxConstraints? constraints,
    EdgeInsetsGeometry? margin,
    Matrix4? transform,
    AlignmentGeometry? transformAlignment,
    Widget? child,
    Clip clipBehavior = Clip.none,
    Duration duration = const Duration(milliseconds: 200),
    Curve curve = Curves.easeInOut,
  }) {
    return AnimatedContainer(
      key: key,
      alignment: alignment,
      padding: padding,
      color: color,
      decoration: decoration,
      foregroundDecoration: foregroundDecoration,
      width: width,
      height: height,
      constraints: constraints,
      margin: margin,
      transform: transform,
      transformAlignment: transformAlignment,
      clipBehavior: clipBehavior,
      duration: duration,
      curve: curve,
      child: child,
    );
  }

  // ==================== Card Animations ====================

  /// Card hover animation
  static MouseRegion cardHover({
    required Widget child,
    VoidCallback? onEnter,
    VoidCallback? onExit,
  }) {
    return MouseRegion(
      onEnter: (_) => onEnter?.call(),
      onExit: (_) => onExit?.call(),
      child: child,
    );
  }

  // ==================== Hero Animations ====================

  /// Create hero widget
  static Hero hero({
    required Object tag,
    required Widget child,
    CreateRectTween? createRectTween,
    HeroFlightShuttleBuilder? flightShuttleBuilder,
    HeroPlaceholderBuilder? placeholderBuilder,
    bool transitionOnUserGestures = false,
  }) {
    return Hero(
      tag: tag,
      child: child,
      createRectTween: createRectTween,
      flightShuttleBuilder: flightShuttleBuilder,
      placeholderBuilder: placeholderBuilder,
      transitionOnUserGestures: transitionOnUserGestures,
    );
  }

  // ==================== Utility Functions ====================

  /// Delay execution
  static Future<void> delay({
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return Future.delayed(duration);
  }

  /// Create animation controller
  static AnimationController createController({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 300),
    double? value,
    Duration? reverseDuration,
    AnimationBehavior animationBehavior = AnimationBehavior.normal,
  }) {
    return AnimationController(
      vsync: vsync,
      duration: duration,
      value: value,
      reverseDuration: reverseDuration,
      animationBehavior: animationBehavior,
    );
  }

  /// Create tween animation
  static Animation<T> createTween<T>({
    required AnimationController controller,
    required T begin,
    required T end,
    Curve curve = Curves.easeInOut,
  }) {
    return Tween<T>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(parent: controller, curve: curve));
  }
}

/// Extension on Widget for easy animation wrapping
extension AppAnimationExtensions on Widget {
  /// Wrap with tap scale animation
  Widget withTapScale({VoidCallback? onTap, double scale = 0.98}) {
    return AppAnimations.tapScale(child: this, onTap: onTap, scale: scale);
  }

  /// Wrap with hero animation
  Widget withHero(Object tag) {
    return Hero(tag: tag, child: this);
  }

  /// Wrap with staggered animation
  Widget withStagger(int index) {
    return AppAnimations.staggeredListItem(index: index, child: this);
  }

  /// Wrap with animated switcher
  Widget withAnimatedSwitcher({
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return AnimatedSwitcher(duration: duration, child: this);
  }
}

