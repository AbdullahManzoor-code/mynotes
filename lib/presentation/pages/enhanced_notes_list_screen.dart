import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mynotes/domain/entities/note.dart';
import 'dart:ui' as ui;
import '../design_system/design_system.dart';
import '../bloc/note_bloc.dart';
import '../bloc/note_state.dart';
import '../widgets/note_card_widget.dart';
import '../widgets/notes_view_options_sheet.dart';
import '../widgets/notes_search_bar.dart';
import 'empty_state_notes_help_screen.dart';
import '../../core/routes/app_routes.dart';
import '../bloc/params/note_params.dart';
import '../bloc/note_event.dart';
import '../widgets/quick_add_bottom_sheet.dart';

/// Enhanced Notes List with Templates Screen
/// Modern notes list interface with template picker
/// Based on notes_list_and_templates_1 template
class EnhancedNotesListScreen extends StatelessWidget {
  const EnhancedNotesListScreen({super.key});

  static final List<NoteTemplate> _templates = [
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

  void _createFromTemplate(BuildContext context, NoteTemplate template) {
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
      body: BlocBuilder<NotesBloc, NoteState>(
        builder: (context, state) {
          // Prepare data from BLoC state
          final bool isLoading = state is NoteLoading;
          final bool isError = state is NoteError;
          final bool isLoaded = state is NotesLoaded;

          final List<Note> pinnedNotes = isLoaded
              ? state.displayedNotes.where((n) => n.isPinned).toList()
              : [];
          final List<Note> unpinnedNotes = isLoaded
              ? state.displayedNotes.where((n) => !n.isPinned).toList()
              : [];

          final bool showSections =
              isLoaded &&
              pinnedNotes.isNotEmpty &&
              state.searchQuery.isEmpty &&
              state.selectedTags.isEmpty &&
              state.selectedColors.isEmpty &&
              !state.filterPinned &&
              !state.filterWithMedia;

          final viewMode = isLoaded ? state.viewMode : NoteViewMode.list;
          final sortOption = isLoaded
              ? state.sortBy
              : NoteSortOption.dateModified;
          final sortDescending = isLoaded ? state.sortDescending : true;

          return CustomScrollView(
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
                    onPressed: () {
                      if (isLoaded) {
                        context.read<NotesBloc>().add(
                          UpdateNoteViewConfigEvent(
                            viewMode: state.viewMode == NoteViewMode.list
                                ? NoteViewMode.grid
                                : NoteViewMode.list,
                          ),
                        );
                      }
                    },
                    icon: Icon(
                      viewMode == NoteViewMode.list
                          ? Icons.grid_view
                          : Icons.view_list,
                      color: AppColors.textPrimary(context),
                      size: 24.sp,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showViewOptionsSheet(context, state),
                    icon: Icon(
                      Icons.sort,
                      color: AppColors.textPrimary(context),
                      size: 24.sp,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showMoreOptions(context),
                    icon: Icon(
                      Icons.more_vert,
                      color: AppColors.textPrimary(context),
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 8.w),
                ],
              ),

              // Template Picker Section
              SliverToBoxAdapter(child: _buildTemplateSection(context)),

              // Search Bar Section (ORG-003)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  child: NotesSearchBar(
                    initialSearchQuery: isLoaded ? state.searchQuery : '',
                    initialSelectedTags: isLoaded ? state.selectedTags : [],
                    initialSelectedColors: isLoaded ? state.selectedColors : [],
                    initialFilterPinned: isLoaded ? state.filterPinned : false,
                    initialFilterWithMedia: isLoaded
                        ? state.filterWithMedia
                        : false,
                    onSearchChanged: (query) {
                      context.read<NotesBloc>().add(
                        UpdateNoteViewConfigEvent(searchQuery: query),
                      );
                    },
                    onTagsSelected: (tags) {
                      context.read<NotesBloc>().add(
                        UpdateNoteViewConfigEvent(selectedTags: tags),
                      );
                    },
                    onColorsSelected: (colors) {
                      context.read<NotesBloc>().add(
                        UpdateNoteViewConfigEvent(selectedColors: colors),
                      );
                    },
                    onPinnedFilterChanged: (pinned) {
                      context.read<NotesBloc>().add(
                        UpdateNoteViewConfigEvent(filterPinned: pinned),
                      );
                    },
                    onMediaFilterChanged: (media) {
                      context.read<NotesBloc>().add(
                        UpdateNoteViewConfigEvent(filterWithMedia: media),
                      );
                    },
                  ),
                ),
              ),

              // Filter Chips Section
              SliverToBoxAdapter(child: _buildFilterChips(context, state)),

              // Notes Section Header
              if (!showSections &&
                  (pinnedNotes.isNotEmpty || unpinnedNotes.isNotEmpty))
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
                              'Sorted by ${sortOption.displayName} ${sortDescending ? '(newest first)' : '(oldest first)'}',
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
                              viewMode.displayName,
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
                              viewMode.icon,
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

              if (isLoading)
                SliverToBoxAdapter(child: _buildLoadingState(context)),

              if (isError) SliverToBoxAdapter(child: _buildErrorState(context)),

              if (isLoaded) ...[
                // Empty State
                if (pinnedNotes.isEmpty && unpinnedNotes.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child:
                        state.searchQuery.isNotEmpty ||
                            state.selectedTags.isNotEmpty ||
                            state.selectedColors.isNotEmpty ||
                            state.filterPinned ||
                            state.filterWithMedia
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64.sp,
                                  color: AppColors.getSecondaryTextColor(
                                    Theme.of(context).brightness,
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  'No matching notes',
                                  style: AppTypography.heading3(context),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  'Try adjusting your search or filters',
                                  style: AppTypography.bodyMedium(context),
                                ),
                              ],
                            ),
                          )
                        : const EmptyStateNotesHelpScreen(),
                  ),

