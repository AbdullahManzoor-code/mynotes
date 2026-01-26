import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import '../../core/constants/app_colors.dart';
import '../../core/services/speech_service.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/note_template.dart';
import '../bloc/note_bloc.dart';
import '../bloc/note_state.dart';
import '../bloc/note_event.dart';
import '../widgets/note_card_widget.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/voice_input_button.dart';
import '../widgets/template_selector_sheet.dart';
import 'note_editor_page.dart';
import 'settings_screen.dart';
import 'global_search_screen.dart';

/// Notes List Screen - Display all notes with grid/list view
/// Features: Speech-to-text search, voice commands, filtering
class NotesListScreen extends StatefulWidget {
  const NotesListScreen({Key? key}) : super(key: key);

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen>
    with AutomaticKeepAliveClientMixin {
  late TextEditingController _searchController;
  final SpeechService _speechService = SpeechService();
  Timer? _debounce;
  bool _isListView = false;
  bool _isListening = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
    _loadNotes();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    _speechService.dispose();
    super.dispose();
  }

  void _loadNotes() {
    context.read<NotesBloc>().add(const LoadNotesEvent());
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.isNotEmpty) {
        context.read<NotesBloc>().add(SearchNotesEvent(_searchController.text));
      } else {
        _loadNotes();
      }
    });
  }

  Future<void> _startVoiceSearch() async {
    setState(() => _isListening = true);

    final hasPermission = await _speechService.initialize();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Microphone permission required for voice search'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _isListening = false);
      return;
    }

    _speechService.startListening(
      onResult: (text) {
        setState(() {
          _searchController.text = text;
        });
      },
    );
  }

  void _stopVoiceSearch() {
    _speechService.stopListening();
    setState(() => _isListening = false);
  }

  void _createNewNote() async {
    final template = await showModalBottomSheet<NoteTemplate>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: const TemplateSelectorSheet(),
      ),
    );

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteEditorPage(initialContent: template?.content),
      ),
    );
  }

  void _openNote(Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NoteEditorPage(note: note)),
    );
  }

  void _openSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GlobalSearchScreen()),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<NotesBloc, NoteState>(
      listener: (context, state) {
        // Auto-refresh when note is created, updated, or deleted
        if (state is NoteCreated ||
            state is NoteUpdated ||
            state is NoteDeleted) {
          _loadNotes();
        }
      },
      child: _buildContent(isDark),
    );
  }

  Widget _buildContent(bool isDark) {
    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        automaticallyImplyLeading: false,
        title: Text(
          'My Notes',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isListView ? Icons.grid_view : Icons.view_list,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () {
              setState(() => _isListView = !_isListView);
            },
          ),
          IconButton(
            icon: Icon(
              Icons.search,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: _openSearch,
          ),
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar with Voice Input
          Container(
            padding: EdgeInsets.all(16.w),
            color: isDark ? AppColors.surfaceDark : Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search notes...',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                                _loadNotes();
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: isDark
                          ? AppColors.darkBackground
                          : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                VoiceInputButton(
                  isListening: _isListening,
                  onPressed: _isListening
                      ? _stopVoiceSearch
                      : _startVoiceSearch,
                  size: 48.w,
                ),
              ],
            ),
          ),

          // Notes List/Grid
          Expanded(
            child: BlocBuilder<NotesBloc, NoteState>(
              builder: (context, state) {
                if (state is NoteLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is NoteError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64.sp,
                          color: Colors.red,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Error loading notes',
                          style: TextStyle(fontSize: 16.sp),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          state.message,
                          style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                        ),
                        SizedBox(height: 24.h),
                        ElevatedButton(
                          onPressed: _loadNotes,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is NotesLoaded) {
                  if (state.notes.isEmpty) {
                    return EmptyStateWidget(
                      icon: Icons.note_outlined,
                      title: _searchController.text.isNotEmpty
                          ? 'No notes found'
                          : 'No notes yet',
                      subtitle: _searchController.text.isNotEmpty
                          ? 'Try a different search term'
                          : 'Tap the + button to create your first note',
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _loadNotes(),
                    child: _isListView
                        ? _buildListView(state.notes)
                        : _buildGridView(state.notes),
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewNote,
        backgroundColor: AppColors.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Note', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildGridView(List<Note> notes) {
    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 0.85,
      ),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        return NoteCardWidget(
          note: notes[index],
          onTap: () => _openNote(notes[index]),
          onLongPress: () {},
          onPin: () {
            final note = notes[index];
            context.read<NotesBloc>().add(
              UpdateNoteEvent(
                note.copyWith(
                  isPinned: !note.isPinned,
                  updatedAt: DateTime.now(),
                ),
              ),
            );
          },
          onColorChange: (color) {
            final note = notes[index];
            context.read<NotesBloc>().add(
              UpdateNoteEvent(
                note.copyWith(color: color, updatedAt: DateTime.now()),
              ),
            );
          },
          onDelete: () {
            context.read<NotesBloc>().add(DeleteNoteEvent(notes[index].id));
          },
        );
      },
    );
  }

  Widget _buildListView(List<Note> notes) {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: NoteCardWidget(
            note: notes[index],
            onTap: () => _openNote(notes[index]),
            onLongPress: () {},
            onPin: () {
              final note = notes[index];
              context.read<NotesBloc>().add(
                UpdateNoteEvent(
                  note.copyWith(
                    isPinned: !note.isPinned,
                    updatedAt: DateTime.now(),
                  ),
                ),
              );
            },
            onColorChange: (color) {
              final note = notes[index];
              context.read<NotesBloc>().add(
                UpdateNoteEvent(
                  note.copyWith(color: color, updatedAt: DateTime.now()),
                ),
              );
            },
            onDelete: () {
              context.read<NotesBloc>().add(DeleteNoteEvent(notes[index].id));
            },
          ),
        );
      },
    );
  }
}
