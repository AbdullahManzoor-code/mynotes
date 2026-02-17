import 'package:flutter/material.dart';
import 'package:mynotes/presentation/design_system/design_system.dart';
import 'package:mynotes/core/extensions/extensions.dart';

/// Notes list header component
/// Displays search bar, filters, and view options
class NotesListHeader extends StatefulWidget {
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onFilterTap;
  final VoidCallback? onViewOptionsTap;
  final ValueChanged<int>? onTabChanged;
  final int selectedTab;
  final bool showSearch;
  final String searchQuery;

  const NotesListHeader({
    super.key,
    this.onSearchChanged,
    this.onFilterTap,
    this.onViewOptionsTap,
    this.onTabChanged,
    this.selectedTab = 0,
    this.showSearch = true,
    this.searchQuery = '',
  });

  @override
  State<NotesListHeader> createState() => _NotesListHeaderState();
}

class _NotesListHeaderState extends State<NotesListHeader> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Search bar
        if (widget.showSearch) _buildSearchBar(context),
        // Filter and view options row
        _buildFilterRow(context),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      child: TextField(
        controller: _searchController,
        onChanged: widget.onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search notes...',
          prefixIcon: Icon(Icons.search, size: 20.r),
          suffixIcon: _searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    widget.onSearchChanged?.call('');
                  },
                  child: Icon(Icons.close, size: 20.r),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: context.theme.primaryColor.withOpacity(0.08),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
          hintStyle: AppTypography.body1(
            context,
          ).copyWith(fontSize: 14.sp, color: Colors.grey.shade400),
        ),
        style: AppTypography.body1(context).copyWith(fontSize: 14.sp),
      ),
    );
  }

  Widget _buildFilterRow(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
      child: Row(
        children: [
          // Filter button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onFilterTap,
              borderRadius: BorderRadius.circular(8.r),
              child: Padding(
                padding: EdgeInsets.all(8.w),
                child: Row(
                  children: [
                    Icon(Icons.tune, size: 18.r, color: context.primaryColor),
                    SizedBox(width: 4.w),
                    Text(
                      'Filter',
                      style: AppTypography.body2(
                        context,
                      ).copyWith(fontSize: 12.sp, color: context.primaryColor),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          // View options button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onViewOptionsTap,
              borderRadius: BorderRadius.circular(8.r),
              child: Padding(
                padding: EdgeInsets.all(8.w),
                child: Row(
                  children: [
                    Icon(
                      Icons.view_agenda,
                      size: 18.r,
                      color: context.primaryColor,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'View',
                      style: AppTypography.body2(
                        context,
                      ).copyWith(fontSize: 12.sp, color: context.primaryColor),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Spacer(),
          // Sort indicator
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: context.theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.sort, size: 16.r, color: context.primaryColor),
                SizedBox(width: 4.w),
                Text(
                  'Sorted',
                  style: AppTypography.caption(
                    context,
                  ).copyWith(fontSize: 11.sp, color: context.primaryColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
