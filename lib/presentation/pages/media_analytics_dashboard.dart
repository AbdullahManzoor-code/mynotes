import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../injection_container.dart';
import '../bloc/media/media_analytics/media_analytics_bloc.dart';
import '../../domain/repositories/media_repository.dart';
import '../design_system/app_colors.dart';
import '../design_system/app_typography.dart';
import '../../core/services/global_ui_service.dart';
import '../../core/services/app_logger.dart';

/// Media Analytics Dashboard - Batch 4, Screen 2
/// Refactored to StatelessWidget with BLoC and Design System
class MediaAnalyticsDashboard extends StatelessWidget {
  const MediaAnalyticsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MediaAnalyticsBloc(mediaRepository: getIt<MediaRepository>())
            ..add(LoadMediaAnalyticsEvent()),
      child: const _MediaAnalyticsDashboardView(),
    );
  }
}

class _MediaAnalyticsDashboardView extends StatelessWidget {
  const _MediaAnalyticsDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Media Analytics',
          style: AppTypography.displayMedium(context, AppColors.darkText),
        ),
        centerTitle: true,
        backgroundColor: AppColors.lightSurface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.darkText),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primaryColor),
            onPressed: () {
              AppLogger.i(
                'MediaAnalyticsDashboard: Refresh analytics triggered',
              );
              context.read<MediaAnalyticsBloc>().add(LoadMediaAnalyticsEvent());
              getIt<GlobalUiService>().hapticFeedback();
              getIt<GlobalUiService>().showSuccess('Analytics updated');
            },
          ),
        ],
      ),
      body: BlocBuilder<MediaAnalyticsBloc, MediaAnalyticsState>(
        builder: (context, state) {
          if (state is MediaAnalyticsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          }

          if (state is MediaAnalyticsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Oops! Something went wrong',
                      style: AppTypography.heading2(context),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: AppTypography.bodySmall(
                        context,
                        AppColors.secondaryText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        AppLogger.i(
                          'MediaAnalyticsDashboard: Retry analytics load',
                        );
                        context.read<MediaAnalyticsBloc>().add(
                          LoadMediaAnalyticsEvent(),
                        );
                      },
                      child: Text(
                        'Retry',
                        style: AppTypography.button(context, Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is MediaAnalyticsLoaded) {
            final analytics = state.analytics;
            return RefreshIndicator(
              onRefresh: () async {
                context.read<MediaAnalyticsBloc>().add(
                  LoadMediaAnalyticsEvent(),
                );
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Overall Stats
                    _buildOverallStatsCards(context, analytics),
                    const SizedBox(height: 24),

                    // Media Type Breakdown
                    _buildTypeBreakdownSection(context, analytics),
                    const SizedBox(height: 24),

                    // Storage Analysis
                    _buildStorageAnalysisSection(context, analytics),
                    const SizedBox(height: 24),

                    // Timeline Stats
                    _buildTimelineStatsSection(context, analytics),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildOverallStatsCards(
    BuildContext context,
    Map<String, dynamic> analytics,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overall Statistics',
          style: AppTypography.heading2(context, AppColors.darkText),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: [
            _buildStatCard(
              context,
              'Total Items',
              '${analytics['totalCount'] ?? 0}',
              Icons.perm_media_rounded,
              AppColors.accentBlue,
            ),
            _buildStatCard(
              context,
              'Total Size',
              _formatBytes(analytics['totalSize'] ?? 0),
              Icons.storage_rounded,
              AppColors.accentOrange,
            ),
            _buildStatCard(
              context,
              'Avg Size',
              _formatBytes(analytics['averageSize'] ?? 0),
              Icons.straighten_rounded,
              AppColors.accentGreen,
            ),
            _buildStatCard(
              context,
              'Items/Day',
              '${(analytics['averageItemsPerDay'] ?? 0).toStringAsFixed(1)}',
              Icons.insights_rounded,
              AppColors.accentPurple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTypography.heading1(context, AppColors.darkText),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.labelSmall(context, AppColors.secondaryText),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBreakdownSection(
    BuildContext context,
    Map<String, dynamic> analytics,
  ) {
    final typeBreakdown =
        analytics['typeBreakdown'] as Map<String, dynamic>? ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Media Type Distribution',
          style: AppTypography.heading2(context, AppColors.darkText),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.lightSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: typeBreakdown.length,
            separatorBuilder: (context, index) => const Divider(height: 24),
            itemBuilder: (context, index) {
              final type = typeBreakdown.keys.elementAt(index);
              final count = typeBreakdown[type] as int;
              final total = analytics['totalCount'] as int? ?? 1;
              final percentage = (count / total * 100).toStringAsFixed(1);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _getIconForType(type),
                            size: 18,
                            color: AppColors.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            type.toUpperCase(),
                            style: AppTypography.bodyMedium(
                              context,
                              AppColors.darkText,
                              FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '$count items ($percentage%)',
                        style: AppTypography.bodySmall(
                          context,
                          AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: count / total,
                      minHeight: 8,
                      backgroundColor: AppColors.lightBackground,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primaryColor,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStorageAnalysisSection(
    BuildContext context,
    Map<String, dynamic> analytics,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Storage Analysis',
          style: AppTypography.heading2(context, AppColors.darkText),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.lightSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.circle,
                  size: 12,
                  color: AppColors.accentBlue,
                ),
                title: Text(
                  'Total Storage',
                  style: AppTypography.bodyMedium(context),
                ),
                trailing: Text(
                  _formatBytes(analytics['totalSize'] ?? 0),
                  style: AppTypography.heading2(
                    context,
                    AppColors.primaryColor,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(),
              ),
              ListTile(
                leading: const Icon(
                  Icons.circle,
                  size: 12,
                  color: AppColors.accentGreen,
                ),
                title: Text(
                  'Average File Size',
                  style: AppTypography.bodyMedium(context),
                ),
                trailing: Text(
                  _formatBytes(analytics['averageSize'] ?? 0),
                  style: AppTypography.bodyMedium(
                    context,
                    AppColors.darkText,
                    FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineStatsSection(
    BuildContext context,
    Map<String, dynamic> analytics,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Timeline Insight',
          style: AppTypography.heading2(context, AppColors.darkText),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTimelineItem(
                context,
                'Oldest Entry',
                analytics['oldestItem']?.toString() ?? 'N/A',
                Icons.history_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTimelineItem(
                context,
                'Latest Entry',
                analytics['newestItem']?.toString() ?? 'N/A',
                Icons.fiber_new_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimelineItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryColor, size: 24),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTypography.labelSmall(context, AppColors.secondaryText),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle.split(' ')[0], // Only show date
            style: AppTypography.bodyMedium(
              context,
              AppColors.darkText,
              FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'image':
        return Icons.image_rounded;
      case 'video':
        return Icons.videocam_rounded;
      case 'audio':
        return Icons.audiotrack_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }
}
