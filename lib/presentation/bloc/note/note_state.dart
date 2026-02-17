import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../domain/entities/note.dart';

/// View modes for the notes list
enum NoteViewMode {
  list,
  grid;

  String get displayName => this == list ? 'List View' : 'Grid View';
  IconData get icon => this == list ? Icons.view_list : Icons.grid_view;
}

/// Sort options for notes
enum NoteSortOption {
  dateCreated('Date Created', Icons.access_time),
  dateModified('Date Modified', Icons.update),
  titleAZ('Title A-Z', Icons.sort_by_alpha),
  titleZA('Title Z-A', Icons.sort_by_alpha),
  color('Color', Icons.palette),
  oldest('Oldest first', Icons.history),
  alphabetical('Alphabetical (A-Z)', Icons.sort_by_alpha),
  mostModified('Recently modified', Icons.history_edu),
  pinned('Pinned first', Icons.push_pin),
  completion('Completion %', Icons.percent),
  frequency('Most Used', Icons.trending_up),
  priority('Priority', Icons.priority_high),
  manual('Manual Order', Icons.drag_indicator);

  const NoteSortOption(this.displayName, this.icon);
  final String displayName;
  final IconData icon;
}

/// States for Notes BLoC
abstract class NoteState extends Equatable {
  const NoteState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class NoteInitial extends NoteState {
  const NoteInitial();
}

/// Loading state
class NoteLoading extends NoteState {
  const NoteLoading();
}

/// Notes loaded successfully
class NotesLoaded extends NoteState {
  final List<Note> allNotes;
  final List<Note> displayedNotes;
  final int totalCount;

  // View Configuration
  final String searchQuery;
  final List<String> selectedTags;
  final List<NoteColor> selectedColors;
  final NoteSortOption sortBy;
  final bool sortDescending;
  final NoteSortOption? secondarySortBy;
  final bool? secondarySortDescending;
  final List<String> manualSortItems;
  final bool filterPinned;
  final bool filterWithMedia;
  final bool filterWithImages;
  final bool filterWithAudio;
  final bool filterWithVideo;
  final bool filterWithReminders;
  final bool filterWithTodos;
  final NoteViewMode viewMode;
  final bool isSearchExpanded;
  final List<String> searchHistory;
  final String tagManagementSearchQuery;
  final List<String> tagManagementSelectedTags;

  // Backward compatibility
  List<Note> get notes => displayedNotes;

  const NotesLoaded({
    required this.allNotes,
    required this.displayedNotes,
    this.totalCount = 0,
    this.searchQuery = '',
    this.selectedTags = const [],
    this.selectedColors = const [],
    this.sortBy = NoteSortOption.dateModified,
    this.sortDescending = true,
    this.secondarySortBy,
    this.secondarySortDescending,
    this.manualSortItems = const [
      'Project Alpha',
      'Meeting Notes',
      'Grocery List',
      'Design System',
      'Daily Standup',
    ],
    this.filterPinned = false,
    this.filterWithMedia = false,
    this.filterWithImages = false,
    this.filterWithAudio = false,
    this.filterWithVideo = false,
    this.filterWithReminders = false,
    this.filterWithTodos = false,
    this.viewMode = NoteViewMode.list,
    this.isSearchExpanded = false,
    this.searchHistory = const [
      'tag:work color:blue',
      'before:2024-01-01',
      '"exact phrase" -tag:personal',
    ],
    this.tagManagementSearchQuery = '',
    this.tagManagementSelectedTags = const [],
  });

  /// Factory for backward compatibility or simple loads
  factory NotesLoaded.simple(List<Note> notes) {
    return NotesLoaded(
      allNotes: notes,
      displayedNotes: notes,
      totalCount: notes.length,
    );
  }

