import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'dart:ui';
import '../../core/services/speech_service.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/note_template.dart';
import '../bloc/note_bloc.dart';
import '../bloc/note_state.dart';
import '../bloc/note_event.dart';
import '../design_system/design_system.dart';
import '../widgets/note_card_widget.dart';
import '../widgets/voice_input_button.dart';
import '../widgets/template_selector_sheet.dart';
import '../../core/routes/app_routes.dart';
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

  void _createFromTemplate(NoteTemplate template) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteEditorPage(initialContent: template.content),
      ),
    );
  }

  void _editNote(Note note) {
    _openNote(note);
  }

  void _openNote(Note note) {
    Navigator.pushNamed(context, AppRoutes.noteEditor, arguments: note);
  }

  void _openSearch() {
    Navigator.pushNamed(context, AppRoutes.search);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocListener<NotesBloc, NoteState>(
      listener: (context, state) {
        if (state is NoteCreated ||
            state is NoteUpdated ||
            state is NoteDeleted) {
          _loadNotes();
        }
      },
      child: AppScaffold(
        body: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
            _buildTemplatesSection(),
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Recent Notes',
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.screenPaddingHorizontal,
                  AppSpacing.xl,
                  AppSpacing.screenPaddingHorizontal,
                  AppSpacing.md,
                ),
              ),
            ),
            _buildNotesSection(),
            SliverToBoxAdapter(child: SizedBox(height: 100.h)),
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

  Widget _buildSliverAppBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SliverAppBar(
      floating: true,
      snap: true,
      elevation: 0,
      backgroundColor: isDark
          ? AppColors.darkBackground.withOpacity(0.8)
          : AppColors.lightBackground.withOpacity(0.8),
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(color: Colors.transparent),
        ),
      ),
      title: Text(
        'My Notes',
        style: AppTypography.heading1(context, null, FontWeight.w700),
      ),
      actions: [
        AppIconButton(icon: Icons.search, onPressed: _openSearch),
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildTemplatesSection() {
    final templates = [
      const NoteTemplate(
        id: 'meeting',
        name: 'Meeting Notes',
        type: 'meeting',
        content:
            '**Date:** \n**Attendees:** \n**Topics:** \n\n**Action Items:**\n- ',
        tags: ['work', 'meeting'],
      ),
      const NoteTemplate(
        id: 'shopping',
        name: 'Shopping List',
        type: 'shopping',
        content: '**Shopping List**\n\n- \n- \n- ',
        tags: ['personal', 'shopping'],
      ),
      const NoteTemplate(
        id: 'journal',
        name: 'Daily Journal',
        type: 'journal',
        content:
            '**Date:** \n\n**Mood:** \n\n**What I\'m grateful for:**\n- \n\n**Today\'s highlights:**\n- ',
        tags: ['journal', 'reflection'],
      ),
      const NoteTemplate(
        id: 'brainstorm',
        name: 'Brainstorm',
        type: 'brainstorm',
        content: '**Topic:** \n\n**Ideas:**\n- \n- \n- \n\n**Next Steps:**\n- ',
        tags: ['ideas', 'brainstorm'],
      ),
    ];

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(top: 8.h),
        child: TemplatePicker(
          templates: templates,
          onTemplateSelected: _createFromTemplate,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPaddingHorizontal,
          ),
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return BlocBuilder<NotesBloc, NoteState>(
      builder: (context, state) {
        if (state is NoteLoading) {
          return const SliverFillRemaining(
            child: Center(child: AppLoadingIndicator()),
          );
        }

        if (state is NotesLoaded) {
          if (state.notes.isEmpty) {
            return SliverFillRemaining(
              child: EmptyStateNotes(onCreateNote: _createNewNote),
            );
          }

          if (_isListView) {
            return SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPaddingHorizontal,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final note = state.notes[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: NoteCardWidget(
                      note: note,
                      onTap: () => _openNote(note),
                      onLongPress: () {},
                    ),
                  );
                }, childCount: state.notes.length),
              ),
            );
          } else {
            return SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPaddingHorizontal,
              ),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                  childAspectRatio: 0.8,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final note = state.notes[index];
                  return NoteCardWidget(
                    note: note,
                    onTap: () => _openNote(note),
                    onLongPress: () {},
                  );
                }, childCount: state.notes.length),
              ),
            );
          }
        }

        return const SliverToBoxAdapter(child: SizedBox());
      },
    );
  }

  void _createNewNote() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NoteEditorPage()),
    );
  }
}
