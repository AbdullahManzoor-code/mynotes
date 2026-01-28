import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../design_system/design_system.dart';

/// Backup and Export Start Screen
/// Configure and initiate data export
class BackupExportScreen extends StatefulWidget {
  const BackupExportScreen({Key? key}) : super(key: key);

  @override
  State<BackupExportScreen> createState() => _BackupExportScreenState();
}

class _BackupExportScreenState extends State<BackupExportScreen> {
  bool _includeMedia = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.surface(context),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    SizedBox(height: 32.h),

                    // Illustration
                    _buildIllustration(isDark),

                    SizedBox(height: 32.h),

                    // Title and subtitle
                    Text(
                      'Your data, your control',
                      textAlign: TextAlign.center,
                      style: AppTypography.titleLarge(
                        null,
                        null,
                        FontWeight.bold,
                      ).copyWith(fontSize: 30.sp),
                    ),

                    SizedBox(height: 8.h),

                    Text(
                      'Create a complete archive of your productivity workspace.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall(null).copyWith(
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),

                    SizedBox(height: 32.h),

                    // Section header
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
                        child: Text(
                          'INCLUDED IN EXPORT',
                          style: AppTypography.captionSmall(null).copyWith(
                            color: isDark
                                ? Colors.grey.shade500
                                : Colors.grey.shade400,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),

                    // Include items
                    _buildIncludeItem(
                      icon: Icons.description_outlined,
                      title: 'Notes',
                      subtitle: 'Formatted text and attached media',
                      isDark: isDark,
                    ),

                    SizedBox(height: 4.h),

                    _buildIncludeItem(
                      icon: Icons.check_circle_outline_rounded,
                      title: 'Todos & History',
                      subtitle: 'Task lists and completion logs',
                      isDark: isDark,
                    ),

                    SizedBox(height: 4.h),

                    _buildIncludeItem(
                      icon: Icons.auto_stories_outlined,
                      title: 'Reflection Journal',
                      subtitle: 'Daily thoughts and mood tracking',
                      isDark: isDark,
                    ),

                    SizedBox(height: 32.h),

                    // Toggle option
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.grey.shade900.withOpacity(0.5)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade100,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Include media files',
                                  style: AppTypography.bodyMedium(
                                    null,
                                    null,
                                    FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'Significantly increases file size',
                                  style: AppTypography.captionSmall(null)
                                      .copyWith(
                                        color: isDark
                                            ? Colors.grey.shade400
                                            : Colors.grey.shade600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _includeMedia,
                            onChanged: (value) {
                              setState(() {
                                _includeMedia = value;
                              });
                            },
                            activeColor: AppColors.primary,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 32.h),

                    // Start Export Button
                    SizedBox(
                      width: double.infinity,
                      height: 56.h,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const BackupCompleteScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 8,
                          shadowColor: AppColors.primary.withOpacity(0.2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Start Export',
                              style: AppTypography.bodyLarge(
                                null,
                                Colors.white,
                                FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Icon(Icons.arrow_forward_rounded, size: 20.sp),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Privacy notice
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shield_outlined,
                              size: 14.sp,
                              color: isDark
                                  ? Colors.grey.shade500
                                  : Colors.grey.shade400,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              'Privacy First',
                              style: AppTypography.captionSmall(null).copyWith(
                                color: isDark
                                    ? Colors.grey.shade500
                                    : Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'All data is processed locally on your device before being zipped for you. No unencrypted data ever leaves your hardware.',
                          textAlign: TextAlign.center,
                          style: AppTypography.captionSmall(null).copyWith(
                            color: isDark
                                ? Colors.grey.shade500
                                : Colors.grey.shade400,
                            fontSize: 11.sp,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'Backup & Export',
            style: AppTypography.titleMedium(null, null, FontWeight.bold),
          ),
          SizedBox(width: 40.w),
        ],
      ),
    );
  }

  Widget _buildIllustration(bool isDark) {
    return Container(
      width: 192.w,
      height: 192.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withOpacity(0.1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 80,
            spreadRadius: 20,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 128.w,
            height: 128.w,
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: AppColors.primary, width: 4),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 40,
                ),
              ],
            ),
            child: Icon(
              Icons.enhanced_encryption_rounded,
              size: 60.sp,
              color: AppColors.primary,
            ),
          ),
          Positioned(
            bottom: 16.h,
            right: 16.w,
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.5),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Icon(
                Icons.cloud_done_rounded,
                color: Colors.white,
                size: 20.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncludeItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey.shade900.withOpacity(0.5)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMedium(null, null, FontWeight.w600),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: AppTypography.captionSmall(null).copyWith(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Backup Complete Screen
/// Shows successful export with download/share options
class BackupCompleteScreen extends StatelessWidget {
  const BackupCompleteScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.surface(context),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'Backup & Export',
                      textAlign: TextAlign.center,
                      style: AppTypography.titleMedium(
                        null,
                        null,
                        FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 40.w),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Success icon
                      Container(
                        width: 128.w,
                        height: 128.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withOpacity(0.1),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.15),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.check_circle_rounded,
                          size: 72.sp,
                          color: AppColors.primary,
                        ),
                      ),

                      SizedBox(height: 32.h),

                      Text(
                        'Export Ready',
                        style: AppTypography.titleLarge(
                          null,
                          null,
                          FontWeight.bold,
                        ).copyWith(fontSize: 32.sp),
                      ),

                      SizedBox(height: 8.h),

                      Text(
                        'Your archive has been prepared successfully and is ready for download.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMedium(null).copyWith(
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                      ),

                      SizedBox(height: 40.h),

                      // File info card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey.shade800 : Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: isDark
                                ? Colors.grey.shade700
                                : Colors.grey.shade100,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '14.2 MB',
                                    style: AppTypography.titleMedium(
                                      null,
                                      null,
                                      FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    'MyNotes_Backup_2023.zip',
                                    style: AppTypography.bodySmall(null)
                                        .copyWith(
                                          color: isDark
                                              ? Colors.grey.shade400
                                              : Colors.grey.shade600,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 64.w,
                              height: 64.w,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Icon(
                                Icons.folder_zip_outlined,
                                size: 32.sp,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 32.h),

                      // Action buttons
                      SizedBox(
                        width: double.infinity,
                        height: 56.h,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 8,
                            shadowColor: AppColors.primary.withOpacity(0.2),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.download_rounded, size: 20.sp),
                              SizedBox(width: 8.w),
                              Text(
                                'Save to Device',
                                style: AppTypography.bodyLarge(
                                  null,
                                  Colors.white,
                                  FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 16.h),

                      SizedBox(
                        width: double.infinity,
                        height: 56.h,
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isDark
                                ? Colors.white
                                : Colors.black87,
                            side: BorderSide(
                              color: isDark
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade300,
                            ),
                            backgroundColor: isDark
                                ? Colors.grey.shade800
                                : Colors.grey.shade100,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.share_rounded, size: 20.sp),
                              SizedBox(width: 8.w),
                              Text(
                                'Share Archive',
                                style: AppTypography.bodyLarge(
                                  null,
                                  null,
                                  FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Done button
            Padding(
              padding: EdgeInsets.all(16.w),
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text(
                  'Done',
                  style: AppTypography.bodyLarge(
                    null,
                    AppColors.primary,
                    FontWeight.bold,
                  ),
                ),
              ),
            ),

            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }
}
