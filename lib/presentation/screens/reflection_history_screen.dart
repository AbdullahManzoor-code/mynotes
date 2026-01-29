import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/reflection_answer.dart';
import '../bloc/reflection_bloc.dart';
import '../bloc/reflection_event.dart';
import '../bloc/reflection_state.dart';

class ReflectionHistoryScreen extends StatefulWidget {
  const ReflectionHistoryScreen({super.key});

  @override
  State<ReflectionHistoryScreen> createState() =>
      _ReflectionHistoryScreenState();
}

class _ReflectionHistoryScreenState extends State<ReflectionHistoryScreen> {
  String? _selectedMood;
  final List<String> _moods = [
    'All',
    'happy',
    'sad',
    'neutral',
    'stressed',
    'calm',
    'grateful',
    'anxious',
  ];

  @override
  void initState() {
    super.initState();
    context.read<ReflectionBloc>().add(const LoadAllAnswersEvent());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reflection History',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: isDark
            ? AppColors.darkBackground
            : AppColors.lightBackground,
        foregroundColor: isDark ? AppColors.lightText : AppColors.darkText,
      ),
      body: Column(
        children: [
          // Streak Tracker
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            margin: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkCardBackground
                  : AppColors.lightCardBackground,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColors.primaryColor.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStreakCard(
                  icon: Icons.local_fire_department,
                  label: 'Current Streak',
                  value: '7 days',
                  color: Colors.orange,
                ),
                _buildStreakCard(
                  icon: Icons.trending_up,
                  label: 'Longest Streak',
                  value: '14 days',
                  color: AppColors.primaryColor,
                ),
                _buildStreakCard(
                  icon: Icons.calendar_today,
                  label: 'Total Reflections',
                  value: '42',
                  color: Colors.green,
                ),
              ],
            ),
          ),
          // Mood Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              children: _moods
                  .map(
                    (mood) => Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: FilterChip(
                        label: Text(mood),
                        selected:
                            _selectedMood == (mood == 'All' ? null : mood),
                        onSelected: (selected) {
                          setState(() {
                            _selectedMood = selected
                                ? (mood == 'All' ? null : mood)
                                : null;
                          });
                        },
                        backgroundColor: isDark
                            ? AppColors.darkCardBackground
                            : AppColors.lightCardBackground,
                        selectedColor: AppColors.primaryColor.withOpacity(0.3),
                        side: BorderSide(color: AppColors.outlineColor),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          // History List
          Expanded(
            child: BlocBuilder<ReflectionBloc, ReflectionState>(
              builder: (context, state) {
                if (state is ReflectionLoading) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryColor,
                      ),
                    ),
                  );
                }

                if (state is ReflectionError) {
                  return Center(child: Text(state.message));
                }

                if (state is AllAnswersLoaded) {
                  var answers = state.answers
                      .where((a) => a.draft == null)
                      .toList();

                  // Filter by mood
                  if (_selectedMood != null) {
                    answers = answers
                        .where((a) => a.mood == _selectedMood)
                        .toList();
                  }

                  // Sort by date descending
                  answers.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                  if (answers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 48.sp,
                            color: isDark ? Colors.grey[600] : Colors.grey[400],
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'No reflections yet',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: answers.length,
                    itemBuilder: (context, index) {
                      final answer = answers[index];
                      final isDateChange =
                          index == 0 ||
                          !_isSameDay(
                            answers[index - 1].createdAt,
                            answer.createdAt,
                          );

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isDateChange) ...[
                            if (index != 0) SizedBox(height: 20.h),
                            Padding(
                              padding: EdgeInsets.only(bottom: 12.h, left: 8.w),
                              child: Text(
                                _formatDateHeader(answer.createdAt),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                          ],
                          _buildAnswerCard(isDark, answer),
                        ],
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerCard(bool isDark, ReflectionAnswer answer) {
    const moodIcons = {
      'happy': Icons.sentiment_very_satisfied,
      'sad': Icons.sentiment_very_dissatisfied,
      'neutral': Icons.sentiment_neutral,
      'stressed': Icons.sentiment_very_dissatisfied,
      'calm': Icons.auto_awesome,
      'grateful': Icons.favorite,
      'anxious': Icons.sentiment_satisfied,
    };
    const moodColors = {
      'happy': Colors.yellow,
      'sad': Colors.blue,
      'neutral': Colors.grey,
      'stressed': Colors.red,
      'calm': Colors.green,
      'grateful': Colors.pink,
      'anxious': Colors.orange,
    };

    return GestureDetector(
      onLongPress: () {
        _showAnswerOptions(context, isDark, answer);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkCardBackground
              : AppColors.lightCardBackground,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.outlineColor, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (answer.mood != null) ...[
                  Icon(
                    moodIcons[answer.mood],
                    color: moodColors[answer.mood],
                    size: 18.sp,
                  ),
                  SizedBox(width: 8.w),
                ],
                Text(
                  _formatTime(answer.createdAt),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              answer.answerText,
              style: TextStyle(fontSize: 13.sp),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showAnswerOptions(
    BuildContext context,
    bool isDark,
    ReflectionAnswer answer,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark
          ? AppColors.darkCardBackground
          : AppColors.lightCardBackground,
      builder: (context) => Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('View Full'),
              onTap: () {
                Navigator.pop(context);
                _showFullAnswerDialog(context, isDark, answer);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFullAnswerDialog(
    BuildContext context,
    bool isDark,
    ReflectionAnswer answer,
  ) {
    const moodIcons = {
      'happy': Icons.sentiment_very_satisfied,
      'sad': Icons.sentiment_very_dissatisfied,
      'neutral': Icons.sentiment_neutral,
      'stressed': Icons.sentiment_very_dissatisfied,
      'calm': Icons.auto_awesome,
      'grateful': Icons.favorite,
      'anxious': Icons.sentiment_satisfied,
    };
    const moodColors = {
      'happy': Colors.yellow,
      'sad': Colors.blue,
      'neutral': Colors.grey,
      'stressed': Colors.red,
      'calm': Colors.green,
      'grateful': Colors.pink,
      'anxious': Colors.orange,
    };

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark
            ? AppColors.darkCardBackground
            : AppColors.lightCardBackground,
        title: Row(
          children: [
            if (answer.mood != null) ...[
              Icon(moodIcons[answer.mood], color: moodColors[answer.mood]),
              SizedBox(width: 8.w),
            ],
            Expanded(
              child: Text(
                _formatDateHeader(answer.createdAt),
                style: TextStyle(fontSize: 14.sp),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(answer.answerText, style: TextStyle(fontSize: 13.sp)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else {
      return '${_getMonthName(date.month)} ${date.day}, ${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildStreakCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24.sp),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(fontSize: 10.sp, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
