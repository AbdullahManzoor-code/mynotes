import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../bloc/reflection_bloc.dart';
import '../bloc/reflection_event.dart';
import '../bloc/reflection_state.dart';
import 'question_list_screen.dart';
import 'reflection_history_screen.dart';

class ReflectionHomeScreen extends StatefulWidget {
  const ReflectionHomeScreen({Key? key}) : super(key: key);

  @override
  State<ReflectionHomeScreen> createState() => _ReflectionHomeScreenState();
}

class _ReflectionHomeScreenState extends State<ReflectionHomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ReflectionBloc>().add(const InitializeReflectionEvent());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Self-Reflection',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: isDark
            ? AppColors.darkBackground
            : AppColors.lightBackground,
        foregroundColor: isDark ? AppColors.lightText : AppColors.darkText,
      ),
      body: BlocBuilder<ReflectionBloc, ReflectionState>(
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
                  SizedBox(height: 16.h),
                  Text(
                    'Error',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is QuestionsLoaded) {
            final categories = ['life', 'daily', 'career', 'mental_health'];
            final categoryLabels = {
              'life': 'Life & Purpose',
              'daily': 'Daily Reflection',
              'career': 'Career & Study',
              'mental_health': 'Mental Health',
            };
            final categoryIcons = {
              'life': Icons.stars,
              'daily': Icons.wb_sunny,
              'career': Icons.work,
              'mental_health': Icons.favorite,
            };

            return SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress Card
                  _buildProgressCard(
                    isDark,
                    state.answeredToday,
                    state.questions.length,
                  ),
                  SizedBox(height: 24.h),

                  // Category Cards
                  Text(
                    'Reflection Categories',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ...categories.map((category) {
                    final categoryQuestions = state.questions
                        .where((q) => q.category == category)
                        .toList();
                    return _buildCategoryCard(
                      isDark,
                      categoryLabels[category]!,
                      categoryIcons[category]!,
                      categoryQuestions.length,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QuestionListScreen(
                              category: category,
                              categoryLabel: categoryLabels[category]!,
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                  SizedBox(height: 24.h),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          isDark,
                          'View History',
                          Icons.history,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ReflectionHistoryScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildActionButton(
                          isDark,
                          'New Question',
                          Icons.add,
                          () {
                            _showAddQuestionDialog(context, isDark);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildProgressCard(
    bool isDark,
    int answeredToday,
    int totalQuestions,
  ) {
    final progress = totalQuestions > 0 ? answeredToday / totalQuestions : 0.0;

    return Container(
      padding: EdgeInsets.all(20.w),
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
          Text(
            "Today's Progress",
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8.h,
                    backgroundColor: isDark
                        ? Colors.grey[800]
                        : Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryColor,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Text(
                '$answeredToday/$totalQuestions',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    bool isDark,
    String title,
    IconData icon,
    int questionCount,
    VoidCallback onTap,
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
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, color: AppColors.primaryColor, size: 24.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '$questionCount question${questionCount != 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.sp,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    bool isDark,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18.sp, color: Colors.white),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddQuestionDialog(BuildContext context, bool isDark) {
    final textController = TextEditingController();
    String selectedCategory = 'life';
    String selectedFrequency = 'daily';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark
            ? AppColors.darkCardBackground
            : AppColors.lightCardBackground,
        title: Text(
          'Add New Question',
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
                  hintText: 'Enter your reflection question...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: AppColors.outlineColor),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Category',
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8.h),
              StatefulBuilder(
                builder: (context, setState) => DropdownButton<String>(
                  value: selectedCategory,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(
                      value: 'life',
                      child: Text('Life & Purpose'),
                    ),
                    DropdownMenuItem(
                      value: 'daily',
                      child: Text('Daily Reflection'),
                    ),
                    DropdownMenuItem(
                      value: 'career',
                      child: Text('Career & Study'),
                    ),
                    DropdownMenuItem(
                      value: 'mental_health',
                      child: Text('Mental Health'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => selectedCategory = value ?? 'life');
                  },
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
                  AddQuestionEvent(
                    questionText: textController.text,
                    category: selectedCategory,
                    frequency: selectedFrequency,
                  ),
                );
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

