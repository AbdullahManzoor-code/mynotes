import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/utils/context_scanner.dart';
import '../design_system/design_system.dart';

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

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.9),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SMART SUGGESTIONS',
                  style: TextStyle(
                    color: const Color(0xFF64748B),
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 14.sp,
                    color: const Color(0xFF64748B),
                  ),
                  onPressed: onDismiss,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            height: 44.h,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              scrollDirection: Axis.horizontal,
              itemCount: suggestions.length,
              separatorBuilder: (context, index) => SizedBox(width: 8.w),
              itemBuilder: (context, index) {
                final suggestion = suggestions[index];
                return _buildSuggestionChip(context, suggestion);
              },
            ),
          ),
        ],
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
        color = const Color(0xFF10B981); // Emerald
        label = 'Create Todo';
        break;
      case SuggestionType.reminder:
        icon = Icons.notifications_none;
        color = const Color(0xFFF59E0B); // Amber
        label = 'Add Reminder';
        break;
      case SuggestionType.linkedNote:
        icon = Icons.link;
        color = const Color(0xFF3B82F6); // Blue
        label = 'Link Note';
        break;
      case SuggestionType.template:
        icon = Icons.auto_awesome;
        color = const Color(0xFF8B5CF6); // Violet
        label = 'Use Template';
        break;
    }

    return ActionChip(
      onPressed: () => onAccept(suggestion),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
      avatar: Icon(icon, color: color, size: 16.sp),
      label: Text(
        '$label: ${suggestion.title}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
