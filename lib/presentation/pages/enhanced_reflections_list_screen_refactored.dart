import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/core/extensions/context_extensions.dart';
import 'dart:ui' as ui;
import 'package:mynotes/presentation/design_system/design_system.dart';
import 'package:mynotes/presentation/widgets/reflection/reflection_card.dart';
import 'package:mynotes/presentation/bloc/reflection/reflection_bloc.dart';
import 'package:mynotes/presentation/bloc/reflection/reflection_event.dart';
import 'package:mynotes/presentation/bloc/reflection/reflection_state.dart';

/// ════════════════════════════════════════════════════════════════════════════
/// PHASE 6: REFLECTIONS & INSIGHTS
/// Enhanced Reflections List Screen - StatelessWidget
/// ════════════════════════════════════════════════════════════════════════════
///
/// IMPLEMENTATION PLAN:
/// ════════════════════════════════════════════════════════════════════════════
/// 1. STATE MANAGEMENT: All state handled by ReflectionsBloc (future)
///    - Reflections list (all/filtered)
///    - Search query and filtering
///    - Mood filter options
///    - Tags filtering
///
/// 2. MAIN BUILD STRUCTURE:
///    - Scaffold with FloatingActionButton for new reflection
///    - Search & filter header
///    - Mood filter chips
///    - ReflectionsList (list/grid toggle)
///
/// 3. KEY FEATURES:
///    - Mood-based filtering (happy, neutral, sad, inspired, grateful)
///    - Content search
///    - Tags display and filtering
///    - Insight score visualization
///    - Related note/todo links
/// ════════════════════════════════════════════════════════════════════════════

class EnhancedReflectionsListScreenRefactored extends StatelessWidget {
  const EnhancedReflectionsListScreenRefactored({super.key});

  @override
  Widget build(BuildContext context) {
    AppLogger.i(
      'Building EnhancedReflectionsListScreenRefactored with ReflectionBloc',
    );

    return BlocListener<ReflectionBloc, ReflectionState>(
      listener: (context, state) {
        if (state is ReflectionError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        extendBodyBehindAppBar: true,
        floatingActionButton: _buildFAB(context),
        body: Stack(
          children: [_buildBackgroundGlow(context), _buildMainContent(context)],
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return BlocBuilder<ReflectionBloc, ReflectionState>(
      builder: (context, state) {
        // Determine which reflections to display based on state
        final reflections = state is ReflectionsLoaded ? state.answers : [];

        return SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: kToolbarHeight),
              _buildSearchBar(context),
              _buildMoodFilters(context),
              if (reflections.isEmpty)
                _buildEmptyState(context)
              else
                _buildReflectionsList(context, reflections),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        border: Border(
          bottom: BorderSide(color: context.theme.dividerColor, width: 0.5),
        ),
      ),
      child: TextField(
        onChanged: (query) {
          AppLogger.i('Search reflections: $query');
          // Could dispatch search event here if BLoC supports it
        },
        decoration: InputDecoration(
          hintText: 'Search reflections...',
          prefixIcon: Icon(Icons.search, size: 18.r),
          suffixIcon: Icon(Icons.tune, size: 18.r),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide(color: context.theme.dividerColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide(color: context.theme.dividerColor),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 10.h),
        ),
      ),
    );
  }

  Widget _buildMoodFilters(BuildContext context) {
    final moods = [
      ('All', Icons.apps, Colors.grey),
      ('😊 Happy', Icons.sentiment_satisfied, Colors.green),
      ('😐 Neutral', Icons.sentiment_neutral, Colors.blue),
      ('😔 Sad', Icons.sentiment_dissatisfied, Colors.red),
      ('🌟 Inspired', Icons.wb_incandescent, Colors.amber),
      ('🙏 Grateful', Icons.favorite, Colors.pink),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: moods
            .map(
              (mood) => Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: FilterChip(
                  label: Text(mood.$1),
                  avatar: Icon(mood.$2, size: 14.r),
                  backgroundColor: mood.$3.withOpacity(0.1),
                  labelStyle: AppTypography.body2(
                    context,
                  ).copyWith(fontSize: 10.sp, color: mood.$3),
                  onSelected: (_) {
                    AppLogger.i('Filter by mood: ${mood.$1}');
                    if (mood.$1 != 'All') {
                      context.read<ReflectionBloc>().add(
                        LoadQuestionsByCategoryEvent(mood.$1),
                      );
                    } else {
                      context.read<ReflectionBloc>().add(LoadQuestionsEvent());
                    }
                  },
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildReflectionsList(BuildContext context, dynamic reflections) {
    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reflections.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final item = reflections[index];
        return ReflectionCard(
          reflection: item,
          onTap: () => AppLogger.i('Open reflection'),
          onEdit: () => AppLogger.i('Edit reflection'),
          onDelete: (id) => AppLogger.i('Delete reflection: $id'),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('✍️', style: TextStyle(fontSize: 80.sp)),
          SizedBox(height: 16.h),
          Text(
            'No Reflections Yet',
            style: AppTypography.heading2(context).copyWith(fontSize: 18.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            'Start reflecting on your day',
            style: AppTypography.body2(
              context,
            ).copyWith(fontSize: 13.sp, color: context.theme.disabledColor),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundGlow(BuildContext context) {
    return Positioned(
      top: -100.h,
      right: -100.w,
      child: Container(
        width: 300.w,
        height: 300.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withOpacity(0.08),
        ),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 100, sigmaY: 100),
          child: Container(color: Colors.transparent),
        ),
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: 'reflections_fab',
      onPressed: () {
        AppLogger.i('New reflection FAB pressed');
        Navigator.pushNamed(context, '/reflection-editor');
      },
      backgroundColor: AppColors.primary,
      elevation: 8,
      label: Text(
        'New Reflection',
        style: AppTypography.buttonMedium(context, Colors.white),
      ),
      icon: const Icon(Icons.edit_outlined, color: Colors.white),
    );
  }
}
