// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:mynotes/core/extensions/context_extensions.dart';
// import 'dart:ui' as ui;
// import 'package:mynotes/core/services/app_logger.dart';
// import 'package:mynotes/domain/entities/note.dart';
// import 'package:mynotes/presentation/bloc/params/note_params.dart';
// import 'package:mynotes/presentation/design_system/design_system.dart';
// import 'package:mynotes/presentation/bloc/note/note_bloc.dart';
// import 'package:mynotes/presentation/bloc/note/note_state.dart';
// import 'package:mynotes/presentation/bloc/note/note_event.dart';
// import 'package:mynotes/presentation/widgets/note/note_widgets.dart';
// import 'package:mynotes/core/constants/app_strings.dart';

// /// Refactored Enhanced Notes List Screen - StatelessWidget with BLoC
// /// ============================================================================
// /// IMPLEMENTATION PLAN:
// /// ============================================================================
// /// 1. STATE MANAGEMENT: All state handled by NotesBloc
// ///    - Notes list (pinned/unpinned)
// ///    - Search query
// ///    - Filter state
// ///    - View mode (list/grid)
// ///    - Loading/error states
// ///
// /// 2. BLoC EVENTS DISPATCHED:
// ///    - LoadNotesEvent() - Load all notes
// ///    - LoadArchivedNotesEvent() - Load archived notes
// ///    - SearchNotesEvent(query) - Search notes by query
// ///    - DeleteNoteEvent(id) - Delete note
// ///    - TogglePinNoteEvent(id) - Pin/unpin note
// ///    - ToggleArchiveNoteEvent(id) - Archive/restore note
// ///
// /// 3. MAIN BUILD STRUCTURE:
// ///    - BLocBuilder<NotesBloc> wraps entire content
// ///    - Handles: Loading, Error, Empty, Loaded states
// ///    - Passes appropriate data to child widgets
// ///
// /// 4. WIDGET COMPOSITION:
// ///    - NotesListHeader - Search & filters (BLocBuilder)
// ///    - NotesTemplateSection - Template picker (StatelessWidget)
// ///    - NotesList - Note display (BLocBuilder state-dependent)
// ///
// /// 5. RESPONSIVE DESIGN:
// ///    All widgets use flutter_screenutil (.w, .h, .r, .sp)
// ///    - Mobile: Single column, auto-layout
// ///    - Tablet: Grid view option, centered
// ///    - Desktop: Full width with constraints
// /// ============================================================================

// /// Enhanced Notes List Screen - StatelessWidget
// /// Enhanced Notes List Screen - StatelessWidget
// /// NOTE: References to NotesBloc are commented out pending implementation.
// /// This screen serves as a template for the architecture but requires:
// /// 1. NotesBloc implementation with LoadNotesEvent, SearchNotesEvent, etc.
// /// 2. NotesState implementations (Loading, Loaded, Error, Empty)
// /// 3. Integration with existing note management BLoCs
// class EnhancedNotesListScreenRefactored extends StatelessWidget {
//   const EnhancedNotesListScreenRefactored({super.key});

//   static final List<NoteTemplate> _templates = [
//     NoteTemplate(
//       title: 'Meeting Notes',
//       icon: Icons.groups,
//       color: AppColors.primary,
//       description: 'Capture discussions',
//       contentGenerator: _generateMeetingTemplate,
//     ),
//     NoteTemplate(
//       title: 'Shopping List',
//       icon: Icons.shopping_cart,
//       color: AppColors.accentOrange,
//       description: 'Organize shopping',
//       contentGenerator: _generateShoppingTemplate,
//     ),
//     NoteTemplate(
//       title: 'Daily Journal',
//       icon: Icons.book,
//       color: AppColors.accentPurple,
//       description: 'Reflect daily',
//       contentGenerator: _generateJournalTemplate,
//     ),
//     NoteTemplate(
//       title: 'Project Plan',
//       icon: Icons.business_center,
//       color: AppColors.accentGreen,
//       description: 'Track milestones',
//       contentGenerator: _generateProjectTemplate,
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     AppLogger.i('Building EnhancedNotesListScreenRefactored');

//     // Load notes on widget creation
//     context.read<NotesBloc>().add(const LoadNotesEvent());

//     return Scaffold(
//       backgroundColor: AppColors.background(context),
//       extendBodyBehindAppBar: true,
//       floatingActionButton: _buildFAB(context),
//       body: Stack(
//         children: [
//           // Background glow effect
//           _buildBackgroundGlow(context),
//           // Main content with BLoC builder
//           _buildMainContent(context),
//         ],
//       ),
//     );
//   }

