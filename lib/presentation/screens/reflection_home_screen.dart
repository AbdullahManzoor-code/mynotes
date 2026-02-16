import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/reflection_answer.dart';
import '../bloc/reflection/reflection_bloc.dart';
import '../bloc/reflection/reflection_event.dart';
import '../bloc/reflection/reflection_state.dart';
import '../design_system/design_system.dart';
import '../pages/unified_settings_screen.dart';
import 'package:local_auth/local_auth.dart';
import '../../injection_container.dart' show getIt;
import 'question_list_screen.dart';
import 'answer_screen.dart';
import 'reflection_history_screen.dart';
// Ensure correct import

class ReflectionHomeScreen extends StatefulWidget {
  const ReflectionHomeScreen({super.key});

  @override
  State<ReflectionHomeScreen> createState() => _ReflectionHomeScreenState();
}

class _ReflectionHomeScreenState extends State<ReflectionHomeScreen> {
  final bool _isPrivacyMode = true;
  bool _isUnlocked = false;
  final LocalAuthentication _auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    context.read<ReflectionBloc>().add(const InitializeReflectionEvent());
    context.read<ReflectionBloc>().add(const LoadAllAnswersEvent());
  }

  Future<void> _unlockReflections() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _auth.isDeviceSupported();

      if (!canAuthenticate) {
        // Fallback or show error
        setState(() {
          _isUnlocked = true;
        });
        return;
      }

      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: 'Authenticate to view your private reflections',
        sensitiveTransaction: true,
        biometricOnly: false,
      );

      if (didAuthenticate) {
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
    } catch (e) {
      AppLogger.e('Authentication error: $e');
      // On error, we might want to allow access if it's a dev environment or show an error
      getIt<GlobalUiService>().showError(
        'Authentication failed: ${e.toString()}',
      );
    }
  }

  Future<void> _showNotificationPicker(
    BuildContext context,
    bool isDark,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 20, minute: 0),
      builder: (context, child) {
        return Theme(
          data: isDark
              ? ThemeData.dark().copyWith(
                  primaryColor: AppColors.primaryColor,
                  colorScheme: ColorScheme.dark(
                    primary: AppColors.primaryColor,
                  ),
                )
              : ThemeData.light().copyWith(
                  primaryColor: AppColors.primaryColor,
                  colorScheme: ColorScheme.light(
                    primary: AppColors.primaryColor,
                  ),
                ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final now = DateTime.now();
      DateTime scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      if (!mounted) return;
      context.read<ReflectionBloc>().add(
        ScheduleReflectionNotificationEvent(scheduledDate),
      );

      getIt<GlobalUiService>().showSuccess(
        'Daily reminder set for ${picked.format(context)}',
        actionLabel: 'CANCEL',
        onActionPressed: () {
          context.read<ReflectionBloc>().add(
            const CancelReflectionNotificationEvent(),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.h),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              backgroundColor: (isDark ? AppColors.darkBg : AppColors.lightBg)
                  .withOpacity(0.8),
              elevation: 0,
              centerTitle: true,
              leading: Container(
                margin: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shield_outlined,
                  color: AppColors.primaryColor,
                  size: 24.sp,
                ),
              ),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Reflection',
                    style: AppTypography.heading3().copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.lightText : AppColors.darkText,
                    ),
                  ),
                  if (_isPrivacyMode)
                    Text(
                      'PRIVACY MODE ACTIVE',
                      style: AppTypography.caption().copyWith(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.notifications_active_outlined,
                    size: 22.sp,
                    color: isDark ? AppColors.lightText : AppColors.darkText,
                  ),
                  onPressed: () => _showNotificationPicker(context, isDark),
                ),
                IconButton(
                  icon: Icon(
                    Icons.settings_outlined,
                    size: 22.sp,
                    color: isDark ? AppColors.lightText : AppColors.darkText,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UnifiedSettingsScreen(),
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
      body: BlocBuilder<ReflectionBloc, ReflectionState>(
        builder: (context, state) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final reflections = state.allAnswers.take(3).toList();

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ReflectionBloc>().add(
                const InitializeReflectionEvent(),
              );
              // Small delay to show indicator
              await Future.delayed(const Duration(milliseconds: 500));
            },
            color: AppColors.primaryColor,
            backgroundColor: isDark
                ? AppColors.darkCardBackground
                : Colors.white,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Streak & Progress Row
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStreakCard(isDark, state.streakCount),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _buildHeatmapLite(isDark, state.allAnswers),
                        ),
                      ],
                    ),
                  ),

                  // Today's Prompt Section
                  _buildTodayPrompt(context, state, isDark),

                  // Category Selection
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    child: Text(
                      'CATEGORIES',
                      style: AppTypography.label().copyWith(
                        color: isDark
                            ? AppColors.lightTextSecondary
                            : AppColors.darkTextSecondary,
                      ),
                    ),
                  ),
                  _buildCategoriesList(context, isDark),

                  SizedBox(height: 16.h),

                  // Insights Card
                  _buildInsightsCard(),

                  SizedBox(height: 8.h),

                  // Past Reflections Header
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Past Reflections',
                          style: AppTypography.heading4().copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.lightText
                                : AppColors.darkText,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ReflectionHistoryScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'View All',
                            style: AppTypography.body2().copyWith(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Blurred Reflections List with Unlock Button
                  _buildPrivateReflectionsList(reflections),

                  SizedBox(height: 100.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStreakCard(bool isDark, int streakCount) {
    return Container(
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkCardBackground
            : AppColors.lightCardBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: streakCount > 0
              ? AppColors.primaryColor.withOpacity(0.5)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_fire_department,
                color: streakCount > 0 ? Colors.orange : Colors.grey,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                "Streak",
                style: AppTypography.body1().copyWith(
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            "$streakCount days",
            style: AppTypography.heading3().copyWith(
              fontWeight: FontWeight.w700,
              color: streakCount > 0
                  ? Colors.orange
                  : (isDark ? AppColors.lightText : AppColors.darkText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayPrompt(
    BuildContext context,
    ReflectionState state,
    bool isDark,
  ) {
    // Pick first question as today's prompt or show loading
    final question = state.questions.isNotEmpty ? state.questions.first : null;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  AppColors.primaryColor.withOpacity(0.1),
                  AppColors.darkCardBackground,
                ]
              : [AppColors.primaryColor.withOpacity(0.05), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "TODAY'S PROMPT",
                style: AppTypography.label().copyWith(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.refresh,
                  color: AppColors.primaryColor,
                  size: 20.sp,
                ),
                onPressed: () {
                  context.read<ReflectionBloc>().add(
                    const LoadRandomQuestionEvent(),
                  );
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (question != null) ...[
            Text(
              question.questionText,
              style: AppTypography.heading4().copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.lightText : AppColors.darkText,
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AnswerScreen(question: question),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                elevation: 0,
              ),
              child: const Text("Write Reflection"),
            ),
          ] else
            const Center(child: CircularProgressIndicator()),
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
                color: AppColors.primaryColor.withOpacity(0.4),
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
                    Icon(
                      Icons.memory,
                      color: AppColors.primaryColor,
                      size: 14.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'COMPUTED LOCALLY',
                      style: AppTypography.caption().copyWith(
                        color: const Color(0xFF9eb1b7),
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
                    style: AppTypography.heading3().copyWith(
                      color: isDark ? AppColors.lightText : AppColors.darkText,
                      letterSpacing: -0.5,
                      height: 1.3,
                    ),
                    children: [
                      const TextSpan(text: 'On days you feel '),
                      TextSpan(
                        text: 'Calm',
                        style: TextStyle(color: AppColors.primaryColor),
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
                      style: AppTypography.caption().copyWith(
                        color: const Color(0xFF9eb1b7),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        'Learn more',
                        style: AppTypography.body2().copyWith(
                          color: const Color(0xFF111d21),
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

  Widget _buildCategoriesList(BuildContext context, bool isDark) {
    return Container(
      height: 120.h,
      padding: EdgeInsets.only(left: 16.w),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildCategoryItem(
            context,
            isDark,
            'Daily',
            Icons.wb_sunny_outlined,
            'daily',
            'Daily Check-in',
          ),
          _buildCategoryItem(
            context,
            isDark,
            'Purpose',
            Icons.eco_outlined,
            'life',
            'Life & Purpose',
          ),
          _buildCategoryItem(
            context,
            isDark,
            'Career',
            Icons.work_outline,
            'career',
            'Career & Study',
          ),
          _buildCategoryItem(
            context,
            isDark,
            'Mental',
            Icons.psychology_outlined,
            'mental_health',
            'Mental Health',
          ),
          _buildCategoryItem(
            context,
            isDark,
            'Gratitude',
            Icons.favorite_outline,
            'gratitude',
            'Gratitude',
          ),
          _buildCategoryItem(
            context,
            isDark,
            'Mindful',
            Icons.self_improvement_outlined,
            'mindfulness',
            'Mindfulness',
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    bool isDark,
    String label,
    IconData icon,
    String category,
    String categoryLabel,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuestionListScreen(
              category: category,
              categoryLabel: categoryLabel,
            ),
          ),
        );
      },
      child: Container(
        width: 100.w,
        margin: EdgeInsets.only(right: 12.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCardBackground : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.borderLight.withOpacity(0.5)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primaryColor, size: 28.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: AppTypography.label().copyWith(
                color: isDark ? AppColors.lightText : AppColors.darkText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivateReflectionsList(List<ReflectionAnswer> reflections) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final moodIcons = {
      'great': Icons.sentiment_very_satisfied,
      'happy': Icons.sentiment_satisfied_alt,
      'good': Icons.sentiment_satisfied,
      'neutral': Icons.sentiment_neutral,
      'sad': Icons.sentiment_very_dissatisfied,
    };

    if (reflections.isEmpty) {
      return Container(
        padding: EdgeInsets.all(32.w),
        alignment: Alignment.center,
        child: Text(
          'No reflections yet',
          style: AppTypography.body2().copyWith(
            color: isDark
                ? AppColors.lightTextSecondary
                : AppColors.darkTextSecondary,
          ),
        ),
      );
    }

    return Stack(
      children: [
        // Blurred List Items
        Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: (isDark ? AppColors.darkBorder : AppColors.lightBorder)
                    .withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: reflections.map((reflection) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color:
                          (isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder)
                              .withOpacity(0.2),
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
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusLG,
                        ),
                      ),
                      child: Icon(
                        moodIcons[reflection.mood] ?? Icons.notes,
                        color: AppColors.primaryColor,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat(
                              'MMM d • EEE',
                            ).format(reflection.createdAt),
                            style: AppTypography.body2().copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.lightText
                                  : AppColors.darkText,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            reflection.answerText,
                            style: AppTypography.caption().copyWith(
                              color: isDark
                                  ? AppColors.lightTextSecondary
                                  : AppColors.darkTextSecondary,
                            ),
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
                  color: (isDark ? AppColors.darkBg : AppColors.lightBg)
                      .withOpacity(0.3),
                  child: Center(
                    child: GestureDetector(
                      onTap: _unlockReflections,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 16.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusFull,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryColor.withOpacity(0.3),
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
                              style: AppTypography.body1().copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
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

  Widget _buildHeatmapLite(bool isDark, List<ReflectionAnswer> allAnswers) {
    final now = DateTime.now();
    final last7Days = List.generate(
      7,
      (i) => now.subtract(Duration(days: 6 - i)),
    );

    return Container(
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkCardBackground
            : AppColors.lightCardBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Weekly Activity",
            style: AppTypography.caption().copyWith(
              color: Colors.grey,
              fontSize: 10.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: last7Days.map((date) {
              final dateStr = DateFormat('yyyy-MM-dd').format(date);
              final hasReflection = allAnswers.any(
                (a) => DateFormat('yyyy-MM-dd').format(a.createdAt) == dateStr,
              );
              return Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: hasReflection
                      ? AppColors.primaryColor
                      : Colors.grey.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
