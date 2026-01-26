import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/responsive_utils.dart';
import '../../domain/entities/note.dart';
import '../bloc/note_bloc.dart';
import '../bloc/note_state.dart';
import '../bloc/note_event.dart';
import '../widgets/note_card_widget.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/theme_toggle_button.dart';
import 'note_editor_page.dart';
import 'settings_screen.dart';

/// Home Page - Main screen showing all notes
/// Responsive layout adapts to different screen sizes
/// Supports grid and list views based on device
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late TextEditingController _searchController;
  List<Note> _selectedNotes = [];
  bool _isSelectionMode = false;
  Timer? _debounce;
  late AnimationController _fabController;
  late AnimationController _listController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);

    // Initialize animation controllers
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _listController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fabController.forward();
    _listController.forward();

    // Load notes on init
    if (mounted) {
      try {
        context.read<NotesBloc>().add(const LoadNotesEvent());
      } catch (e) {
        print('Note bloc not found: $e');
      }
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    _fabController.dispose();
    _listController.dispose();
    super.dispose();
  }

  /// Search debouncing to avoid excessive queries
  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.isNotEmpty) {
        context.read<NotesBloc>().add(SearchNotesEvent(_searchController.text));
      } else {
        context.read<NotesBloc>().add(const LoadNotesEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);

    return WillPopScope(
      onWillPop: () async {
        if (_isSelectionMode) {
          setState(() {
            _isSelectionMode = false;
            _selectedNotes.clear();
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: _buildBody(context),
        floatingActionButton: _isSelectionMode
            ? null
            : _buildActionButtons(context),
        drawer: isMobile ? _buildDrawer(context) : null,
      ),
    );
  }

  /// Build app bar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 300),
        style: TextStyle(
          fontSize: _isSelectionMode ? 18.sp : 20.sp,
          fontWeight: FontWeight.bold,
        ),
        child: _isSelectionMode
            ? Text('${_selectedNotes.length} selected')
            : const Text(AppConstants.appName),
      ),
      elevation: 2,
      actions: [
        // Theme toggle button
        const ThemeToggleButton(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Tooltip(
                message: 'Search notes',
                child: InkWell(
                  onTap: () => _showSearchDialog(context),
                  borderRadius: BorderRadius.circular(8.r),
                  child: Padding(
                    padding: EdgeInsets.all(8.r),
                    child: Icon(Icons.search, size: 24.sp),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (!_isSelectionMode)
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value, context),
            elevation: 8,
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'pinned',
                child: Row(
                  children: [
                    Icon(Icons.push_pin, size: 18.sp),
                    SizedBox(width: 12.w),
                    Text('Pinned Notes', style: TextStyle(fontSize: 14.sp)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'archived',
                child: Row(
                  children: [
                    Icon(Icons.archive, size: 18.sp),
                    SizedBox(width: 12.w),
                    Text('Archived Notes', style: TextStyle(fontSize: 14.sp)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 18.sp),
                    SizedBox(width: 12.w),
                    Text('Settings', style: TextStyle(fontSize: 14.sp)),
                  ],
                ),
              ),
            ],
          )
        else ...[
          IconButton(
            icon: const Icon(Icons.archive),
            onPressed: () => _archiveSelected(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteSelected(context),
          ),
        ],
      ],
    );
  }

  /// Build main body
  Widget _buildBody(BuildContext context) {
    return BlocListener<NotesBloc, NoteState>(
      listener: (context, state) {
        if (state is ClipboardTextDetected) {
          _showClipboardSaveDialog(context, state.text);
          if (state is ClipboardNoteSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Note saved from clipboard'),
                backgroundColor: AppColors.successColor,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      },
      child: BlocBuilder<NotesBloc, NoteState>(
        builder: (context, state) {
          if (state is NoteLoading) {
            return _buildLoadingState();
          }

          if (state is NoteEmpty) {
            return EmptyStateWidget(
              icon: Icons.note_outlined,
              title: 'No Notes Yet',
              subtitle: 'Create your first note to get started',
              onAction: () => _createNewNote(context),
            );
          }

          if (state is NoteError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64.sp,
                    color: AppColors.errorColor,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<NotesBloc>().add(const LoadNotesEvent()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is NotesLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<NotesBloc>().add(const LoadNotesEvent());
              },
              child: _buildNotesGrid(context, state.notes),
            );
          }

          if (state is SearchResultsLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<NotesBloc>().add(const LoadNotesEvent());
              },
              child: _buildNotesGrid(context, state.results),
            );
          }

          return const Center(child: Text('Unknown state'));
        },
      ),
    );
  }

  /// Build notes grid (responsive)
  Widget _buildNotesGrid(BuildContext context, List<Note> notes) {
    final crossAxisCount = ResponsiveUtils.getGridColumns(context);
    final padding = ResponsiveUtils.getResponsivePadding(context);

    return Padding(
      padding: padding,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: AppConstants.gridAspectRatio,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
        ),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          final isSelected = _selectedNotes.any((n) => n.id == note.id);

          return SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0, 0.5),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _listController,
                    curve: Interval(
                      (index * 0.05).clamp(0.0, 1.0),
                      ((index + 1) * 0.05).clamp(0.0, 1.0),
                      curve: Curves.easeOut,
                    ),
                  ),
                ),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: _listController,
                  curve: Interval(
                    (index * 0.05).clamp(0.0, 1.0),
                    ((index + 1) * 0.05).clamp(0.0, 1.0),
                    curve: Curves.easeOut,
                  ),
                ),
              ),
              child: NoteCardWidget(
                note: note,
                isSelected: isSelected,
                onTap: () => _isSelectionMode
                    ? _toggleSelection(note)
                    : _editNote(context, note),
                onLongPress: () {
                  if (!_isSelectionMode) {
                    setState(() {
                      _isSelectionMode = true;
                      _selectedNotes = [note];
                    });
                  } else {
                    _toggleSelection(note);
                  }
                },
                onDelete: () => _deleteNote(context, note.id),
                onPin: () => _togglePin(context, note.id),
                onColorChange: (color) =>
                    _changeNoteColor(context, note.id, color),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Build loading state with shimmer
  Widget _buildLoadingState() {
    final crossAxisCount = ResponsiveUtils.getGridColumns(context);

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: AppConstants.gridAspectRatio,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.grey300, AppColors.grey200],
            ),
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withOpacity(0.05),
                blurRadius: 8.w,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build floating action buttons
  Widget _buildActionButtons(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildAnimatedFAB(
            heroTag: 'fab_record',
            mini: true,
            onPressed: () => _startAudioRecording(context),
            tooltip: 'Quick Voice Note',
            icon: Icons.mic,
          ),
          SizedBox(height: 12.h),
          _buildAnimatedFAB(
            heroTag: 'fab_camera',
            mini: true,
            onPressed: () => _captureImage(context),
            tooltip: 'Photo Note',
            icon: Icons.camera_alt,
          ),
          SizedBox(height: 12.h),
          _buildAnimatedFAB(
            heroTag: 'fab_add',
            onPressed: () => _createNewNote(context),
            tooltip: 'New Note',
            icon: Icons.add,
          ),
        ],
      ),
    );
  }

  /// Build animated FAB with ripple effect
  Widget _buildAnimatedFAB({
    required String heroTag,
    required VoidCallback onPressed,
    required String tooltip,
    required IconData icon,
    bool mini = false,
  }) {
    return FloatingActionButton(
      heroTag: heroTag,
      mini: mini,
      onPressed: onPressed,
      tooltip: tooltip,
      elevation: 8.0,
      hoverElevation: 12.0,
      child: Icon(icon, size: 24.sp),
    );
  }

  /// Build drawer for mobile
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primaryLight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  AppConstants.appName,
                  style: TextStyle(
                    color: AppColors.onPrimary,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Your Personal Notes App',
                  style: TextStyle(
                    color: AppColors.whiteOpacity70,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.note),
            title: const Text('All Notes'),
            onTap: () {
              Navigator.pop(context);
              context.read<NotesBloc?>()?.add(const LoadNotesEvent());
            },
          ),
          ListTile(
            leading: const Icon(Icons.push_pin),
            title: const Text('Pinned'),
            onTap: () {
              Navigator.pop(context);
              context.read<NotesBloc?>()?.add(const LoadPinnedNotesEvent());
            },
          ),
          ListTile(
            leading: const Icon(Icons.archive),
            title: const Text('Archived'),
            onTap: () {
              Navigator.pop(context);
              context.read<NotesBloc?>()?.add(const LoadArchivedNotesEvent());
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              _handleMenuAction('settings', context);
            },
          ),
        ],
      ),
    );
  }

  // Helper methods
  void _createNewNote(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NoteEditorPage()),
    );
  }

  void _editNote(BuildContext context, Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NoteEditorPage(note: note)),
    );
  }

  void _deleteNote(BuildContext context, String noteId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<NotesBloc?>()?.add(DeleteNoteEvent(noteId));
              Navigator.pop(context);
            },
            child: Text(
              'Delete',
              style: TextStyle(color: AppColors.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteSelected(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notes'),
        content: Text(
          'Delete ${_selectedNotes.length} selected note(s)? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final ids = _selectedNotes.map((n) => n.id).toList();
              context.read<NotesBloc?>()?.add(DeleteMultipleNotesEvent(ids));
              setState(() {
                _isSelectionMode = false;
                _selectedNotes.clear();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Notes deleted')));
            },
            child: Text(
              'Delete',
              style: TextStyle(color: AppColors.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  void _archiveSelected(BuildContext context) {
    for (final note in _selectedNotes) {
      context.read<NotesBloc?>()?.add(ToggleArchiveNoteEvent(note.id));
    }
    setState(() {
      _isSelectionMode = false;
      _selectedNotes.clear();
    });
  }

  void _togglePin(BuildContext context, String noteId) {
    context.read<NotesBloc?>()?.add(TogglePinNoteEvent(noteId));
  }

  void _changeNoteColor(BuildContext context, String noteId, NoteColor color) {
    // Find the note and update its color
    final noteState = context.read<NotesBloc>().state;
    if (noteState is NotesLoaded) {
      final note = noteState.notes.firstWhere(
        (n) => n.id == noteId,
        orElse: () =>
            Note(id: noteId, title: '', content: '', createdAt: DateTime.now()),
      );
      final updatedNote = note.copyWith(color: color);
      context.read<NotesBloc>().add(UpdateNoteEvent(updatedNote));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Note color updated')));
    }
  }

  void _toggleSelection(Note note) {
    setState(() {
      if (_selectedNotes.any((n) => n.id == note.id)) {
        _selectedNotes.removeWhere((n) => n.id == note.id);
      } else {
        _selectedNotes.add(note);
      }

      if (_selectedNotes.isEmpty) {
        _isSelectionMode = false;
      }
    });
  }

  void _startAudioRecording(BuildContext context) {
    // Navigate to note editor to record audio
    Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => const NoteEditorPage()),
    ).then((_) {
      // Refresh notes when returning from editor
      context.read<NotesBloc>().add(const LoadNotesEvent());
    });
  }

  void _captureImage(BuildContext context) {
    // Navigate to note editor to capture image
    Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => const NoteEditorPage()),
    ).then((_) {
      // Refresh notes when returning from editor
      context.read<NotesBloc>().add(const LoadNotesEvent());
    });
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Notes'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(hintText: 'Search...'),
          onChanged: (value) {
            if (value.isNotEmpty) {
              context.read<NotesBloc?>()?.add(SearchNotesEvent(value));
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              _searchController.clear();
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action, BuildContext context) {
    switch (action) {
      case 'pinned':
        context.read<NotesBloc>().add(const LoadPinnedNotesEvent());
        break;
      case 'archived':
        context.read<NotesBloc>().add(const LoadArchivedNotesEvent());
        break;
      case 'settings':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        );
        break;
      case 'sort':
        _showSortOptions(context);
        break;
      case 'backup':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup feature coming soon')),
        );
        break;
    }
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Sort by', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Newest first'),
              onTap: () {
                context.read<NotesBloc>().add(
                  const SortNotesEvent(NoteSortBy.newest),
                );
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Oldest first'),
              onTap: () {
                context.read<NotesBloc>().add(
                  const SortNotesEvent(NoteSortBy.oldest),
                );
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.sort_by_alpha),
              title: const Text('Alphabetical'),
              onTap: () {
                context.read<NotesBloc>().add(
                  const SortNotesEvent(NoteSortBy.alphabetical),
                );
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.push_pin),
              title: const Text('Pinned first'),
              onTap: () {
                context.read<NotesBloc>().add(
                  const SortNotesEvent(NoteSortBy.pinned),
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Show clipboard save dialog
  void _showClipboardSaveDialog(BuildContext context, String clipboardText) {
    final titleController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.assignment_returned,
                      size: 28.sp,
                      color: AppColors.accentColor,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'Clipboard Detected',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Text(
                  'Would you like to save this text as a note?',
                  style: TextStyle(fontSize: 14.sp, color: AppColors.grey700),
                ),
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: AppColors.infoColor.withOpacity(0.05),
                    border: Border.all(
                      color: AppColors.infoColor.withOpacity(0.2),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    clipboardText,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 12.sp,
                      color: AppColors.grey700,
                      height: 1.5,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Note Title (Optional)',
                    hintText: 'Leave empty for "Clipboard Note"',
                    prefixIcon: Icon(Icons.title, size: 20.sp),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(
                        color: Colors.grey[300]!,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(
                        color: AppColors.accentColor,
                        width: 2,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                  ),
                  maxLines: 1,
                ),
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 12.h,
                        ),
                      ),
                      child: Text('Discard', style: TextStyle(fontSize: 14.sp)),
                    ),
                    SizedBox(width: 12.w),
                    ElevatedButton(
                      onPressed: () {
                        final title = titleController.text.trim().isEmpty
                            ? 'Clipboard Note'
                            : titleController.text.trim();

                        context.read<NotesBloc>().add(
                          SaveClipboardAsNoteEvent(clipboardText, title: title),
                        );

                        titleController.dispose();
                        Navigator.pop(dialogContext);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 12.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        'Save as Note',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
