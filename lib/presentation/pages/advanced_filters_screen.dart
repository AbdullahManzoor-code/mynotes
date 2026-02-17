import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mynotes/core/design_system/app_colors.dart';
import 'package:mynotes/core/design_system/app_spacing.dart';
import 'package:mynotes/core/design_system/app_typography.dart';
import 'package:mynotes/injection_container.dart';
import '../design_system/design_system.dart';
import '../../core/services/global_ui_service.dart';
import '../bloc/filters/filters_bloc.dart';

/// Advanced Filters Screen (ORG-005)
/// Complex visual filter builder with multiple conditions
class AdvancedFiltersScreen extends StatelessWidget {
  const AdvancedFiltersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FiltersBloc(),
      child: const _AdvancedFiltersScreenContent(),
    );
  }
}

class _AdvancedFiltersScreenContent extends StatefulWidget {
  const _AdvancedFiltersScreenContent();

  @override
  State<_AdvancedFiltersScreenContent> createState() =>
      _AdvancedFiltersScreenContentState();
}

class _AdvancedFiltersScreenContentState
    extends State<_AdvancedFiltersScreenContent>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  final savedFilters = [
    {
      'name': 'High Priority Work',
      'conditions': 3,
      'color': AppColors.primaryColor,
      'icon': Icons.priority_high,
    },
    {
      'name': 'Personal Goals',
      'conditions': 2,
      'color': AppColors.warningColor,
      'icon': Icons.track_changes,
    },
    {
      'name': 'Recent Changes',
      'conditions': 1,
      'color': AppColors.successColor,
      'icon': Icons.update,
    },
  ];

  @override
  void initState() {
    super.initState();
    AppLogger.i('AdvancedFiltersScreen: Initialized');
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    AppLogger.i('AdvancedFiltersScreen: Disposed');
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.i('AdvancedFiltersScreen: Building UI');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: _buildAppBar(context),
      body: TabBarView(
        controller: tabController,
        children: [
          _buildBuilderTab(context),
          _buildPresetsTab(context),
          _buildSavedFiltersTab(context),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: isDark ? AppColors.lightText : AppColors.darkText,
        ),
        onPressed: () {
          AppLogger.i('AdvancedFiltersScreen: Back button pressed');
          Navigator.pop(context);
        },
      ),
      title: Text(
        'Advanced Filters',
        style: AppTypography.heading2().copyWith(
          color: isDark ? AppColors.lightText : AppColors.darkText,
        ),
      ),
      bottom: TabBar(
        controller: tabController,
        labelColor: AppColors.primaryColor,
        unselectedLabelColor: isDark
            ? AppColors.lightTextSecondary
            : AppColors.darkTextSecondary,
        indicatorColor: AppColors.primaryColor,
        onTap: (index) {
          AppLogger.i('AdvancedFiltersScreen: Tab switched to index $index');
        },
        tabs: [
          Tab(text: 'Builder'),
          Tab(text: 'Presets'),
          Tab(text: 'Saved'),
        ],
      ),
    );
  }

  Widget _buildBuilderTab(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLogicSelector(context),
          SizedBox(height: AppSpacing.lg),
          _buildConditionsBuilder(context),
          SizedBox(height: AppSpacing.lg),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildLogicSelector(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<FiltersBloc, FiltersState>(
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter Logic',
                style: AppTypography.body2(context).copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.lightText : AppColors.darkText,
                ),
              ),
              SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _buildLogicButton('AND', state.logic == 'AND', () {
                      AppLogger.i(
                        'AdvancedFiltersScreen: Logic changed to AND',
                      );
                      context.read<FiltersBloc>().add(UpdateLogicEvent('AND'));
                    }, context),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _buildLogicButton('OR', state.logic == 'OR', () {
                      AppLogger.i('AdvancedFiltersScreen: Logic changed to OR');
                      context.read<FiltersBloc>().add(UpdateLogicEvent('OR'));
                    }, context),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16.sp,
                    color: isDark
                        ? AppColors.secondaryTextDark
                        : AppColors.secondaryText,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      state.logic == 'AND'
                          ? 'All conditions must match'
                          : 'Any condition can match',
                      style: AppTypography.caption(context).copyWith(
                        color: isDark
                            ? AppColors.secondaryTextDark
                            : AppColors.secondaryText,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogicButton(
    String label,
    bool isSelected,
    VoidCallback onTap,
    BuildContext context,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withOpacity(0.2)
              : isDark
              ? AppColors.darkBg
              : AppColors.lightBg,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : AppColors.divider(context),
            width: 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTypography.body2(context).copyWith(
            color: isSelected
                ? AppColors.primaryColor
                : isDark
                ? AppColors.lightText
                : AppColors.darkText,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildConditionsBuilder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<FiltersBloc, FiltersState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Conditions',
                  style: AppTypography.body2(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.lightText : AppColors.darkText,
                  ),
                ),
                Text(
                  '${state.conditions.length}',
                  style: AppTypography.body2(context).copyWith(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.conditions.length,
              itemBuilder: (context, index) {
                return _buildConditionRow(
                  index,
                  context,
                  state.conditions[index],
                );
              },
            ),
            SizedBox(height: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: () {
                AppLogger.i(
                  'AdvancedFiltersScreen: Add Condition button pressed',
                );
                context.read<FiltersBloc>().add(AddConditionEvent());
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Condition'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor.withOpacity(0.2),
                foregroundColor: AppColors.primaryColor,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildConditionRow(
    int index,
    BuildContext context,
    Map<String, dynamic> condition,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 1,
                child: _buildDropdown(
                  'Type',
                  condition['type'] as String,
                  ['tag', 'date', 'color', 'status'],
                  (value) {
                    AppLogger.i(
                      'AdvancedFiltersScreen: Condition $index Type changed to $value',
                    );
                    context.read<FiltersBloc>().add(
                      UpdateConditionEvent(index, 'type', value),
                    );
                  },
                  context,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                flex: 1,
                child: _buildDropdown(
                  'Op',
                  condition['operator'] as String,
                  ['contains', 'equals', 'before', 'after'],
                  (value) {
                    AppLogger.i(
                      'AdvancedFiltersScreen: Condition $index Operator changed to $value',
                    );
                    context.read<FiltersBloc>().add(
                      UpdateConditionEvent(index, 'operator', value),
                    );
                  },
                  context,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              IconButton(
                icon: Icon(Icons.delete, size: 20.sp, color: Colors.red),
                onPressed: () {
                  AppLogger.i(
                    'AdvancedFiltersScreen: Remove Condition $index pressed',
                  );
                  context.read<FiltersBloc>().add(RemoveConditionEvent(index));
                },
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          TextField(
            decoration: InputDecoration(
              hintText: 'Value',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
              ),
            ),
            onChanged: (value) {
              AppLogger.i(
                'AdvancedFiltersScreen: Condition $index Value changed',
              );
              context.read<FiltersBloc>().add(
                UpdateConditionEvent(index, 'value', value),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> options,
    Function(String) onChanged,
    BuildContext context,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.caption(context).copyWith(
            color: isDark
                ? AppColors.secondaryTextDark
                : AppColors.secondaryText,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        DropdownButton<String>(
          value: value,
          isExpanded: true,
          isDense: true,
          items: options.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Text(
                option,
                style: AppTypography.bodySmall(context).copyWith(
                  color: isDark ? AppColors.lightText : AppColors.darkText,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              AppLogger.i('AdvancedFiltersScreen: Reset button pressed');
              context.read<FiltersBloc>().add(ResetFiltersEvent());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reset'),
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              AppLogger.i('AdvancedFiltersScreen: Apply button pressed');
              getIt<GlobalUiService>().showSuccess('Filter applied');
            },
            icon: const Icon(Icons.check),
            label: const Text('Apply'),
          ),
        ),
      ],
    );
  }

  Widget _buildPresetsTab(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Filter Presets',
            style: AppTypography.titleLarge(context).copyWith(
              color: isDark ? AppColors.lightText : AppColors.darkText,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
              childAspectRatio: 1.5,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              final presets = [
                {'name': 'This Week', 'icon': Icons.calendar_today},
                {'name': 'High Priority', 'icon': Icons.priority_high},
                {'name': 'Unread', 'icon': Icons.mail_outline},
                {'name': 'Pinned', 'icon': Icons.push_pin},
                {'name': 'Archived', 'icon': Icons.archive},
                {'name': 'Shared', 'icon': Icons.share},
              ];

              final preset = presets[index];

              return GestureDetector(
                onTap: () {
                  AppLogger.i(
                    'AdvancedFiltersScreen: Preset ${preset['name']} tapped',
                  );
                  getIt<GlobalUiService>().showInfo(
                    '${preset['name']} filter has been applied.',
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurface
                        : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                    border: Border.all(
                      color: isDark
                          ? AppColors.dividerDark
                          : AppColors.dividerLight,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        preset['icon'] as IconData,
                        color: AppColors.primaryColor,
                        size: 24.sp,
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        preset['name'] as String,
                        style: AppTypography.bodySmall(context).copyWith(
                          color: isDark
                              ? AppColors.lightText
                              : AppColors.darkText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSavedFiltersTab(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Saved Filters',
                style: AppTypography.titleLarge(context).copyWith(
                  color: isDark ? AppColors.lightText : AppColors.darkText,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle),
                color: AppColors.primaryColor,
                onPressed: () {
                  AppLogger.i(
                    'AdvancedFiltersScreen: Add Saved Filter pressed',
                  );
                  getIt<GlobalUiService>().showInfo(
                    'Feature coming soon to save current configuration.',
                  );
                },
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: savedFilters.length,
            itemBuilder: (context, index) {
              final filter = savedFilters[index];
              return Container(
                margin: EdgeInsets.only(bottom: AppSpacing.md),
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurface
                      : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                  border: Border.all(
                    color: isDark
                        ? AppColors.dividerDark
                        : AppColors.dividerLight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: BoxDecoration(
                        color: (filter['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.xs),
                      ),
                      child: Icon(
                        filter['icon'] as IconData,
                        color: filter['color'] as Color,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            filter['name'] as String,
                            style: AppTypography.titleMedium(context).copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.lightText
                                  : AppColors.darkText,
                            ),
                          ),
                          SizedBox(height: AppSpacing.xs),
                          Text(
                            '${filter['conditions']} conditions',
                            style: AppTypography.caption(context).copyWith(
                              color: isDark
                                  ? AppColors.secondaryTextDark
                                  : AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {
                        AppLogger.i(
                          'AdvancedFiltersScreen: Saved Filter ${filter['name']} menu tapped',
                        );
                      },
                      color: isDark
                          ? AppColors.secondaryTextDark
                          : AppColors.secondaryText,
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
}
