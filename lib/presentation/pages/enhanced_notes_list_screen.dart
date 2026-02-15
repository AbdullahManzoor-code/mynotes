import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/core/services/app_logger.dart';
import 'package:mynotes/presentation/pages/archived_notes_screen.dart'
    show ArchivedNotesScreen;
import 'package:mynotes/presentation/widgets/notes_search_bar.dart'
    show NotesSearchBar;
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mynotes/domain/entities/note.dart';
import 'dart:ui' as ui;
import 'package:mynotes/presentation/design_system/design_system.dart';
import 'package:mynotes/presentation/bloc/note/note_bloc.dart';
import 'package:mynotes/presentation/bloc/note/note_state.dart';
import 'package:mynotes/presentation/widgets/note_card_widget.dart';
import 'package:mynotes/presentation/widgets/notes_view_options_sheet.dart';
// import 'package:mynotes/presentation/widgets/notes_search_bar.dart';

import 'package:mynotes/presentation/bloc/params/note_params.dart';
import '../bloc/note/note_event.dart';
import '../widgets/animated_list_grid_view.dart';

/// Simple template data class for note templates
class SimpleNoteTemplate {
  final String title;
  final IconData icon;
  final Color color;
  final String description;

  const SimpleNoteTemplate({
    required this.title,
    required this.icon,
    required this.color,
    required this.description,
  });
}

/// Enhanced Notes List with Templates Screen
/// Modern notes list interface with template picker
/// Based on notes_list_and_templates_1 template
class EnhancedNotesListScreen extends StatefulWidget {
  const EnhancedNotesListScreen({super.key});

  @override
  State<EnhancedNotesListScreen> createState() =>
      _EnhancedNotesListScreenState();
}

