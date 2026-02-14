import 'package:flutter/material.dart';
import '../design_system/design_system.dart';
import '../../domain/entities/note_template.dart';

/// Template Selector Bottom Sheet
/// Allows users to select from predefined note templates
class TemplateSelectorSheet extends StatelessWidget {
  const TemplateSelectorSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomSheetContainer(
      title: 'Note Templates',
      showCloseButton: true,
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Text(
              'Choose a template to jumpstart your creativity. Each template includes specialized structure and helpful prompts.',
              style: AppTypography.bodySmall(
                context,
                AppColors.textSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Flexible(
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.all(AppSpacing.md),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: 1.1,
              ),
              itemCount: NoteTemplateType.values.length,
              itemBuilder: (context, index) {
                final templateType = NoteTemplateType.values[index];
                return _buildTemplateCard(context, templateType);
              },
            ),
          ),
          SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(
    BuildContext context,
    NoteTemplateType templateType,
  ) {
    return InkWell(
      onTap: () {
        Navigator.pop(context, NoteTemplate.fromType(templateType));
      },
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface(context).withOpacity(0.5),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.divider(context), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon Background
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Text(templateType.icon, style: TextStyle(fontSize: 28.sp)),
            ),
            SizedBox(height: AppSpacing.sm),

            // Name
            Text(
              templateType.displayName,
              textAlign: TextAlign.center,
              style: AppTypography.titleMedium(context, null, FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 2.h),

            // Description or small tag
            Text(
              'Select',
              style: AppTypography.bodySmall(context, AppColors.primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}
