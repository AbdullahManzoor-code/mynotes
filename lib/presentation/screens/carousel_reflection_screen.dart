import 'package:flutter/material.dart' hide CarouselController;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../bloc/reflection_bloc.dart';
import '../bloc/reflection_state.dart';
import '../bloc/reflection_event.dart';
import '../screens/answer_screen.dart';
import '../screens/reflection_history_screen.dart';

/// Modern Carousel-based Reflection Home Screen
class CarouselReflectionScreen extends StatefulWidget {
  const CarouselReflectionScreen({super.key});

  @override
  State<CarouselReflectionScreen> createState() =>
      _CarouselReflectionScreenState();
}

class _CarouselReflectionScreenState extends State<CarouselReflectionScreen> {
  int _currentIndex = 0;
  final CarouselController _carouselController = CarouselController();

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Daily Reflection',
      'category': 'daily',
      'icon': Icons.wb_sunny,
      'gradient': [Colors.orange, Colors.deepOrange],
      'description': 'End your day with mindful thoughts',
    },
    {
      'name': 'Life & Purpose',
      'category': 'life',
      'icon': Icons.explore,
      'gradient': [Colors.blue, Colors.indigo],
      'description': 'Discover your path and meaning',
    },
    {
      'name': 'Career Growth',
      'category': 'career',
      'icon': Icons.work,
      'gradient': [Colors.green, Colors.teal],
      'description': 'Professional development insights',
    },
    {
      'name': 'Mental Wellness',
      'category': 'mental_health',
      'icon': Icons.favorite,
      'gradient': [Colors.pink, Colors.purple],
      'description': 'Check in with your emotions',
    },
  ];

  @override
  void initState() {
    super.initState();
    context.read<ReflectionBloc>().add(const InitializeReflectionEvent());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(isDark),

            SizedBox(height: 20.h),

            // Daily Prompt Card
            _buildDailyPromptCard(isDark),

            SizedBox(height: 30.h),

            // Categories Carousel
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Text(
                      'Explore Topics',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Carousel
                  CarouselSlider.builder(
                    carouselController: _carouselController,
                    itemCount: _categories.length,
                    options: CarouselOptions(
                      height: 280.h,
                      aspectRatio: 16 / 9,
                      viewportFraction: 0.75,
                      enlargeCenterPage: true,
                      enableInfiniteScroll: false,
                      onPageChanged: (index, reason) {
                        setState(() => _currentIndex = index);
                      },
                    ),
                    itemBuilder: (context, index, realIndex) {
                      return _buildCategoryCard(_categories[index]);
                    },
                  ),

                  SizedBox(height: 20.h),

                  // Carousel Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _categories.asMap().entries.map((entry) {
                      return Container(
                        width: _currentIndex == entry.key ? 24.w : 8.w,
                        height: 8.h,
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.r),
                          color: _currentIndex == entry.key
                              ? AppColors.primaryColor
                              : Colors.grey.shade300,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // Bottom Actions
            _buildBottomActions(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Self-Reflection',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Take a moment to reflect',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.history),
            iconSize: 28.sp,
            color: AppColors.primaryColor,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReflectionHistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDailyPromptCard(bool isDark) {
    return BlocBuilder<ReflectionBloc, ReflectionState>(
      builder: (context, state) {
        String prompt = 'What made you smile today?';

        if (state is QuestionsLoaded && state.questions.isNotEmpty) {
          prompt = state.questions.first.questionText;
        }

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryColor, AppColors.secondaryColor],
            ),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.lightbulb,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Today\'s Prompt',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                prompt,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () {
                  if (state is QuestionsLoaded && state.questions.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AnswerScreen(question: state.questions.first),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primaryColor,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
                child: const Text('Start Writing'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return GestureDetector(
      onTap: () {
        // Navigate to question list for this category
        context.read<ReflectionBloc>().add(
          LoadQuestionsByCategoryEvent(category['category']),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: category['gradient'],
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: category['gradient'][0].withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background Pattern
            Positioned(
              top: -20,
              right: -20,
              child: Icon(
                category['icon'],
                size: 150.sp,
                color: Colors.white.withOpacity(0.1),
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          category['icon'],
                          color: Colors.white,
                          size: 32.sp,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        category['name'],
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        category['description'],
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),

                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Explore',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 16.sp,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReflectionHistoryScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.history),
              label: const Text('View History'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
                side: const BorderSide(color: AppColors.primaryColor),
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // Create custom question
              },
              icon: const Icon(Icons.add),
              label: const Text('Custom'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
