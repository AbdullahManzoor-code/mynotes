// lib/presentation/widgets/animated_list_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

/// Slide direction for animated items
enum SlideDirection { left, right, up, down }

/// Animated list view with staggered entry animations
class AnimatedListView extends StatelessWidget {
  final List<dynamic> items;
  final IndexedWidgetBuilder itemBuilder;
  final ScrollPhysics physics;
  final bool addSemanticIndexes;
  final Duration staggerDuration;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollController? controller;

  const AnimatedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.physics = const AlwaysScrollableScrollPhysics(),
    this.addSemanticIndexes = true,
    this.staggerDuration = const Duration(milliseconds: 375),
    this.padding,
    this.shrinkWrap = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimationLimiter(
      child: ListView.builder(
        controller: controller,
        physics: physics,
        padding: padding,
        shrinkWrap: shrinkWrap,
        itemCount: items.length,
        addSemanticIndexes: addSemanticIndexes,
        itemBuilder: (BuildContext context, int index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: staggerDuration,
            child: SlideAnimation(
              horizontalOffset: 50.0,
              child: FadeInAnimation(
                child: itemBuilder(context, index),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Animated grid view with staggered entry animations
class AnimatedGridView extends StatelessWidget {
  final List<dynamic> items;
  final IndexedWidgetBuilder itemBuilder;
  final int columnCount;
  final ScrollPhysics physics;
  final Duration staggerDuration;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollController? controller;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;

  const AnimatedGridView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.columnCount = 2,
    this.physics = const AlwaysScrollableScrollPhysics(),
    this.staggerDuration = const Duration(milliseconds: 375),
    this.padding,
    this.shrinkWrap = false,
    this.controller,
    this.crossAxisSpacing = 10,
    this.mainAxisSpacing = 10,
    this.childAspectRatio = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimationLimiter(
      child: GridView.builder(
        controller: controller,
        physics: physics,
        padding: padding,
        shrinkWrap: shrinkWrap,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columnCount,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
          childAspectRatio: childAspectRatio,
        ),
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: staggerDuration,
            columnCount: columnCount,
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: itemBuilder(context, index),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Single item animation wrapper for flexibility
class AnimatedItem extends StatelessWidget {
  final int index;
  final Widget child;
  final Duration duration;
  final SlideDirection slideDirection;
  final double offset;

  const AnimatedItem({
    super.key,
    required this.index,
    required this.child,
    this.duration = const Duration(milliseconds: 375),
    this.slideDirection = SlideDirection.left,
    this.offset = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    double horizontalOffset = 0.0;
    double verticalOffset = 0.0;

    switch (slideDirection) {
      case SlideDirection.left:
        horizontalOffset = offset;
        break;
      case SlideDirection.right:
        horizontalOffset = -offset;
        break;
      case SlideDirection.up:
        verticalOffset = offset;
        break;
      case SlideDirection.down:
        verticalOffset = -offset;
        break;
    }

    return AnimationConfiguration.staggeredList(
      position: index,
      duration: duration,
      child: SlideAnimation(
        horizontalOffset: horizontalOffset,
        verticalOffset: verticalOffset,
        child: FadeInAnimation(
          child: child,
        ),
      ),
    );
  }
}