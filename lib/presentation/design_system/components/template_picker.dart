import 'package:flutter/material.dart';
import '../../../domain/entities/note_template.dart';
import '../design_system.dart';

/// Template Card - Square card representing a note template type
class TemplateCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color backgroundColor;
  final VoidCallback onTap;

  const TemplateCard({
    super.key,
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
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
              style: AppTypography.caption(null, null, FontWeight.w500),
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
    super.key,
    required this.templates,
    required this.onTemplateSelected,
    this.padding,
  });

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

  IconData _getTemplateIcon(NoteTemplateType type) {
    switch (type) {
      case NoteTemplateType.meeting:
        return Icons.groups;
      case NoteTemplateType.todoList:
        return Icons.checklist;
      case NoteTemplateType.journal:
        return Icons.menu_book;
      case NoteTemplateType.ideaBrainstorm:
        return Icons.lightbulb;
      case NoteTemplateType.travelPlan:
        return Icons.flight;
      case NoteTemplateType.recipe:
        return Icons.restaurant_menu;
      case NoteTemplateType.project:
        return Icons.folder_special;
      case NoteTemplateType.studyNotes:
        return Icons.school;
      case NoteTemplateType.bookSummary:
        return Icons.menu_book;
      default:
        return Icons.description;
    }
  }

  Color _getTemplateColor(NoteTemplateType type) {
    switch (type) {
      case NoteTemplateType.meeting:
        return AppColors.primary;
      case NoteTemplateType.journal:
        return AppColors.successGreen;
      case NoteTemplateType.ideaBrainstorm:
        return AppColors.accentPurple;
      case NoteTemplateType.travelPlan:
        return AppColors.accentBlue;
      case NoteTemplateType.recipe:
        return AppColors.accentOrange;
      case NoteTemplateType.todoList:
        return AppColors.primary;
      case NoteTemplateType.project:
        return AppColors.accentPurple;
      case NoteTemplateType.studyNotes:
        return AppColors.accentBlue;
      case NoteTemplateType.bookSummary:
        return AppColors.successGreen;
      default:
        return AppColors.primary;
    }
  }
}
