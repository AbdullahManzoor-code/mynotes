import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../core/constants/app_colors.dart';
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
                        : [AppColors.primaryColor, AppColors.secondaryColor],
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
                            if (state is NotesLoaded) {
                              count = state.notes.length;
                            }
                            return Text(
                              '$count notes • ${DateTime.now().toString().split(' ')[0]}',
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
                          [AppColors.primaryColor, AppColors.secondaryColor],
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
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.note,
                            size: 80.sp,
                            color: Colors.grey.withOpacity(0.3),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'No notes yet',
                            style: TextStyle(
                              fontSize: 18.sp,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
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
                        onColorChange: (NoteColor p1) {},
                      );
                    },
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
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NoteEditorPage()),
        );
      },
      backgroundColor: AppColors.primaryColor,
      child: const Icon(Icons.add, color: Colors.white),
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
