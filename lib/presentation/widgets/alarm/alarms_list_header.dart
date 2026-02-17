import 'package:flutter/material.dart';
import 'package:mynotes/core/extensions/context_extensions.dart';
import 'package:mynotes/presentation/design_system/design_system.dart';

/// Reusable alarms list header component with search, filter, sort buttons
class AlarmsListHeader extends StatefulWidget {
  final String searchQuery;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onFilterTap;
  final VoidCallback? onViewOptionsTap;
  final int activeCount;

  const AlarmsListHeader({
    super.key,
    this.searchQuery = '',
    this.onSearchChanged,
    this.onFilterTap,
    this.onViewOptionsTap,
    this.activeCount = 0,
  });

  @override
  State<AlarmsListHeader> createState() => _AlarmsListHeaderState();
}

class _AlarmsListHeaderState extends State<AlarmsListHeader> {
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
      child: Column(
        children: [
          // Search bar
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    color:
                        context.theme.inputDecorationTheme.fillColor ??
                        context.theme.disabledColor.withOpacity(0.08),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: widget.onSearchChanged,
                    style: AppTypography.body2(
                      context,
                    ).copyWith(fontSize: 14.sp),
                    decoration: InputDecoration(
                      hintText: 'Search alarms...',
                      hintStyle: AppTypography.body2(context).copyWith(
                        fontSize: 14.sp,
                        color: context.theme.disabledColor.withOpacity(0.5),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        size: 20.r,
                        color: context.theme.disabledColor,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? InkWell(
                              onTap: () {
                                _searchController.clear();
                                widget.onSearchChanged?.call('');
                              },
                              child: Icon(
                                Icons.close,
                                size: 18.r,
                                color: context.theme.disabledColor,
                              ),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 10.h,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              // Filter button
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: context.theme.dividerColor,
                    width: 1,
                  ),
                  color: context.theme.cardColor,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onFilterTap,
                    borderRadius: BorderRadius.circular(8.r),
                    child: Padding(
                      padding: EdgeInsets.all(10.w),
                      child: Icon(
                        Icons.filter_list,
                        size: 20.r,
                        color: context.primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              // Sort button
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: context.theme.dividerColor,
                    width: 1,
                  ),
                  color: context.theme.cardColor,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onViewOptionsTap,
                    borderRadius: BorderRadius.circular(8.r),
                    child: Padding(
                      padding: EdgeInsets.all(10.w),
                      child: Icon(
                        Icons.sort,
                        size: 20.r,
                        color: context.primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          // Status indicator
          Row(
            children: [
              Icon(Icons.schedule, size: 14.r, color: context.primaryColor),
              SizedBox(width: 4.w),
              Text(
                '${widget.activeCount} active ${widget.activeCount == 1 ? 'alarm' : 'alarms'}',
                style: AppTypography.caption(context).copyWith(
                  fontSize: 11.sp,
                  color: context.theme.disabledColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
