import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../design_system/design_system.dart';

/// Edit Daily Highlight Screen
/// Allows users to edit and add details to their daily wins
class EditDailyHighlightScreen extends StatefulWidget {
  const EditDailyHighlightScreen({super.key});

  @override
  State<EditDailyHighlightScreen> createState() =>
      _EditDailyHighlightScreenState();
}

class _EditDailyHighlightScreenState extends State<EditDailyHighlightScreen> {
  final List<TextEditingController> _detailControllers = List.generate(
    3,
    (index) => TextEditingController(),
  );

  int _selectedMood = 2; // Good mood selected by default (index 2)

  final List<String> _defaultWins = [
    'Completed project proposal',
    'Morning meditation',
    'Cooked a healthy dinner',
  ];

  final List<String> _moodLabels = [
    'Tired',
    'Okay',
    'Good',
    'Great',
    'Amazing',
  ];

  final List<String> _moodEmojis = ['😔', '😐', '🙂', '😊', '🤩'];

  @override
  void initState() {
    super.initState();
    // Pre-populate first controller with example text
    _detailControllers[0].text =
        'I finally managed to clear the backlog and sent the final draft to the stakeholder. Feels like a weight off my shoulders.';
  }

  @override
  void dispose() {
    for (var controller in _detailControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppScaffold(
      backgroundColor: isDark
          ? const Color(0xFF111d21)
          : const Color(0xFFf6f7f8),
      body: Column(
        children: [
          // Top App Bar
          _buildTopAppBar(context, isDark),

          // Main Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Container(
                constraints: BoxConstraints(maxWidth: 480.w),
                child: Column(
                  children: [
                    // Progress Bar
                    _buildProgressBar(isDark),

                    // Win Sections
                    ..._buildWinSections(isDark),

                    // Mood Picker
                    _buildMoodPicker(isDark),

                    SizedBox(height: 100.h), // Space for sticky footer
                  ],
                ),
              ),
            ),
          ),

          // Sticky Footer
          _buildStickyFooter(context, isDark),
        ],
      ),
    );
  }

  Widget _buildTopAppBar(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xFF111d21) : const Color(0xFFf6f7f8))
            .withOpacity(0.8),
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
      ),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: SizedBox(
                    width: 40.w,
                    height: 40.w,
                    child: Icon(
                      Icons.close,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                      size: 24.sp,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Edit Highlight',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(bool isDark) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress bar with exact template styling
          Container(
            height: 4.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2.r),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF475569)
                          : const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),

          // Step text with exact template styling
          Text(
            'STEP 2 OF 3: REFLECTION',
            style: TextStyle(
              color: const Color(0xFF64748B),
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildWinSections(bool isDark) {
    return List.generate(_defaultWins.length, (index) {
      return _buildWinSection(
        index + 1,
        _defaultWins[index],
        _detailControllers[index],
        index == 0
            ? 'Deep Dive'
            : index == 1
            ? 'Reflections'
            : 'Details',
        index == 0
            ? 'What made this a win today?'
            : 'Add more detail about this win...',
        isDark,
      );
    });
  }

  Widget _buildWinSection(
    int number,
    String title,
    TextEditingController controller,
    String label,
    String placeholder,
    bool isDark,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              children: [
                Container(
                  width: 24.w,
                  height: 24.w,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: Text(
                      number.toString(),
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  title,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.grey[900],
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Text field
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 8.h, left: 4.w),
                  child: Text(
                    label.toUpperCase(),
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[500],
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.grey[900]!.withOpacity(0.5)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: controller,
                    maxLines: 4,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.grey[900],
                      fontSize: 14.sp,
                      height: 1.5,
                    ),
                    decoration: InputDecoration(
                      hintText: placeholder,
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey[600] : Colors.grey[400],
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16.w),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: AppColors.primaryColor.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodPicker(bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 24.h),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How are you feeling about today?',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),

          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF0F172A).withOpacity(0.5)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_moodEmojis.length, (index) {
                final isSelected = index == _selectedMood;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMood = index;
                    });
                  },
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            transform: Matrix4.identity()
                              ..scale(isSelected ? 1.25 : 1.0),
                            child: ColorFiltered(
                              colorFilter: isSelected
                                  ? const ColorFilter.mode(
                                      Colors.transparent,
                                      BlendMode.multiply,
                                    )
                                  : const ColorFilter.matrix([
                                      0.2126, 0.7152, 0.0722, 0, 0, // Red
                                      0.2126, 0.7152, 0.0722, 0, 0, // Green
                                      0.2126, 0.7152, 0.0722, 0, 0, // Blue
                                      0, 0, 0, 0.4, 0, // Alpha (40% opacity)
                                    ]),
                              child: Text(
                                _moodEmojis[index],
                                style: TextStyle(fontSize: 32.sp),
                              ),
                            ),
                          ),
                          if (isSelected)
                            Positioned(
                              top: -4.h,
                              right: -4.w,
                              child: Container(
                                width: 8.w,
                                height: 8.w,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  borderRadius: BorderRadius.circular(4.r),
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0xFF0F172A)
                                        : Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        _moodLabels[index].toUpperCase(),
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.primaryColor
                              : const Color(0xFF64748B),
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyFooter(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xFF111d21) : const Color(0xFFf6f7f8))
            .withOpacity(0.9),
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            height: 56.h,
            child: ElevatedButton(
              onPressed: () => _saveHighlights(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: isDark ? Colors.grey[900] : Colors.white,
                elevation: 8,
                shadowColor: AppColors.primaryColor.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Confirm & Save',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(Icons.check_circle, size: 20.sp),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _saveHighlights(BuildContext context) {
    // Save the highlights
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Highlights saved successfully'),
        backgroundColor: AppColors.primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context);
  }
}
