import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mynotes/presentation/design_system/app_typography.dart';
import '../../presentation/design_system/app_colors.dart';
import '../../domain/entities/note.dart';
import '../bloc/note_bloc.dart';
import '../bloc/note_state.dart';
import '../bloc/note_event.dart';
import '../widgets/note_card_widget.dart';
import 'note_editor_page.dart';
import 'settings_screen.dart';
import 'search_filter_screen.dart';
import '../screens/reflection_home_screen.dart';
import 'reminders_screen.dart';
import 'todo_focus_screen.dart';
import 'focus_session_screen.dart';
import '../widgets/command_palette.dart';
import '../widgets/quick_add_bottom_sheet.dart';
import '../widgets/empty_state_notes.dart';

/// Modern Advanced Home Screen with categorized views
class ModernHomeScreen extends StatefulWidget {
  const ModernHomeScreen({Key? key}) : super(key: key);

  @override
  State<ModernHomeScreen> createState() => _ModernHomeScreenState();
}

class _ModernHomeScreenState extends State<ModernHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _categories = [
    'All',
    'Pinned',
    'Recent',
    'Work',
    'Personal',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    context.read<NotesBloc>().add(const LoadNotesEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          // Modern Sliver AppBar
          SliverAppBar(
            expandedHeight: 200.h,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: isDark
                ? AppColors.darkBackground
                : AppColors.primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            AppColors.darkBackground,
                            AppColors.primaryColor.withOpacity(0.3),
                          ]
                        : [AppColors.primaryColor, AppColors.primaryColorLight],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'My Notes',
                          style: TextStyle(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        BlocBuilder<NotesBloc, NoteState>(
                          builder: (context, state) {
                            int count = 0;
                            String displayText = 'Loading...';

                            if (state is NotesLoaded) {
                              count = state.notes.length;
                              displayText =
                                  '$count notes • ${DateTime.now().toString().split(' ')[0]}';
                            } else if (state is NoteError) {
                              displayText = 'Error loading notes';
                            } else if (state is NoteLoading) {
                              displayText = 'Loading notes...';
                            }

                            return Text(
                              displayText,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.white70,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              title: null,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SearchFilterScreen(),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),

          // Quick Action Cards
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    height: 120.h,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildQuickActionCard(
                          context,
                          'New Note',
                          Icons.note_add,
                          [AppColors.primaryColor, AppColors.primaryColorLight],
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NoteEditorPage(),
                              ),
                            );
                          },
                        ),
                        _buildQuickActionCard(
                          context,
                          'Reflection',
                          Icons.psychology,
                          [Colors.purple, Colors.purpleAccent],
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ReflectionHomeScreen(),
                              ),
                            );
                          },
                        ),
                        _buildQuickActionCard(
                          context,
                          'Reminders',
                          Icons.alarm,
                          [Colors.orange, Colors.orangeAccent],
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RemindersScreen(),
                              ),
                            );
                          },
                        ),
                        _buildQuickActionCard(
                          context,
                          'Todo Focus',
                          Icons.check_circle,
                          [Colors.green, Colors.greenAccent],
                          () {
                            // Get first note with todos
                            final state = context.read<NotesBloc>().state;
                            if (state is NotesLoaded) {
                              final noteWithTodos = state.notes.firstWhere(
                                (n) => n.todos != null && n.todos!.isNotEmpty,
                                orElse: () => state.notes.first,
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      TodoFocusScreen(note: noteWithTodos),
                                ),
                              );
                            }
                          },
                        ),
                        _buildQuickActionCard(
                          context,
                          'Focus Timer',
                          Icons.timer_outlined,
                          [Colors.teal, Colors.tealAccent],
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const FocusSessionScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Category Tabs
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: AppColors.primaryColor,
                labelColor: isDark ? Colors.white : AppColors.primaryColor,
                unselectedLabelColor: Colors.grey,
                tabs: _categories.map((cat) => Tab(text: cat)).toList(),
              ),
            ),
          ),

          // Notes Grid
          BlocBuilder<NotesBloc, NoteState>(
            builder: (context, state) {
              if (state is NoteLoading) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (state is NotesLoaded) {
                final notes = _filterNotesByCategory(
                  state.notes,
                  _categories[_tabController.index],
                );

                if (notes.isEmpty) {
                  return const SliverFillRemaining(child: EmptyStateNotes());
                }

                return SliverPadding(
                  padding: EdgeInsets.all(16.w),
                  sliver: SliverMasonryGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12.h,
                    crossAxisSpacing: 12.w,
                    childCount: notes.length,
                    itemBuilder: (context, index) {
                      return NoteCardWidget(
                        note: notes[index],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  NoteEditorPage(note: notes[index]),
                            ),
                          );
                        },
                        onLongPress: () {},
                        onDelete: () {},
                        onPin: () {},
                        onColorChange: (val) {},
                      );
                    },
                  ),
                );
              }

              if (state is NoteError) {
                return SliverFillRemaining(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.errorColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading notes',
                          style: AppTypography.heading3(
                            context,
                            Theme.of(context).colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          style: AppTypography.bodyMedium(
                            context,
                            Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            context.read<NotesBloc>().add(
                              const LoadNotesEvent(),
                            );
                          },
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return const SliverFillRemaining(
                child: Center(child: Text('Failed to load notes')),
              );
            },
          ),
        ],
      ),

      // Floating Action Button with Speed Dial
      floatingActionButton: _buildSpeedDial(context),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    IconData icon,
    List<Color> gradient,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140.w,
        margin: EdgeInsets.only(right: 12.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40.sp, color: Colors.white),
            SizedBox(height: 8.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Note> _filterNotesByCategory(List<Note> notes, String category) {
    switch (category) {
      case 'Pinned':
        return notes.where((n) => n.isPinned).toList();
      case 'Recent':
        final now = DateTime.now();
        return notes.where((n) {
          final diff = now.difference(n.updatedAt).inDays;
          return diff <= 7;
        }).toList();
      case 'Work':
        return notes.where((n) => n.tags.contains('work')).toList();
      case 'Personal':
        return notes.where((n) => n.tags.contains('personal')).toList();
      default:
        return notes;
    }
  }

  Widget _buildSpeedDial(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Command Palette
        FloatingActionButton.small(
          heroTag: 'command_palette',
          onPressed: () {
            CommandPalette.show(context);
          },
          backgroundColor: AppColors.primaryColor.withOpacity(0.9),
          child: const Icon(
            Icons.keyboard_command_key_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        SizedBox(height: 12.h),
        // Quick Add
        FloatingActionButton.small(
          heroTag: 'quick_add',
          onPressed: () {
            QuickAddBottomSheet.show(context);
          },
          backgroundColor: AppColors.primaryColor.withOpacity(0.9),
          child: const Icon(
            Icons.flash_on_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        SizedBox(height: 12.h),
        // New Note
        FloatingActionButton(
          heroTag: 'new_note',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NoteEditorPage()),
            );
          },
          backgroundColor: AppColors.primaryColor,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
