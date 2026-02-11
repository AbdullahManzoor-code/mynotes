import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../injection_container.dart';
import '../bloc/media_search_bloc.dart';
import '../../domain/repositories/media_repository.dart';
import '../design_system/app_colors.dart';
import '../design_system/app_typography.dart';
import '../design_system/app_spacing.dart';
import '../../core/services/global_ui_service.dart';

/// Media Search Results - Batch 4, Screen 4
/// Refactored to StatelessWidget with BLoC and Design System
class MediaSearchResultsScreen extends StatelessWidget {
  final String query;

  const MediaSearchResultsScreen({Key? key, required this.query})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MediaSearchBloc(mediaRepository: getIt<MediaRepository>())
            ..add(PerformMediaSearchEvent(query)),
      child: _MediaSearchResultsView(query: query),
    );
  }
}

class _MediaSearchResultsView extends StatelessWidget {
  final String query;

  const _MediaSearchResultsView({Key? key, required this.query})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Search Results',
          style: AppTypography.displayMedium(context, AppColors.darkText),
        ),
        centerTitle: true,
        backgroundColor: AppColors.lightSurface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.darkText),
      ),
      body: BlocBuilder<MediaSearchBloc, MediaSearchState>(
        builder: (context, state) {
          if (state is MediaSearchLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          }

          if (state is MediaSearchError) {
            return Center(
              child: Padding(
                padding: AppSpacing.paddingAllL,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48.sp,
                      color: Colors.orangeAccent,
                    ),
                    AppSpacing.gapM,
                    Text(
                      state.message,
                      style: AppTypography.bodyMedium(context),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is MediaSearchLoaded) {
            final results = state.results;

            if (results.isEmpty) {
              return Center(
                child: Padding(
                  padding: AppSpacing.paddingAllXL,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: AppSpacing.paddingAllL,
                        decoration: const BoxDecoration(
                          color: AppColors.primary10,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.search_off_outlined,
                          size: 64.sp,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      AppSpacing.gapL,
                      Text(
                        'No results found for "$query"',
                        style: AppTypography.heading1(context),
                        textAlign: TextAlign.center,
                      ),
                      AppSpacing.gapS,
                      Text(
                        'Try using different keywords or refine your search filters.',
                        style: AppTypography.bodyMedium(
                          context,
                          AppColors.secondaryText,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  color: AppColors.lightSurface,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${results.length} result${results.length != 1 ? 's' : ''} found',
                        style: AppTypography.bodySmall(
                          context,
                          AppColors.secondaryText,
                          FontWeight.w600,
                        ),
                      ),
                      _buildSortMenu(context),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: results.length,
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    itemBuilder: (context, index) {
                      final result = results[index];
                      return _buildResultCard(
                        context,
                        result.item,
                        result.score,
                        index + 1,
                      );
                    },
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSortMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.sort_rounded,
        color: AppColors.primaryColor,
        size: 24.sp,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      onSelected: (value) {
        getIt<GlobalUiService>().hapticFeedback();
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'relevance',
          child: Text('By Relevance', style: AppTypography.bodyMedium(context)),
        ),
        PopupMenuItem(
          value: 'date',
          child: Text('By Date', style: AppTypography.bodyMedium(context)),
        ),
        PopupMenuItem(
          value: 'size',
          child: Text('By Size', style: AppTypography.bodyMedium(context)),
        ),
      ],
    );
  }

  Widget _buildResultCard(
    BuildContext context,
    dynamic item,
    double score,
    int rank,
  ) {
    final relevancePercentage = (score * 10).clamp(0, 100).toInt();

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: const BorderSide(color: AppColors.borderLight),
      ),
      child: InkWell(
        onTap: () {
          // Action for card tap
        },
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: AppSpacing.paddingAllM,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryColor,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '#$rank',
                      style: AppTypography.button(context, Colors.white),
                    ),
                  ),
                  AppSpacing.gapM,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name ?? 'Unnamed',
                          style: AppTypography.heading2(
                            context,
                            AppColors.darkText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (item.description != null &&
                            item.description.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: 4.h),
                            child: Text(
                              item.description,
                              style: AppTypography.bodySmall(
                                context,
                                AppColors.secondaryText,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              AppSpacing.gapM,
              _buildRelevanceIndicator(context, relevancePercentage),
              AppSpacing.gapM,
              Row(
                children: [
                  if (item.type != null) ...[
                    _buildMetaChip(
                      context,
                      item.type.toString().toUpperCase(),
                      Icons.category_outlined,
                    ),
                    AppSpacing.gapS,
                  ],
                  if (item.createdAt != null)
                    Text(
                      _formatDate(item.createdAt.toString()),
                      style: AppTypography.bodySmall(
                        context,
                        AppColors.tertiaryText,
                      ),
                    ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.primaryColor,
                      size: 20.sp,
                    ),
                    onPressed: () => _showItemDetails(context, item),
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.open_in_new_rounded,
                      color: AppColors.primaryColor,
                      size: 20.sp,
                    ),
                    onPressed: () {},
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRelevanceIndicator(BuildContext context, int percentage) {
    return Row(
      children: [
        Icon(Icons.bolt_rounded, size: 18.sp, color: AppColors.accentYellow),
        AppSpacing.gapS,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Search Match',
                    style: AppTypography.labelSmall(
                      context,
                      AppColors.secondaryText,
                    ),
                  ),
                  Text(
                    '$percentage%',
                    style: AppTypography.labelSmall(
                      context,
                      AppColors.primaryColor,
                      FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  minHeight: 6.h,
                  backgroundColor: AppColors.primary10,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    percentage > 70
                        ? AppColors.successGreen
                        : AppColors.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetaChip(BuildContext context, String label, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: AppColors.secondaryText),
          AppSpacing.gapS,
          Text(
            label,
            style: AppTypography.labelSmall(
              context,
              AppColors.secondaryText,
              FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showItemDetails(BuildContext context, dynamic item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.lightSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: AppSpacing.paddingAllL,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Media Information',
                  style: AppTypography.heading1(context),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            AppSpacing.gapM,
            _buildDetailRow(context, 'Name', item.name ?? 'Unnamed'),
            if (item.type != null)
              _buildDetailRow(context, 'Type', item.type.toString()),
            if (item.size != null)
              _buildDetailRow(
                context,
                'Storage Size',
                _formatBytes(item.size as int),
              ),
            if (item.createdAt != null)
              _buildDetailRow(context, 'Created On', item.createdAt.toString()),
            AppSpacing.gapL,
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Close',
                  style: AppTypography.button(context, Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.labelSmall(context, AppColors.secondaryText),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: AppTypography.bodyMedium(
              context,
              AppColors.darkText,
              FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Unknown';
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
