import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../app_colors.dart';
import '../../app_spacing.dart';
import '../../app_typography.dart';

/// Bottom sheet container with glass effect
/// Used for modals, action sheets, and overlays
class BottomSheetContainer extends StatelessWidget {
  final Widget child;
  final String? title;
  final bool showDragHandle;
  final bool showCloseButton;
  final VoidCallback? onClose;
  final EdgeInsetsGeometry? padding;
  final double? maxHeight;
  final Color? backgroundColor;

  const BottomSheetContainer({
    super.key,
    required this.child,
    this.title,
    this.showDragHandle = true,
    this.showCloseButton = false,
    this.onClose,
    this.padding,
    this.maxHeight,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final defaultMaxHeight = screenHeight * 0.9;

    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSpacing.radiusXl),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          constraints: BoxConstraints(maxHeight: maxHeight ?? defaultMaxHeight),
          decoration: BoxDecoration(
            color:
                backgroundColor ?? AppColors.surface(context).withOpacity(0.95),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusXl),
            ),
            border: Border.all(color: AppColors.border(context), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              if (showDragHandle)
                Container(
                  margin: EdgeInsets.only(top: AppSpacing.sm.h),
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary(context).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                ),

              // Header
              if (title != null || showCloseButton)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg.w,
                    vertical: AppSpacing.md.h,
                  ),
                  child: Row(
                    children: [
                      if (title != null)
                        Expanded(
                          child: Text(title!, style: AppTypography.heading3()),
                        ),
                      if (showCloseButton)
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: AppColors.textSecondary(context),
                          ),
                          onPressed: onClose ?? () => Navigator.pop(context),
                        ),
                    ],
                  ),
                ),

              // Divider
              if (title != null || showCloseButton)
                Divider(height: 1, color: AppColors.border(context)),

              // Content
              Flexible(
                child: Padding(
                  padding: padding ?? EdgeInsets.all(AppSpacing.lg.w),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Show bottom sheet helper
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  String? title,
  bool showDragHandle = true,
  bool showCloseButton = false,
  bool isDismissible = true,
  bool enableDrag = true,
  EdgeInsetsGeometry? padding,
  double? maxHeight,
  Color? backgroundColor,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    builder: (context) => BottomSheetContainer(
      title: title,
      showDragHandle: showDragHandle,
      showCloseButton: showCloseButton,
      padding: padding,
      maxHeight: maxHeight,
      backgroundColor: backgroundColor,
      child: child,
    ),
  );
}

/// Action bottom sheet (list of actions)
class ActionBottomSheet extends StatelessWidget {
  final String? title;
  final List<ActionSheetItem> actions;
  final VoidCallback? onCancel;

  const ActionBottomSheet({
    super.key,
    this.title,
    required this.actions,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return BottomSheetContainer(
      title: title,
      showDragHandle: true,
      padding: EdgeInsets.zero,
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: actions.length + (onCancel != null ? 1 : 0),
        separatorBuilder: (context, index) =>
            Divider(height: 1, color: AppColors.border(context)),
        itemBuilder: (context, index) {
          if (index == actions.length) {
            // Cancel button
            return _ActionSheetTile(
              icon: Icons.close,
              label: 'Cancel',
              onTap: () {
                Navigator.pop(context);
                onCancel?.call();
              },
              isDestructive: false,
            );
          }

          final action = actions[index];
          return _ActionSheetTile(
            icon: action.icon,
            label: action.label,
            onTap: () {
              Navigator.pop(context);
              action.onTap();
            },
            isDestructive: action.isDestructive,
          );
        },
      ),
    );
  }
}

class ActionSheetItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const ActionSheetItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });
}

class _ActionSheetTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ActionSheetTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDestructive,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? AppColors.error
        : AppColors.textPrimary(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg.w,
          vertical: AppSpacing.md.h,
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24.sp),
            SizedBox(width: AppSpacing.md.w),
            Expanded(
              child: Text(
                label,
                style: AppTypography.body1().copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Show action bottom sheet helper
Future<T?> showActionSheet<T>({
  required BuildContext context,
  String? title,
  required List<ActionSheetItem> actions,
  VoidCallback? onCancel,
}) {
  return showAppBottomSheet<T>(
    context: context,
    title: title,
    showDragHandle: true,
    padding: EdgeInsets.zero,
    child: ActionBottomSheet(
      title: title,
      actions: actions,
      onCancel: onCancel,
    ),
  );
}
