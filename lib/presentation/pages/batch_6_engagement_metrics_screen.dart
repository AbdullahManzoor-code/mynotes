import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/presentation/bloc/smart_reminders_bloc.dart';
import 'package:mynotes/domain/services/ai_suggestion_engine.dart';

/// Engagement Metrics - Batch 6, Screen 4
class EngagementMetricsScreen extends StatefulWidget {
  const EngagementMetricsScreen({Key? key}) : super(key: key);

  @override
  State<EngagementMetricsScreen> createState() =>
      _EngagementMetricsScreenState();
}

class _EngagementMetricsScreenState extends State<EngagementMetricsScreen> {
  final _aiEngine = AISuggestionEngine();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Engagement Metrics'),
        centerTitle: true,
      ),
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
                    // Overall Engagement
                    _buildOverallEngagement(data),
                    const SizedBox(height: 24),

                    // Engagement Score Breakdown
                    _buildScoreBreakdown(data),
                    const SizedBox(height: 24),

                    // Activity Metrics
                    _buildActivityMetrics(state),
                    const SizedBox(height: 24),

                    // Recommendations
                    _buildRecommendations(data),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildOverallEngagement(Map<String, dynamic> data) {
    final score = data['score'] as int? ?? 0;
    final strength = data['strength'] as String? ?? 'low';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Overall Engagement',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 150,
                  height: 150,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation(
                      _getEngagementColor(score),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '$score%',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      strength.toUpperCase(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _getEngagementColor(score),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _getEngagementColor(score).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _getEngagementMessage(score),
                style: TextStyle(
                  color: _getEngagementColor(score),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBreakdown(Map<String, dynamic> data) {
    final patterns = data['patterns'] as Map<String, dynamic>? ?? {};
    final completionRate = patterns['completionRate'] as double? ?? 0;
    final responseTime = patterns['responseTime'] as double? ?? 0;
    final consistency = patterns['consistency'] as double? ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Score Breakdown',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildScoreItem(
          'Completion Rate',
          (completionRate * 100).toStringAsFixed(0),
          completionRate,
          Icons.check_circle,
        ),
        const SizedBox(height: 16),
        _buildScoreItem(
          'Response Time',
          (responseTime * 100).toStringAsFixed(0),
          responseTime,
          Icons.timer,
        ),
        const SizedBox(height: 16),
        _buildScoreItem(
          'Consistency',
          (consistency * 100).toStringAsFixed(0),
          consistency,
          Icons.trending_up,
        ),
      ],
    );
  }

  Widget _buildScoreItem(
    String label,
    String value,
    double percentage,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                Text(
                  '$value%',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: percentage, minHeight: 8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityMetrics(SmartRemindersLoaded state) {
    final totalReminders = state.reminders.length;
    final completedCount = (totalReminders * 0.85).toInt();
    final missedCount = totalReminders - completedCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activity Overview',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Card(
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(Icons.check, color: Colors.green, size: 32),
                      const SizedBox(height: 8),
                      Text('Completed', style: TextStyle(color: Colors.green)),
                      const SizedBox(height: 4),
                      Text(
                        completedCount.toString(),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Card(
                color: Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(Icons.close, color: Colors.red, size: 32),
                      const SizedBox(height: 8),
                      Text('Missed', style: TextStyle(color: Colors.red)),
                      const SizedBox(height: 4),
                      Text(
                        missedCount.toString(),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
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

  Widget _buildRecommendations(Map<String, dynamic> data) {
    final score = data['score'] as int? ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Improvement Suggestions',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ..._getRecommendations(score).map((rec) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb, color: Colors.amber),
                    const SizedBox(width: 12),
                    Expanded(child: Text(rec, style: TextStyle(height: 1.5))),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  List<String> _getRecommendations(int score) {
    if (score < 40) {
      return [
        'Set up reminders at times you are most active',
        'Create simple, achievable reminder goals',
        'Review completed reminders weekly to build momentum',
      ];
    } else if (score < 70) {
      return [
        'Increase reminder complexity gradually',
        'Set up recurring reminders for consistent habits',
        'Add collaborative reminders to boost engagement',
      ];
    } else {
      return [
        'Continue your current routine - it\'s working well',
        'Consider mentoring others or sharing best practices',
        'Explore advanced features like AI suggestions',
      ];
    }
  }

  Color _getEngagementColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  String _getEngagementMessage(int score) {
    if (score >= 80) return 'Excellent engagement! Keep it up.';
    if (score >= 60) return 'Good engagement. Room for improvement.';
    if (score >= 40) return 'Moderate engagement. Try building better habits.';
    return 'Low engagement. Start with simpler reminders.';
  }
}

