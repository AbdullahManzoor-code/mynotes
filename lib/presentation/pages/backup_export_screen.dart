import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../design_system/design_system.dart';
import 'package:mynotes/core/services/backup_service.dart';
import 'package:file_picker/file_picker.dart';
import '../../injection_container.dart' show getIt;
import '../bloc/backup_bloc.dart';
import '../bloc/params/backup_params.dart';

/// Backup and Export Start Screen
/// Refactored to use Design System, BackupBloc, and Stateless architecture
class BackupExportScreen extends StatelessWidget {
  const BackupExportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<BackupBloc>()..add(const LoadBackupStatsEvent()),
      child: const _BackupExportView(),
    );
  }
}

class _BackupExportView extends StatelessWidget {
  const _BackupExportView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<BackupBloc, BackupState>(
      listener: (context, state) {
        if (state is BackupCompleted) {
          final statsState = context.read<BackupBloc>().state;
          double totalSize = 0;
          if (statsState is BackupStatsLoaded) {
            totalSize = state.params.includeMedia
                ? (statsState.dbSize + statsState.mediaSize)
                : statsState.dbSize;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BackupCompleteScreen(
                backupPath: state.backupFile,
                fileSize: totalSize,
              ),
            ),
          );
        } else if (state is BackupError) {
          getIt<GlobalUiService>().showError(state.message);
        } else if (state is RestoreCompleted) {
          getIt<GlobalUiService>().showSuccess(state.message);
        }
      },
      builder: (context, state) {
        bool isLoading = state is BackupInProgress || state is BackupInitial;
        BackupParams params = const BackupParams();

        if (state is BackupStatsLoaded) {
          params = state.params;
        } else if (state is BackupSettingsUpdated) {
          params = state.params;
        }

        return Scaffold(
          backgroundColor: AppColors.lightBackground,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(context),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: AppSpacing.paddingAllL,
                    child: Column(
                      children: [
                        AppSpacing.gapXXXL,

                        // Illustration
                        _buildIllustration(context, isDark),

                        AppSpacing.gapXXXL,

                        // Title and subtitle
                        Text(
                          'Your data, your control',
                          textAlign: TextAlign.center,
                          style: AppTypography.displayLarge(context),
                        ),

                        AppSpacing.gapS,

                        Text(
                          'Create a complete archive of your productivity workspace.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySmall(
                            context,
                            AppColors.secondaryText,
                          ),
                        ),

                        AppSpacing.gapXXXL,

                        // Section header
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
                            child: Text(
                              'INCLUDED IN EXPORT',
                              style: AppTypography.labelSmall(
                                context,
                                AppColors.secondaryText,
                                FontWeight.bold,
                              ).copyWith(letterSpacing: 1.5),
                            ),
                          ),
                        ),

                        // Include items
                        _buildIncludeItem(
                          context,
                          icon: Icons.description_outlined,
                          title: 'Notes',
                          subtitle: 'Formatted text and attached media',
                          isDark: isDark,
                        ),

                        AppSpacing.gapXS,

                        _buildIncludeItem(
                          context,
                          icon: Icons.check_circle_outline_rounded,
                          title: 'Todos & History',
                          subtitle: 'Task lists and completion logs',
                          isDark: isDark,
                        ),

                        AppSpacing.gapXS,

                        _buildIncludeItem(
                          context,
                          icon: Icons.auto_stories_outlined,
                          title: 'Reflection Journal',
                          subtitle: 'Daily thoughts and mood tracking',
                          isDark: isDark,
                        ),

                        AppSpacing.gapXXXL,

                        // Toggle option
                        Container(
                          padding: AppSpacing.paddingAllM,
                          decoration: BoxDecoration(
                            color: AppColors.lightSurface,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: AppColors.borderLight),
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
                                        context,
                                        null,
                                        FontWeight.w600,
                                      ),
                                    ),
                                    AppSpacing.gapXS,
                                    Text(
                                      'Significantly increases file size',
                                      style: AppTypography.labelSmall(
                                        context,
                                        AppColors.secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: params.includeMedia,
                                onChanged: (value) {
                                  context.read<BackupBloc>().add(
                                    UpdateBackupSettingsEvent(
                                      params.copyWith(includeMedia: value),
                                    ),
                                  );
                                },
                                activeColor: AppColors.primaryColor,
                              ),
                            ],
                          ),
                        ),

                        AppSpacing.gapXXXL,

                        // Export Format Section
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: 4.w,
                              top: 8.h,
                              bottom: 8.h,
                            ),
                            child: Text(
                              'EXPORT FORMAT',
                              style: AppTypography.labelSmall(
                                context,
                                AppColors.secondaryText,
                                FontWeight.bold,
                              ).copyWith(letterSpacing: 1.5),
                            ),
                          ),
                        ),

                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          decoration: BoxDecoration(
                            color: AppColors.lightSurface,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: params.exportFormat,
                              isExpanded: true,
                              onChanged: (value) {
                                if (value != null) {
                                  context.read<BackupBloc>().add(
                                    UpdateBackupSettingsEvent(
                                      params.copyWith(exportFormat: value),
                                    ),
                                  );
                                }
                              },
                              items: ['ZIP', 'Markdown', 'JSON', 'PDF'].map((
                                String value,
                              ) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: AppTypography.bodyMedium(context),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),

                        AppSpacing.gapXXXL,

                        // Start Export Button
                        SizedBox(
                          width: double.infinity,
                          height: 56.h,
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () => _startExport(context, params),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (isLoading)
                                  const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                else ...[
                                  Text(
                                    'Start ${params.exportFormat} Export',
                                    style: AppTypography.button(
                                      context,
                                      Colors.white,
                                    ),
                                  ),
                                  AppSpacing.gapS,
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 20.sp,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        AppSpacing.gapM,

                        // Import Button
                        SizedBox(
                          width: double.infinity,
                          height: 56.h,
                          child: OutlinedButton(
                            onPressed: isLoading
                                ? null
                                : () => _importData(context, params),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.darkText,
                              side: const BorderSide(
                                color: AppColors.borderLight,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.upload_file_rounded, size: 20.sp),
                                AppSpacing.gapS,
                                Text(
                                  'Import from File',
                                  style: AppTypography.button(
                                    context,
                                    AppColors.darkText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        AppSpacing.gapXXXL,

                        // Privacy notice
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shield_outlined,
                                  size: 14.sp,
                                  color: AppColors.secondaryText,
                                ),
                                AppSpacing.gapXS,
                                Text(
                                  'Privacy First',
                                  style: AppTypography.labelSmall(
                                    context,
                                    AppColors.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                            AppSpacing.gapS,
                            Text(
                              'All data is processed locally on your device before being zipped for you. No unencrypted data ever leaves your hardware.',
                              textAlign: TextAlign.center,
                              style: AppTypography.labelSmall(
                                context,
                                AppColors.secondaryText,
                              ).copyWith(fontSize: 11.sp, height: 1.4),
                            ),
                          ],
                        ),

                        AppSpacing.gapXXXL,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: AppSpacing.paddingAllM,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          Text('Backup & Export', style: AppTypography.displayMedium(context)),
          SizedBox(width: 40.w),
        ],
      ),
    );
  }

  Widget _buildIllustration(BuildContext context, bool isDark) {
    return Container(
      width: 192.w,
      height: 192.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryColor.withOpacity(0.1),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 128.w,
            height: 128.w,
            decoration: BoxDecoration(
              color: AppColors.lightSurface,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: AppColors.primaryColor, width: 4),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.3),
                  blurRadius: 40,
                ),
              ],
            ),
            child: Icon(
              Icons.enhanced_encryption_rounded,
              size: 60.sp,
              color: AppColors.primaryColor,
            ),
          ),
          Positioned(
            bottom: 16.h,
            right: 16.w,
            child: Container(
              padding: AppSpacing.paddingAllS,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(12.r),
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

  Widget _buildIncludeItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Container(
      padding: AppSpacing.paddingAllM,
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: AppColors.primary10,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: AppColors.primaryColor, size: 24.sp),
          ),
          AppSpacing.gapL,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMedium(
                    context,
                    null,
                    FontWeight.w600,
                  ),
                ),
                AppSpacing.gapXS,
                Text(
                  subtitle,
                  style: AppTypography.labelSmall(
                    context,
                    AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _startExport(BuildContext context, BackupParams params) {
    context.read<BackupBloc>().add(CreateBackupEvent(params));
  }

  Future<void> _importData(BuildContext context, BackupParams params) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip', 'json'],
    );

    if (result != null && result.files.single.path != null) {
      context.read<BackupBloc>().add(
        RestoreBackupEvent(
          params: params,
          backupFilePath: result.files.single.path!,
        ),
      );
    }
  }
}

