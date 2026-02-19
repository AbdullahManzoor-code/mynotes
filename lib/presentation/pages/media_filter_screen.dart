import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/injection_container.dart';
import 'package:mynotes/presentation/bloc/media/media_gallery/media_gallery_bloc.dart';
import 'package:mynotes/presentation/bloc/media/media_filter/media_filter_bloc.dart';
import 'package:mynotes/presentation/bloc/params/media_filter_params.dart';
import 'package:mynotes/presentation/design_system/design_system.dart';

/// Advanced Media Filter Screen - Batch 4, Screen 1
/// Refactored to BLoC and Design System - ORG-004
class AdvancedMediaFilterScreen extends StatelessWidget {
  const AdvancedMediaFilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MediaFilterBloc(),
      child: const _AdvancedMediaFilterContent(),
    );
  }
}

class _AdvancedMediaFilterContent extends StatelessWidget {
  const _AdvancedMediaFilterContent();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Advanced Media Filter',
          style: AppTypography.heading2(context),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? AppColors.lightText : AppColors.darkText,
            size: 20.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<MediaGalleryBloc, MediaGalleryState>(
        listener: (context, state) {
          if (state is MediaGalleryError) {
            getIt<GlobalUiService>().showError(state.message);
          }
        },
        child: BlocBuilder<MediaFilterBloc, MediaFilterState>(
          builder: (context, filterState) {
            final params = filterState.params;

            return SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Media Type Filter
                  _buildSectionTitle(context, 'Media Type'),
                  _buildMediaTypeSelector(context, params),
                  SizedBox(height: AppSpacing.lg),

                  // Date Range Filter
                  _buildSectionTitle(context, 'Date Range'),
                  _buildDateRangeSelector(context, params),
                  SizedBox(height: AppSpacing.lg),

                  // File Size Filter
                  _buildSectionTitle(context, 'File Size'),
                  _buildSizeRangeSelector(context, params),
                  SizedBox(height: AppSpacing.lg),

                  // Tags Filter
                  _buildSectionTitle(context, 'Tags'),
                  _buildTagsInput(context, params),
                  SizedBox(height: AppSpacing.lg),

                  // Options
                  _buildSectionTitle(context, 'Options'),
                  _buildOptionsCheckbox(context, params),
                  SizedBox(height: AppSpacing.xl),

                  // Action Buttons
                  _buildActionButtons(context, params),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        title,
        style: AppTypography.titleMedium(
          context,
        ).copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildMediaTypeSelector(
    BuildContext context,
    MediaFilterParams params,
  ) {
    final types = ['image', 'video', 'audio', 'document'];

    return Wrap(
      spacing: AppSpacing.xs,
      children: types.map((type) {
        final isSelected = params.selectedType == type;
        return ChoiceChip(
          label: Text(type.toUpperCase()),
          selected: isSelected,
          selectedColor: AppColors.primaryColor.withOpacity(0.2),
          labelStyle: TextStyle(
            color: isSelected
                ? AppColors.primaryColor
                : AppColors.secondaryText,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          onSelected: (selected) {
            AppLogger.i(
              'AdvancedMediaFilterScreen: Media type selected: $type ($selected)',
            );
            context.read<MediaFilterBloc>().add(
              UpdateMediaTypeEvent(selected ? type : null),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildDateRangeSelector(
    BuildContext context,
    MediaFilterParams params,
  ) {
    return Card(
      elevation: 0,
      color: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkSurface
          : AppColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              'From: ${params.fromDate?.toString().split(' ')[0] ?? 'Not set'}',
              style: AppTypography.bodyMedium(context),
            ),
            trailing: Icon(
              Icons.calendar_today,
              size: 18.sp,
              color: AppColors.primaryColor,
            ),
            onTap: () => _selectDate(context, true),
          ),
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: Theme.of(context).dividerColor,
          ),
          ListTile(
            title: Text(
              'To: ${params.toDate?.toString().split(' ')[0] ?? 'Not set'}',
              style: AppTypography.bodyMedium(context),
            ),
            trailing: Icon(
              Icons.calendar_today,
              size: 18.sp,
              color: AppColors.primaryColor,
            ),
            onTap: () => _selectDate(context, false),
          ),
          if (params.fromDate != null || params.toDate != null)
            TextButton(
              onPressed: () {
                AppLogger.i('AdvancedMediaFilterScreen: Clear dates pressed');
                context.read<MediaFilterBloc>().add(
                  const UpdateDateRangeEvent(fromDate: null, toDate: null),
                );
              },
              child: Text(
                'Clear Dates',
                style: TextStyle(color: AppColors.errorColor),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSizeRangeSelector(
    BuildContext context,
    MediaFilterParams params,
  ) {
    return Column(
      children: [
        AppTextField(
          labelText: 'Min Size (MB)',
          prefixIcon: Icons.storage,
          keyboardType: TextInputType.number,
          hintText: 'Minimum size in MB',
          onChanged: (value) {
            final bytes = int.tryParse(value) != null
                ? int.parse(value) * 1024 * 1024
                : null;
            context.read<MediaFilterBloc>().add(
              UpdateSizeRangeEvent(
                minSize: bytes,
                maxSize: params.maxSizeBytes,
              ),
            );
          },
        ),
        SizedBox(height: AppSpacing.sm),
        AppTextField(
          labelText: 'Max Size (MB)',
          prefixIcon: Icons.storage,
          keyboardType: TextInputType.number,
          hintText: 'Maximum size in MB',
          onChanged: (value) {
            final bytes = int.tryParse(value) != null
                ? int.parse(value) * 1024 * 1024
                : null;
            context.read<MediaFilterBloc>().add(
              UpdateSizeRangeEvent(
                minSize: params.minSizeBytes,
                maxSize: bytes,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTagsInput(BuildContext context, MediaFilterParams params) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          labelText: 'Enter tags',
          hintText: 'e.g., vacation, important',
          prefixIcon: Icons.label,
          suffixIcon: Icons.add,
          onSuffixIconTap: () => _showTagSuggestions(context),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              context.read<MediaFilterBloc>().add(AddTagEvent(value.trim()));
            }
          },
        ),
        if (params.selectedTags.isNotEmpty) ...[
          SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            children: params.selectedTags.map((tag) {
              return Chip(
                label: Text(tag),
                backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                deleteIcon: Icon(Icons.close, size: 14.sp),
                onDeleted: () {
                  context.read<MediaFilterBloc>().add(RemoveTagEvent(tag));
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildOptionsCheckbox(BuildContext context, MediaFilterParams params) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkSurface
            : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
      ),
      child: CheckboxListTile(
        title: Text(
          'Exclude Archived Items',
          style: AppTypography.bodyMedium(context),
        ),
        value: params.excludeArchived,
        activeColor: AppColors.primaryColor,
        onChanged: (value) {
          context.read<MediaFilterBloc>().add(
            ToggleExcludeArchivedEvent(value ?? true),
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, MediaFilterParams params) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Reset'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              side: BorderSide(color: AppColors.secondaryText),
            ),
            onPressed: () {
              AppLogger.i('AdvancedMediaFilterScreen: Reset filters pressed');
              context.read<MediaFilterBloc>().add(const ClearAllFiltersEvent());
            },
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: BlocBuilder<MediaGalleryBloc, MediaGalleryState>(
            builder: (context, state) {
              final isLoading = state is MediaGalleryLoading;
              return ElevatedButton.icon(
                icon: isLoading
                    ? SizedBox(
                        width: 16.sp,
                        height: 16.sp,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.search),
                label: const Text('Apply Filter'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: isLoading
                    ? null
                    : () {
                        AppLogger.i(
                          'AdvancedMediaFilterScreen: Apply filter pressed',
                        );
                        _applyFilter(context, params);
                      },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primaryColor,
              primary: AppColors.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final currentParams = context.read<MediaFilterBloc>().state.params;
      context.read<MediaFilterBloc>().add(
        UpdateDateRangeEvent(
          fromDate: isFromDate ? picked : currentParams.fromDate,
          toDate: isFromDate ? currentParams.toDate : picked,
        ),
      );
    }
  }

  void _showTagSuggestions(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Popular Tags',
          style: AppTypography.heading3(dialogContext),
        ),
        content: Wrap(
          spacing: AppSpacing.xs,
          children: ['vacation', 'work', 'important', 'family', 'project']
              .map(
                (tag) => ActionChip(
                  label: Text(tag),
                  onPressed: () {
                    context.read<MediaFilterBloc>().add(AddTagEvent(tag));
                    Navigator.pop(dialogContext);
                  },
                ),
              )
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _applyFilter(BuildContext context, MediaFilterParams params) {
    context.read<MediaGalleryBloc>().add(
      FilterMediaEvent(
        filterType: params.selectedType,
        fromDate: params.fromDate,
        toDate: params.toDate,
        minSizeBytes: params.minSizeBytes,
        maxSizeBytes: params.maxSizeBytes,
        tags: params.selectedTags.isNotEmpty ? params.selectedTags : null,
      ),
    );

    getIt<GlobalUiService>().showSuccess('Narrowed down your media search');
    Navigator.pop(context);
  }
}


