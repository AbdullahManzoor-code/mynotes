import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../../core/services/speech_service.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/note_template.dart';
import '../bloc/note_bloc.dart';
import '../bloc/note_state.dart';
import '../bloc/note_event.dart';
import '../design_system/design_system.dart';
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

    return BlocListener<NotesBloc, NoteState>(
      listener: (context, state) {
        // Auto-refresh when note is created, updated, or deleted
        if (state is NoteCreated ||
            state is NoteUpdated ||
            state is NoteDeleted) {
          _loadNotes();
        }
      },
      child: AppScaffold(
        appBar: GlassAppBar(
          title: 'My Notes',
          actions: [
            AppIconButton(
              icon: _isListView ? Icons.grid_view : Icons.view_list,
              onPressed: () => setState(() => _isListView = !_isListView),
              tooltip: _isListView ? 'Grid View' : 'List View',
            ),
            AppIconButton(
              icon: Icons.search,
              onPressed: _openSearch,
              tooltip: 'Search',
            ),
            AppIconButton(
              icon: Icons.settings_outlined,
              onPressed: _openSettings,
              tooltip: 'Settings',
            ),
          ],
        ),
        body: Column(
          children: [
            // Search Bar with Voice Input
            PageContainer(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: SearchTextField(
                      controller: _searchController,
                      hintText: 'Search notes...',
                      onChanged: (value) {
                        // Search is handled by listener
                      },
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  VoiceInputButton(
                    isListening: _isListening,
                    onPressed: _isListening
                        ? _stopVoiceSearch
                        : _startVoiceSearch,
                    size: 48,
                  ),
                ],
              ),
            ),

            // Notes List/Grid
            Expanded(
              child: BlocBuilder<NotesBloc, NoteState>(
                builder: (context, state) {
                  if (state is NoteLoading) {
                    return const AppLoadingIndicator();
                  }

                  if (state is NoteError) {
                    return ErrorState(
                      title: 'Error loading notes',
                      message: state.message,
                      actionText: 'Retry',
                      onActionPressed: _loadNotes,
                    );
                  }

                  if (state is NotesLoaded) {
                    if (state.notes.isEmpty) {
                      return EmptyStateCard(
                        icon: Icons.note_outlined,
                        title: _searchController.text.isNotEmpty
                            ? 'No notes found'
                            : 'No notes yet',
                        message: _searchController.text.isNotEmpty
                            ? 'Try a different search term'
                            : 'Tap the + button to create your first note',
                        actionText: _searchController.text.isEmpty
                            ? 'Create Note'
                            : null,
                        onActionPressed: _searchController.text.isEmpty
                            ? _createNewNote
                            : null,
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
        floatingActionButton: AppFAB(
          icon: Icons.add,
          onPressed: _createNewNote,
          tooltip: 'Create New Note',
        ),
      ),
    );
  }

  Widget _buildGridView(List<Note> notes) {
    return GridView.builder(
      padding: EdgeInsets.all(AppSpacing.lg),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.85,
      ),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return NoteCard(
          title: note.title,
          content: note.content,
          category: note.tags.isNotEmpty ? note.tags.first : null,
          categoryColor: AppColors.getNoteColor(context, note.color),
          createdAt: note.createdAt,
          isPinned: note.isPinned,
          onTap: () => _openNote(note),
          margin: EdgeInsets.zero,
        );
      },
    );
  }

  Widget _buildListView(List<Note> notes) {
    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.lg),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return NoteCard(
          title: note.title,
          content: note.content,
          category: note.tags.isNotEmpty ? note.tags.first : null,
          categoryColor: AppColors.getNoteColor(context, note.color),
          createdAt: note.createdAt,
          isPinned: note.isPinned,
          onTap: () => _openNote(note),
          margin: EdgeInsets.only(bottom: AppSpacing.md),
        );
      },
    );
  }
}

