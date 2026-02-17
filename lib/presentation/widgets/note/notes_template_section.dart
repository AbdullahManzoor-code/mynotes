import 'package:flutter/material.dart';
import 'package:mynotes/core/extensions/context_extensions.dart';
import 'package:mynotes/presentation/design_system/design_system.dart';

/// Note template data class
class NoteTemplate {
  final String title;
  final IconData icon;
  final Color color;
  final String description;
  final String Function() contentGenerator;

  const NoteTemplate({
    required this.title,
    required this.icon,
    required this.color,
    required this.description,
    required this.contentGenerator,
  });
}

/// Notes template section widget
/// Displays quick template picker for creating new notes from templates
class NotesTemplateSection extends StatelessWidget {
  final List<NoteTemplate> templates;
  final ValueChanged<NoteTemplate> onTemplateSelected;
  final bool isExpanded;
  final VoidCallback? onToggle;

  const NotesTemplateSection({
    super.key,
    required this.templates,
    required this.onTemplateSelected,
    this.isExpanded = true,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (!isExpanded) {
      return Padding(
        padding: EdgeInsets.all(16.w),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(12.r),
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Row(
                children: [
                  Icon(Icons.note_add, size: 20.r, color: context.primaryColor),
                  SizedBox(width: 8.w),
                  Text(
                    'Show Templates',
                    style: AppTypography.body1(
                      context,
                    ).copyWith(fontSize: 14.sp, color: context.primaryColor),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: templates.map((template) {
          return Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: _TemplateCard(
              template: template,
              onTap: () => onTemplateSelected(template),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final NoteTemplate template;
  final VoidCallback onTap;

  const _TemplateCard({required this.template, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: 140.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: context.theme.dividerColor, width: 1),
            color: template.color.withOpacity(0.08),
          ),
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: template.color,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(template.icon, color: Colors.white, size: 20.r),
              ),
              SizedBox(height: 8.h),
              Text(
                template.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.body1(
                  context,
                ).copyWith(fontSize: 12.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 4.h),
              Text(
                template.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption(
                  context,
                ).copyWith(fontSize: 10.sp, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
