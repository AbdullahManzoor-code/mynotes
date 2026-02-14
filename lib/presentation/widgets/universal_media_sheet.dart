import 'package:flutter/material.dart';
import '../design_system/design_system.dart';

enum MediaOption { photoVideo, camera, audio, scan, sketch, link }

class UniversalMediaSheet extends StatelessWidget {
  final Function(MediaOption) onOptionSelected;

  const UniversalMediaSheet({super.key, required this.onOptionSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 40.h),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Add Attachment',
            style: AppTypography.titleMedium(
              context,
              AppColors.textPrimary(context),
              FontWeight.bold,
            ),
          ),
          SizedBox(height: 24.h),
          GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 16.h,
            crossAxisSpacing: 16.w,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildOption(
                context,
                icon: Icons.image_outlined,
                label: 'Photo/Video',
                color: Colors.purple,
                option: MediaOption.photoVideo,
              ),
              _buildOption(
                context,
                icon: Icons.camera_alt_outlined,
                label: 'Camera',
                color: Colors.blue,
                option: MediaOption.camera,
              ),
              _buildOption(
                context,
                icon: Icons.mic_none_outlined,
                label: 'Audio',
                color: Colors.red,
                option: MediaOption.audio,
              ),
              _buildOption(
                context,
                icon: Icons.document_scanner_outlined,
                label: 'Scan',
                color: Colors.orange,
                option: MediaOption.scan,
              ),
              _buildOption(
                context,
                icon: Icons.brush_outlined,
                label: 'Sketch',
                color: Colors.green,
                option: MediaOption.sketch,
              ),
              _buildOption(
                context,
                icon: Icons.link,
                label: 'Link',
                color: Colors.teal,
                option: MediaOption.link,
              ),
            ],
          ),
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
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onOptionSelected(option);
      },
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background(context),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.borderLight.withOpacity(0.5)),
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
              style: AppTypography.caption(
                context,
                AppColors.textPrimary(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
