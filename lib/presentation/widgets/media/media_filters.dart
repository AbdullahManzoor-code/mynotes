import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mynotes/core/extensions/context_extensions.dart';
import 'package:mynotes/core/services/app_logger.dart';
import 'package:mynotes/presentation/design_system/design_system.dart';

/// ════════════════════════════════════════════════════════════════════════════
/// PHASE 4: MEDIA & ATTACHMENTS
/// Media Filters - Search, filter, and sort controls
/// ════════════════════════════════════════════════════════════════════════════

class MediaFilters extends StatefulWidget {
  final String searchQuery;
  final String
  selectedType; // 'all', 'image', 'video', 'audio', 'document', 'pdf'
  final String sortBy; // 'date', 'size', 'name'
  final int totalCount;
  final Function(String)? onSearchChanged;
  final Function(String)? onTypeSelected;
  final Function(String)? onSortChanged;
  final Function()? onFiltersTap;

  const MediaFilters({
    super.key,
    this.searchQuery = '',
    this.selectedType = 'all',
    this.sortBy = 'date',
    this.totalCount = 0,
    this.onSearchChanged,
    this.onTypeSelected,
    this.onSortChanged,
    this.onFiltersTap,
  });

  @override
  State<MediaFilters> createState() => _MediaFiltersState();
}

class _MediaFiltersState extends State<MediaFilters> {
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        border: Border(
          bottom: BorderSide(color: context.theme.dividerColor, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            onChanged: widget.onSearchChanged,
            style: AppTypography.body2(context).copyWith(fontSize: 14.sp),
            decoration: InputDecoration(
              hintText: 'Search media...',
              hintStyle: AppTypography.body2(
                context,
              ).copyWith(fontSize: 14.sp, color: context.theme.disabledColor),
              prefixIcon: Icon(Icons.search, size: 18.r),
              suffixIcon: _searchController.text.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        widget.onSearchChanged?.call('');
                      },
                      child: Icon(Icons.clear, size: 18.r),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(
                  color: context.theme.dividerColor,
                  width: 0.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(
                  color: context.theme.dividerColor,
                  width: 0.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(
                  color: context.theme.primaryColor,
                  width: 1,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 10.h),
            ),
          ),
          SizedBox(height: 12.h),
          // Filter and sort buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Type filter button
              Expanded(
                child: PopupMenuButton<String>(
                  onSelected: (value) {
                    AppLogger.i('Media type filter changed: $value');
                    widget.onTypeSelected?.call(value);
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'all',
                      child: Text('All Media'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'image',
                      child: Text('Images'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'video',
                      child: Text('Videos'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'audio',
                      child: Text('Audio'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'document',
                      child: Text('Documents'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'pdf',
                      child: Text('PDFs'),
                    ),
                  ],
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: context.theme.dividerColor,
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.filter_list, size: 16.r),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            _getTypeLabel(widget.selectedType),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.body2(
                              context,
                            ).copyWith(fontSize: 12.sp),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              // Sort button
              Expanded(
                child: PopupMenuButton<String>(
                  onSelected: (value) {
                    AppLogger.i('Media sort changed: $value');
                    widget.onSortChanged?.call(value);
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'date',
                      child: Text('Newest First'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'date_old',
                      child: Text('Oldest First'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'size',
                      child: Text('Size (Large)'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'size_small',
                      child: Text('Size (Small)'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'name',
                      child: Text('Name (A-Z)'),
                    ),
                  ],
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: context.theme.dividerColor,
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.sort, size: 16.r),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            _getSortLabel(widget.sortBy),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.body2(
                              context,
                            ).copyWith(fontSize: 12.sp),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              // Media count badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '${widget.totalCount}',
                  style: AppTypography.body2(context).copyWith(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Get type label
  String _getTypeLabel(String type) {
    switch (type) {
      case 'all':
        return 'All';
      case 'image':
        return 'Images';
      case 'video':
        return 'Videos';
      case 'audio':
        return 'Audio';
      case 'document':
        return 'Documents';
      case 'pdf':
        return 'PDFs';
      default:
        return 'All';
    }
  }

  /// Get sort label
  String _getSortLabel(String sort) {
    switch (sort) {
      case 'date':
        return 'Newest';
      case 'date_old':
        return 'Oldest';
      case 'size':
        return 'Large';
      case 'size_small':
        return 'Small';
      case 'name':
        return 'Name';
      default:
        return 'Newest';
    }
  }
}
