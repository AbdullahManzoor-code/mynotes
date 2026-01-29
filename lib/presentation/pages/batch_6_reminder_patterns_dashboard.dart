import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/presentation/bloc/smart_reminders_bloc.dart';
import 'package:mynotes/domain/services/ai_suggestion_engine.dart';

/// Reminder Patterns Dashboard - Batch 6, Screen 2
class ReminderPatternsDashboard extends StatefulWidget {
  const ReminderPatternsDashboard({Key? key}) : super(key: key);

  @override
  State<ReminderPatternsDashboard> createState() =>
      _ReminderPatternsDashboardState();
}

class _ReminderPatternsDashboardState extends State<ReminderPatternsDashboard> {
  final _aiEngine = AISuggestionEngine();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reminder Patterns'), centerTitle: true),
      body: BlocBuilder<SmartRemindersBloc, SmartRemindersState>(
        builder: (context, state) {
          if (state is! SmartRemindersLoaded) {
            return Center(child: CircularProgressIndicator());
          }

          return FutureBuilder<Map<String, dynamic>>(
            future: _aiEngine.getPersonalizedRecommendationStrength(
              reminderHistory: state.reminders,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final data = snapshot.data ?? {};

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Engagement Overview
                    _buildEngagementOverview(data),
                    const SizedBox(height: 24),

                    // Time Patterns
                    _buildTimePatternsSection(),
                    const SizedBox(height: 24),

                    // Frequency Analysis
                    _buildFrequencyAnalysis(data),
                    const SizedBox(height: 24),

                    // Trend Analysis
                    _buildTrendAnalysis(data),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEngagementOverview(Map<String, dynamic> data) {
    final strength = data['strength'] as String? ?? 'low';
    final score = data['score'] as int? ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Engagement Strength',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 8,
                  ),
                ),
                const SizedBox(width: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$score%',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      strength.toUpperCase(),
                      style: TextStyle(
                        color: _getStrengthColor(strength),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePatternsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Time Patterns',
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
                _buildPatternRow('Morning (5-12)', '12%'),
                _buildPatternRow('Afternoon (12-17)', '45%'),
                _buildPatternRow('Evening (17-21)', '35%'),
                _buildPatternRow('Night (21-5)', '8%'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPatternRow(String label, String percentage) {
    final percent = double.tryParse(percentage.replaceAll('%', '')) ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Text(percentage, style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: percent / 100, minHeight: 8),
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencyAnalysis(Map<String, dynamic> data) {
    final patterns = data['patterns'] as Map<String, dynamic>? ?? {};
    final avgPerDay = patterns['avgPerDay'] as double? ?? 0;
    final avgPerWeek = patterns['avgPerWeek'] as double? ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frequency Analysis',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text('Per Day'),
                      const SizedBox(height: 8),
                      Text(
                        avgPerDay.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text('Per Week'),
                      const SizedBox(height: 8),
                      Text(
                        avgPerWeek.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTrendAnalysis(Map<String, dynamic> data) {
    final patterns = data['patterns'] as Map<String, dynamic>? ?? {};
    final trend = patterns['trend'] as String? ?? 'stable';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activity Trend',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  trend == 'increasing'
                      ? Icons.trending_up
                      : Icons.trending_flat,
                  size: 32,
                  color: trend == 'increasing' ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trend == 'increasing'
                          ? 'Activity Increasing'
                          : 'Activity Stable',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      trend == 'increasing'
                          ? 'Your reminder activity is trending up'
                          : 'Your activity level is consistent',
                      style: Theme.of(context).textTheme.bodySmall,
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

  Color _getStrengthColor(String strength) {
    switch (strength.toLowerCase()) {
      case 'very_high':
        return Colors.green;
      case 'high':
        return Colors.lightGreen;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