//   /// ════════════════════════════════════════════════════════════════════════
//   /// MAIN CONTENT BUILDER - Handles all BLoC state
//   /// ════════════════════════════════════════════════════════════════════════
//   Widget _buildMainContent(BuildContext context) {
//     return BlocBuilder<NotesBloc, NoteState>(
//       builder: (context, state) {
//         AppLogger.i('NotesBloc state: ${state.runtimeType}');

//         // Handle different states
//         if (state is NoteLoading) {
//           return _buildLoadingState(context);
//         } else if (state is NoteError) {
//           return _buildErrorState(context, state);
//         } else if (state is NoteEmpty) {
//           return _buildEmptyState(context);
//         } else if (state is NotesLoaded) {
//           return _buildNotesLoadedState(context, state);
//         }

//         return const SizedBox.shrink();
//       },
//     );
//   }

//   /// ════════════════════════════════════════════════════════════════════════
//   /// STATE: LOADING
//   /// ════════════════════════════════════════════════════════════════════════
//   Widget _buildLoadingState(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           SizedBox(
//             width: 50.r,
//             height: 50.r,
//             child: const CircularProgressIndicator(),
//           ),
//           SizedBox(height: 16.h),
//           Text(
//             AppStrings.loading,
//             style: AppTypography.body1(context).copyWith(fontSize: 14.sp),
//           ),
//         ],
//       ),
//     );
//   }

//   /// ════════════════════════════════════════════════════════════════════════
//   /// STATE: ERROR
//   /// ════════════════════════════════════════════════════════════════════════
//   Widget _buildErrorState(BuildContext context, NoteError error) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.error_outline, size: 60.r, color: context.errorColor),
//           SizedBox(height: 16.h),
//           Text(
//             AppStrings.error,
//             style: AppTypography.heading2(
//               context,
//             ).copyWith(fontSize: 18.sp, color: context.errorColor),
//           ),
//           SizedBox(height: 8.h),
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 32.w),
//             child: Text(
//               error.message,
//               textAlign: TextAlign.center,
//               style: AppTypography.body2(context).copyWith(fontSize: 14.sp),
//             ),
//           ),
//           SizedBox(height: 24.h),
//           ElevatedButton(
//             onPressed: () =>
//                 context.read<NotesBloc>().add(const LoadNotesEvent()),
//             child: Text(AppStrings.retry),
//           ),
//         ],
//       ),
//     );
//   }

//   /// ════════════════════════════════════════════════════════════════════════
//   /// STATE: EMPTY
//   /// ════════════════════════════════════════════════════════════════════════
//   Widget _buildEmptyState(BuildContext context) {
//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           SizedBox(height: kToolbarHeight),
//           Padding(
//             padding: EdgeInsets.all(24.w),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.note_outlined,
//                   size: 100.r,
//                   color: context.theme.disabledColor,
//                 ),
//                 SizedBox(height: 24.h),
//                 Text(
//                   'No Notes Yet',
//                   style: AppTypography.heading2(context).copyWith(
//                     fontSize: 20.sp,
//                     color: context.theme.disabledColor,
//                   ),
//                 ),
//                 SizedBox(height: 8.h),
//                 Text(
//                   'Create your first note to get started',
//                   textAlign: TextAlign.center,
//                   style: AppTypography.body2(context).copyWith(
//                     fontSize: 14.sp,
//                     color: context.theme.disabledColor.withOpacity(0.7),
//                   ),
//                 ),
//                 SizedBox(height: 32.h),
//                 NotesTemplateSection(
//                   templates: _templates,
//                   onTemplateSelected: _createFromTemplate,
//                   isExpanded: true,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   /// ════════════════════════════════════════════════════════════════════════
//   /// STATE: LOADED - Main content layout
//   /// ════════════════════════════════════════════════════════════════════════
//   Widget _buildNotesLoadedState(BuildContext context, NotesLoaded state) {
//     final pinnedNotes = state.displayedNotes.where((n) => n.isPinned).toList();
//     final unpinnedNotes = state.displayedNotes
//         .where((n) => !n.isPinned)
//         .toList();

