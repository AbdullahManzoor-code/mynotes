import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/reflection_question.dart';
import '../bloc/reflection_bloc.dart';
import '../bloc/reflection_event.dart';
import '../bloc/reflection_state.dart';

class AnswerScreen extends StatefulWidget {
  final ReflectionQuestion question;

  const AnswerScreen({Key? key, required this.question}) : super(key: key);

  @override
  State<AnswerScreen> createState() => _AnswerScreenState();
}

class _AnswerScreenState extends State<AnswerScreen> {
  late final TextEditingController _answerController;
  String? _selectedMood;
  final List<String> _moods = [
    'happy',
    'sad',
    'neutral',
    'stressed',
    'calm',
    'grateful',
    'anxious',
  ];
  final Map<String, IconData> _moodIcons = {
    'happy': Icons.sentiment_very_satisfied,
    'sad': Icons.sentiment_very_dissatisfied,
    'neutral': Icons.sentiment_neutral,
    'stressed': Icons.sentiment_very_dissatisfied,
    'calm': Icons.auto_awesome,
    'grateful': Icons.favorite,
    'anxious': Icons.sentiment_satisfied,
  };
  final Map<String, Color> _moodColors = {
    'happy': Colors.yellow,
    'sad': Colors.blue,
    'neutral': Colors.grey,
    'stressed': Colors.red,
    'calm': Colors.green,
    'grateful': Colors.pink,
    'anxious': Colors.orange,
  };

  @override
  void initState() {
    super.initState();
    _answerController = TextEditingController();
    _loadDraft();
  }

  void _loadDraft() {
    context.read<ReflectionBloc>().add(LoadDraftEvent(widget.question.id));
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<ReflectionBloc, ReflectionState>(
      listener: (context, state) {
        if (state is DraftLoaded && state.draftText != null) {
          _answerController.text = state.draftText!;
        }
        if (state is AnswerSaved) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) Navigator.pop(context);
          });
        }
        if (state is ReflectionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Your Reflection',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
          ),
          elevation: 0,
          backgroundColor: isDark
              ? AppColors.darkBackground
              : AppColors.lightBackground,
          foregroundColor: isDark ? AppColors.lightText : AppColors.darkText,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question Display
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  widget.question.questionText,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              // Mood Selector
              Text(
                'How are you feeling?',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12.h),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _moods
                      .map(
                        (mood) => Padding(
                          padding: EdgeInsets.only(right: 12.w),
                          child: _buildMoodButton(mood, _selectedMood == mood),
                        ),
                      )
                      .toList(),
                ),
              ),
              SizedBox(height: 24.h),

              // Answer Text Field
              Text(
                'Your Reflection',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: _answerController,
                maxLines: 10,
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    context.read<ReflectionBloc>().add(
                      SaveDraftEvent(
                        questionId: widget.question.id,
                        draftText: value,
                      ),
                    );
                  }
                },
                style: TextStyle(fontSize: 14.sp),
                decoration: InputDecoration(
                  hintText: 'Write your reflection here...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.outlineColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: AppColors.primaryColor,
                      width: 2,
                    ),
                  ),
                  contentPadding: EdgeInsets.all(16.w),
                ),
              ),
              SizedBox(height: 24.h),

              // Previous Answers Section
              BlocBuilder<ReflectionBloc, ReflectionState>(
                builder: (context, state) {
                  if (state is AnswersLoaded && state.answers.isNotEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Previous Responses',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        ...state.answers
                            .where((a) => a.draft == null)
                            .take(3)
                            .map(
                              (answer) => _buildPreviousAnswer(
                                isDark,
                                answer.answerText,
                                answer.mood,
                                answer.createdAt,
                              ),
                            )
                            .toList(),
                        if (state.answers.length > 3)
                          Padding(
                            padding: EdgeInsets.only(top: 12.h),
                            child: Text(
                              '+${state.answers.length - 3} more responses',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        SizedBox(height: 24.h),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_answerController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please write your reflection before saving',
                          ),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }
                    context.read<ReflectionBloc>().add(
                      SubmitAnswerEvent(
                        questionId: widget.question.id,
                        answerText: _answerController.text.trim(),
                        mood: _selectedMood,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'Save Reflection',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodButton(String mood, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMood = isSelected ? null : mood;
        });
      },
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isSelected
              ? _moodColors[mood]!.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected
                ? _moodColors[mood]!
                : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(_moodIcons[mood], color: _moodColors[mood], size: 24.sp),
            SizedBox(height: 4.h),
            Text(
              mood,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
                color: _moodColors[mood],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviousAnswer(
    bool isDark,
    String text,
    String? mood,
    DateTime date,
  ) {
    return Container(
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
              if (mood != null) ...[
                Icon(_moodIcons[mood], color: _moodColors[mood], size: 16.sp),
                SizedBox(width: 8.w),
              ],
              Expanded(
                child: Text(
                  _formatDate(date),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12.sp),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (dateOnly == yesterday) {
      return 'Yesterday at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}

