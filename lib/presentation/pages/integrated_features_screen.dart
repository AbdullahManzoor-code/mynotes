import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/media_gallery_widget.dart';
import '../widgets/drawing_canvas_widget.dart';
import '../widgets/collection_manager_widget.dart';
import '../widgets/kanban_board_widget.dart';
import '../design_system/design_system.dart';
import '../../core/routes/app_routes.dart';
import '../../core/design_system/app_typography.dart'; // Added

/// Integrated Features Screen - Display all advanced features
/// Includes: Media Gallery, Drawing Canvas, Collections, Kanban Board
class IntegratedFeaturesScreen extends StatefulWidget {
  const IntegratedFeaturesScreen({super.key});

  @override
  State<IntegratedFeaturesScreen> createState() =>
      _IntegratedFeaturesScreenState();
}

class _IntegratedFeaturesScreenState extends State<IntegratedFeaturesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Advanced Features',
          style: AppTypography.heading3().copyWith(
            color: isDark ? AppColors.lightText : AppColors.darkText,
          ),
        ),
        backgroundColor: isDark
            ? AppColors.darkSurface
            : AppColors.lightSurface,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.h),
          child: TabBar(
            controller: _tabController,
            isScrollable: true, // Made scrollable for smaller screens
            tabs: [
              _buildTab('Media', Icons.image),
              _buildTab('Draw', Icons.brush),
              _buildTab('Collections', Icons.folder),
              _buildTab('Kanban', Icons.list_alt),
              _buildTab('AI & Insights', Icons.auto_awesome),
            ],
            indicator: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.primary, width: 3.h),
              ),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.getSecondaryTextColor(
              Theme.of(context).brightness,
            ),
            labelStyle: AppTypography.body2().copyWith(
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: AppTypography.body2(),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Media Gallery
          _buildMediaGalleryTab(),

          // Tab 2: Drawing Canvas
          _buildDrawingCanvasTab(),

          // Tab 3: Collections Manager
          _buildCollectionsTab(),

          // Tab 4: Kanban Board
          _buildKanbanBoardTab(),

          // Tab 5: AI & Insights
          _buildAIInsightsTab(),
        ],
      ),
    );
  }

  Widget _buildTab(String label, IconData icon) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18.sp),
          SizedBox(width: 6.w),
          Text(label),
        ],
      ),
    );
  }

  // ==================== Tab 1: Media Gallery ====================
  Widget _buildMediaGalleryTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTabHeader(
              'Media Gallery',
              'Browse, filter, and organize your media files',
              Icons.image_outlined,
            ),
            SizedBox(height: 16.h),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.getSecondaryTextColor(
                    Theme.of(context).brightness,
                  ).withOpacity(0.3),
                ),
              ),
              height: 400.h,
              child: MediaGalleryWidget(
                onMediaSelected: (mediaItems) {
                  _showSnackBar('Selected ${mediaItems.length} media item(s)');
                },
                multiSelect: true,
              ),
            ),
            SizedBox(height: 16.h),
            _buildFeatureList([
              'Filter by type (Images, Videos, Audio, Documents)',
              'Real-time search functionality',
              'Multi-select capability',
              'Responsive grid layout',
              'Empty state handling',
            ]),
          ],
        ),
      ),
    );
  }

  // ==================== Tab 2: Drawing Canvas ====================
  Widget _buildDrawingCanvasTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTabHeader(
              'Drawing Canvas',
              'Create sketches and annotations with ease',
              Icons.brush_outlined,
            ),
            SizedBox(height: 16.h),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.getSecondaryTextColor(
                    Theme.of(context).brightness,
                  ).withOpacity(0.3),
                ),
              ),
              height: 400.h,
              child: DrawingCanvasWidget(
                onDrawingComplete: (image) {
                  _showSnackBar('Drawing saved successfully!');
                },
              ),
            ),
            SizedBox(height: 16.h),
            _buildFeatureList([
              '8-color palette for drawing',
              '5 adjustable brush sizes',
              'Eraser tool with visual feedback',
              'Undo/redo functionality',
              'Clear canvas with confirmation',
              'Export as ui.Image',
            ]),
          ],
        ),
      ),
    );
  }

  // ==================== Tab 3: Collections Manager ====================
  Widget _buildCollectionsTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTabHeader(
              'Collections Manager',
              'Organize notes into collections',
              Icons.folder_outlined,
            ),
            SizedBox(height: 16.h),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.getSecondaryTextColor(
                    Theme.of(context).brightness,
                  ).withOpacity(0.3),
                ),
              ),
              height: 400.h,
              child: CollectionManagerWidget(
                onCollectionSelected: (collection) {
                  _showSnackBar('Collection: ${collection.name}');
                },
                onCollectionCreated: (collection) {
                  _showSnackBar('Created: ${collection.name}');
                },
              ),
            ),
            SizedBox(height: 16.h),
            _buildFeatureList([
              'Create/Read/Update/Delete collections',
              'Color-coded organization (8 colors)',
              'Item count tracking',
              'Edit collections with dialogs',
              'Delete with confirmation',
              'Hierarchical folder structure',
            ]),
          ],
        ),
      ),
    );
  }

  // ==================== Tab 4: Kanban Board ====================
  Widget _buildKanbanBoardTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTabHeader(
              'Kanban Board',
              '4-column task management with drag-drop',
              Icons.list_alt_outlined,
            ),
            SizedBox(height: 16.h),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.getSecondaryTextColor(
                    Theme.of(context).brightness,
                  ).withOpacity(0.3),
                ),
              ),
              height: 500.h,
              child: const KanbanBoardWidget(),
            ),
            SizedBox(height: 16.h),
            _buildFeatureList([
              '4-column layout (To Do, In Progress, In Review, Done)',
              'Drag-and-drop between columns',
              'Priority-based color coding',
              'Task count per column',
              'Smart date formatting',
              'TodoBloc integration',
            ]),
          ],
        ),
      ),
    );
  }

  // ==================== Tab 5: AI & Insights ====================
  Widget _buildAIInsightsTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTabHeader(
              'AI & Smart Insights',
              'Advanced AI-driven tools for your productivity',
              Icons.auto_awesome_outlined,
            ),
            SizedBox(height: 16.h),
            _buildHubCard(
              title: 'Reflection & Gratitude',
              subtitle: 'Daily prompts for mindfulness',
              icon: Icons.self_improvement,
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.reflectionHome),
            ),
            SizedBox(height: 12.h),
            _buildHubCard(
              title: 'Smart Recommendations',
              subtitle: 'AI-generated tips for your reminders',
              icon: Icons.lightbulb_outline,
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.suggestionRecommendations,
              ),
            ),
            SizedBox(height: 12.h),
            _buildHubCard(
              title: 'Reminder Patterns',
              subtitle: 'Analyze your habits and frequency',
              icon: Icons.api_outlined,
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.reminderPatterns),
            ),
            SizedBox(height: 12.h),
            _buildHubCard(
              title: 'Advanced Search',
              subtitle: 'Precision search with operators',
              icon: Icons.manage_search,
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.advancedSearch),
            ),
            SizedBox(height: 12.h),
            _buildHubCard(
              title: 'Template Gallery',
              subtitle: 'Quick-start your notes with templates',
              icon: Icons.auto_stories,
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.templateGallery),
            ),
            SizedBox(height: 24.h),
            _buildFeatureList([
              'Dynamic suggestions based on usage',
              'Deep pattern analysis for better habit tracking',
              'Full-text search with Boolean operators',
              'Pre-built templates for common tasks',
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildHubCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 24.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.body1().copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.lightText : AppColors.darkText,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: AppTypography.body2().copyWith(
                      color: isDark
                          ? AppColors.lightTextSecondary
                          : AppColors.darkTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textTertiary(context)),
          ],
        ),
      ),
    );
  }

  // ==================== Helper Widgets ====================

  Widget _buildTabHeader(String title, String subtitle, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.heading4().copyWith(
                      color: isDark ? AppColors.lightText : AppColors.darkText,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: AppTypography.body2().copyWith(
                      color: isDark
                          ? AppColors.lightTextSecondary
                          : AppColors.darkTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureList(List<String> features) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Features',
            style: AppTypography.body1().copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.lightText : AppColors.darkText,
            ),
          ),
          SizedBox(height: 8.h),
          ...features.map((feature) {
            return Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '✓',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.successGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      feature,
                      style: AppTypography.body2().copyWith(
                        color: isDark
                            ? AppColors.lightTextSecondary
                            : AppColors.darkTextSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
