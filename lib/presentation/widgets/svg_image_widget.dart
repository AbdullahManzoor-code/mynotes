import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Centralized SVG image widget with built-in error handling and theming
class SvgImageWidget extends StatelessWidget {
  final String name; // filename without extension
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? color; // For single-color SVGs
  final bool useColorFilter;
  final String assetType; // 'icons', 'illustrations', 'animations'

  const SvgImageWidget(
    this.name, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.color,
    this.useColorFilter = false,
    this.assetType = 'icons',
  });

  @override
  Widget build(BuildContext context) {
    final path = 'assets/svg/$assetType/$name.svg';

    return SvgPicture.asset(
      path,
      width: width,
      height: height,
      fit: fit,
      colorFilter: useColorFilter && color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
      placeholderBuilder: (context) => Container(
        width: width,
        height: height,
        color: Colors.grey.shade300,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
    );
  }
}

/// Convenience extension for easy SVG access
extension SvgAssets on BuildContext {
  /// Quick access to icon SVGs
  /// Usage: context.icon('home_icon', size: 32)
  SvgImageWidget icon(
    String name, {
    double size = 24,
    Color? color,
    bool useColorFilter = false,
  }) => SvgImageWidget(
    name,
    width: size,
    height: size,
    assetType: 'icons',
    color: color,
    useColorFilter: useColorFilter,
  );

  /// Quick access to illustration SVGs
  /// Usage: context.illustration('empty_notes', width: 200)
  SvgImageWidget illustration(
    String name, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
  }) => SvgImageWidget(
    name,
    width: width,
    height: height,
    fit: fit,
    assetType: 'illustrations',
  );

  /// Quick access to animation SVGs
  /// Usage: context.animation('loading', width: 80)
  SvgImageWidget animation(String name, {double? width, double? height}) =>
      SvgImageWidget(
        name,
        width: width,
        height: height,
        assetType: 'animations',
      );
}
