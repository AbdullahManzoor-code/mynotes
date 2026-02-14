import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mynotes/core/design_system/app_colors.dart';
import 'package:mynotes/core/design_system/app_typography.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/presentation/bloc/reminder_templates/reminder_templates_bloc.dart';

/// Reminder Templates Screen (ALM-004)
/// Pre-built reminder templates for quick reminder creation
class ReminderTemplatesScreen extends StatelessWidget {
  const ReminderTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<ReminderTemplatesBloc, ReminderTemplatesState>(
      builder: (context, state) {
        if (state is ReminderTemplatesInitial) {
          context.read<ReminderTemplatesBloc>().add(const LoadTemplatesEvent());
        }

        if (state is ReminderTemplatesLoading) {
          return Scaffold(
            backgroundColor: AppColors.background(context),
            appBar: _buildAppBar(context, {}),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is ReminderTemplatesError) {
          return Scaffold(
            backgroundColor: AppColors.background(context),
            appBar: _buildAppBar(context, {}),
            body: Center(
              child: Text(
                'Error: ${state.message}',
                style: AppTypography.body1(context),
              ),
            ),
          );
        }

        if (state is ReminderTemplatesLoaded) {
          return Scaffold(
            backgroundColor: AppColors.background(context),
            appBar: _buildAppBar(context, state.favoriteIds),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  _buildCategoryFilter(
                    state.categories,
                    state.selectedCategory,
                    context,
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available Templates',
                          style: AppTypography.heading3().copyWith(
                            color: isDark
                                ? AppColors.lightText
                                : AppColors.darkText,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 12.h,
                                crossAxisSpacing: 12.w,
                                childAspectRatio: 0.85,
                              ),
                          itemCount: state.templates.length,
                          itemBuilder: (context, index) {
                            return _buildTemplateCard(
                              state.templates[index],
                              state.favoriteIds.contains(
                                state.templates[index]['id'],
                              ),
                              context,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    Set<String> favorites,
  ) {
    // isDark removed

    return AppBar(
      backgroundColor: AppColors.surface(context),
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.textPrimary(context)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Reminder Templates',
        style: AppTypography.heading2().copyWith(
          color: AppColors.textPrimary(context),
        ),
      ),
      actions: [
        if (favorites.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Text(
                  '${favorites.length} saved',
                  style: AppTypography.caption().copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCategoryFilter(
    List<String> categories,
    String selectedCategory,
    BuildContext context,
  ) {
    // isDark removed

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.divider(context), width: 0.5),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((category) {
            final isSelected = selectedCategory == category;
            return Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: GestureDetector(
                onTap: () {
                  context.read<ReminderTemplatesBloc>().add(
                    FilterTemplatesByCategoryEvent(category: category),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryColor
                        : AppColors.surface(context),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryColor
                          : AppColors.divider(context),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    category,
                    style: AppTypography.body2().copyWith(
                      color: isSelected
                          ? Colors.white
                          : AppColors.textPrimary(context),
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTemplateCard(
    Map<String, dynamic> template,
    bool isFavorite,
    BuildContext context,
  ) {
    // isDark removed
    final categoryColor = _getCategoryColor(template['category']);
    final categoryIcon = _getCategoryIcon(template['category']);

    return GestureDetector(
      onTap: () => _showTemplateDetails(template, context),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.divider(context), width: 0.5),
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          categoryIcon,
                          color: categoryColor,
                          size: 20.sp,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              template['name'] as String,
                              style: AppTypography.body2().copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary(context),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              template['category'] as String,
                              style: AppTypography.caption().copyWith(
                                color: categoryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    template['description'] as String,
                    style: AppTypography.caption().copyWith(
                      color: AppColors.textSecondary(context),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 4.w,
                    children: [
                      _buildBadge(
                        Icons.access_time,
                        template['time'] as String,
                        context,
                      ),
                      _buildBadge(
                        Icons.repeat,
                        template['frequency'] as String,
                        context,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8.w,
              right: 8.w,
              child: GestureDetector(
                onTap: () {
                  context.read<ReminderTemplatesBloc>().add(
                    ToggleFavoriteTemplateEvent(templateId: template['id']),
                  );
                },
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite
                      ? Colors.red
                      : AppColors.textSecondary(context),
                  size: 20.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    // Attempt to get from AppColors categoryColors map
    final normalized = category.toLowerCase();
    if (AppColors.categoryColors.containsKey(normalized)) {
      return AppColors.categoryColors[normalized]!;
    }

    // Fallback if not found in map (though map covers most)
    switch (category) {
      case 'Work':
        return Colors.blue;
      case 'Personal':
        return Colors.orange;
      case 'Health':
        return Colors.green;
      default:
        return AppColors.accentPurple;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Work':
        return Icons.people;
      case 'Personal':
        return Icons.restaurant;
      case 'Health':
        return Icons.health_and_safety;
      default:
        return Icons.category;
    }
  }

  Widget _buildBadge(IconData icon, String label, BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColors.background(context),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10.sp, color: AppColors.textSecondary(context)),
          SizedBox(width: 2.w),
          Text(
            label,
            style: AppTypography.captionSmall(
              context,
            ).copyWith(fontSize: 9.sp, color: AppColors.textSecondary(context)),
          ),
        ],
      ),
    );
  }

  void _showTemplateDetails(
    Map<String, dynamic> template,
    BuildContext context,
  ) {
    final categoryColor = _getCategoryColor(template['category']);
    final categoryIcon = _getCategoryIcon(template['category']);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface(context),
      builder: (context) => Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(categoryIcon, color: categoryColor, size: 28.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template['name'] as String,
                        style: AppTypography.heading3().copyWith(
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      Text(
                        template['category'] as String,
                        style: AppTypography.body2().copyWith(
                          color: categoryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            _buildDetailRow(
              'Description',
              template['description'] as String,
              Icons.description,
              context,
            ),
            SizedBox(height: 12.h),
            _buildDetailRow(
              'Time',
              template['time'] as String,
              Icons.access_time,
              context,
            ),
            SizedBox(height: 12.h),
            _buildDetailRow(
              'Frequency',
              template['frequency'] as String,
              Icons.repeat,
              context,
            ),
            SizedBox(height: 12.h),
            _buildDetailRow(
              'Duration',
              template['duration'] as String,
              Icons.timer,
              context,
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Close'),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Created from template: ${template['name']}',
                          ),
                        ),
                      );
                      Navigator.pop(context);
                    },
                    child: Text('Use Template'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon,
    BuildContext context,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: AppColors.textSecondary(context)),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.caption().copyWith(
                  color: AppColors.textSecondary(context),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: AppTypography.body2().copyWith(
                  color: AppColors.textPrimary(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

