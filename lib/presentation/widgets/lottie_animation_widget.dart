import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Centralized Lottie animation widget with built-in error handling
class LottieAnimationWidget extends StatelessWidget {
  final String animationName; // filename without extension
  final double? width;
  final double? height;
  final bool repeat;
  final bool reverse;
  final Duration? duration;
  final VoidCallback? onLoaded;
  final Duration animationDuration;

  const LottieAnimationWidget(
    this.animationName, {
    Key? key,
    this.width,
    this.height,
    this.repeat = true,
    this.reverse = false,
    this.duration,
    this.onLoaded,
    this.animationDuration = const Duration(milliseconds: 2000),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/animations/$animationName.json',
      width: width,
      height: height,
      fit: BoxFit.contain,
      repeat: repeat,
      reverse: reverse,
      animate: true,
      onLoaded: (_) => onLoaded?.call(),
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Lottie Loading Error: $error');
        return Container(
          width: width,
          height: height,
          color: Colors.grey.shade300,
          child: const Center(child: Icon(Icons.animation, size: 32)),
        );
      },
    );
  }
}

/// Preset animations for common use cases
class LottiePresets {
  static const String loading = 'loading';
  static const String success = 'success_checkmark';
  static const String error = 'error';
  static const String empty = 'empty_state';
  static const String celebration = 'celebration';
}

/// Convenience extension for easy Lottie access
extension LottieAssets on BuildContext {
  /// Show loading animation
  /// Usage: context.lottieLoading(width: 100)
  LottieAnimationWidget lottieLoading({double? width, double? height}) =>
      LottieAnimationWidget(
        LottiePresets.loading,
        width: width ?? 100,
        height: height ?? 100,
        repeat: true,
      );

  /// Show success animation (plays once)
  /// Usage: context.lottieSuccess(width: 80)
  LottieAnimationWidget lottieSuccess({double? width, double? height}) =>
      LottieAnimationWidget(
        LottiePresets.success,
        width: width ?? 80,
        height: height ?? 80,
        repeat: false,
      );

  /// Show empty state animation
  /// Usage: context.lottieEmpty(width: 200)
  LottieAnimationWidget lottieEmpty({double? width, double? height}) =>
      LottieAnimationWidget(
        LottiePresets.empty,
        width: width ?? 200,
        height: height ?? 200,
        repeat: true,
      );

  /// Show celebration animation
  /// Usage: context.lottieCelebration(width: 150)
  LottieAnimationWidget lottieCelebration({double? width, double? height}) =>
      LottieAnimationWidget(
        LottiePresets.celebration,
        width: width ?? 150,
        height: height ?? 150,
        repeat: false,
      );
}
