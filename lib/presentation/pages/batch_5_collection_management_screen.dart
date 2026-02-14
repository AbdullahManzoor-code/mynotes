import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mynotes/presentation/bloc/smart_collections/smart_collections_bloc.dart';
import 'package:mynotes/domain/entities/smart_collection.dart';
import 'package:mynotes/core/routes/app_routes.dart';
import '../design_system/app_colors.dart';
import '../design_system/app_typography.dart';
import '../design_system/app_spacing.dart';
import '../../core/services/global_ui_service.dart';
import '../../injection_container.dart';

/// Collection Management - Batch 5, Screen 4
/// Refactored to StatelessWidget with BLoC and Design System
class CollectionManagementScreen extends StatelessWidget {
  const CollectionManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Manage Collections',
          style: AppTypography.displayMedium(context, AppColors.darkText),
        ),
        centerTitle: true,
        backgroundColor: AppColors.lightSurface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.darkText),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add_circle_outline_rounded,
              color: AppColors.primaryColor,
              size: 24.sp,
            ),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.createCollection);
              getIt<GlobalUiService>().hapticFeedback();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(context),
          Expanded(
            child: BlocBuilder<SmartCollectionsBloc, SmartCollectionsState>(
              builder: (context, state) {
                if (state is SmartCollectionsLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  );
                }

                if (state is SmartCollectionsError) {
                  return Center(
                    child: Padding(
                      padding: AppSpacing.paddingAllM,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 48.sp,
                            color: AppColors.error,
                          ),
                          AppSpacing.gapM,
                          Text(
                            state.message,
                            style: AppTypography.bodyMedium(context),
                          ),
                          AppSpacing.gapM,
                          ElevatedButton(
                            onPressed: () => context
                                .read<SmartCollectionsBloc>()
                                .add(const LoadSmartCollectionsEvent()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is SmartCollectionsLoaded) {
                  final collections = state.params.filteredCollections;
                  if (collections.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  return ListView.separated(
                    itemCount: collections.length,
                    padding: AppSpacing.paddingAllM,
                    separatorBuilder: (context, index) => AppSpacing.gapM,
                    itemBuilder: (context, index) {
                      final collection = collections[index];
                      return _buildCollectionCard(context, collection);
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

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      color: AppColors.lightSurface,
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search collections...',
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppColors.primaryColor,
            size: 20.sp,
          ),
          filled: true,
          fillColor: AppColors.lightBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16.w),
        ),
        onChanged: (value) {
          context.read<SmartCollectionsBloc>().add(
            SearchSmartCollectionsEvent(query: value),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(32.w),
              decoration: const BoxDecoration(
                color: AppColors.primary10,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.collections_bookmark_outlined,
                size: 80.sp,
                color: AppColors.primaryColor,
              ),
            ),
            AppSpacing.gapL,
            Text(
              'No Smart Collections',
              style: AppTypography.heading1(context),
            ),
            AppSpacing.gapS,
            Text(
              'Keep your workspace organized automatically by setting up smart grouping rules.',
              style: AppTypography.bodyMedium(context, AppColors.secondaryText),
              textAlign: TextAlign.center,
            ),
            AppSpacing.gapL,
            SizedBox(
              width: 200.w,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.createCollection),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Get Started',
                  style: AppTypography.button(context, Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectionCard(
    BuildContext context,
    SmartCollection collection,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.collectionDetails,
            arguments: collection.id,
          );
        },
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: AppSpacing.paddingAllM,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary10,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_motion_rounded,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  AppSpacing.gapM,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          collection.name,
                          style: AppTypography.heading2(
                            context,
                            AppColors.darkText,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '${collection.itemCount} matching items',
                          style: AppTypography.labelSmall(
                            context,
                            AppColors.primaryColor,
                            FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildMenuButton(context, collection),
                ],
              ),
              AppSpacing.gapS,
              Text(
                collection.description.isEmpty
                    ? 'No description provided.'
                    : collection.description,
                style: AppTypography.bodySmall(
                  context,
                  AppColors.secondaryText,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              AppSpacing.gapM,
              Row(
                children: [
                  _buildTag(
                    context,
                    'RULE: ${collection.logic}',
                    AppColors.accentBlue,
                  ),
                  AppSpacing.gapS,
                  if (collection.isActive)
                    _buildTag(context, 'ACTIVE', AppColors.successGreen)
                  else
                    _buildTag(context, 'INACTIVE', AppColors.tertiaryText),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, SmartCollection collection) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert_rounded,
        color: AppColors.tertiaryText,
        size: 24.sp,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      onSelected: (value) {
        if (value == 'delete') {
          _confirmDelete(context, collection);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 18.sp),
              AppSpacing.gapS,
              Text('Edit', style: AppTypography.bodyMedium(context)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(
                Icons.delete_outline_rounded,
                size: 18.sp,
                color: AppColors.error,
              ),
              AppSpacing.gapS,
              Text(
                'Delete',
                style: AppTypography.bodyMedium(context, AppColors.error),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTag(BuildContext context, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall(context, color, FontWeight.w700),
      ),
    );
  }

  void _confirmDelete(BuildContext context, SmartCollection collection) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'Delete Collection',
          style: AppTypography.heading1(context),
        ),
        content: Text(
          'Are you sure you want to delete "${collection.name}"? This will not delete the actual notes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: AppTypography.button(context, AppColors.secondaryText),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<SmartCollectionsBloc>().add(
                DeleteSmartCollectionEvent(collectionId: collection.id),
              );
              Navigator.pop(dialogContext);
              getIt<GlobalUiService>().showSuccess('Collection deleted');
              getIt<GlobalUiService>().hapticFeedback();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              'Delete',
              style: AppTypography.button(context, Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

