import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../design_system.dart';

/// Template Card - Square card representing a note template type
class TemplateCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color backgroundColor;
  final VoidCallback onTap;

  const TemplateCard({
    Key? key,
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.backgroundColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon Container (Square)
            AnimatedScale(
              scale: 1.0,
              duration: const Duration(milliseconds: 100),
              child: Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
                  border: Border.all(
                    color: iconColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Icon(icon, size: 36.sp, color: iconColor),
              ),
            ),
            SizedBox(height: 8.h),

            // Label
            Text(
              label,
              style: AppTypography.caption(null, FontWeight.w500),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Template Picker - Horizontal scrolling row of template cards
/// Based on template: notes_list_and_templates_1
class TemplatePicker extends StatelessWidget {
  final List<NoteTemplate> templates;
  final Function(NoteTemplate) onTemplateSelected;
  final EdgeInsetsGeometry? padding;

  const TemplatePicker({
    Key? key,
    required this.templates,
    required this.onTemplateSelected,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Templates', padding: padding),
        SizedBox(height: 8.h),
        SizedBox(
          height: 150.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding:
                padding ??
                EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPaddingHorizontal,
                ),
            itemCount: templates.length,
            separatorBuilder: (context, index) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              final template = templates[index];
              return TemplateCard(
                icon: _getTemplateIcon(template.type),
                label: template.name,
                iconColor: _getTemplateColor(template.type),
                backgroundColor: _getTemplateColor(
                  template.type,
                ).withOpacity(0.1),
                onTap: () => onTemplateSelected(template),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _getTemplateIcon(String type) {
    switch (type.toLowerCase()) {
      case 'meeting':
        return Icons.groups;
      case 'shopping':
        return Icons.shopping_cart;
      case 'journal':
        return Icons.menu_book;
      case 'brainstorm':
        return Icons.lightbulb;
      case 'checklist':
        return Icons.checklist;
      case 'travel':
        return Icons.flight;
      default:
        return Icons.description;
    }
  }

  Color _getTemplateColor(String type) {
    switch (type.toLowerCase()) {
      case 'meeting':
        return AppColors.primary;
      case 'shopping':
        return AppColors.accentOrange;
      case 'journal':
        return AppColors.successGreen;
      case 'brainstorm':
        return AppColors.accentPurple;
      case 'checklist':
        return AppColors.primary;
      case 'travel':
        return AppColors.accentBlue;
      default:
        return AppColors.primary;
    }
  }
}

/// Note Template Entity (if not already defined)
class NoteTemplate {
  final String id;
  final String name;
  final String type;
  final String content;
  final List<String>? tags;

  const NoteTemplate({
    required this.id,
    required this.name,
    required this.type,
    required this.content,
    this.tags,
  });
}

/// Pre-defined templates
class NoteTemplates {
  static const List<NoteTemplate> defaultTemplates = [
    NoteTemplate(
      id: 'meeting',
      name: 'Meeting Notes',
      type: 'meeting',
      content:
          '**Date:** \n**Attendees:** \n**Topics:** \n\n**Action Items:**\n- ',
      tags: ['work', 'meeting'],
    ),
    NoteTemplate(
      id: 'shopping',
      name: 'Shopping List',
      type: 'shopping',
      content: '**Shopping List**\n\n- \n- \n- ',
      tags: ['personal', 'shopping'],
    ),
    NoteTemplate(
      id: 'journal',
      name: 'Daily Journal',
      type: 'journal',
      content:
          '**Date:** \n\n**Mood:** \n\n**What I\'m grateful for:**\n- \n\n**Today\'s highlights:**\n- ',
      tags: ['journal', 'reflection'],
    ),
    NoteTemplate(
      id: 'brainstorm',
      name: 'Brainstorm',
      type: 'brainstorm',
      content: '**Topic:** \n\n**Ideas:**\n- \n- \n- \n\n**Next Steps:**\n- ',
      tags: ['ideas', 'brainstorm'],
    ),
  ];
}
