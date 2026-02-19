import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:confetti/confetti.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import '../bloc/analytics/analytics_bloc.dart';
import 'edit_daily_highlight_screen_new.dart';
import '../design_system/design_system.dart' hide OutlinedButton;

/// Daily Highlight Summary Screen
/// Shows evening review with top 3 wins of the day
class DailyHighlightSummaryScreen extends StatefulWidget {
  const DailyHighlightSummaryScreen({super.key});

  @override
  State<DailyHighlightSummaryScreen> createState() =>
      _DailyHighlightSummaryScreenState();
}

class _DailyHighlightSummaryScreenState
    extends State<DailyHighlightSummaryScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    AppLogger.i('DailyHighlightSummaryScreen: Initialized');
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    // Trigger confetti on entry
    Future.delayed(const Duration(milliseconds: 500), () {
      AppLogger.i('DailyHighlightSummaryScreen: Playing confetti');
      _confettiController.play();
    });
  }

  @override
  void dispose() {
    AppLogger.i('DailyHighlightSummaryScreen: Disposed');
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnalyticsBloc, AnalyticsState>(
      builder: (context, state) {
        final List<String> highlights = state is AnalyticsLoaded
            ? state.dailyHighlights
            : [
                'Finalized the Project X product strategy proposal',
                'Took a mindful 20-minute walk during lunch',
                'Organized workspace and set priorities for tomorrow',
              ];

        return AppScaffold(
          body: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF1a162e),
                      Color(0xFF2d1b4d),
                      Color(0xFF141121),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      // Top App Bar
                      _buildTopAppBar(context),

                      // Main Content
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Container(
                            width: double.infinity,
                            constraints: BoxConstraints(maxWidth: 480.w),
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            child: Column(
                              children: [
                                SizedBox(height: 24.h),
                                _buildHeader(),
                                SizedBox(height: 24.h),
                                _buildDecorativeImage(),
                                SizedBox(height: 24.h),
                                _buildWinsSummaryCard(highlights),
                                SizedBox(height: 24.h),
                                _buildActionButtons(context),
                                SizedBox(height: 32.h),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  colors: const [
                    Colors.green,
                    Colors.blue,
                    Colors.pink,
                    Colors.orange,
                    Colors.purple,
                  ],
                  createParticlePath: drawStar,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Path drawStar(Size size) {
    // Method to draw a star shape
    double degToRad(double deg) => deg * (math.pi / 180.0);

    const int numberOfPoints = 5;
    final double halfWidth = size.width / 2;
    final double externalRadius = halfWidth;
    final double internalRadius = halfWidth / 2.5;
    final double degreesPerStep = degToRad(360 / numberOfPoints);
    final double halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final double fullAngle = degToRad(-90);

    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < degToRad(360); step += degreesPerStep) {
      path.lineTo(
        halfWidth + externalRadius * math.cos(step + fullAngle),
        halfWidth + externalRadius * math.sin(step + fullAngle),
      );
      path.lineTo(
        halfWidth +
            internalRadius * math.cos(step + halfDegreesPerStep + fullAngle),
        halfWidth +
            internalRadius * math.sin(step + halfDegreesPerStep + fullAngle),
      );
    }

    path.close();
    return path;
  }

  Widget _buildTopAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              AppLogger.i('DailyHighlightSummaryScreen: Close pressed');
              Navigator.pop(context);
            },
            child: Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.close, color: Colors.white, size: 24.sp),
            ),
          ),
          Expanded(
            child: Text(
              'EVENING REVIEW',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.0,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          GestureDetector(
            onTap: () {
              AppLogger.i(
                'DailyHighlightSummaryScreen: Share highlights pressed',
              );
              _shareHighlights();
            },
            child: Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.share, color: Colors.white, size: 24.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final now = DateTime.now();
    final dateString = _formatDate(now);

    return Column(
      children: [
        // Icon
        Container(
          width: 64.w,
          height: 64.w,
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(32.r),
          ),
          child: Icon(Icons.bedtime, color: AppColors.primary, size: 40.sp),
        ),
        SizedBox(height: 16.h),

        // Title
        Text(
          'Your Daily Highlights',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32.sp,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.h),

        // Date
        Text(
          dateString,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 14.sp,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildDecorativeImage() {
    return Container(
      width: double.infinity,
      height: 192.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6B46C1),
            Color(0xFF8B5CF6),
            Color(0xFF3B82F6),
            Color(0xFF06B6D4),
          ],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          backgroundBlendMode: BlendMode.overlay,
          color: Colors.black.withOpacity(0.1),
        ),
      ),
    );
  }

  Widget _buildWinsSummaryCard(List<String> highlights) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with border
              Column(
                children: [
                  Text(
                    'Top 3 Wins Today',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    height: 1,
                    width: double.infinity,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Wins List
              ...highlights.map((win) => _buildWinItem(win)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWinItem(String win) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Check circle
          Container(
            width: 24.w,
            height: 24.w,
            margin: EdgeInsets.only(top: 2.h),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.check,
              color: AppColors.primaryColor,
              size: 14.sp,
              weight: 700,
            ),
          ),
          SizedBox(width: 16.w),

          // Win text
          Expanded(
            child: Text(
              win,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16.sp,
                fontWeight: FontWeight.normal,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Save as Reflection Button
        SizedBox(
          width: double.infinity,
          height: 56.h,
          child: ElevatedButton(
            onPressed: () {
              AppLogger.i(
                'DailyHighlightSummaryScreen: Save as Reflection pressed',
              );
              _saveAsReflection(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              elevation: 8,
              shadowColor: AppColors.primaryColor.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome, size: 20.sp, color: Colors.white),
                SizedBox(width: 8.w),
                Text(
                  'Save as Reflection',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 12.h),

        // Edit Wins Button
        SizedBox(
          width: double.infinity,
          height: 56.h,
          child: OutlinedButton(
            onPressed: () {
              AppLogger.i('DailyHighlightSummaryScreen: Edit Wins pressed');
              _editWins(context);
            },
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.05),
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.edit_note, size: 20.sp, color: Colors.white),
                SizedBox(width: 8.w),
                Text(
                  'Edit Wins',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];
    return '$weekday, $month ${date.day}';
  }

  void _shareHighlights() {
    // Share functionality
    // TODO: Implement sharing
  }

  void _saveAsReflection(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Highlights saved as reflection'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _editWins(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditDailyHighlightScreen()),
    );
  }
}


