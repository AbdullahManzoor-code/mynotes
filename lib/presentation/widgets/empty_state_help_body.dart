import 'package:flutter/material.dart';
import '../design_system/design_system.dart';
import 'lottie_animation_widget.dart';

class EmptyStateTemplateChip {
  final String label;
  final IconData icon;

  const EmptyStateTemplateChip({required this.label, required this.icon});
}

class EmptyStateHelpBody extends StatelessWidget {
  final String title;
  final String subtitle;
  final String templateHeader;
  final String animationKey;
  final List<EmptyStateTemplateChip> templates;
  final String primaryActionLabel;
  final IconData primaryActionIcon;
  final VoidCallback onPrimaryAction;
  final String? secondaryActionLabel;
  final IconData? secondaryActionIcon;
  final VoidCallback? onSecondaryAction;

  const EmptyStateHelpBody({
    super.key,
    required this.title,
    required this.subtitle,
    required this.templateHeader,
    required this.animationKey,
    required this.templates,
    required this.primaryActionLabel,
    required this.primaryActionIcon,
    required this.onPrimaryAction,
    this.secondaryActionLabel,
    this.secondaryActionIcon,
    this.onSecondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          children: [
            SizedBox(height: 32.h),
            _buildIllustration(context),
            SizedBox(height: 32.h),
            _buildEmptyStateContent(context),
            SizedBox(height: 40.h),
            _buildTemplateSection(context),
            SizedBox(height: 32.h),
            _buildActionButtons(context),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildIllustration(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 280.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 240.w,
            height: 240.w,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  Colors.transparent,
                ],
                stops: const [0.0, 1.0],
              ),
              borderRadius: BorderRadius.circular(120.w),
            ),
          ),
          SizedBox(
            width: 200.w,
            height: 200.h,
            child: LottieAnimationWidget(
              animationKey,
              width: 200.w,
              height: 200.h,
              repeat: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateContent(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: AppTypography.heading2(
            context,
          ).copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.5),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 12.h),
        Text(
          subtitle,
          style: AppTypography.bodyMedium(
            context,
            AppColors.textSecondary(context),
          ).copyWith(height: 1.5),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTemplateSection(BuildContext context) {
    return Column(
      children: [
        Text(
          templateHeader,
          style: AppTypography.captionSmall(context).copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: AppColors.textSecondary(context),
          ),
        ),
        SizedBox(height: 16.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          alignment: WrapAlignment.center,
          children: templates
              .map((template) => _buildTemplateChip(context, template))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildTemplateChip(
    BuildContext context,
    EmptyStateTemplateChip template,
  ) {
    return Container(
      height: 40.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        border: Border.all(color: AppColors.border(context), width: 1),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(template.icon, size: 20.sp, color: AppColors.primary),
          SizedBox(width: 8.w),
          Text(
            template.label,
            style: AppTypography.bodySmall(
              context,
            ).copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56.h,
          child: ElevatedButton.icon(
            onPressed: onPrimaryAction,
            icon: Icon(primaryActionIcon),
            label: Text(
              primaryActionLabel,
              style: AppTypography.bodyLarge(
                context,
                Colors.white,
              ).copyWith(fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 8,
              shadowColor: AppColors.primary.withOpacity(0.3),
            ),
          ),
        ),
        if (secondaryActionLabel != null) ...[
          SizedBox(height: 16.h),
          TextButton.icon(
            onPressed: onSecondaryAction,
            icon: Icon(secondaryActionIcon ?? Icons.arrow_forward),
            label: Text(
              secondaryActionLabel!,
              style: AppTypography.bodySmall(
                context,
                AppColors.textSecondary(context),
              ).copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ],
    );
  }
}
