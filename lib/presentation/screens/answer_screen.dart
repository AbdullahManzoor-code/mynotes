import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/reflection_question.dart';
import '../../injection_container.dart' show getIt;
import '../bloc/reflection_bloc.dart';
import '../bloc/reflection_event.dart';
import '../bloc/reflection_state.dart';
import '../design_system/design_system.dart';

class AnswerScreen extends StatefulWidget {
  final ReflectionQuestion question;

  const AnswerScreen({super.key, required this.question});

  @override
  State<AnswerScreen> createState() => _AnswerScreenState();
}

class _AnswerScreenState extends State<AnswerScreen> {
  late final TextEditingController _answerController;
  String? _selectedMood;
  final List<String> _moods = ['sad', 'neutral', 'good', 'happy', 'great'];
  final Map<String, IconData> _moodIcons = {
    'sad': Icons.sentiment_very_dissatisfied,
    'neutral': Icons.sentiment_neutral,
    'good': Icons.sentiment_satisfied,
    'happy': Icons.sentiment_satisfied_alt,
    'great': Icons.sentiment_very_satisfied,
  };
  final Map<String, Color> _moodColors = {
    'sad': Colors.blue,
    'neutral': Colors.grey,
    'good': Colors.lightGreen,
    'happy': Colors.green,
    'great': Colors.orange,
  };
  final Map<String, int> _moodValues = {
    'sad': 1,
    'neutral': 2,
    'good': 3,
    'happy': 4,
    'great': 5,
  };
  int _moodValue = 3;
  int _energyLevel = 3;
  int _sleepQuality = 3;
  final List<String> _selectedTags = [];
  bool _isPrivate = false;
  DateTime _reflectionDate = DateTime.now();

  final List<String> _availableTags = [
    'Work',
    'Health',
    'Social',
    'Family',
    'Study',
    'Hobbies',
    'Personal',
  ];

  @override
  void initState() {
    super.initState();
    _answerController = TextEditingController();
    _loadAnswers();
  }

  void _loadAnswers() {
    context.read<ReflectionBloc>().add(LoadDraftEvent(widget.question.id));
    context.read<ReflectionBloc>().add(LoadAnswersEvent(widget.question.id));
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
          getIt<GlobalUiService>().showSuccess(state.message);
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) Navigator.pop(context);
          });
        }
        if (state is ReflectionError) {
          getIt<GlobalUiService>().showError(state.message);
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

              // Date Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Reflection Date',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _reflectionDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() => _reflectionDate = picked);
                      }
                    },
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(_formatDate(_reflectionDate)),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Mood Selector
              Text(
                'How are you feeling?',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _moods
                    .map(
                      (mood) => _buildMoodButton(mood, _selectedMood == mood),
                    )
                    .toList(),
              ),
              SizedBox(height: 24.h),

              // Energy Level
              Text(
                'Energy Level (1-5)',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
              Slider(
                value: _energyLevel.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                label: _energyLevel.toString(),
                onChanged: (v) => setState(() => _energyLevel = v.toInt()),
              ),
              SizedBox(height: 16.h),

              // Sleep Quality
              Text(
                'Sleep Quality (1-5)',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
              Slider(
                value: _sleepQuality.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                label: _sleepQuality.toString(),
                onChanged: (v) => setState(() => _sleepQuality = v.toInt()),
              ),
              SizedBox(height: 16.h),

              // Activity Tags
              Text(
                'Activities',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                children: _availableTags.map((tag) {
                  final isSelected = _selectedTags.contains(tag);
                  return FilterChip(
                    label: Text(tag, style: TextStyle(fontSize: 12.sp)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedTags.add(tag);
                        } else {
                          _selectedTags.remove(tag);
                        }
                      });
                    },
                  );
                }).toList(),
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
                maxLines: 8,
                onChanged: (value) {
                  setState(() {}); // For character counter
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
                    borderSide: BorderSide(color: AppColors.noteBlue),
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
              SizedBox(height: 8.h),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Characters: ${_answerController.text.length}',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),
              ),
              SizedBox(height: 16.h),

              // Privacy Toggle
              SwitchListTile(
                title: Text(
                  'Make Reflection Private',
                  style: TextStyle(fontSize: 14.sp),
                ),
                subtitle: Text(
                  'Hidden from history carousel',
                  style: TextStyle(fontSize: 12.sp),
                ),
                value: _isPrivate,
                onChanged: (v) => setState(() => _isPrivate = v),
              ),
              SizedBox(height: 24.h),

              // Previous Answers Section
              BlocBuilder<ReflectionBloc, ReflectionState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (state.error != null) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Error loading previous responses: ${state.error}',
                        style: TextStyle(
                          color: AppColors.errorColor,
                          fontSize: 12.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  if (state.answers.isNotEmpty) {
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
                            ),
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
                      getIt<GlobalUiService>().showWarning(
                        'Please write your reflection before saving',
                      );
                      return;
                    }
                    context.read<ReflectionBloc>().add(
                      SubmitAnswerEvent(
                        questionId: widget.question.id,
                        answerText: _answerController.text.trim(),
                        mood: _selectedMood,
                        moodValue: _moodValue,
                        energyLevel: _energyLevel,
                        sleepQuality: _sleepQuality,
                        activityTags: _selectedTags,
                        isPrivate: _isPrivate,
                        reflectionDate: _reflectionDate,
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
          if (_selectedMood != null) {
            _moodValue = _moodValues[mood]!;
          }
        });
      },
      child: Column(
        children: [
          Icon(
            _moodIcons[mood],
            color: isSelected
                ? _moodColors[mood]
                : Colors.grey.withOpacity(0.5),
            size: 32.sp,
          ),
          SizedBox(height: 4.h),
          Text(
            mood,
            style: TextStyle(
              fontSize: 10.sp,
              color: isSelected ? _moodColors[mood] : Colors.grey,
            ),
          ),
        ],
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
        border: Border.all(color: AppColors.noteBlue, width: 1),
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