  NotesLoaded copyWith({
    List<Note>? allNotes,
    List<Note>? displayedNotes,
    int? totalCount,
    String? searchQuery,
    List<String>? selectedTags,
    List<NoteColor>? selectedColors,
    NoteSortOption? sortBy,
    bool? sortDescending,
    NoteSortOption? secondarySortBy,
    bool? secondarySortDescending,
    List<String>? manualSortItems,
    bool? filterPinned,
    bool? filterWithMedia,
    bool? filterWithImages,
    bool? filterWithAudio,
    bool? filterWithVideo,
    bool? filterWithReminders,
    bool? filterWithTodos,
    NoteViewMode? viewMode,
    bool? isSearchExpanded,
    List<String>? searchHistory,
    String? tagManagementSearchQuery,
    List<String>? tagManagementSelectedTags,
  }) {
    return NotesLoaded(
      allNotes: allNotes ?? this.allNotes,
      displayedNotes: displayedNotes ?? this.displayedNotes,
      totalCount: totalCount ?? this.totalCount,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedTags: selectedTags ?? this.selectedTags,
      selectedColors: selectedColors ?? this.selectedColors,
      sortBy: sortBy ?? this.sortBy,
      sortDescending: sortDescending ?? this.sortDescending,
      secondarySortBy: secondarySortBy ?? this.secondarySortBy,
      secondarySortDescending:
          secondarySortDescending ?? this.secondarySortDescending,
      manualSortItems: manualSortItems ?? this.manualSortItems,
      filterPinned: filterPinned ?? this.filterPinned,
      filterWithMedia: filterWithMedia ?? this.filterWithMedia,
      filterWithImages: filterWithImages ?? this.filterWithImages,
      filterWithAudio: filterWithAudio ?? this.filterWithAudio,
      filterWithVideo: filterWithVideo ?? this.filterWithVideo,
      filterWithReminders: filterWithReminders ?? this.filterWithReminders,
      filterWithTodos: filterWithTodos ?? this.filterWithTodos,
      viewMode: viewMode ?? this.viewMode,
      isSearchExpanded: isSearchExpanded ?? this.isSearchExpanded,
      searchHistory: searchHistory ?? this.searchHistory,
      tagManagementSearchQuery:
          tagManagementSearchQuery ?? this.tagManagementSearchQuery,
      tagManagementSelectedTags:
          tagManagementSelectedTags ?? this.tagManagementSelectedTags,
    );
  }

  @override
  List<Object?> get props => [
    allNotes,
    displayedNotes,
    totalCount,
    searchQuery,
    selectedTags,
    selectedColors,
    sortBy,
    sortDescending,
    secondarySortBy,
    secondarySortDescending,
    manualSortItems,
    filterPinned,
    filterWithMedia,
    filterWithImages,
    filterWithAudio,
    filterWithVideo,
    filterWithReminders,
    filterWithTodos,
    viewMode,
    isSearchExpanded,
    searchHistory,
    tagManagementSearchQuery,
    tagManagementSelectedTags,
  ];
}

/// Single note loaded
class NoteLoaded extends NoteState {
  final Note note;

  const NoteLoaded(this.note);

  @override
  List<Object?> get props => [note];
}

/// Note created successfully
class NoteCreated extends NoteState {
  final Note note;

  const NoteCreated(this.note);

  @override
  List<Object?> get props => [note];
}

/// Note updated successfully
class NoteUpdated extends NoteState {
  final Note note;

  const NoteUpdated(this.note);

  @override
  List<Object?> get props => [note];
}

/// Note deleted successfully
class NoteDeleted extends NoteState {
  final String noteId;

  const NoteDeleted(this.noteId);

  @override
  List<Object?> get props => [noteId];
}

/// Multiple notes deleted
class NotesDeleted extends NoteState {
  final List<String> noteIds;
  final int deletedCount;

  const NotesDeleted(this.noteIds, this.deletedCount);

  @override
  List<Object?> get props => [noteIds, deletedCount];
}

/// Note(s) deleted with undo option available
/// Shown with undo snackbar for 5 seconds
class NoteDeletedWithUndo extends NoteState {
  const NoteDeletedWithUndo();

