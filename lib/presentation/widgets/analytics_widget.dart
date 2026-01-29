import 'package:flutter/material.dart';

/// Mood analytics data (HIS-003)
class MoodAnalytics {
  final Map<String, int> moodCounts; // mood -> count
  final Map<DateTime, String> dailyMoods; // date -> mood
  final double averageMood; // 1-5 scale
  final String mostFrequentMood;
  final int totalEntries;

  MoodAnalytics({
    required this.moodCounts,
    required this.dailyMoods,
    required this.averageMood,
    required this.mostFrequentMood,
    required this.totalEntries,
  });
}

/// Mood analytics widget
class MoodAnalyticsWidget extends StatelessWidget {
  final MoodAnalytics analytics;

  const MoodAnalyticsWidget({Key? key, required this.analytics})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mood Analytics',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            // Average mood
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Average Mood',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      Text(
                        '${analytics.averageMood.toStringAsFixed(1)}/5.0',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  Text(
                    _getMoodEmoji(analytics.averageMood.toInt()),
                    style: TextStyle(fontSize: 48),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            // Most frequent mood
            Text(
              'Most Frequent: ${analytics.mostFrequentMood}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 8),
            // Mood distribution
            ..._buildMoodDistribution(context),
            SizedBox(height: 16),
            // Total entries
            Text(
              'Total Entries: ${analytics.totalEntries}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMoodDistribution(BuildContext context) {
    return analytics.moodCounts.entries.map((entry) {
      final percentage = analytics.totalEntries > 0
          ? (entry.value / analytics.totalEntries)
          : 0;
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: Text(
                entry.key,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(value: percentage.toDouble(), minHeight: 6),
              ),
            ),
            SizedBox(width: 8),
            SizedBox(
              width: 30,
              child: Text(
                '${(percentage * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  String _getMoodEmoji(int mood) {
    switch (mood) {
      case 1:
        return '😢';
      case 2:
        return '😔';
      case 3:
        return '😐';
      case 4:
        return '🙂';
      case 5:
        return '😄';
      default:
        return '😐';
    }
  }
}

/// Notes statistics (ANL-001)
class NotesStatistics {
  final int totalNotes;
  final int archivedNotes;
  final int notesWithAttachments;
  final int totalWords;
  final double averageNoteLength;
  final DateTime lastNoteDate;

  NotesStatistics({
    required this.totalNotes,
    required this.archivedNotes,
    required this.notesWithAttachments,
    required this.totalWords,
    required this.averageNoteLength,
    required this.lastNoteDate,
  });
}

/// Notes statistics widget
class NotesStatsWidget extends StatelessWidget {
  final NotesStatistics stats;

  const NotesStatsWidget({Key? key, required this.stats}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notes Statistics',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildStatRow(
              context,
              'Total Notes',
              '${stats.totalNotes}',
              Icons.note,
            ),
            _buildStatRow(
              context,
              'Archived',
              '${stats.archivedNotes}',
              Icons.archive,
            ),
            _buildStatRow(
              context,
              'With Attachments',
              '${stats.notesWithAttachments}',
              Icons.attach_file,
            ),
            _buildStatRow(
              context,
              'Total Words',
              '${stats.totalWords}',
              Icons.text_fields,
            ),
            _buildStatRow(
              context,
              'Avg. Length',
              '${stats.averageNoteLength.toStringAsFixed(0)} words',
              Icons.analytics,
            ),
            SizedBox(height: 12),
            Text(
              'Last note: ${_formatDate(stats.lastNoteDate)}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey),
              SizedBox(width: 12),
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// Productivity statistics (ANL-002)
class ProductivityStatistics {
  final int totalTodosCompleted;
  final int totalTodosCreated;
  final double completionRate;
  final int consecutiveDaysActive;
  final Duration averageTaskDuration;
  final int tasksCompletedThisWeek;

  ProductivityStatistics({
    required this.totalTodosCompleted,
    required this.totalTodosCreated,
    required this.completionRate,
    required this.consecutiveDaysActive,
    required this.averageTaskDuration,
    required this.tasksCompletedThisWeek,
  });
}

/// Productivity statistics widget
class ProductivityStatsWidget extends StatelessWidget {
  final ProductivityStatistics stats;

  const ProductivityStatsWidget({Key? key, required this.stats})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Productivity Statistics',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            // Completion rate gauge
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Completion Rate',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      Text(
                        '${(stats.completionRate * 100).toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: stats.completionRate,
                      strokeWidth: 6,
                      valueColor: AlwaysStoppedAnimation(Colors.green),
                      backgroundColor: Colors.grey.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            // Stats rows
            _buildStatRow(
              context,
              'Completed',
              '${stats.totalTodosCompleted}/${stats.totalTodosCreated}',
              Icons.done_all,
            ),
            _buildStatRow(
              context,
              'This Week',
              '${stats.tasksCompletedThisWeek} tasks',
              Icons.calendar_today,
            ),
            _buildStatRow(
              context,
              'Streak',
              '${stats.consecutiveDaysActive} days',
              Icons.local_fire_department,
            ),
            _buildStatRow(
              context,
              'Avg. Duration',
              _formatDuration(stats.averageTaskDuration),
              Icons.schedule,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey),
              SizedBox(width: 12),
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    }
    return '${duration.inMinutes}m';
  }
}

/// Reflection statistics (ANL-003)
class ReflectionStatistics {
  final int totalAnswers;
  final int answersThisWeek;
  final List<String> topCategories;
  final int consecutiveReflectionDays;
  final Map<String, int> answersPerCategory;

  ReflectionStatistics({
    required this.totalAnswers,
    required this.answersThisWeek,
    required this.topCategories,
    required this.consecutiveReflectionDays,
    required this.answersPerCategory,
  });
}

/// Reflection statistics widget
class ReflectionStatsWidget extends StatelessWidget {
  final ReflectionStatistics stats;

  const ReflectionStatsWidget({Key? key, required this.stats})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reflection Statistics',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            // Total answers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Reflections',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    Text(
                      '${stats.totalAnswers}',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This Week',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    Text(
                      '${stats.answersThisWeek}',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Streak',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    Text(
                      '${stats.consecutiveReflectionDays} days',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            // Top categories
            Text(
              'Top Categories',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            SizedBox(height: 8),
            ...stats.answersPerCategory.entries.map((entry) {
              final percentage = stats.totalAnswers > 0
                  ? (entry.value / stats.totalAnswers) * 100
                  : 0;
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 70,
                      child: Text(
                        entry.key,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percentage / 100,
                          minHeight: 6,
                          backgroundColor: Colors.grey.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation(Colors.purple),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    SizedBox(
                      width: 35,
                      child: Text(
                        '${percentage.toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

/// Journal export service (HIS-004)
class JournalExporter {
  /// Export reflection answers to PDF
  static Future<String> exportToPDF(
    List<Map<String, dynamic>> answers,
    String journalTitle,
  ) async {
    // Implementation would use pdf package
    return 'journal_export.pdf';
  }

  /// Export to markdown
  static String exportToMarkdown(List<Map<String, dynamic>> answers) {
    final buffer = StringBuffer();
    buffer.writeln('# Journal Export\n');

    for (final answer in answers) {
      buffer.writeln('## ${answer['question']}');
      buffer.writeln('\n${answer['answer']}\n');
      buffer.writeln('*Date: ${answer['date']}*\n');
      buffer.writeln('---\n');
    }

    return buffer.toString();
  }
}
