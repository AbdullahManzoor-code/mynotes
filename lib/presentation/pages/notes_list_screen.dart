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
import 'enhanced_note_editor_screen.dart';
import 'advanced_note_editor.dart';
import 'settings_screen.dart';
import 'global_search_screen.dart';
import 'empty_state_notes_help_screen.dart';

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
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: AppColors.primary),
          onSelected: (value) => _handleNotesMenu(value),
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem(
              value: 'enhanced_editor',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 12),
                  Text('Enhanced Editor'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'advanced_editor',
              child: Row(
                children: [
                  Icon(Icons.app_settings_alt, size: 20),
                  SizedBox(width: 12),
                  Text('Advanced Editor'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'help',
              child: Row(
                children: [
                  Icon(Icons.help, size: 20),
                  SizedBox(width: 12),
                  Text('Getting Started'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings, size: 20),
                  SizedBox(width: 12),
                  Text('Settings'),
                ],
              ),
            ),
          ],
        ),
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildTemplatesSection() {
    final templates = [
      NoteTemplate(
        id: 'meeting',
        name: 'Meeting Notes',
        type: NoteTemplateType.meeting,
        content:
            '**Date:** \n**Attendees:** \n**Topics:** \n\n**Action Items:**\n- ',
        icon: NoteTemplateType.meeting.icon,
        createdAt: DateTime.now(),
      ),
      NoteTemplate(
        id: 'todoList',
        name: 'To-Do List',
        type: NoteTemplateType.todoList,
        content: '**To-Do List**\n\n- [ ] \n- [ ] \n- [ ] ',
        icon: NoteTemplateType.todoList.icon,
        createdAt: DateTime.now(),
      ),
      NoteTemplate(
        id: 'journal',
        name: 'Daily Journal',
        type: NoteTemplateType.journal,
        content:
            '**Date:** \n\n**Mood:** \n\n**What I\'m grateful for:**\n- \n\n**Today\'s highlights:**\n- ',
        icon: NoteTemplateType.journal.icon,
        createdAt: DateTime.now(),
      ),
      NoteTemplate(
        id: 'brainstorm',
        name: 'Idea Brainstorm',
        type: NoteTemplateType.ideaBrainstorm,
        content: '**Topic:** \n\n**Ideas:**\n- \n- \n- \n\n**Next Steps:**\n- ',
        icon: NoteTemplateType.ideaBrainstorm.icon,
        createdAt: DateTime.now(),
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
                      AppColors.textPrimary(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: AppTypography.bodyMedium(
                      context,
                      AppColors.textSecondary(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<NotesBloc>().add(const LoadNotesEvent());
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            ),
          );
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

  void _handleNotesMenu(String value) {
    switch (value) {
      case 'enhanced_editor':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EnhancedNoteEditorScreen()),
        );
        break;
      case 'advanced_editor':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdvancedNoteEditor()),
        );
        break;
      case 'help':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EmptyStateNotesHelpScreen()),
        );
        break;
      case 'settings':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        );
        break;
    }
  }
}