class _EnhancedNotesListScreenState extends State<EnhancedNotesListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    AppLogger.i('Initializing EnhancedNotesListScreen');
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    AppLogger.i('Notes list tab switched to: ${_tabController.index}');
    if (_tabController.index == 1) {
      // Load Archived Notes when switching to second tab
      context.read<NotesBloc>().add(const LoadArchivedNotesEvent());
    } else {
      // Load active notes when switching back to first tab
      context.read<NotesBloc>().add(const LoadNotesEvent());
    }
  }

  @override
  void dispose() {
    AppLogger.i('Disposing EnhancedNotesListScreen');
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  static final List<SimpleNoteTemplate> _templates = [
    SimpleNoteTemplate(
      title: 'Meeting Notes',
      icon: Icons.groups,
      color: AppColors.primary,
      description: 'Capture meeting discussions and action items',
    ),
    SimpleNoteTemplate(
      title: 'Shopping List',
      icon: Icons.shopping_cart,
      color: AppColors.accentOrange,
      description: 'Create organized shopping lists',
    ),
    SimpleNoteTemplate(
      title: 'Daily Journal',
      icon: Icons.book,
      color: AppColors.accentPurple,
      description: 'Reflect on your day and thoughts',
    ),
    SimpleNoteTemplate(
      title: 'Project Plan',
      icon: Icons.business_center,
      color: AppColors.accentGreen,
      description: 'Plan and track project milestones',
    ),
    SimpleNoteTemplate(
      title: 'Travel Plan',
      icon: Icons.flight_takeoff,
      color: AppColors.accentBlue,
      description: 'Organize your travel itinerary',
    ),
    SimpleNoteTemplate(
      title: 'Recipe',
      icon: Icons.restaurant,
      color: AppColors.accentYellow,
      description: 'Save your favorite recipes',
    ),
  ];

  void _createFromTemplate(BuildContext context, SimpleNoteTemplate template) {
    AppLogger.i('Creating note from template: ${template.title}');
    Navigator.pushNamed(
      context,
      '/notes/editor',
      arguments: {
        'template': template.title,
        'content': _getTemplateContent(template),
      },
    );
  }

  String _getTemplateContent(SimpleNoteTemplate template) {
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
      backgroundColor: AppColors.background(context),
      extendBodyBehindAppBar: true,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'enhanced_notes_fab',
        onPressed: () {
          AppLogger.i('EnhancedNotesListScreen: New Note FAB pressed');
          Navigator.pushNamed(context, '/notes/editor');
        },
        backgroundColor: AppColors.primary,
        elevation: 8,
        highlightElevation: 0,
        label: Text(
          'New Note',
          style: AppTypography.buttonMedium(
            context,
            Colors.white,
          ).copyWith(fontWeight: FontWeight.w700),
        ),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: Stack(
        children: [
          // Background Glow
          Positioned(
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
          ),

          BlocBuilder<NotesBloc, NoteState>(
            builder: (context, state) {
              final bool isLoading = state is NoteLoading;
              final bool isError = state is NoteError;
              final bool isLoaded = state is NotesLoaded;
              final bool isArchived = state is ArchivedNotesLoaded;

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
                  state.selectedColors.isEmpty;

              final viewMode = isLoaded ? state.viewMode : NoteViewMode.list;

              return NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  // Premium Glass AppBar
                  SliverAppBar(
                    floating: true,
                    snap: true,
                    pinned: true,
                    expandedHeight: 160.h,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    scrolledUnderElevation: 0,
                    flexibleSpace: FlexibleSpaceBar(
                      background: GlassContainer(
                        blur: 20,
                        color: AppColors.surface(context).withOpacity(0.4),
                        borderRadius: 0,
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.primary.withOpacity(0.1),
                            width: 1.h,
                          ),
                        ),
                        child: const SizedBox.expand(),
                      ),
                      titlePadding: EdgeInsets.only(left: 20.w, bottom: 62.h),
                      title: Text(
                        'Think Tank',
                        style: AppTypography.heading1(context).copyWith(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                    bottom: PreferredSize(
                      preferredSize: Size.fromHeight(48.h),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: 20.w),
                          child: TabBar(
                            controller: _tabController,
                            isScrollable: true,
                            indicatorColor: AppColors.primary,
                            indicatorWeight: 3,
                            indicatorSize: TabBarIndicatorSize.label,
                            labelColor: AppColors.primary,
                            labelStyle: AppTypography.bodyLarge(context),
                            unselectedLabelColor: AppColors.textSecondary(
                              context,
                            ),
                            unselectedLabelStyle: AppTypography.bodyMedium(
                              context,
                            ),
                            tabs: const [
                              Tab(text: 'All Notes'),
                              Tab(text: 'Archive'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    actions: [
                      IconButton(
                        onPressed: () {
                          if (isLoaded) {
                            AppLogger.i(
                              'EnhancedNotesListScreen: Toggled view mode',
                            );
                            HapticFeedback.lightImpact();
                            context.read<NotesBloc>().add(
                              UpdateNoteViewConfigEvent(
                                viewMode: state.viewMode == NoteViewMode.list
                                    ? NoteViewMode.grid
                                    : NoteViewMode.list,
                              ),
                            );
                          }
                        },
                        icon: Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            viewMode == NoteViewMode.list
                                ? Icons.grid_view_rounded
                                : Icons.view_list_rounded,
                            color: AppColors.primary,
                            size: 20.sp,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (isLoaded) {
                            AppLogger.i(
                              'EnhancedNotesListScreen: Opening view options sheet',
                            );
                            _showViewOptionsSheet(
                              context,
                              state as NotesLoaded,
                            );
                          }
                        },
                        icon: Icon(
                          Icons.tune_rounded,
                          color: AppColors.textPrimary(context),
                          size: 22.sp,
                        ),
                      ),
                      SizedBox(width: 8.w),
                    ],
                  ),
                ],
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: All Notes
                    CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        // Template Picker Section
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.only(top: 16.h),
                            child: _buildTemplateSection(context),
                          ),
                        ),

                        // Search Bar Section
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 16.h,
                            ),
                            child: const NotesSearchBar(),
                          ),
                        ),

                        // Filter Chips Section
                        SliverToBoxAdapter(
                          child: _buildFilterChips(context, state),
                        ),

                        // Status Info
                        if (isLoaded && !isLoading)
                          SliverToBoxAdapter(
                            child: _buildCollectionStats(context, state),
                          ),

                        if (isLoading)
                          SliverToBoxAdapter(
                            child: _buildLoadingState(context),
                          ),

                        if (isError)
                          SliverToBoxAdapter(child: _buildErrorState(context)),

                        if (isLoaded) ...[
                          if (pinnedNotes.isEmpty && unpinnedNotes.isEmpty)
                            const SliverFillRemaining(
                              hasScrollBody: false,
                              child: EmptyStateNotes(),
                            )
                          else
                            _buildNotesGridSection(
                              context,
                              state as NotesLoaded,
                              pinnedNotes,
                              unpinnedNotes,
                              showSections,
                              viewMode,
                            ),
                        ],

                        // Padding at the bottom for FAB
                        SliverToBoxAdapter(child: SizedBox(height: 100.h)),
                      ],
                    ),

                    // Tab 2: Archive
                    const ArchivedNotesScreen(showAppBar: false),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotesGridSection(
    BuildContext context,
    NotesLoaded state,
    List<Note> pinnedNotes,
    List<Note> unpinnedNotes,
    bool showSections,
    NoteViewMode viewMode,
  ) {
    return SliverMainAxisGroup(
      slivers: [
        if (showSections && pinnedNotes.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 16.w, 12.h),
              child: Row(
                children: [
                  Icon(Icons.push_pin, size: 14.sp, color: AppColors.primary),
                  SizedBox(width: 8.w),
                  Text(
                    'PINNED',
                    style: AppTypography.caption(context).copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: AppColors.textSecondary(context),
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
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Divider(
                  color: AppColors.primary.withOpacity(0.1),
                  thickness: 1,
                ),
              ),
            ),
        ],

        if (unpinnedNotes.isNotEmpty) ...[
          if (showSections)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 16.w, 12.h),
                child: Text(
                  'ALL NOTES',
                  style: AppTypography.caption(context).copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ),
            ),
          _buildNoteGridOrList(unpinnedNotes, viewMode),
        ],
      ],
    );
  }

  Widget _buildCollectionStats(BuildContext context, NotesLoaded state) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              '${state.displayedNotes.length} Thoughts',
              style: AppTypography.captionSmall(
                context,
              ).copyWith(color: AppColors.primary, fontWeight: FontWeight.w800),
            ),
          ),
          const Spacer(),
          Text(
            state.sortBy.displayName,
            style: AppTypography.captionSmall(context).copyWith(
              color: AppColors.textSecondary(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          Icon(
            state.sortDescending
                ? Icons.arrow_downward_rounded
                : Icons.arrow_upward_rounded,
            size: 14.sp,
            color: AppColors.textSecondary(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 16.w, 12.h),
          child: Row(
            children: [
              Text(
                'BRAINSTORMING KITS',
                style: AppTypography.caption(context).copyWith(
                  color: AppColors.textSecondary(context),
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              Text(
                'Explore All',
                style: AppTypography.captionSmall(context).copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 14.sp,
                color: AppColors.primary,
              ),
            ],
          ),
        ),

        SizedBox(
          height: 110.h,
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

  Widget _buildTemplateCard(BuildContext context, SimpleNoteTemplate template) {
    return GestureDetector(
      onTap: () {
        AppLogger.i(
          'EnhancedNotesListScreen: Template card tapped: ${template.title}',
        );
        HapticFeedback.mediumImpact();
        _createFromTemplate(context, template);
      },
      child: SizedBox(
        width: 140.w,
        child: GlassContainer(
          borderRadius: 24.r,
          blur: 10,
          color: template.color.withOpacity(0.08),
          border: Border.all(color: template.color.withOpacity(0.2)),
          padding: EdgeInsets.all(12.r),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: template.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(template.icon, color: template.color, size: 20.sp),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.title.split(' ')[0],
                      style: AppTypography.bodySmall(context).copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      template.title.contains(' ')
                          ? template.title.split(' ')[1]
                          : 'Kit',
                      style: AppTypography.captionSmall(
                        context,
                      ).copyWith(color: AppColors.textSecondary(context)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.getSecondaryTextColor(
        Theme.of(context).brightness,
      ).withOpacity(0.1),
      highlightColor: AppColors.getSecondaryTextColor(
        Theme.of(context).brightness,
      ).withOpacity(0.2),
      child: Column(
        children: List.generate(
          3,
          (index) => Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            child: Container(
              height: 120.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ),
        ),
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
        onDeleted: () {
          AppLogger.i('EnhancedNotesListScreen: Filter chip deleted: $label');
          onDeleted();
        },
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
          AppLogger.i('EnhancedNotesListScreen: View mode changed to: $mode');
          context.read<NotesBloc>().add(
            UpdateNoteViewConfigEvent(viewMode: mode),
          );
        },
        onSortChanged: (option, descending) {
          AppLogger.i(
            'EnhancedNotesListScreen: Sort option changed: $option, descending: $descending',
          );
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
        sliver: SliverMasonryGrid.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12.h,
          crossAxisSpacing: 12.w,
          itemBuilder: (context, index) {
            final note = notes[index];
            return NoteCardWidget(
              note: note,
              isGridView: true,
              onTap: () {
                AppLogger.i(
                  'EnhancedNotesListScreen: Note tapped (grid): ${note.id}',
                );
                Navigator.pushNamed(
                  context,
                  '/notes/editor',
                  arguments: {'note': note},
                );
              },
              onLongPress: () {
                AppLogger.i(
                  'EnhancedNotesListScreen: Note long pressed (grid): ${note.id}',
                );
                _showNoteContextMenu(context, note);
              },
            );
          },
          childCount: notes.length,
        ),
      );
    }

    return SliverToBoxAdapter(
      child: AnimatedListView(
        items: notes,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
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
                  AppLogger.i(
                    'EnhancedNotesListScreen: Note archived via swipe: ${note.id}',
                  );
                  context.read<NotesBloc>().add(
                    ToggleArchiveNoteEvent(
                      NoteParams.fromNote(note).toggleArchive(),
                    ),
                  );
                } else {
                  AppLogger.i(
                    'EnhancedNotesListScreen: Note deleted via swipe: ${note.id}',
                  );
                  context.read<NotesBloc>().add(DeleteNoteEvent(note.id));
                }
              },
              child: NoteCardWidget(
                note: note,
                isGridView: false,
                onTap: () {
                  AppLogger.i(
                    'EnhancedNotesListScreen: Note tapped (list): ${note.id}',
                  );
                  Navigator.pushNamed(
                    context,
                    '/notes/editor',
                    arguments: {'note': note},
                  );
                },
                onLongPress: () {
                  AppLogger.i(
                    'EnhancedNotesListScreen: Note long pressed (list): ${note.id}',
                  );
                  _showNoteContextMenu(context, note);
                },
              ),
            ),
          );
        },
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
                  AppLogger.i(
                    'EnhancedNotesListScreen: Context menu - Pin/Unpin tapped: ${note.id}',
                  );
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
                  AppLogger.i(
                    'EnhancedNotesListScreen: Context menu - Archive tapped: ${note.id}',
                  );
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
                  AppLogger.i(
                    'EnhancedNotesListScreen: Context menu - Delete tapped: ${note.id}',
                  );
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
}