  @override
  List<Object?> get props => [];
}

/// Note pin status toggled
class NotePinToggled extends NoteState {
  final Note note;
  final bool isPinned;

  const NotePinToggled(this.note, this.isPinned);

  @override
  List<Object?> get props => [note, isPinned];
}

/// Note archive status toggled
class NoteArchiveToggled extends NoteState {
  final Note note;
  final bool isArchived;

  const NoteArchiveToggled(this.note, this.isArchived);

  @override
  List<Object?> get props => [note, isArchived];
}

/// Tag added to note
class TagAdded extends NoteState {
  final Note note;
  final String tag;

  const TagAdded(this.note, this.tag);

  @override
  List<Object?> get props => [note, tag];
}

/// Tag removed from note
class TagRemoved extends NoteState {
  final Note note;
  final String tag;

  const TagRemoved(this.note, this.tag);

  @override
  List<Object?> get props => [note, tag];
}

/// Search results loaded
class SearchResultsLoaded extends NoteState {
  final List<dynamic> results;
  final String query;
  final int resultCount;

  const SearchResultsLoaded(this.results, this.query, {this.resultCount = 0});

  @override
  List<Object?> get props => [results, query, resultCount];
}

/// Pinned notes loaded
class PinnedNotesLoaded extends NoteState {
  final List<Note> notes;

  const PinnedNotesLoaded(this.notes);

  @override
  List<Object?> get props => [notes];
}

/// Archived notes loaded
class ArchivedNotesLoaded extends NoteState {
  final List<Note> notes;

  const ArchivedNotesLoaded(this.notes);

  @override
  List<Object?> get props => [notes];
}

/// Notes by tag loaded
class NotesByTagLoaded extends NoteState {
  final List<Note> notes;
  final String tag;

  const NotesByTagLoaded(this.notes, this.tag);

  @override
  List<Object?> get props => [notes, tag];
}

/// PDF exported successfully
class PdfExported extends NoteState {
  final String filePath;
  final String fileName;

  const PdfExported(this.filePath, this.fileName);

  @override
  List<Object?> get props => [filePath, fileName];
}

/// Alarm added to note
class AlarmAdded extends NoteState {
  final Note note;

  const AlarmAdded(this.note);

  @override
  List<Object?> get props => [note];
}

/// Alarm removed from note
class AlarmRemoved extends NoteState {
  final Note note;

  const AlarmRemoved(this.note);

  @override
  List<Object?> get props => [note];
}

/// Old notes cleared
class OldNotesCleared extends NoteState {
  final int clearedCount;

  const OldNotesCleared(this.clearedCount);

  @override
  List<Object?> get props => [clearedCount];
}

/// Note restored from archive
class NoteRestored extends NoteState {
  final Note note;

  const NoteRestored(this.note);

  @override
  List<Object?> get props => [note];
}

/// Error state
class NoteError extends NoteState {
  final String message;
  final String? errorCode;
  final Exception? exception;

  const NoteError(this.message, {this.errorCode, this.exception});

  @override
  List<Object?> get props => [message, errorCode, exception];
}

/// Empty state (no notes found)
class NoteEmpty extends NoteState {
  final String message;

  const NoteEmpty({this.message = 'No notes found'});

  @override
  List<Object?> get props => [message];
}

/// Clipboard text detected - ready to save
class ClipboardTextDetected extends NoteState {
  final String text;

  const ClipboardTextDetected(this.text);

  @override
  List<Object?> get props => [text];
}

/// Clipboard note saved successfully
class ClipboardNoteSaved extends NoteState {
  final Note note;

  const ClipboardNoteSaved(this.note);

  @override
  List<Object?> get props => [note];
}

/// Link added to note
class LinkAddedToNote extends NoteState {
  final Note note;

  const LinkAddedToNote(this.note);

  @override
  List<Object?> get props => [note];
}

/// Link removed from note
class LinkRemovedFromNote extends NoteState {
  final Note note;

  const LinkRemovedFromNote(this.note);

  @override
  List<Object?> get props => [note];
}
