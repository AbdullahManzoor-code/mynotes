import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/note_bloc.dart';
import '../bloc/note_state.dart';
import '../design_system/design_system.dart';

/// Analytics and Insights Dashboard
class AnalyticsDashboard extends StatefulWidget {
  const AnalyticsDashboard({Key? key}) : super(key: key);

  @override
  State<AnalyticsDashboard> createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends State<AnalyticsDashboard> {
  int _selectedPeriod = 7; // days

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
          _buildSummarySection(),
          SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
          _buildActivityChartSection(),
          _buildDistributionSection(),
          SliverToBoxAdapter(child: SizedBox(height: 120.h)),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      sliver: SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Insights',
                  style: AppTypography.displayLarge(
                    context,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Your productivity at a glance',
                  style: AppTypography.bodySmall(
                    context,
                  ).copyWith(color: AppColors.textSecondary(context)),
                ),
              ],
            ),
            PopupMenuButton<int>(
              icon: Icon(
                Icons.calendar_today,
                color: AppColors.textPrimary(context),
              ),
              initialValue: _selectedPeriod,
              onSelected: (value) => setState(() => _selectedPeriod = value),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 7, child: Text('Last 7 days')),
                const PopupMenuItem(value: 30, child: Text('Last 30 days')),
                const PopupMenuItem(value: 90, child: Text('Last 3 months')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection() {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      sliver: BlocBuilder<NotesBloc, NoteState>(
        builder: (context, state) {
          int totalNotes = 0;
          int todosCompleted = 0;
          int activeAlarms = 0;

          if (state is NoteLoading) {
            return const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (state is NoteError) {
            return SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.errorColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading analytics',
                      style: AppTypography.heading3(
                        context,
                        AppColors.textPrimary(context),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: AppTypography.bodyMedium(
                        context,
                        AppColors.textSecondary(context),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is NotesLoaded) {
            totalNotes = state.notes.length;
            for (var note in state.notes) {
              todosCompleted +=
                  (note.tags.contains('todo') &&
                      note.tags.contains('completed'))
                  ? 1
                  : 0;
              activeAlarms += note.alarms?.where((a) => a.isActive).length ?? 0;
            }
          }

          return SliverGrid.count(
            crossAxisCount: 3,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            children: [
              _buildStatCard(
                'Notes',
                totalNotes.toString(),
                Icons.edit_note,
                Colors.blue,
              ),
              _buildStatCard(
                'Tasks',
                todosCompleted.toString(),
                Icons.check_circle_outline,
                const Color(0xFF10B981),
              ),
              _buildStatCard(
                'Alarms',
                activeAlarms.toString(),
                Icons.alarm,
                Colors.orange,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return CardContainer(
      padding: EdgeInsets.all(AppSpacing.sm),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24.sp),
          SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.heading2(
              context,
              AppColors.textPrimary(context),
              FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: AppTypography.captionSmall(
              context,
            ).copyWith(color: AppColors.textSecondary(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityChartSection() {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ACTIVITY',
              style: AppTypography.captionSmall(context).copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: AppColors.textSecondary(context),
              ),
            ),
            SizedBox(height: AppSpacing.md),
            CardContainer(
              height: 200.h,
              padding: EdgeInsets.all(AppSpacing.md),
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 3),
                        FlSpot(1, 1),
                        FlSpot(2, 4),
                        FlSpot(3, 2),
                        FlSpot(4, 5),
                        FlSpot(5, 3),
                        FlSpot(6, 4),
                      ],
                      isCurved: true,
                      color: AppColors.primaryColor,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primaryColor.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistributionSection() {
    return SliverPadding(
      padding: EdgeInsets.all(AppSpacing.lg),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DISTRIBUTION',
              style: AppTypography.captionSmall(context).copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: AppColors.textSecondary(context),
              ),
            ),
            SizedBox(height: AppSpacing.md),
            CardContainer(
              height: 180.h,
              padding: EdgeInsets.all(AppSpacing.md),
              child: PieChart(
                PieChartData(
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(
                      color: Colors.blue,
                      value: 40,
                      showTitle: false,
                      radius: 25,
                    ),
                    PieChartSectionData(
                      color: const Color(0xFF10B981),
                      value: 30,
                      showTitle: false,
                      radius: 25,
                    ),
                    PieChartSectionData(
                      color: Colors.orange,
                      value: 15,
                      showTitle: false,
                      radius: 25,
                    ),
                    PieChartSectionData(
                      color: Colors.purple,
                      value: 15,
                      showTitle: false,
                      radius: 25,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
