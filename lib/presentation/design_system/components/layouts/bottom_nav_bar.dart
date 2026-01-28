import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../app_colors.dart';
import '../../app_spacing.dart';
import '../../app_typography.dart';
import '../../app_animations.dart';

/// Bottom navigation item data
class BottomNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final VoidCallback? onTap;

  const BottomNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.onTap,
  });
}

/// Glass bottom navigation bar with blur effect
/// Matches the design system's frosted glass style
class GlassBottomNavBar extends StatelessWidget {
  final List<BottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final bool showLabels;

  const GlassBottomNavBar({
    Key? key,
    required this.items,
    required this.currentIndex,
    this.onTap,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.showLabels = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 70.h,
          decoration: BoxDecoration(
            color:
                backgroundColor ?? AppColors.surface(context).withOpacity(0.8),
            border: Border(
              top: BorderSide(color: AppColors.border(context), width: 1),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(items.length, (index) {
                final item = items[index];
                final isSelected = index == currentIndex;

                return _BottomNavBarItem(
                  icon: item.icon,
                  activeIcon: item.activeIcon,
                  label: item.label,
                  isSelected: isSelected,
                  onTap: () {
                    onTap?.call(index);
                    item.onTap?.call();
                  },
                  selectedColor: selectedItemColor ?? AppColors.primary,
                  unselectedColor:
                      unselectedItemColor ?? AppColors.textSecondary(context),
                  showLabel: showLabels,
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavBarItem extends StatefulWidget {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color selectedColor;
  final Color unselectedColor;
  final bool showLabel;

  const _BottomNavBarItem({
    Key? key,
    required this.icon,
    this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.selectedColor,
    required this.unselectedColor,
    required this.showLabel,
  }) : super(key: key);

  @override
  State<_BottomNavBarItem> createState() => _BottomNavBarItemState();
}

class _BottomNavBarItemState extends State<_BottomNavBarItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.fast,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isSelected
        ? widget.selectedColor
        : widget.unselectedColor;
    final displayIcon = widget.isSelected && widget.activeIcon != null
        ? widget.activeIcon!
        : widget.icon;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md.w,
            vertical: AppSpacing.xs.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: AppAnimations.fast,
                padding: EdgeInsets.all(AppSpacing.xs.w),
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? widget.selectedColor.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(displayIcon, color: color, size: 24.sp),
              ),
              if (widget.showLabel) ...[
                SizedBox(height: AppSpacing.xxs.h),
                AnimatedDefaultTextStyle(
                  duration: AppAnimations.fast,
                  style: AppTypography.caption().copyWith(
                    color: color,
                    fontWeight: widget.isSelected
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                  child: Text(
                    widget.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Simple bottom navigation bar without blur
class SimpleBottomNavBar extends StatelessWidget {
  final List<BottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;

  const SimpleBottomNavBar({
    Key? key,
    required this.items,
    required this.currentIndex,
    this.onTap,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: backgroundColor ?? AppColors.surface(context),
      selectedItemColor: selectedItemColor ?? AppColors.primary,
      unselectedItemColor:
          unselectedItemColor ?? AppColors.textSecondary(context),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      items: items
          .map(
            (item) => BottomNavigationBarItem(
              icon: Icon(item.icon),
              activeIcon: Icon(item.activeIcon ?? item.icon),
              label: item.label,
            ),
          )
          .toList(),
    );
  }
}

/// Floating bottom navigation bar (card style)
class FloatingBottomNavBar extends StatelessWidget {
  final List<BottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final EdgeInsetsGeometry? margin;

  const FloatingBottomNavBar({
    Key? key,
    required this.items,
    required this.currentIndex,
    this.onTap,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          margin ??
          EdgeInsets.only(
            left: AppSpacing.lg.w,
            right: AppSpacing.lg.w,
            bottom: AppSpacing.lg.h,
          ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            height: 60.h,
            decoration: BoxDecoration(
              color:
                  backgroundColor ??
                  AppColors.surface(context).withOpacity(0.9),
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              border: Border.all(color: AppColors.border(context), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(items.length, (index) {
                final item = items[index];
                final isSelected = index == currentIndex;

                return _BottomNavBarItem(
                  icon: item.icon,
                  activeIcon: item.activeIcon,
                  label: item.label,
                  isSelected: isSelected,
                  onTap: () {
                    onTap?.call(index);
                    item.onTap?.call();
                  },
                  selectedColor: selectedItemColor ?? AppColors.primary,
                  unselectedColor:
                      unselectedItemColor ?? AppColors.textSecondary(context),
                  showLabel: false,
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
