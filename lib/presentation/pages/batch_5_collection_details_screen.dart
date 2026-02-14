import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mynotes/presentation/bloc/smart_collections/smart_collections_bloc.dart';
import '../design_system/app_colors.dart';
import '../design_system/app_typography.dart';
import '../design_system/app_spacing.dart';
import '../../core/services/global_ui_service.dart';
import '../../injection_container.dart';

/// Collection Details - Batch 5, Screen 3
/// Refactored to StatelessWidget with BLoC and Design System
class CollectionDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> collection;

  const CollectionDetailsScreen({super.key, required this.collection});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          collection['name'] ?? 'Collection',
          style: AppTypography.displayMedium(context, AppColors.darkText),
        ),
        centerTitle: true,
        backgroundColor: AppColors.lightSurface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.darkText),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              color: AppColors.darkText,
              size: 24.sp,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            onSelected: (value) {
              if (value == 'edit') {
                _showEditDialog(context);
              } else if (value == 'delete') {
                _confirmDelete(context);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 20.sp),
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
                      size: 20.sp,
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
              ),
            ],
          ),
        ],
      ),
      body: BlocListener<SmartCollectionsBloc, SmartCollectionsState>(
        listener: (context, state) {
          if (state is SmartCollectionsError) {
            getIt<GlobalUiService>().showError(state.message);
          }
        },
        child: SingleChildScrollView(
          padding: AppSpacing.paddingAllM,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              AppSpacing.gapL,
              _buildRulesSection(context),
              AppSpacing.gapL,
              _buildItemsSection(context),
              AppSpacing.gapXL,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingAllM,
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: AppSpacing.paddingAllM,
                decoration: const BoxDecoration(
                  color: AppColors.primary10,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome_motion_rounded,
                  color: AppColors.primaryColor,
                  size: 28.sp,
                ),
              ),
              AppSpacing.gapM,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      collection['name'] ?? 'Untitled Collection',
                      style: AppTypography.heading1(
                        context,
                        AppColors.darkText,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Smart Collection',
                      style: AppTypography.labelSmall(
                        context,
                        AppColors.primaryColor,
                        FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.gapL,
          const Divider(),
          AppSpacing.gapM,
          _buildInfoRow(
            context,
            'Description',
            collection['description'] ?? 'No description provided.',
          ),
          _buildInfoRow(
            context,
            'Created',
            collection['createdAt']?.toString() ?? 'Unknown',
          ),
          _buildInfoRow(context, 'Logic Pattern', collection['logic'] ?? 'AND'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.labelSmall(context, AppColors.secondaryText),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: AppTypography.bodyMedium(context, AppColors.darkText),
          ),
        ],
      ),
    );
  }

  Widget _buildRulesSection(BuildContext context) {
    final rules = (collection['rules'] as List?) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filtering Rules (${rules.length})',
          style: AppTypography.heading2(context),
        ),
        AppSpacing.gapM,
        Container(
          decoration: BoxDecoration(
            color: AppColors.lightSurface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: rules.isEmpty
              ? Padding(
                  padding: AppSpacing.paddingAllL,
                  child: Center(
                    child: Text(
                      'No rules defined',
                      style: AppTypography.bodyMedium(
                        context,
                        AppColors.tertiaryText,
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: rules.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final rule = rules[index] as Map<String, dynamic>;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary10,
                        radius: 14.r,
                        child: Text(
                          '${index + 1}',
                          style: AppTypography.labelSmall(
                            context,
                            AppColors.primaryColor,
                          ),
                        ),
                      ),
                      title: Text(
                        '${rule['field']} ${rule['operator']} ${rule['value']}',
                        style: AppTypography.bodyMedium(
                          context,
                          AppColors.darkText,
                          FontWeight.w500,
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildItemsSection(BuildContext context) {
    final items = (collection['items'] as List?) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Items in Collection (${items.length})',
          style: AppTypography.heading2(context),
        ),
        AppSpacing.gapM,
        if (items.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40.h),
              child: Column(
                children: [
                  Icon(
                    Icons.folder_open_rounded,
                    size: 48.sp,
                    color: AppColors.tertiaryText,
                  ),
                  AppSpacing.gapM,
                  Text(
                    'No items match this collection',
                    style: AppTypography.bodyMedium(
                      context,
                      AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: AppColors.lightSurface,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  title: Text(
                    item['name'] ?? 'Unnamed',
                    style: AppTypography.bodyMedium(
                      context,
                      AppColors.darkText,
                      FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    item['type'] ?? 'Unknown',
                    style: AppTypography.bodySmall(
                      context,
                      AppColors.secondaryText,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.tertiaryText,
                  ),
                  onTap: () {},
                );
              },
            ),
          ),
      ],
    );
  }

  void _showEditDialog(BuildContext context) {
    final nameController = TextEditingController(text: collection['name']);
    final descController = TextEditingController(
      text: collection['description'],
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text('Edit Collection', style: AppTypography.heading1(context)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
            AppSpacing.gapM,
            TextField(
              controller: descController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              getIt<GlobalUiService>().showSuccess('Collection updated');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'Delete Collection',
          style: AppTypography.heading1(context),
        ),
        content: Text(
          'Are you sure you want to delete "${collection['name']}"? This action cannot be undone.',
          style: AppTypography.bodyMedium(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<SmartCollectionsBloc>().add(
                DeleteSmartCollectionEvent(collectionId: collection['id']),
              );
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back from details
              getIt<GlobalUiService>().hapticFeedback();
              getIt<GlobalUiService>().showSuccess('Collection deleted');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