/// Backup Complete Screen
/// Shows successful export with download/share options
class BackupCompleteScreen extends StatelessWidget {
  final String backupPath;
  final double fileSize;

  const BackupCompleteScreen({
    super.key,
    required this.backupPath,
    required this.fileSize,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fileName = backupPath.split(Platform.pathSeparator).last;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: AppSpacing.paddingAllM,
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
                      style: AppTypography.displayMedium(context),
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
                          color: AppColors.primary10,
                        ),
                        child: Icon(
                          Icons.check_circle_rounded,
                          size: 72.sp,
                          color: AppColors.primaryColor,
                        ),
                      ),

                      AppSpacing.gapXXXL,

                      Text(
                        'Export Ready',
                        style: AppTypography.displayLarge(context),
                      ),

                      AppSpacing.gapS,

                      Text(
                        'Your archive has been prepared successfully and is ready for download.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMedium(
                          context,
                          AppColors.secondaryText,
                        ),
                      ),

                      AppSpacing.gapXXXL,

                      // File info card
                      Container(
                        width: double.infinity,
                        padding: AppSpacing.paddingAllM,
                        decoration: BoxDecoration(
                          color: AppColors.lightSurface,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: AppColors.borderLight),
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
                                    '${fileSize.toStringAsFixed(1)} MB',
                                    style: AppTypography.bodyLarge(
                                      context,
                                      null,
                                      FontWeight.bold,
                                    ),
                                  ),
                                  AppSpacing.gapXS,
                                  Text(
                                    fileName,
                                    style: AppTypography.labelSmall(
                                      context,
                                      AppColors.secondaryText,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 64.w,
                              height: 64.w,
                              decoration: BoxDecoration(
                                color: AppColors.primary10,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Icon(
                                Icons.folder_zip_outlined,
                                size: 32.sp,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      AppSpacing.gapXXXL,

                      // Action buttons
                      SizedBox(
                        width: double.infinity,
                        height: 56.h,
                        child: ElevatedButton(
                          onPressed: () =>
                              BackupService.shareBackup(backupPath),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.download_rounded, size: 20.sp),
                              AppSpacing.gapS,
                              Text(
                                'Save or Share',
                                style: AppTypography.button(
                                  context,
                                  Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      AppSpacing.gapM,

                      SizedBox(
                        width: double.infinity,
                        height: 56.h,
                        child: OutlinedButton(
                          onPressed: () =>
                              BackupService.shareBackup(backupPath),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.darkText,
                            side: const BorderSide(
                              color: AppColors.borderLight,
                            ),
                            backgroundColor: AppColors.lightBackground,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.share_rounded, size: 20.sp),
                              AppSpacing.gapS,
                              Text(
                                'Share Archive',
                                style: AppTypography.button(
                                  context,
                                  AppColors.darkText,
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
              padding: AppSpacing.paddingAllM,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text(
                  'Done',
                  style: AppTypography.button(context, AppColors.primaryColor),
                ),
              ),
            ),

            AppSpacing.gapXXXL,
          ],
        ),
      ),
    );
  }
}
