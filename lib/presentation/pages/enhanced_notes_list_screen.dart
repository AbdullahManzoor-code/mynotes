import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui' as ui;
import '../design_system/design_system.dart';
import '../bloc/note_bloc.dart';
import '../bloc/note_state.dart';
import '../widgets/note_card_widget.dart';

/// Enhanced Notes List with Templates Screen
/// Modern notes list interface with template picker
/// Based on notes_list_and_templates_1 template
class EnhancedNotesListScreen extends StatefulWidget {
  const EnhancedNotesListScreen({super.key});

  @override
  State<EnhancedNotesListScreen> createState() =>
      _EnhancedNotesListScreenState();
}

class _EnhancedNotesListScreenState extends State<EnhancedNotesListScreen> {
  final ScrollController _templateScrollController = ScrollController();
  final ScrollController _notesScrollController = ScrollController();

  final List<NoteTemplate> _templates = [
    NoteTemplate(
      title: 'Meeting Notes',
      icon: Icons.groups,
      color: AppColors.primary,
      description: 'Capture meeting discussions and action items',
    ),
    NoteTemplate(
      title: 'Shopping List',
      icon: Icons.shopping_cart,
      color: AppColors.accentOrange,
      description: 'Create organized shopping lists',
    ),
    NoteTemplate(
      title: 'Daily Journal',
      icon: Icons.book,
      color: AppColors.accentPurple,
      description: 'Reflect on your day and thoughts',
    ),
    NoteTemplate(
      title: 'Project Plan',
      icon: Icons.business_center,
      color: AppColors.accentGreen,
      description: 'Plan and track project milestones',
    ),
    NoteTemplate(
      title: 'Travel Plan',
      icon: Icons.flight_takeoff,
      color: AppColors.accentBlue,
      description: 'Organize your travel itinerary',
    ),
    NoteTemplate(
      title: 'Recipe',
      icon: Icons.restaurant,
      color: AppColors.accentYellow,
      description: 'Save your favorite recipes',
    ),
  ];

  void _createFromTemplate(NoteTemplate template) {
    Navigator.pushNamed(
      context,
      '/notes/editor',
      arguments: {
        'template': template.title,
        'content': _getTemplateContent(template),
      },
    );
  }

  String _getTemplateContent(NoteTemplate template) {
    switch (template.title) {
      case 'Meeting Notes':
        return '''# Meeting Notes

**Date:** ${DateTime.now().toString().split(' ')[0]}
**Attendees:** 
**Agenda:** 

## Discussion Points
- 

## Action Items
- [ ] 

## Next Steps
- 
''';
      case 'Shopping List':
        return '''# Shopping List

## Groceries
- [ ] 

## Household Items
- [ ] 

## Other
- [ ] 
''';
      case 'Daily Journal':
        return '''# Daily Journal - ${DateTime.now().toString().split(' ')[0]}

## How I'm feeling today


## What happened today


## What I'm grateful for


## Tomorrow's goals

''';
      case 'Project Plan':
        return '''# Project Plan

## Overview


## Goals
- [ ] 

## Timeline


## Resources Needed


## Next Actions
- [ ] 
''';
      case 'Travel Plan':
        return '''# Travel Plan

## Destination


## Dates


## Flight Details


## Accommodation


## Activities
- [ ] 

## Packing List
- [ ] 
''';
      case 'Recipe':
        return '''# Recipe Name

## Ingredients
- 

## Instructions
1. 

## Notes


## Cooking Time


## Servings

''';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(
        Theme.of(context).brightness,
      ),
      body: CustomScrollView(
        controller: _notesScrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: AppColors.getBackgroundColor(
              Theme.of(context).brightness,
            ).withOpacity(0.8),
            elevation: 0,
            scrolledUnderElevation: 0,
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  color: AppColors.getBackgroundColor(
                    Theme.of(context).brightness,
                  ).withOpacity(0.8),
                ),
              ),
            ),
            title: Text(
              'My Notes',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: AppColors.getTextColor(Theme.of(context).brightness),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => Navigator.pushNamed(context, '/search'),
                icon: Icon(
                  Icons.search,
                  color: AppColors.getTextColor(Theme.of(context).brightness),
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 8.w),
            ],
          ),

          // Template Picker Section
          SliverToBoxAdapter(child: _buildTemplateSection()),

          // Notes Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'RECENT NOTES',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: AppColors.getSecondaryTextColor(
                        Theme.of(context).brightness,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Show filter/sort options
                    },
                    child: Icon(
                      Icons.tune,
                      size: 20.sp,
                      color: AppColors.getSecondaryTextColor(
                        Theme.of(context).brightness,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Notes List
          BlocBuilder<NotesBloc, NoteState>(
            builder: (context, state) {
              if (state is NoteLoading) {
                return SliverToBoxAdapter(child: _buildLoadingState());
              }

              if (state is NotesLoaded) {
                if (state.notes.isEmpty) {
                  return SliverToBoxAdapter(child: _buildEmptyState());
                }

                return SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final note = state.notes[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: NoteCardWidget(
                          note: note,
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/notes/editor',
                            arguments: {'note': note},
                          ),
                          onLongPress: () {},
                        ),
                      );
                    }, childCount: state.notes.length),
                  ),
                );
              }

              return SliverToBoxAdapter(child: _buildErrorState());
            },
          ),

          // Bottom padding
          SliverToBoxAdapter(child: SizedBox(height: 100.h)),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/notes/editor'),
        backgroundColor: AppColors.primary,
        elevation: 8,
        icon: Icon(Icons.add, color: Colors.white, size: 24.sp),
        label: Text(
          'New Note',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
          child: Text(
            'TEMPLATES',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: AppColors.getSecondaryTextColor(
                Theme.of(context).brightness,
              ),
            ),
          ),
        ),

        SizedBox(
          height: 140.h,
          child: ListView.builder(
            controller: _templateScrollController,
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: _templates.length,
            itemBuilder: (context, index) {
              final template = _templates[index];
              return Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: _buildTemplateCard(template),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTemplateCard(NoteTemplate template) {
    return GestureDetector(
      onTap: () => _createFromTemplate(template),
      child: AnimatedScale(
        scale: 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 120.w,
          child: Column(
            children: [
              // Icon container
              Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  color: template.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: template.color.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Icon(template.icon, color: template.color, size: 32.sp),
              ),

              SizedBox(height: 8.h),

              // Label
              Text(
                template.title,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.getTextColor(Theme.of(context).brightness),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            strokeWidth: 2,
          ),
          SizedBox(height: 16.h),
          Text(
            'Loading your notes...',
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.getSecondaryTextColor(
                Theme.of(context).brightness,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.all(48.w),
      child: Column(
        children: [
          Icon(
            Icons.note_add_outlined,
            size: 80.sp,
            color: AppColors.getSecondaryTextColor(
              Theme.of(context).brightness,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'No notes yet',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.getTextColor(Theme.of(context).brightness),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Start with a template or create a new note',
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.getSecondaryTextColor(
                Theme.of(context).brightness,
              ),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48.sp, color: AppColors.error),
          SizedBox(height: 16.h),
          Text(
            'Error loading notes',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextColor(Theme.of(context).brightness),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Please try again',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.getSecondaryTextColor(
                Theme.of(context).brightness,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NoteTemplate {
  final String title;
  final IconData icon;
  final Color color;
  final String description;

  NoteTemplate({
    required this.title,
    required this.icon,
    required this.color,
    required this.description,
  });
}
