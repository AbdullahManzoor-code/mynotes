import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui' as ui;
import '../design_system/design_system.dart';
import '../bloc/note_bloc.dart';
import '../bloc/note_state.dart';
import '../widgets/note_card_widget.dart';
import '../widgets/notes_view_options_sheet.dart';
import '../widgets/notes_search_bar.dart';

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

  // Search and View Options State (ORG-001, ORG-002, ORG-003)
  String _searchQuery = '';
  NoteViewMode _currentViewMode = NoteViewMode.list;
  NoteSortOption _currentSortOption = NoteSortOption.dateModified;
  bool _sortDescending = true;
  List<String> _selectedTags = [];
  List<Color> _selectedColors = [];

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
              // View Mode Toggle Button
              IconButton(
                onPressed: () {
                  setState(() {
                    _currentViewMode = _currentViewMode == NoteViewMode.list
                        ? NoteViewMode.grid
                        : NoteViewMode.list;
                  });
                },
                icon: Icon(
                  _currentViewMode == NoteViewMode.list
                      ? Icons.grid_view
                      : Icons.view_list,
                  color: AppColors.getTextColor(Theme.of(context).brightness),
                  size: 24.sp,
                ),
              ),

              // View Options Button
              IconButton(
                onPressed: _showViewOptionsSheet,
                icon: Icon(
                  Icons.tune,
                  color: AppColors.getTextColor(Theme.of(context).brightness),
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 8.w),
            ],
          ),

          // Template Picker Section
          SliverToBoxAdapter(child: _buildTemplateSection()),

          // Search Bar Section (ORG-003)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: NotesSearchBar(
                onSearchChanged: (query) {
                  setState(() {
                    _searchQuery = query;
                  });
                },
                onTagsSelected: (tags) {
                  setState(() {
                    _selectedTags = tags;
                  });
                },
                onColorsSelected: (colors) {
                  setState(() {
                    _selectedColors = colors;
                  });
                },
              ),
            ),
          ),

          // Notes Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      SizedBox(height: 2.h),
                      Text(
                        'Sorted by ${_currentSortOption.displayName} ${_sortDescending ? '(newest first)' : '(oldest first)'}',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.getSecondaryTextColor(
                            Theme.of(context).brightness,
                          ).withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        _currentViewMode.displayName,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.getSecondaryTextColor(
                            Theme.of(context).brightness,
                          ).withOpacity(0.7),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        _currentViewMode.icon,
                        size: 16.sp,
                        color: AppColors.getSecondaryTextColor(
                          Theme.of(context).brightness,
                        ).withOpacity(0.7),
                      ),
                    ],
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
                // Apply filtering and sorting
                final filteredNotes = _getFilteredAndSortedNotes(state.notes);

                if (filteredNotes.isEmpty) {
                  return SliverToBoxAdapter(
                    child:
                        _searchQuery.isNotEmpty ||
                            _selectedTags.isNotEmpty ||
                            _selectedColors.isNotEmpty
                        ? _buildNoResultsState()
                        : _buildEmptyState(),
                  );
                }

                // Grid View Mode (ORG-001)
                if (_currentViewMode == NoteViewMode.grid) {
                  return SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                      ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final note = filteredNotes[index];
                        return NoteCardWidget(
                          note: note,
                          isGridView: true,
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/notes/editor',
                            arguments: {'note': note},
                          ),
                          onLongPress: () {},
                        );
                      }, childCount: filteredNotes.length),
                    ),
                  );
                }

                // List View Mode (default)
                return SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final note = filteredNotes[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: NoteCardWidget(
                          note: note,
                          isGridView: false,
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/notes/editor',
                            arguments: {'note': note},
                          ),
                          onLongPress: () {},
                        ),
                      );
                    }, childCount: filteredNotes.length),
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

      floatingActionButton: Semantics(
        button: true,
        enabled: true,
        label: 'Create new note',
        onTap: () => Navigator.pushNamed(context, '/notes/editor'),
        child: FloatingActionButton.extended(
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
        child: SizedBox(
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

  Widget _buildNoResultsState() {
    return Padding(
      padding: EdgeInsets.all(48.w),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 80.sp,
            color: AppColors.getSecondaryTextColor(
              Theme.of(context).brightness,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'No matching notes',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.getTextColor(Theme.of(context).brightness),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Try adjusting your search or filters',
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

  // Helper Methods for View Options (ORG-001, ORG-002)
  void _showViewOptionsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NotesViewOptionsSheet(
        currentViewMode: _currentViewMode,
        currentSortOption: _currentSortOption,
        sortDescending: _sortDescending,
        onViewModeChanged: (mode) {
          setState(() {
            _currentViewMode = mode;
          });
        },
        onSortChanged: (option, descending) {
          setState(() {
            _currentSortOption = option;
            _sortDescending = descending;
          });
        },
      ),
    );
  }

  // Filter and sort notes based on current options
  List<dynamic> _getFilteredAndSortedNotes(List<dynamic> notes) {
    // Apply search filter
    List<dynamic> filteredNotes = notes.where((note) {
      if (_searchQuery.isEmpty) return true;

      // Search in title, content, and tags
      final searchLower = _searchQuery.toLowerCase();
      return (note.title?.toLowerCase().contains(searchLower) ?? false) ||
          (note.content?.toLowerCase().contains(searchLower) ?? false) ||
          (note.tags?.any((tag) => tag.toLowerCase().contains(searchLower)) ??
              false);
    }).toList();

    // Apply tag filter
    if (_selectedTags.isNotEmpty) {
      filteredNotes = filteredNotes.where((note) {
        return note.tags?.any((tag) => _selectedTags.contains(tag)) ?? false;
      }).toList();
    }

    // Apply color filter
    if (_selectedColors.isNotEmpty) {
      filteredNotes = filteredNotes.where((note) {
        return _selectedColors.contains(note.color);
      }).toList();
    }

    // Apply sorting
    filteredNotes.sort((a, b) {
      int comparison;

      switch (_currentSortOption) {
        case NoteSortOption.dateCreated:
          comparison = (a.createdAt ?? DateTime.now()).compareTo(
            b.createdAt ?? DateTime.now(),
          );
          break;
        case NoteSortOption.dateModified:
          comparison = (a.updatedAt ?? DateTime.now()).compareTo(
            b.updatedAt ?? DateTime.now(),
          );
          break;
        case NoteSortOption.titleAZ:
          comparison = (a.title ?? '').compareTo(b.title ?? '');
          break;
        case NoteSortOption.color:
          comparison = (a.color?.value ?? 0).compareTo(b.color?.value ?? 0);
          break;
      }

      return _sortDescending ? -comparison : comparison;
    });

    return filteredNotes;
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
