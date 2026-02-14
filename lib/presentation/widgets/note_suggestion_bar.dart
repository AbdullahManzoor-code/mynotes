import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import '../../core/utils/context_scanner.dart';
import '../design_system/design_system.dart';
import '../design_system/components/layouts/glass_container.dart';

class NoteSuggestionBar extends StatelessWidget {
  final List<ContextSuggestion> suggestions;
  final Function(ContextSuggestion) onAccept;
  final VoidCallback onDismiss;

  const NoteSuggestionBar({
    super.key,
    required this.suggestions,
    required this.onAccept,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return AppAnimations.tapScale(
      child: GlassContainer(
        borderRadius: 0,
        blur: 15,
        color: AppColors.surface(context).withOpacity(0.8),
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 14.sp,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'SMART SUGGESTIONS',
                        style: AppTypography.caption(context).copyWith(
                          color: AppColors.textSecondary(context),
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      onDismiss();
                    },
                    child: Padding(
                      padding: EdgeInsets.all(4.w),
                      child: Icon(
                        Icons.close,
                        size: 16.sp,
                        color: AppColors.textSecondary(
                          context,
                        ).withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            SizedBox(
              height: 48.h,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                scrollDirection: Axis.horizontal,
                itemCount: suggestions.length,
                separatorBuilder: (context, index) => SizedBox(width: 10.w),
                itemBuilder: (context, index) {
                  final suggestion = suggestions[index];
                  return AppAnimations.tapScale(
                    // delayIndex: index,
                    // direction: Axis.horizontal,
                    child: _buildSuggestionChip(context, suggestion),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(
    BuildContext context,
    ContextSuggestion suggestion,
  ) {
    IconData icon;
    Color color;
    String label;

    switch (suggestion.type) {
      case SuggestionType.todo:
        icon = Icons.check_circle_outline;
        color = const Color(0xFF10B981);
        label = 'Create Todo';
        break;
      case SuggestionType.reminder:
        icon = Icons.notifications_none;
        color = const Color(0xFFF59E0B);
        label = 'Add Reminder';
        break;
      case SuggestionType.linkedNote:
        icon = Icons.link;
        color = const Color(0xFF3B82F6);
        label = 'Link Note';
        break;
      case SuggestionType.template:
        icon = Icons.auto_stories_outlined;
        color = const Color(0xFF8B5CF6);
        label = 'Apply Template';
        break;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onAccept(suggestion);
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18.sp, color: color),
              SizedBox(width: 8.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (suggestion.title.isNotEmpty)
                    Text(
                      suggestion.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textSecondary(context),
                        fontSize: 10.sp,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
