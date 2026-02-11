import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/reflection_question.dart';
import '../bloc/reflection_bloc.dart';
import '../bloc/reflection_event.dart';
import '../bloc/reflection_state.dart';
import 'answer_screen.dart';

class QuestionListScreen extends StatefulWidget {
  final String category;
  final String categoryLabel;

  const QuestionListScreen({
    super.key,
    required this.category,
    required this.categoryLabel,
  });

  @override
  State<QuestionListScreen> createState() => _QuestionListScreenState();
}

class _QuestionListScreenState extends State<QuestionListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ReflectionBloc>().add(
      LoadQuestionsByCategoryEvent(widget.category),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.categoryLabel,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: isDark
            ? AppColors.darkBackground
            : AppColors.lightBackground,
        foregroundColor: isDark ? AppColors.lightText : AppColors.darkText,
      ),
      body: BlocBuilder<ReflectionBloc, ReflectionState>(
        builder: (context, state) {
          if (state.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryColor,
                ),
              ),
            );
          }

          if (state.error != null) {
            return Center(child: Text(state.error!));
          }

          if (state.questions.isNotEmpty || state.error == null) {
            if (state.questions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox,
                      size: 48.sp,
                      color: isDark ? Colors.grey[600] : Colors.grey[400],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'No questions yet',
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
              padding: EdgeInsets.all(20.w),
              itemCount: state.questions.length,
              itemBuilder: (context, index) {
                final question = state.questions[index];
                return _buildQuestionCard(
                  isDark,
                  question,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AnswerScreen(question: question),
                      ),
                    );
                  },
                  () {
                    _showQuestionOptions(context, isDark, question);
                  },
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildQuestionCard(
    bool isDark,
    ReflectionQuestion question,
    VoidCallback onTap,
    VoidCallback onMore,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkCardBackground
              : AppColors.lightCardBackground,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.outlineColor, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      if (question.isPinned)
                        Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: Icon(
                            Icons.push_pin,
                            size: 14.sp,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      Expanded(
                        child: Text(
                          question.questionText,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: question.isPinned
                                ? FontWeight.bold
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: onMore,
                  child: Icon(
                    Icons.more_vert,
                    size: 20.sp,
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    question.frequency,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
                if (question.isUserCreated) ...[
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      'Custom',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showQuestionOptions(
    BuildContext context,
    bool isDark,
    ReflectionQuestion question,
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
              leading: Icon(
                question.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
                color: AppColors.primaryColor,
              ),
              title: Text(question.isPinned ? 'Unpin' : 'Pin as Daily Prompt'),
              onTap: () {
                Navigator.pop(context);
                if (question.isPinned) {
                  context.read<ReflectionBloc>().add(
                    const UnpinQuestionEvent(),
                  );
                } else {
                  context.read<ReflectionBloc>().add(
                    PinQuestionEvent(question.id),
                  );
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.edit, color: AppColors.primaryColor),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                _showEditDialog(context, isDark, question);
              },
            ),
            if (question.isUserCreated)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirm(context, question);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    bool isDark,
    ReflectionQuestion question,
  ) {
    final textController = TextEditingController(text: question.questionText);
    String selectedFrequency = question.frequency;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark
            ? AppColors.darkCardBackground
            : AppColors.lightCardBackground,
        title: Text(
          'Edit Question',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: textController,
                maxLines: 3,
                style: TextStyle(fontSize: 14.sp),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Frequency',
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8.h),
              StatefulBuilder(
                builder: (context, setState) => DropdownButton<String>(
                  value: selectedFrequency,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'daily', child: Text('Daily')),
                    DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                    DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                  ],
                  onChanged: (value) {
                    setState(() => selectedFrequency = value ?? 'daily');
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                context.read<ReflectionBloc>().add(
                  UpdateQuestionEvent(
                    question.copyWith(
                      questionText: textController.text,
                      frequency: selectedFrequency,
                    ),
                  ),
                );
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, ReflectionQuestion question) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Question?'),
        content: const Text(
          'This will also delete all answers to this question. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ReflectionBloc>().add(
                DeleteQuestionEvent(question.id),
              );
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
