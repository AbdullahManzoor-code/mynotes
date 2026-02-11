import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../injection_container.dart';
import '../bloc/media_organization_bloc.dart';
import '../../domain/repositories/media_repository.dart';
import '../design_system/app_colors.dart';
import '../design_system/app_typography.dart';
import '../design_system/app_spacing.dart';
import '../../core/services/global_ui_service.dart';

/// Media Organization View - Batch 4, Screen 3
/// Refactored to StatelessWidget with BLoC and Design System
class MediaOrganizationView extends StatelessWidget {
  const MediaOrganizationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MediaOrganizationBloc(mediaRepository: getIt<MediaRepository>())
            ..add(const LoadMediaOrganizationEvent(groupBy: 'type')),
      child: const _MediaOrganizationViewContent(),
    );
  }
}

class _MediaOrganizationViewContent extends StatelessWidget {
  const _MediaOrganizationViewContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Media Organization',
          style: AppTypography.displayMedium(context, AppColors.darkText),
        ),
        centerTitle: true,
        backgroundColor: AppColors.lightSurface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.darkText),
      ),
      body: Column(
        children: [
          _buildGroupBySelector(context),
          Expanded(
            child: BlocBuilder<MediaOrganizationBloc, MediaOrganizationState>(
              builder: (context, state) {
                if (state is MediaOrganizationLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  );
                }

                if (state is MediaOrganizationError) {
                  return Center(
                    child: Padding(
                      padding: AppSpacing.paddingAllL,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48.sp,
                            color: Colors.redAccent,
                          ),
                          AppSpacing.gapM,
                          Text(
                            state.message,
                            style: AppTypography.bodyMedium(context),
                          ),
                          AppSpacing.gapM,
                          TextButton(
                            onPressed: () =>
                                context.read<MediaOrganizationBloc>().add(
                                  const LoadMediaOrganizationEvent(
                                    groupBy: 'type',
                                  ),
                                ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is MediaOrganizationLoaded) {
                  final grouped = state.groupedMedia;
                  if (grouped.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.folder_open_outlined,
                            size: 64.sp,
                            color: AppColors.tertiaryText,
                          ),
                          AppSpacing.gapM,
                          Text(
                            'No media found to organize',
                            style: AppTypography.bodyMedium(
                              context,
                              AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: grouped.length,
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    itemBuilder: (context, index) {
                      final groupKey = grouped.keys.elementAt(index);
                      final items = grouped[groupKey] ?? [];
                      return _buildGroupCard(context, groupKey, items);
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupBySelector(BuildContext context) {
    final state = context.watch<MediaOrganizationBloc>().state;
    final currentGroupBy = (state is MediaOrganizationLoaded)
        ? state.groupBy
        : 'type';

    return Container(
      padding: AppSpacing.paddingAllM,
      color: AppColors.lightSurface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildGroupButton(context, 'Type', 'type', currentGroupBy == 'type'),
          _buildGroupButton(context, 'Date', 'date', currentGroupBy == 'date'),
          _buildGroupButton(context, 'Size', 'size', currentGroupBy == 'size'),
        ],
      ),
    );
  }

  Widget _buildGroupButton(
    BuildContext context,
    String label,
    String value,
    bool isSelected,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: ElevatedButton(
        onPressed: () {
          context.read<MediaOrganizationBloc>().add(
            LoadMediaOrganizationEvent(groupBy: value),
          );
          getIt<GlobalUiService>().hapticFeedback();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? AppColors.primaryColor
              : AppColors.lightBackground,
          foregroundColor: isSelected ? Colors.white : AppColors.secondaryText,
          elevation: isSelected ? 2 : 0,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
            side: BorderSide(
              color: isSelected
                  ? AppColors.primaryColor
                  : AppColors.borderLight,
            ),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.button(
            context,
            isSelected ? Colors.white : AppColors.secondaryText,
          ),
        ),
      ),
    );
  }

  Widget _buildGroupCard(
    BuildContext context,
    String groupKey,
    List<dynamic> items,
  ) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: const BorderSide(color: AppColors.borderLight),
      ),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        collapsedShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        title: Row(
          children: [
            Text(
              groupKey,
              style: AppTypography.heading2(context, AppColors.darkText),
            ),
            AppSpacing.gapS,
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppColors.primary10,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                '${items.length}',
                style: AppTypography.labelSmall(
                  context,
                  AppColors.primaryColor,
                ),
              ),
            ),
          ],
        ),
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: _getMediaIcon(item),
                title: Text(
                  item.name ?? 'Unnamed',
                  style: AppTypography.bodyMedium(
                    context,
                    AppColors.darkText,
                    FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'Size: ${_formatBytes(item.size ?? 0)}',
                  style: AppTypography.bodySmall(
                    context,
                    AppColors.secondaryText,
                  ),
                ),
                trailing: PopupMenuButton(
                  icon: Icon(
                    Icons.more_vert_rounded,
                    size: 20.sp,
                    color: AppColors.secondaryText,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(Icons.visibility_outlined, size: 18.sp),
                          AppSpacing.gapS,
                          Text(
                            'View',
                            style: AppTypography.bodyMedium(context),
                          ),
                        ],
                      ),
                      onTap: () {
                        // View action
                      },
                    ),
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(Icons.drive_file_rename_outline, size: 18.sp),
                          AppSpacing.gapS,
                          Text(
                            'Organize',
                            style: AppTypography.bodyMedium(context),
                          ),
                        ],
                      ),
                      onTap: () {
                        // Use a post-frame callback to show dialog after menu closes
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _showOrganizeDialog(context, item);
                        });
                      },
                    ),
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 18.sp,
                            color: Colors.redAccent,
                          ),
                          AppSpacing.gapS,
                          Text(
                            'Delete',
                            style: AppTypography.bodyMedium(
                              context,
                              Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        // Delete action
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showOrganizeDialog(BuildContext context, dynamic item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text('Organize Item', style: AppTypography.heading1(context)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Add Tags',
                hintText: 'e.g., important, work',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                prefixIcon: const Icon(Icons.tag_rounded),
              ),
            ),
            AppSpacing.gapM,
            TextField(
              decoration: InputDecoration(
                labelText: 'Add to Collection',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                prefixIcon: const Icon(Icons.collections_bookmark_rounded),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTypography.bodyMedium(context, AppColors.secondaryText),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              getIt<GlobalUiService>().showSuccess(
                'Item organized successfully',
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              'Save',
              style: AppTypography.button(context, Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getMediaIcon(dynamic item) {
    final type = item.type?.toString().toLowerCase() ?? 'unknown';

    switch (type) {
      case 'image':
        return Container(
          padding: AppSpacing.paddingAllS,
          decoration: BoxDecoration(
            color: AppColors.accentBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            Icons.image_rounded,
            color: AppColors.accentBlue,
            size: 20.sp,
          ),
        );
      case 'video':
        return Container(
          padding: AppSpacing.paddingAllS,
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            Icons.videocam_rounded,
            color: Colors.redAccent,
            size: 20.sp,
          ),
        );
      case 'audio':
        return Container(
          padding: AppSpacing.paddingAllS,
          decoration: BoxDecoration(
            color: AppColors.accentOrange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            Icons.audiotrack_rounded,
            color: AppColors.accentOrange,
            size: 20.sp,
          ),
        );
      case 'document':
        return Container(
          padding: AppSpacing.paddingAllS,
          decoration: BoxDecoration(
            color: AppColors.accentGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            Icons.description_rounded,
            color: AppColors.accentGreen,
            size: 20.sp,
          ),
        );
      default:
        return Container(
          padding: AppSpacing.paddingAllS,
          decoration: BoxDecoration(
            color: AppColors.tertiaryText.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            Icons.file_present_rounded,
            color: AppColors.secondaryText,
            size: 20.sp,
          ),
        );
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
