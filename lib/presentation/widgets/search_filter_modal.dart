import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../design_system/design_system.dart';
import '../../domain/models/search_filters.dart';
import '../bloc/global_search/search_filters_bloc.dart';

class SearchFilterModal extends StatelessWidget {
  final SearchFilters initialFilters;

  const SearchFilterModal({super.key, required this.initialFilters});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SearchFiltersBloc(initialFilters),
      child: BlocBuilder<SearchFiltersBloc, SearchFiltersState>(
        builder: (context, state) {
          final filters = state.filters;
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Search Filters',
                      style: AppTypography.titleLarge(
                        null,
                        null,
                        FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<SearchFiltersBloc>().add(
                          const ResetSearchFiltersEvent(),
                        );
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                // Types
                Text(
                  'Item Types',
                  style: AppTypography.titleMedium(
                    null,
                    null,
                    FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 8.w,
                  children: [
                    _buildTypeChip(context, filters, 'Notes', 'note'),
                    _buildTypeChip(context, filters, 'Todos', 'todo'),
                    _buildTypeChip(context, filters, 'Reminders', 'reminder'),
                  ],
                ),
                SizedBox(height: 24.h),

                // Date Range
                Text(
                  'Date Range',
                  style: AppTypography.titleMedium(
                    null,
                    null,
                    FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildDateButton(
                        context,
                        filters.startDate == null
                            ? 'From'
                            : DateFormat('MMM d, y').format(
                                filters.startDate!,
                              ),
                        () => _selectDate(context, true),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildDateButton(
                        context,
                        filters.endDate == null
                            ? 'To'
                            : DateFormat('MMM d, y').format(
                                filters.endDate!,
                              ),
                        () => _selectDate(context, false),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                // Sorting
                Text(
                  'Sort By',
                  style: AppTypography.titleMedium(
                    null,
                    null,
                    FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12.h),
                DropdownButtonFormField<String>(
                  value: filters.sortBy,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor:
                        isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'updated_at',
                      child: Text('Last Updated'),
                    ),
                    DropdownMenuItem(
                      value: 'created_at',
                      child: Text('Created Date'),
                    ),
                    DropdownMenuItem(value: 'title', child: Text('Title')),
                  ],
                  onChanged: (val) {
                    if (val == null) return;
                    context.read<SearchFiltersBloc>().add(
                      UpdateSearchSortByEvent(val),
                    );
                  },
                ),
                SizedBox(height: 12.h),
                SwitchListTile(
                  title: Text(
                    'Descending Order',
                    style: AppTypography.bodyMedium(null),
                  ),
                  value: filters.sortDescending,
                  onChanged: (val) {
                    context.read<SearchFiltersBloc>().add(
                      UpdateSearchSortDescendingEvent(val),
                    );
                  },
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppColors.primary,
                ),

                SizedBox(height: 32.h),
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, filters),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTypeChip(
    BuildContext context,
    SearchFilters filters,
    String label,
    String value,
  ) {
    final isSelected = filters.types.contains(value);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        context.read<SearchFiltersBloc>().add(
          ToggleSearchFilterTypeEvent(value, selected),
        );
      },
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(color: isSelected ? Colors.white : null),
      checkmarkColor: Colors.white,
    );
  }

  Widget _buildDateButton(
    BuildContext context,
    String label,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTypography.bodyMedium(null)),
            Icon(Icons.calendar_today, size: 16.sp, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    if (isStart) {
      context.read<SearchFiltersBloc>().add(
        UpdateSearchFilterStartDateEvent(picked),
      );
      return;
    }
    context.read<SearchFiltersBloc>().add(
      UpdateSearchFilterEndDateEvent(picked),
    );
  }
}


