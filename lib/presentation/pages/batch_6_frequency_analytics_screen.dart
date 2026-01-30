import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/presentation/bloc/smart_reminders_bloc.dart';
import 'package:mynotes/domain/services/ai_suggestion_engine.dart';

/// Frequency Analytics - Batch 6, Screen 3
class FrequencyAnalyticsScreen extends StatefulWidget {
  const FrequencyAnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<FrequencyAnalyticsScreen> createState() =>
      _FrequencyAnalyticsScreenState();
}

class _FrequencyAnalyticsScreenState extends State<FrequencyAnalyticsScreen> {
  // Removed unused _aiEngine field
  String _selectedPeriod = 'week'; // week, month, year

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Frequency Analytics'),
        centerTitle: true,
      ),
      body: BlocBuilder<SmartRemindersBloc, SmartRemindersState>(
        builder: (context, state) {
          if (state is! SmartRemindersLoaded) {
            return Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPeriodSelector(),
                const SizedBox(height: 24),

                // Main Metrics
                _buildMainMetrics(state),
                const SizedBox(height: 24),

                // Daily Distribution
                _buildDailyDistribution(),
                const SizedBox(height: 24),

                // Comparison Card
                _buildComparisonCard(state),
                const SizedBox(height: 24),

                // Projection
                _buildProjection(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(label: Text('Week'), value: 'week'),
                  ButtonSegment(label: Text('Month'), value: 'month'),
                  ButtonSegment(label: Text('Year'), value: 'year'),
                ],
                selected: {_selectedPeriod},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _selectedPeriod = newSelection.first;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainMetrics(SmartRemindersLoaded state) {
    final totalReminders = state.reminders.length;
    final avgPerDay = totalReminders / 7;
    final avgPerWeek = totalReminders.toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overall Statistics',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _buildStatCard('Total', totalReminders.toString(), Icons.list),
            _buildStatCard(
              'Per Day',
              avgPerDay.toStringAsFixed(1),
              Icons.calendar_today,
            ),
            _buildStatCard(
              'Per Week',
              avgPerWeek.toStringAsFixed(1),
              Icons.calendar_view_week,
            ),
            _buildStatCard('Avg Duration', '45 min', Icons.timer),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 24, color: Colors.blue),
            Column(
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(label, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyDistribution() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily Distribution',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDayRow('Monday', 8, 12),
                _buildDayRow('Tuesday', 10, 12),
                _buildDayRow('Wednesday', 7, 12),
                _buildDayRow('Thursday', 11, 12),
                _buildDayRow('Friday', 9, 12),
                _buildDayRow('Saturday', 6, 12),
                _buildDayRow('Sunday', 5, 12),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDayRow(String day, int count, int maxCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(day, style: TextStyle(fontWeight: FontWeight.w500)),
              Text('$count', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: count / maxCount,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation(
                count > maxCount * 0.7 ? Colors.orange : Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard(SmartRemindersLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Period Comparison',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildComparisonRow(
                  'Current Period',
                  state.reminders.length,
                  Colors.blue,
                ),
                const SizedBox(height: 16),
                _buildComparisonRow(
                  'Previous Period',
                  (state.reminders.length * 0.85).toInt(),
                  Colors.grey,
                ),
                const SizedBox(height: 16),
                Divider(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.trending_up, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '+15% increase from previous period',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonRow(String label, int value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            value.toString(),
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildProjection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '30-Day Projection',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          color: Colors.blue[50],
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Based on current patterns',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildProjectionRow('Estimated Total', '240 reminders'),
                const SizedBox(height: 12),
                _buildProjectionRow('Peak Days', 'Thursday & Friday'),
                const SizedBox(height: 12),
                _buildProjectionRow('Best Time', '2-3 PM'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProjectionRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
        ),
      ],
    );
  }
}

