import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/presentation/bloc/smart_collections/smart_collections_bloc.dart';
import 'package:mynotes/domain/entities/smart_collection.dart';
import 'package:mynotes/presentation/design_system/design_system.dart';
import '../../domain/repositories/smart_collection_repository.dart';
import '../../injection_container.dart';

/// Smart Collections Screen (ORG-003)
/// AI-powered, rule-based collections that auto-organize notes
class SmartCollectionsScreen extends StatelessWidget {
  const SmartCollectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SmartCollectionsBloc(
        smartCollectionRepository: getIt<SmartCollectionRepository>(),
      )..add(const LoadSmartCollectionsEvent()),
      child: const _SmartCollectionsView(),
    );
  }
}

class _SmartCollectionsView extends StatelessWidget {
  const _SmartCollectionsView();

  @override
  Widget build(BuildContext context) {
    AppLogger.i('_SmartCollectionsView: build');
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildFilterChips(context),
          Expanded(child: _buildCollectionsList(context)),
        ],
      ),
      floatingActionButton: _buildCreateButton(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface(context),
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.textPrimary(context)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text('Smart Collections', style: AppTypography.heading2(context)),
      actions: [
        IconButton(
          icon: Icon(Icons.info_outline, color: AppColors.textPrimary(context)),
          onPressed: () => _showInfoDialog(context),
        ),
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    return BlocBuilder<SmartCollectionsBloc, SmartCollectionsState>(
      buildWhen: (p, c) => p.params.selectedFilter != c.params.selectedFilter,
      builder: (context, state) {
        return Container(
          padding: AppSpacing.paddingAllS,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.borderLight, width: 0.5),
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  context,
                  'All',
                  'all',
                  Icons.apps,
                  state.params.selectedFilter,
                ),
                AppSpacing.gapS,
                _buildFilterChip(
                  context,
                  'Active',
                  'active',
                  Icons.check_circle,
                  state.params.selectedFilter,
                ),
                AppSpacing.gapS,
                _buildFilterChip(
                  context,
                  'Archived',
                  'archived',
                  Icons.archive,
                  state.params.selectedFilter,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    String selectedValue,
  ) {
    final isSelected = selectedValue == value;

    return GestureDetector(
      onTap: () {
        AppLogger.i('_SmartCollectionsView: Filter changed to $value');
        context.read<SmartCollectionsBloc>().add(FilterChangedEvent(value));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary10 : AppColors.surface(context),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : AppColors.borderLight,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16.sp,
              color: isSelected
                  ? AppColors.primaryColor
                  : AppColors.textPrimary(context),
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: AppTypography.bodySmall(
                context,
                isSelected
                    ? AppColors.primaryColor
                    : AppColors.textPrimary(context),
                isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectionsList(BuildContext context) {
    return BlocBuilder<SmartCollectionsBloc, SmartCollectionsState>(
      builder: (context, state) {
        if (state is SmartCollectionsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final collections = state.params.filteredCollections;

        if (collections.isEmpty) {
          return Center(
            child: Text(
              'No collections found',
              style: AppTypography.bodyMedium(context, AppColors.secondaryText),
            ),
          );
        }

        return ListView.builder(
          padding: AppSpacing.paddingAllM,
          itemCount: collections.length,
          itemBuilder: (context, index) {
            return _buildCollectionCard(context, collections[index]);
          },
        );
      },
    );
  }

  Widget _buildCollectionCard(
    BuildContext context,
    SmartCollection collection,
  ) {
    final Color itemColor = _getCollectionColor(collection.id);
    final IconData itemIcon = _getCollectionIcon(collection.id);

    return GestureDetector(
      onTap: () {
        AppLogger.i(
          '_SmartCollectionsView: Opening collection details - ${collection.name}',
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                _CollectionDetailsScreen(collection: collection),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: AppSpacing.paddingAllM,
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.borderLight, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: itemColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(itemIcon, color: itemColor, size: 24.sp),
                ),
                AppSpacing.gapM,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        collection.name,
                        style: AppTypography.bodyLarge(
                          context,
                          null,
                          FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        collection.description,
                        style: AppTypography.bodySmall(
                          context,
                          AppColors.secondaryText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                _buildCollectionsMenu(context, collection),
              ],
            ),
            AppSpacing.gapM,
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.insert_drive_file,
                        size: 16.sp,
                        color: AppColors.secondaryText,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        '${collection.itemCount} items',
                        style: AppTypography.bodySmall(
                          context,
                          AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.background(context),
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(
                      color: AppColors.borderLight,
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    '${collection.rules.length} rules',
                    style: AppTypography.labelSmall(
                      context,
                      AppColors.secondaryText,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectionsMenu(
    BuildContext context,
    SmartCollection collection,
  ) {
    return PopupMenuButton(
      icon: Icon(Icons.more_vert, color: AppColors.textPrimary(context)),
      itemBuilder: (context) => [
        PopupMenuItem(
          child: Row(
            children: [
              Icon(Icons.edit, size: 18.sp),
              AppSpacing.gapS,
              const Text('Edit Rules'),
            ],
          ),
          onTap: () => _showRuleBuilder(context, collection),
        ),
        PopupMenuItem(
          child: Row(
            children: [
              Icon(
                collection.isActive ? Icons.archive : Icons.unarchive,
                size: 18.sp,
              ),
              AppSpacing.gapS,
              Text(collection.isActive ? 'Archive' : 'Activate'),
            ],
          ),
          onTap: () {
            AppLogger.i(
              '_SmartCollectionsView: Archive/Activate collection - ${collection.id}',
            );
            context.read<SmartCollectionsBloc>().add(
              ArchiveSmartCollectionEvent(collectionId: collection.id),
            );
          },
        ),
        PopupMenuItem(
          child: Row(
            children: [
              Icon(Icons.delete, size: 18.sp, color: Colors.red),
              AppSpacing.gapS,
              const Text('Delete', style: TextStyle(color: Colors.red)),
            ],
          ),
          onTap: () {
            AppLogger.i(
              '_SmartCollectionsView: Delete collection - ${collection.id}',
            );
            context.read<SmartCollectionsBloc>().add(
              DeleteSmartCollectionEvent(collectionId: collection.id),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCreateButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        AppLogger.i('_SmartCollectionsView: Create button pressed');
        _showCreateDialog(context);
      },
      label: const Text('New Collection'),
      icon: const Icon(Icons.add),
      backgroundColor: AppColors.primaryColor,
    );
  }

  void _showCreateDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface(context),
        title: Text(
          'Create Smart Collection',
          style: AppTypography.heading3(context),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: 'Collection name'),
            ),
            AppSpacing.gapM,
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                hintText: 'Description (optional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              AppLogger.i('_SmartCollectionsView: Create dialog cancelled');
              Navigator.pop(dialogContext);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                AppLogger.i(
                  '_SmartCollectionsView: Creating smart collection - ${nameController.text}',
                );
                context.read<SmartCollectionsBloc>().add(
                  CreateSmartCollectionEvent(
                    name: nameController.text,
                    description: descController.text,
                    rules: const [],
                  ),
                );
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showRuleBuilder(BuildContext context, SmartCollection collection) {
    AppLogger.i(
      '_SmartCollectionsView: Showing rule builder for ${collection.name}',
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<SmartCollectionsBloc>(),
        child: _RuleBuilderSheet(collection: collection),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    AppLogger.i('_SmartCollectionsView: Showing info dialog');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface(context),
        title: Text(
          'About Smart Collections',
          style: AppTypography.heading3(context),
        ),
        content: Text(
          'Smart Collections use rules to automatically organize your notes. Set conditions like tags, colors, and dates, and notes matching all rules are automatically grouped.',
          style: AppTypography.bodyMedium(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              AppLogger.i('_SmartCollectionsView: Info dialog dismissed');
              Navigator.pop(context);
            },
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Color _getCollectionColor(String id) {
    switch (id) {
      case '1':
        return Colors.blue;
      case '2':
        return Colors.orange;
      case '3':
        return Colors.red;
      case 'sys_1':
        return Colors.teal;
      case 'sys_2':
        return Colors.purple;
      default:
        return Colors.blueGrey;
    }
  }

  IconData _getCollectionIcon(String id) {
    switch (id) {
      case '1':
        return Icons.work;
      case '2':
        return Icons.track_changes;
      case '3':
        return Icons.priority_high;
      case 'sys_1':
        return Icons.history;
      case 'sys_2':
        return Icons.notifications_active;
      default:
        return Icons.folder;
    }
  }
}

class _CollectionDetailsScreen extends StatelessWidget {
  final SmartCollection collection;

  const _CollectionDetailsScreen({required this.collection});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.surface(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(collection.name, style: AppTypography.heading2(context)),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingAllM,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoSection(context),
            AppSpacing.gapL,
            _buildRulesSection(context, collection),
            AppSpacing.gapL,
            _buildItemsPreview(context, collection),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingAllM,
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderLight, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  color: AppColors.primary10,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.folder,
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
                      collection.name,
                      style: AppTypography.heading3(context),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      collection.description,
                      style: AppTypography.bodySmall(
                        context,
                        AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.gapM,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard(
                context,
                'Items',
                '${collection.itemCount}',
                Icons.insert_drive_file,
              ),
              _buildStatCard(
                context,
                'Rules',
                '${collection.rules.length}',
                Icons.rule,
              ),
              _buildStatCard(
                context,
                'Active',
                collection.isActive ? 'Yes' : 'No',
                Icons.check_circle_outline,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: AppSpacing.paddingAllS,
        decoration: BoxDecoration(
          color: AppColors.background(context),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20.sp, color: AppColors.secondaryText),
            SizedBox(height: 4.h),
            Text(value, style: AppTypography.heading4(context)),
            Text(
              label,
              style: AppTypography.labelSmall(context, AppColors.secondaryText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRulesSection(BuildContext context, SmartCollection collection) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Rules', style: AppTypography.heading3(context)),
            TextButton.icon(
              onPressed: () {},
              icon: Icon(Icons.add, size: 18.sp),
              label: const Text('Add Rule'),
            ),
          ],
        ),
        AppSpacing.gapM,
        if (collection.rules.isEmpty)
          Center(
            child: Text(
              'No rules defined.',
              style: AppTypography.bodySmall(context, AppColors.secondaryText),
            ),
          )
        else
          ...collection.rules.map((rule) => _buildRuleItem(context, rule)),
      ],
    );
  }

  Widget _buildRuleItem(BuildContext context, CollectionRule rule) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: AppSpacing.paddingAllS,
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.borderLight, width: 0.5),
      ),
      child: Row(
        children: [
          Icon(Icons.rule, size: 18.sp, color: AppColors.primaryColor),
          AppSpacing.gapM,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${rule.type} ${rule.operator}',
                  style: AppTypography.bodySmall(
                    context,
                    null,
                    FontWeight.w600,
                  ),
                ),
                Text(
                  'Value: ${rule.value}',
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

  Widget _buildItemsPreview(BuildContext context, SmartCollection collection) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Items Preview', style: AppTypography.heading3(context)),
            Text(
              '${collection.itemCount} items',
              style: AppTypography.heading4(context, AppColors.primaryColor),
            ),
          ],
        ),
        AppSpacing.gapM,
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: collection.itemCount > 5 ? 5 : collection.itemCount,
          itemBuilder: (context, index) {
            return Container(
              margin: EdgeInsets.only(bottom: 8.h),
              padding: AppSpacing.paddingAllM,
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.borderLight, width: 0.5),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.description,
                    size: 20.sp,
                    color: AppColors.secondaryText,
                  ),
                  AppSpacing.gapM,
                  Text(
                    'Note ${index + 1}',
                    style: AppTypography.bodyMedium(context),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _RuleBuilderSheet extends StatelessWidget {
  final SmartCollection collection;

  const _RuleBuilderSheet({required this.collection});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingAllM,
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: BlocBuilder<SmartCollectionsBloc, SmartCollectionsState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Edit Rules', style: AppTypography.heading3(context)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              AppSpacing.gapL,
              _buildRuleList(context),
              AppSpacing.gapL,
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  AppSpacing.gapM,
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // In a real app, we would gather rules from UI
                        // For this refactor, we maintain existing ones
                        context.read<SmartCollectionsBloc>().add(
                          UpdateSmartCollectionEvent(
                            collectionId: collection.id,
                            name: collection.name,
                            rules: collection.rules,
                          ),
                        );
                        Navigator.pop(context);
                      },
                      child: const Text('Save Changes'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRuleList(BuildContext context) {
    if (collection.rules.isEmpty) {
      return Center(
        child: Padding(
          padding: AppSpacing.paddingAllL,
          child: Text(
            'No rules defined yet.',
            style: AppTypography.bodyMedium(context, AppColors.secondaryText),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: collection.rules.length,
      itemBuilder: (context, index) {
        final rule = collection.rules[index];
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: AppSpacing.paddingAllM,
          decoration: BoxDecoration(
            color: AppColors.background(context),
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
                      '${rule.type} ${rule.operator}',
                      style: AppTypography.bodyMedium(
                        context,
                        null,
                        FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Value: ${rule.value}',
                      style: AppTypography.bodySmall(
                        context,
                        AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red, size: 20.sp),
                onPressed: () {
                  // TODO: Implement rule deletion logic
                },
              ),
            ],
          ),
        );
      },
    );
  }
}




