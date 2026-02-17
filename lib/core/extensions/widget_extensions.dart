import 'package:flutter/material.dart';

/// Extension methods on Widget for convenient padding, margin, and styling
extension WidgetExtensions on Widget {
  /// Add symmetric padding (horizontal and vertical)
  Widget padSymmetric({double horizontal = 0, double vertical = 0}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      child: this,
    );
  }

  /// Add padding on all sides
  Widget padAll(double value) {
    return Padding(padding: EdgeInsets.all(value), child: this);
  }

  /// Add horizontal padding only
  Widget padH(double value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: value),
      child: this,
    );
  }

  /// Add vertical padding only
  Widget padV(double value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: value),
      child: this,
    );
  }

  /// Add custom padding
  Widget padOnly({
    double top = 0,
    double bottom = 0,
    double left = 0,
    double right = 0,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        top: top,
        bottom: bottom,
        left: left,
        right: right,
      ),
      child: this,
    );
  }

  /// Center the widget
  Widget centered() {
    return Center(child: this);
  }

  /// Expand the widget to fill parent
  Widget expanded({int flex = 1}) {
    return Expanded(flex: flex, child: this);
  }

  /// Add opacity to the widget
  Widget withOpacity(double opacity) {
    return Opacity(opacity: opacity, child: this);
  }

  /// Add gestureDetector with onTap
  Widget onTap(VoidCallback onTap) {
    return GestureDetector(onTap: onTap, child: this);
  }

  /// Add gestureDetector with various callbacks
  Widget withGestureDetector({
    VoidCallback? onTap,
    VoidCallback? onDoubleTap,
    VoidCallback? onLongPress,
    GestureDragStartCallback? onPanStart,
    GestureDragUpdateCallback? onPanUpdate,
    GestureDragEndCallback? onPanEnd,
    HitTestBehavior? behavior,
  }) {
    return GestureDetector(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      onPanStart: onPanStart,
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanEnd,
      behavior: behavior,
      child: this,
    );
  }

  /// Add material ink response for tap feedback
  Widget withInkWell({
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    double? radius,
    Color? splashColor,
    Color? highlightColor,
    Color? hoverColor,
  }) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(radius ?? 0),
      splashColor: splashColor,
      highlightColor: highlightColor,
      hoverColor: hoverColor,
      child: this,
    );
  }

  /// Add decoration box
  Widget withDecoration({
    Color? color,
    List<BoxShadow>? shadows,
    BorderRadius? borderRadius,
    Border? border,
    Gradient? gradient,
    BoxShape shape = BoxShape.rectangle,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        boxShadow: shadows,
        borderRadius: borderRadius,
        border: border,
        gradient: gradient,
        shape: shape,
      ),
      child: this,
    );
  }

  /// Add rounded corners
  Widget withBorderRadius(double radius) {
    return ClipRRect(borderRadius: BorderRadius.circular(radius), child: this);
  }

  /// Add circular clip
  Widget withCircleClip() {
    return ClipOval(child: this);
  }

  /// Add sized box with specific width and height
  Widget withSize({required double width, required double height}) {
    return SizedBox(width: width, height: height, child: this);
  }

  /// Add sized box with specific width
  Widget withWidth(double width) {
    return SizedBox(width: width, child: this);
  }

  /// Add sized box with specific height
  Widget withHeight(double height) {
    return SizedBox(height: height, child: this);
  }

  /// Add positioned widget (for Stack)
  Widget positioned({
    double? top,
    double? bottom,
    double? left,
    double? right,
    double? width,
    double? height,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      width: width,
      height: height,
      child: this,
    );
  }

  /// Wrap in SingleChildScrollView
  Widget scrollable({
    Axis scrollDirection = Axis.vertical,
    bool reverse = false,
    ScrollPhysics? physics,
  }) {
    return SingleChildScrollView(
      scrollDirection: scrollDirection,
      reverse: reverse,
      physics: physics,
      child: this,
    );
  }

  /// Wrap in Flexible
  Widget flexible({int flex = 1, FlexFit fit = FlexFit.loose}) {
    return Flexible(flex: flex, fit: fit, child: this);
  }

  /// Add semitransparent overlay
  Widget withOverlay({required Color color, required double opacity}) {
    return Stack(
      children: [
        this,
        Positioned.fill(child: Container(color: color.withOpacity(opacity))),
      ],
    );
  }

  /// Wrap in AspectRatio
  Widget withAspectRatio(double aspectRatio) {
    return AspectRatio(aspectRatio: aspectRatio, child: this);
  }

  /// Align to specific alignment
  Widget align(AlignmentGeometry alignment) {
    return Align(alignment: alignment, child: this);
  }
}