                // Pinned Section
                if (showSections) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
                      child: Row(
                        children: [
                          Icon(
                            Icons.push_pin,
                            size: 14.sp,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'PINNED',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                              color: AppColors.getSecondaryTextColor(
                                Theme.of(context).brightness,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildNoteGridOrList(pinnedNotes, viewMode),
                  if (unpinnedNotes.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        child: Divider(
                          color: AppColors.getSecondaryTextColor(
                            Theme.of(context).brightness,
                          ).withOpacity(0.2),
                          thickness: 1,
                        ),
                      ),
                    ),
                ],

                // All Notes Section
                if (unpinnedNotes.isNotEmpty) ...[
                  if (showSections)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
                        child: Text(
                          'ALL NOTES',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                            color: AppColors.getSecondaryTextColor(
                              Theme.of(context).brightness,
                            ),
                          ),
                        ),
                      ),
                    ),
                  _buildNoteGridOrList(unpinnedNotes, viewMode),
                ],
              ],

              // Bottom padding
              SliverToBoxAdapter(child: SizedBox(height: 100.h)),
            ],
          );
        },
      ),

      floatingActionButton: GestureDetector(
        onLongPress: () => QuickAddBottomSheet.show(context),
        child: Semantics(
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
      ),
    );
  }

  Widget _buildTemplateSection(BuildContext context) {
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
          height: 160.h,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: _templates.length,
            itemBuilder: (context, index) {
              final template = _templates[index];
              return Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: _buildTemplateCard(context, template),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTemplateCard(BuildContext context, NoteTemplate template) {
    return GestureDetector(
      onTap: () => _createFromTemplate(context, template),
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

  Widget _buildLoadingState(BuildContext context) {
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

  Widget _buildErrorState(BuildContext context) {
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

  Widget _buildFilterChips(BuildContext context, NoteState state) {
    if (state is! NotesLoaded) return const SizedBox.shrink();

    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final List<Widget> chips = [];

    // Tag chips
    for (final tag in state.selectedTags) {
      chips.add(
        _buildChip(
          context,
          tag,
          Icons.tag,
          () => context.read<NotesBloc>().add(
            UpdateNoteViewConfigEvent(
              selectedTags: state.selectedTags.where((t) => t != tag).toList(),
            ),
          ),
        ),
      );
    }

    // Color chips
    for (final color in state.selectedColors) {
      chips.add(
        _buildChip(
          context,
          'Color',
          Icons.palette,
          () => context.read<NotesBloc>().add(
            UpdateNoteViewConfigEvent(
              selectedColors: state.selectedColors
                  .where((c) => c != color)
                  .toList(),
            ),
          ),
          color: color.toColor(isDarkMode),
        ),
      );
    }

    // Special filters
    if (state.filterPinned) {
      chips.add(
        _buildChip(
          context,
          'Pinned',
          Icons.push_pin,
          () => context.read<NotesBloc>().add(
            const UpdateNoteViewConfigEvent(filterPinned: false),
          ),
        ),
      );
    }

    if (state.filterWithMedia) {
      chips.add(
        _buildChip(
          context,
          'With Media',
          Icons.image,
          () => context.read<NotesBloc>().add(
            const UpdateNoteViewConfigEvent(filterWithMedia: false),
          ),
        ),
      );
    }

    if (state.filterWithReminders) {
      chips.add(
        _buildChip(
          context,
          'Reminders',
          Icons.notification_important,
          () => context.read<NotesBloc>().add(
            const UpdateNoteViewConfigEvent(filterWithReminders: false),
          ),
        ),
      );
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(children: chips),
    );
  }

  Widget _buildChip(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onDeleted, {
    Color? color,
  }) {
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: InputChip(
        label: Text(label),
        avatar: Icon(icon, size: 14.sp, color: color ?? AppColors.primary),
        onDeleted: onDeleted,
        backgroundColor: (color ?? AppColors.primary).withOpacity(0.1),
        labelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
      ),
    );
  }

  // Helper Methods for View Options
  void _showViewOptionsSheet(BuildContext context, NoteState state) {
    if (state is! NotesLoaded) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (mContext) => NotesViewOptionsSheet(
        currentViewMode: state.viewMode,
        currentSortOption: state.sortBy,
        sortDescending: state.sortDescending,
        onViewModeChanged: (mode) {
          context.read<NotesBloc>().add(
            UpdateNoteViewConfigEvent(viewMode: mode),
          );
        },
        onSortChanged: (option, descending) {
          context.read<NotesBloc>().add(
            UpdateNoteViewConfigEvent(
              sortBy: option,
              sortDescending: descending,
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoteGridOrList(List<Note> notes, NoteViewMode viewMode) {
    if (viewMode == NoteViewMode.grid) {
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
            final note = notes[index];
            return NoteCardWidget(
              note: note,
              isGridView: true,
              onTap: () => Navigator.pushNamed(
                context,
                '/notes/editor',
                arguments: {'note': note},
              ),
              onLongPress: () => _showNoteContextMenu(context, note),
            );
          }, childCount: notes.length),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final note = notes[index];
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Dismissible(
              key: Key('note_${note.id}'),
              direction: DismissDirection.horizontal,
              background: Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 20.w),
                color: AppColors.primary,
                child: const Icon(Icons.archive_outlined, color: Colors.white),
              ),
              secondaryBackground: Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 20.w),
                color: AppColors.errorColor,
                child: const Icon(Icons.delete_outline, color: Colors.white),
              ),
              onDismissed: (direction) {
                if (direction == DismissDirection.startToEnd) {
                  context.read<NotesBloc>().add(
                    ToggleArchiveNoteEvent(
                      NoteParams.fromNote(note).toggleArchive(),
                    ),
                  );
                } else {
                  context.read<NotesBloc>().add(DeleteNoteEvent(note.id));
                }
              },
              child: NoteCardWidget(
                note: note,
                isGridView: false,
                onTap: () => Navigator.pushNamed(
                  context,
                  '/notes/editor',
                  arguments: {'note': note},
                ),
                onLongPress: () => _showNoteContextMenu(context, note),
              ),
            ),
          );
        }, childCount: notes.length),
      ),
    );
  }

  void _showNoteContextMenu(BuildContext context, Note note) {
    final params = NoteParams.fromNote(note);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                  color: AppColors.textPrimary(context),
                ),
                title: Text(
                  note.isPinned ? 'Unpin Note' : 'Pin Note',
                  style: AppTypography.bodyLarge(context),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.read<NotesBloc>().add(
                    TogglePinNoteEvent(params.togglePin()),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.archive_outlined,
                  color: AppColors.textPrimary(context),
                ),
                title: Text(
                  'Archive Note',
                  style: AppTypography.bodyLarge(context),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.read<NotesBloc>().add(
                    ToggleArchiveNoteEvent(params.toggleArchive()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: AppColors.errorColor,
                ),
                title: Text(
                  'Delete Note',
                  style: AppTypography.bodyLarge(
                    context,
                  ).copyWith(color: AppColors.errorColor),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.read<NotesBloc>().add(DeleteNoteEvent(note.id));
                },
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.archive_outlined,
                  color: AppColors.textPrimary(context),
                ),
                title: Text(
                  'Archived Notes',
                  style: AppTypography.bodyLarge(context),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.archivedNotes);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.settings_outlined,
                  color: AppColors.textPrimary(context),
                ),
                title: Text(
                  'Notes Settings',
                  style: AppTypography.bodyLarge(context),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to notes settings
                },
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
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
