import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design_system/design_system.dart';
import '../bloc/note/note_state.dart';

/// Notes View Options Bottom Sheet
/// Provides grid/list toggle, sort options, and filter controls (ORG-001, ORG-002)
class NotesViewOptionsSheet extends StatelessWidget {
  final NoteViewMode currentViewMode;
  final NoteSortOption currentSortOption;
  final bool sortDescending;
  final Function(NoteViewMode) onViewModeChanged;
  final Function(NoteSortOption, bool) onSortChanged;
  final VoidCallback? onFilterTapped;

  const NotesViewOptionsSheet({
    super.key,
    required this.currentViewMode,
    required this.currentSortOption,
    required this.sortDescending,
    required this.onViewModeChanged,
    required this.onSortChanged,
    this.onFilterTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: AppColors.textSecondary(context).withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  'View Options',
                  style: AppTypography.heading2(
                    context,
                    AppColors.textPrimary(context),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Done',
                    style: AppTypography.labelMedium(
                      context,
                      AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // View Mode Section
          _buildSection(
            context,
            title: 'Display Mode',
            child: _buildViewModeSelector(context),
          ),

          const SizedBox(height: 24),

          // Sort Options Section
          _buildSection(
            context,
            title: 'Sort By',
            child: _buildSortOptions(context),
          ),

          const SizedBox(height: 24),

          // Additional Options
          if (onFilterTapped != null) ...[
            _buildSection(
              context,
              title: 'Filters',
              child: _buildFilterOption(context),
            ),
            const SizedBox(height: 24),
          ],

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.labelMedium(
              context,
              AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildViewModeSelector(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        children: NoteViewMode.values.map((mode) {
          final isSelected = mode == currentViewMode;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                onViewModeChanged(mode);
                HapticFeedback.lightImpact();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      mode.icon,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary(context),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      mode.displayName.split(' ')[0], // Just "List" or "Grid"
                      style: AppTypography.labelMedium(
                        context,
                        isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSortOptions(BuildContext context) {
    return Column(
      children: NoteSortOption.values.map((option) {
        final isSelected = option == currentSortOption;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.1)
                : AppColors.surface(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border(context),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            leading: Icon(
              option.icon,
              color: isSelected
                  ? AppColors.primary
                  : AppColors.textSecondary(context),
              size: 20,
            ),
            title: Text(
              option.displayName,
              style: AppTypography.bodyMedium(
                context,
                isSelected ? AppColors.primary : AppColors.textPrimary(context),
              ),
            ),
            trailing: isSelected
                ? GestureDetector(
                    onTap: () {
                      onSortChanged(option, !sortDescending);
                      HapticFeedback.lightImpact();
                    },
                    child: Icon(
                      sortDescending
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  )
                : null,
            onTap: () {
              onSortChanged(option, sortDescending);
              HapticFeedback.lightImpact();
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFilterOption(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onFilterTapped?.call();
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.filter_list,
              color: AppColors.textSecondary(context),
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              'Filter by tags, colors, dates',
              style: AppTypography.bodyMedium(
                context,
                AppColors.textPrimary(context),
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary(context),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
