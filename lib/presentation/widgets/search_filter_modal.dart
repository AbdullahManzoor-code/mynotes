import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../design_system/design_system.dart';
import '../../domain/models/search_filters.dart';

class SearchFilterModal extends StatefulWidget {
  final SearchFilters initialFilters;

  const SearchFilterModal({super.key, required this.initialFilters});

  @override
  State<SearchFilterModal> createState() => _SearchFilterModalState();
}

class _SearchFilterModalState extends State<SearchFilterModal> {
  late List<String> _selectedTypes;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedCategory;
  late String _sortBy;
  late bool _sortDescending;

  @override
  void initState() {
    super.initState();
    _selectedTypes = List.from(widget.initialFilters.types);
    _startDate = widget.initialFilters.startDate;
    _endDate = widget.initialFilters.endDate;
    _selectedCategory = widget.initialFilters.category;
    _sortBy = widget.initialFilters.sortBy;
    _sortDescending = widget.initialFilters.sortDescending;
  }

  @override
  Widget build(BuildContext context) {
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
                style: AppTypography.titleLarge(null, null, FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedTypes = [];
                    _startDate = null;
                    _endDate = null;
                    _selectedCategory = null;
                    _sortBy = 'updated_at';
                    _sortDescending = true;
                  });
                },
                child: const Text('Reset'),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // Types
          Text(
            'Item Types',
            style: AppTypography.titleMedium(null, null, FontWeight.bold),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            children: [
              _buildTypeChip('Notes', 'note'),
              _buildTypeChip('Todos', 'todo'),
              _buildTypeChip('Reminders', 'reminder'),
            ],
          ),
          SizedBox(height: 24.h),

          // Date Range
          Text(
            'Date Range',
            style: AppTypography.titleMedium(null, null, FontWeight.bold),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildDateButton(
                  _startDate == null
                      ? 'From'
                      : DateFormat('MMM d, y').format(_startDate!),
                  () => _selectDate(true),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildDateButton(
                  _endDate == null
                      ? 'To'
                      : DateFormat('MMM d, y').format(_endDate!),
                  () => _selectDate(false),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // Sorting
          Text(
            'Sort By',
            style: AppTypography.titleMedium(null, null, FontWeight.bold),
          ),
          SizedBox(height: 12.h),
          DropdownButtonFormField<String>(
            value: _sortBy,
            decoration: InputDecoration(
              filled: true,
              fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
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
            onChanged: (val) => setState(() => _sortBy = val!),
          ),
          SizedBox(height: 12.h),
          SwitchListTile(
            title: Text(
              'Descending Order',
              style: AppTypography.bodyMedium(null),
            ),
            value: _sortDescending,
            onChanged: (val) => setState(() => _sortDescending = val),
            contentPadding: EdgeInsets.zero,
            activeColor: AppColors.primary,
          ),

          SizedBox(height: 32.h),
          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  SearchFilters(
                    types: _selectedTypes,
                    startDate: _startDate,
                    endDate: _endDate,
                    category: _selectedCategory,
                    sortBy: _sortBy,
                    sortDescending: _sortDescending,
                  ),
                );
              },
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
  }

  Widget _buildTypeChip(String label, String value) {
    final isSelected = _selectedTypes.contains(value);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedTypes.add(value);
          } else {
            _selectedTypes.remove(value);
          }
        });
      },
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(color: isSelected ? Colors.white : null),
      checkmarkColor: Colors.white,
    );
  }

  Widget _buildDateButton(String label, VoidCallback onTap) {
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

  Future<void> _selectDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }
}
