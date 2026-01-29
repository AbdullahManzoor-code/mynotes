import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design_system/design_system.dart';

/// Sort and Filter Options for Notes
enum NoteSortOption {
  dateCreated('Date Created', Icons.access_time),
  dateModified('Date Modified', Icons.update),
  titleAZ('Title A-Z', Icons.sort_by_alpha),
  color('Color', Icons.palette);

  const NoteSortOption(this.displayName, this.icon);
  final String displayName;
  final IconData icon;
}

enum NoteViewMode {
  list('List View', Icons.view_list),
  grid('Grid View', Icons.grid_view);

  const NoteViewMode(this.displayName, this.icon);
  final String displayName;
  final IconData icon;
}

/// Notes View Options Bottom Sheet
/// Provides grid/list toggle, sort options, and filter controls (ORG-001, ORG-002)
class NotesViewOptionsSheet extends StatefulWidget {
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
  State<NotesViewOptionsSheet> createState() => _NotesViewOptionsSheetState();
}

class _NotesViewOptionsSheetState extends State<NotesViewOptionsSheet> {
  late NoteViewMode _viewMode;
  late NoteSortOption _sortOption;
  late bool _sortDescending;

  @override
  void initState() {
    super.initState();
    _viewMode = widget.currentViewMode;
    _sortOption = widget.currentSortOption;
    _sortDescending = widget.sortDescending;
  }

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
          _buildSection(title: 'Display Mode', child: _buildViewModeSelector()),

          const SizedBox(height: 24),

          // Sort Options Section
          _buildSection(title: 'Sort By', child: _buildSortOptions()),

          const SizedBox(height: 24),

          // Additional Options
          if (widget.onFilterTapped != null) ...[
            _buildSection(title: 'Filters', child: _buildFilterOption()),
            const SizedBox(height: 24),
          ],

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
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

  Widget _buildViewModeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        children: NoteViewMode.values.map((mode) {
          final isSelected = mode == _viewMode;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _viewMode = mode;
                });
                widget.onViewModeChanged(mode);
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

  Widget _buildSortOptions() {
    return Column(
      children: NoteSortOption.values.map((option) {
        final isSelected = option == _sortOption;
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
                      setState(() {
                        _sortDescending = !_sortDescending;
                      });
                      widget.onSortChanged(option, _sortDescending);
                      HapticFeedback.lightImpact();
                    },
                    child: Icon(
                      _sortDescending
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  )
                : null,
            onTap: () {
              setState(() {
                _sortOption = option;
              });
              widget.onSortChanged(option, _sortDescending);
              HapticFeedback.lightImpact();
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFilterOption() {
    return GestureDetector(
      onTap: () {
        widget.onFilterTapped?.call();
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
