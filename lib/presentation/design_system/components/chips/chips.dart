import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../app_colors.dart';
import '../../app_spacing.dart';
import '../../app_typography.dart';

/// Category chip (filter chip)
class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback? onTap;
  final IconData? icon;

  const CategoryChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.color,
    this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md.w,
          vertical: AppSpacing.sm.h,
        ),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : chipColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: isSelected ? chipColor : chipColor.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16.sp,
                color: isSelected ? Colors.white : chipColor,
              ),
              SizedBox(width: AppSpacing.xs.w),
            ],
            Text(
              label,
              style: AppTypography.label().copyWith(
                color: isSelected ? Colors.white : chipColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Priority tag
class PriorityTag extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const PriorityTag({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm.w,
        vertical: AppSpacing.xxs.h,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12.sp, color: color),
            SizedBox(width: AppSpacing.xxs.w),
          ],
          Text(
            label,
            style: AppTypography.caption().copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Mood chip for reflection
class MoodChip extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const MoodChip({
    super.key,
    required this.emoji,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md.w,
          vertical: AppSpacing.sm.h,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.surface(context),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border(context),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: TextStyle(fontSize: 24.sp)),
            SizedBox(height: AppSpacing.xxs.h),
            Text(
              label,
              style: AppTypography.caption().copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Removable tag chip
class RemovableChip extends StatelessWidget {
  final String label;
  final Color? color;
  final VoidCallback? onRemove;

  const RemovableChip({
    super.key,
    required this.label,
    this.color,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primary;

    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.sm.w,
        right: AppSpacing.xxs.w,
        top: AppSpacing.xxs.h,
        bottom: AppSpacing.xxs.h,
      ),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: chipColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypography.caption().copyWith(
              color: chipColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (onRemove != null) ...[
            SizedBox(width: AppSpacing.xxs.w),
            GestureDetector(
              onTap: onRemove,
              child: Icon(Icons.close, size: 14.sp, color: chipColor),
            ),
          ],
        ],
      ),
    );
  }
}
