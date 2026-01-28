import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/reflection_bloc.dart';
import '../bloc/reflection_event.dart';
import '../bloc/reflection_state.dart';
import '../design_system/design_system.dart';
import '../pages/settings_screen.dart';
import 'question_list_screen.dart';
import 'reflection_history_screen.dart';

class ReflectionHomeScreen extends StatefulWidget {
  const ReflectionHomeScreen({super.key});

  @override
  State<ReflectionHomeScreen> createState() => _ReflectionHomeScreenState();
}

class _ReflectionHomeScreenState extends State<ReflectionHomeScreen> {
  final bool _isPrivacyMode = true;
  bool _isUnlocked = false;

  @override
  void initState() {
    super.initState();
    context.read<ReflectionBloc>().add(const InitializeReflectionEvent());
  }

  Future<void> _unlockReflections() async {
    // In a real app, this would use biometric authentication
    // For now, just toggle the unlock state
    setState(() {
      _isUnlocked = true;
    });

    // Auto-lock after 30 seconds
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        setState(() {
          _isUnlocked = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.h),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              backgroundColor: AppColors.background(context).withOpacity(0.8),
              elevation: 0,
              centerTitle: true,
              leading: Container(
                margin: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shield_outlined,
                  color: AppColors.primary,
                  size: 24.sp,
                ),
              ),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Reflection',
                    style: AppTypography.bodyLarge(null, null, FontWeight.bold),
                  ),
                  if (_isPrivacyMode)
                    Text(
                      'PRIVACY MODE ACTIVE',
                      style: AppTypography.captionSmall(null).copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.settings_outlined, size: 22.sp),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
                SizedBox(width: 4.w),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Insights Card
            _buildInsightsCard(),

            SizedBox(height: 8.h),

            // Past Reflections Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Past Reflections',
                    style: AppTypography.bodyLarge(null, null, FontWeight.bold),
                  ),
                  Icon(
                    Icons.visibility_off_outlined,
                    size: 18.sp,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),

            // Blurred Reflections List with Unlock Button
            _buildPrivateReflectionsList(),

            SizedBox(height: 100.h),
          ],
        ),
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
        border: Border.all(color: AppColors.borderLight, width: 1),
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
          border: Border.all(color: AppColors.borderLight, width: 1),
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
                    borderSide: BorderSide(color: AppColors.borderLight),
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

  Widget _buildInsightsCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1c2426) : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[100]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Hero Image Background
          Container(
            width: double.infinity,
            height: 120.h,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF111d21), Color(0xFF1e3a44)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
            ),
            child: Center(
              child: Icon(
                Icons.insights,
                size: 64.sp,
                color: AppColors.primary.withOpacity(0.4),
              ),
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Computed Locally Badge
                Row(
                  children: [
                    Icon(Icons.memory, color: AppColors.primary, size: 14.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'COMPUTED LOCALLY',
                      style: TextStyle(
                        color: const Color(0xFF9eb1b7),
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),

                // Insight Text
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      height: 1.3,
                    ),
                    children: [
                      const TextSpan(text: 'On days you feel '),
                      TextSpan(
                        text: 'Calm',
                        style: TextStyle(color: AppColors.primary),
                      ),
                      const TextSpan(
                        text: ', your productivity increases by 20%',
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                // Footer Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Encrypted & Private',
                      style: TextStyle(
                        color: const Color(0xFF9eb1b7),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        'Learn more',
                        style: TextStyle(
                          color: const Color(0xFF111d21),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivateReflectionsList() {
    final sampleReflections = [
      {
        'date': 'Oct 24 • 🌿',
        'icon': Icons.eco_outlined,
        'text': 'Today I felt extremely grounded while working in the garden',
      },
      {
        'date': 'Oct 23 • 🌊',
        'icon': Icons.water_drop_outlined,
        'text': 'The sound of the ocean during my morning walk helped me focus',
      },
      {
        'date': 'Oct 22 • ✨',
        'icon': Icons.wb_sunny_outlined,
        'text': 'A productive day with clear skies and even clearer mind',
      },
    ];

    return Stack(
      children: [
        // Blurred List Items
        Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: AppColors.borderLight.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: sampleReflections.map((reflection) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.borderLight.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusLG,
                        ),
                      ),
                      child: Icon(
                        reflection['icon'] as IconData,
                        color: AppColors.primary,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reflection['date'] as String,
                            style: AppTypography.bodyMedium(
                              null,
                              null,
                              FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            reflection['text'] as String,
                            style: AppTypography.captionSmall(
                              null,
                            ).copyWith(color: AppColors.textMuted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: AppColors.textMuted,
                      size: 20.sp,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),

        // Privacy Blur Overlay
        if (!_isUnlocked)
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  color: AppColors.background(context).withOpacity(0.3),
                  child: Center(
                    child: GestureDetector(
                      onTap: _unlockReflections,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 16.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusFull,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.fingerprint,
                              color: Colors.white,
                              size: 24.sp,
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              'Tap to Unlock',
                              style: AppTypography.bodyMedium(
                                null,
                                Colors.white,
                                FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
