import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../design_system/design_system.dart';
import '../design_system/components/layouts/glass_container.dart';

enum MediaOption {
  photo,
  video,
  camera,
  audio,
  dictate,
  scan,
  sketch,
  document,
  graph,
  link,
}

class UniversalMediaSheet extends StatelessWidget {
  final Function(MediaOption) onOptionSelected;

  const UniversalMediaSheet({super.key, required this.onOptionSelected});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 40.h),
      borderRadius: 32.r,
      blur: 30,
      color: AppColors.surface(context).withOpacity(0.85),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 50.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: AppColors.textSecondary(context).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text(
              'Creative Capture',
              style: AppTypography.heading3(
                context,
              ).copyWith(letterSpacing: -0.5, fontWeight: FontWeight.w800),
            ),
          ),
          SizedBox(height: 24.h),
          GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 12.h,
            crossAxisSpacing: 12.w,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildOption(
                context,
                icon: Icons.image_rounded,
                label: 'Photo',
                color: const Color(0xFF60A5FA),
                option: MediaOption.photo,
                index: 0,
              ),
              _buildOption(
                context,
                icon: Icons.videocam_rounded,
                label: 'Video',
                color: const Color(0xFFC084FC),
                option: MediaOption.video,
                index: 1,
              ),
              _buildOption(
                context,
                icon: Icons.camera_alt_rounded,
                label: 'Camera',
                color: const Color(0xFFF472B6),
                option: MediaOption.camera,
                index: 2,
              ),
              _buildOption(
                context,
                icon: Icons.mic_rounded,
                label: 'Audio',
                color: const Color(0xFFF87171),
                option: MediaOption.audio,
                index: 3,
              ),
              _buildOption(
                context,
                icon: Icons.keyboard_voice_rounded,
                label: 'Dictate',
                color: const Color(0xFFFB923C),
                option: MediaOption.dictate,
                index: 4,
              ),
              _buildOption(
                context,
                icon: Icons.document_scanner_rounded,
                label: 'Scan',
                color: const Color(0xFFFACC15),
                option: MediaOption.scan,
                index: 5,
              ),
              _buildOption(
                context,
                icon: Icons.brush_rounded,
                label: 'Sketch',
                color: const Color(0xFF4ADE80),
                option: MediaOption.sketch,
                index: 6,
              ),
              _buildOption(
                context,
                icon: Icons.description_rounded,
                label: 'File',
                color: const Color(0xFF2DD4BF),
                option: MediaOption.document,
                index: 7,
              ),
              _buildOption(
                context,
                icon: Icons.hub_rounded,
                label: 'Graph',
                color: const Color(0xFF818CF8),
                option: MediaOption.graph,
                index: 8,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildLinkOption(context),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required MediaOption option,
    required int index,
  }) {
    return AppAnimations.tapScale(
      // direction: Axis.vertical,
      // offset: 30.0,
      duration: Duration(milliseconds: 300 + (index * 50)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
            onOptionSelected(option);
          },
          borderRadius: BorderRadius.circular(20.r),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface(context).withOpacity(0.4),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 28.sp),
                ),
                SizedBox(height: 8.h),
                Text(
                  label,
                  style: AppTypography.bodySmall(
                    context,
                  ).copyWith(fontWeight: FontWeight.w600, fontSize: 12.sp),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLinkOption(BuildContext context) {
    return AppAnimations.tapScale(
      // delay: const Duration(milliseconds: 600),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
            onOptionSelected(MediaOption.link);
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.primary.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.link_rounded, color: AppColors.primary, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  'Insert Hyperlink',
                  style: AppTypography.bodyMedium(context).copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