//     return Column(
//       children: [
//         SizedBox(height: kToolbarHeight),
//         // Search & Filter Header
//         _buildHeaderSection(context, state),
//         // Template Section
//         NotesTemplateSection(
//           templates: _templates,
//           onTemplateSelected: _createFromTemplate,
//           isExpanded: state is NotesLoaded && pinnedNotes.isEmpty,
//         ),
//         // Notes List
//         Expanded(
//           child: NotesList(
//             pinnedNotes: pinnedNotes,
//             unpinnedNotes: unpinnedNotes,
//             onNoteTap: (note) {
//               AppLogger.i('Note tapped: ${note.id}');
//               Navigator.pushNamed(
//                 context,
//                 '/notes/editor',
//                 arguments: {'note': note},
//               );
//             },
//             onNoteDelete: (note) {
//               AppLogger.i('Note delete requested: ${note.id}');
//               context.read<NotesBloc>().add(DeleteNoteEvent(note.id));
//             },
//             onNotePin: (note) {
//               AppLogger.i('Note pin toggled: ${note.id}');
//               final params = NoteParams.fromNote(note).togglePin();
//               context.read<NotesBloc>().add(TogglePinNoteEvent(params));
//             },
//             onNoteArchive: (note) {
//               AppLogger.i('Note archive toggled: ${note.id}');
//               final params = NoteParams.fromNote(note).toggleArchive();
//               context.read<NotesBloc>().add(ToggleArchiveNoteEvent(params));
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   /// ════════════════════════════════════════════════════════════════════════
//   /// HEADER SECTION - Search, Filter, View Options
//   /// ════════════════════════════════════════════════════════════════════════
//   Widget _buildHeaderSection(BuildContext context, NotesLoaded state) {
//     return NotesListHeader(
//       searchQuery: state.searchQuery,
//       onSearchChanged: (query) {
//         AppLogger.i('Searching notes: $query');
//         context.read<NotesBloc>().add(SearchNotesEvent(query));
//       },
//       onFilterTap: () {
//         AppLogger.i('Filter tapped');
//         // Show filter bottom sheet
//         _showFilterBottomSheet(context);
//       },
//       onViewOptionsTap: () {
//         AppLogger.i('View options tapped');
//         // Show view options
//         _showViewOptionsBottomSheet(context);
//       },
//     );
//   }

//   /// ════════════════════════════════════════════════════════════════════════
//   /// BACKGROUND GLOW
//   /// ════════════════════════════════════════════════════════════════════════
//   Widget _buildBackgroundGlow(BuildContext context) {
//     return Positioned(
//       top: -100.h,
//       right: -100.w,
//       child: Container(
//         width: 300.w,
//         height: 300.h,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: AppColors.primary.withOpacity(0.08),
//         ),
//         child: BackdropFilter(
//           filter: ui.ImageFilter.blur(sigmaX: 100, sigmaY: 100),
//           child: Container(color: Colors.transparent),
//         ),
//       ),
//     );
//   }

//   /// ════════════════════════════════════════════════════════════════════════
//   /// FLOATING ACTION BUTTON
//   /// ════════════════════════════════════════════════════════════════════════
//   Widget _buildFAB(BuildContext context) {
//     return FloatingActionButton.extended(
//       heroTag: 'notes_fab',
//       onPressed: () {
//         AppLogger.i('New Note FAB pressed');
//         Navigator.pushNamed(context, '/notes/editor');
//       },
//       backgroundColor: AppColors.primary,
//       elevation: 8,
//       label: Text(
//         AppStrings.newNote,
//         style: AppTypography.buttonMedium(context, Colors.white),
//       ),
//       icon: const Icon(Icons.add_rounded, color: Colors.white),
//     );
//   }

//   /// ════════════════════════════════════════════════════════════════════════
//   /// HELPER METHODS
//   /// ════════════════════════════════════════════════════════════════════════

//   void _createFromTemplate(NoteTemplate template) {
//     AppLogger.i('Creating note from template: ${template.title}');
//   }

//   void _showFilterBottomSheet(BuildContext context) {
//     AppLogger.i('Showing filter bottom sheet');
//     // TODO: Implement filter sheet
//   }

//   void _showViewOptionsBottomSheet(BuildContext context) {
//     AppLogger.i('Showing view options bottom sheet');
//     // TODO: Implement view options sheet
//   }

//   /// ════════════════════════════════════════════════════════════════════════
//   /// TEMPLATE CONTENT GENERATORS
//   /// ════════════════════════════════════════════════════════════════════════

//   static String _generateMeetingTemplate() =>
//       '''# Meeting Notes

// **Date:** ${DateTime.now().toString().split(' ')[0]}
// **Attendees:** 

// ## Discussion Points
// - 

// ## Action Items
// - [ ] 
// ''';

//   static String _generateShoppingTemplate() => '''# Shopping List

// ## Groceries
// - [ ] 

// ## Household Items
// - [ ] 
// ''';

//   static String _generateJournalTemplate() =>
//       '''# Daily Journal - ${DateTime.now().toString().split(' ')[0]}

// ## How I'm feeling today

// ## What happened today

// ## Grateful for
// ''';

//   static String _generateProjectTemplate() => '''# Project Plan

// ## Overview

// ## Goals
// - [ ] 

// ## Timeline
// ''';
// }
