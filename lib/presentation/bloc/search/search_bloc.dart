import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mynotes/injection_container.dart';
import '../../../domain/entities/note.dart';
import '../../../domain/repositories/note_repository.dart';

// Events
abstract class SearchEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class InitializeSearch extends SearchEvent {
  final String? initialQuery;

  InitializeSearch({this.initialQuery});

  @override
  List<Object?> get props => [initialQuery];
}

class SearchQueryChanged extends SearchEvent {
  final String query;

  SearchQueryChanged(this.query);

  @override
  List<Object> get props => [query];
}

class PerformSearch extends SearchEvent {
  final String query;

  PerformSearch(this.query);

  @override
  List<Object> get props => [query];
}

class ClearSearch extends SearchEvent {}

class ToggleFilters extends SearchEvent {}

class ApplyFilter extends SearchEvent {
  final SearchFilter filter;

  ApplyFilter(this.filter);

  @override
  List<Object> get props => [filter];
}

class SelectRecentSearch extends SearchEvent {
  final String query;

  SelectRecentSearch(this.query);

  @override
  List<Object> get props => [query];
}

class StartVoiceSearch extends SearchEvent {}

class StopVoiceSearch extends SearchEvent {}

class VoiceSearchResult extends SearchEvent {
  final String text;
  final bool isFinal;

  VoiceSearchResult(this.text, {this.isFinal = false});

  @override
  List<Object> get props => [text, isFinal];
}

class LoadRecentSearches extends SearchEvent {}

// States
abstract class SearchState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoaded extends SearchState {
  final String searchQuery;
  final List<Note> searchResults;
  final List<String> recentSearches;
  final bool isSearching;
  final bool showFilters;
  final SearchFilter selectedFilter;
  final bool isListening;
  final bool isVoiceAvailable;

  SearchLoaded({
    this.searchQuery = '',
    this.searchResults = const [],
    this.recentSearches = const [],
    this.isSearching = false,
    this.showFilters = false,
    this.selectedFilter = SearchFilter.all,
    this.isListening = false,
    this.isVoiceAvailable = false,
  });

  @override
  List<Object?> get props => [
    searchQuery,
    searchResults,
    recentSearches,
    isSearching,
    showFilters,
    selectedFilter,
    isListening,
    isVoiceAvailable,
  ];

  SearchLoaded copyWith({
    String? searchQuery,
    List<Note>? searchResults,
    List<String>? recentSearches,
    bool? isSearching,
    bool? showFilters,
    SearchFilter? selectedFilter,
    bool? isListening,
    bool? isVoiceAvailable,
  }) {
    return SearchLoaded(
      searchQuery: searchQuery ?? this.searchQuery,
      searchResults: searchResults ?? this.searchResults,
      recentSearches: recentSearches ?? this.recentSearches,
      isSearching: isSearching ?? this.isSearching,
      showFilters: showFilters ?? this.showFilters,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      isListening: isListening ?? this.isListening,
      isVoiceAvailable: isVoiceAvailable ?? this.isVoiceAvailable,
    );
  }
}

class SearchError extends SearchState {
  final String message;

  SearchError(this.message);

  @override
  List<Object> get props => [message];
}

// Filter enum
enum SearchFilter { all, notes, todos, reminders }

// BLoC
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final NoteRepository _noteRepository;

  SearchBloc({NoteRepository? noteRepository})
    : _noteRepository = noteRepository ?? getIt<NoteRepository>(),
      super(SearchInitial()) {
    on<InitializeSearch>(_onInitializeSearch);
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<PerformSearch>(_onPerformSearch);
    on<ClearSearch>(_onClearSearch);
    on<ToggleFilters>(_onToggleFilters);
    on<ApplyFilter>(_onApplyFilter);
    on<SelectRecentSearch>(_onSelectRecentSearch);
    on<StartVoiceSearch>(_onStartVoiceSearch);
    on<StopVoiceSearch>(_onStopVoiceSearch);
    on<VoiceSearchResult>(_onVoiceSearchResult);
    on<LoadRecentSearches>(_onLoadRecentSearches);
  }

  void _onInitializeSearch(InitializeSearch event, Emitter<SearchState> emit) {
    emit(
      SearchLoaded(
        searchQuery: event.initialQuery ?? '',
        isVoiceAvailable: true, // Will be updated by voice service
      ),
    );

    if (event.initialQuery != null && event.initialQuery!.isNotEmpty) {
      add(PerformSearch(event.initialQuery!));
    }

    add(LoadRecentSearches());
  }

  void _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) {
    if (state is SearchLoaded) {
      emit((state as SearchLoaded).copyWith(searchQuery: event.query));
    }
  }

  Future<void> _onPerformSearch(
    PerformSearch event,
    Emitter<SearchState> emit,
  ) async {
    if (state is! SearchLoaded) return;

    final currentState = state as SearchLoaded;

    try {
      emit(currentState.copyWith(isSearching: true));

      // Perform search through repository
      final allNotes = await _noteRepository.getAllNotes();
      final query = event.query.toLowerCase();

      // Filter based on selected filter
      List<Note> results = allNotes.where((note) {
        final matchesQuery =
            note.title.toLowerCase().contains(query) ||
            note.content.toLowerCase().contains(query) ||
            note.tags.any((tag) => tag.toLowerCase().contains(query));

        if (!matchesQuery) return false;

        switch (currentState.selectedFilter) {
          case SearchFilter.all:
            return true;
          case SearchFilter.notes:
            return !note.tags.contains('todo') &&
                !note.tags.contains('reminder');
          case SearchFilter.todos:
            return note.tags.contains('todo');
          case SearchFilter.reminders:
            return note.tags.contains('reminder');
        }
      }).toList();

      // Update recent searches
      final updatedRecent = List<String>.from(currentState.recentSearches);
      if (!updatedRecent.contains(event.query)) {
        updatedRecent.insert(0, event.query);
        if (updatedRecent.length > 10) {
          updatedRecent.removeLast();
        }
      }

      emit(
        currentState.copyWith(
          searchResults: results,
          isSearching: false,
          recentSearches: updatedRecent,
        ),
      );
    } catch (e) {
      emit(SearchError('Failed to perform search: $e'));
    }
  }

  void _onClearSearch(ClearSearch event, Emitter<SearchState> emit) {
    if (state is SearchLoaded) {
      emit(
        (state as SearchLoaded).copyWith(
          searchQuery: '',
          searchResults: [],
          isSearching: false,
        ),
      );
    }
  }

  void _onToggleFilters(ToggleFilters event, Emitter<SearchState> emit) {
    if (state is SearchLoaded) {
      final currentState = state as SearchLoaded;
      emit(currentState.copyWith(showFilters: !currentState.showFilters));
    }
  }

  void _onApplyFilter(ApplyFilter event, Emitter<SearchState> emit) {
    if (state is SearchLoaded) {
      final currentState = state as SearchLoaded;
      emit(currentState.copyWith(selectedFilter: event.filter));

      // Re-run search with new filter
      if (currentState.searchQuery.isNotEmpty) {
        add(PerformSearch(currentState.searchQuery));
      }
    }
  }

  void _onSelectRecentSearch(
    SelectRecentSearch event,
    Emitter<SearchState> emit,
  ) {
    if (state is SearchLoaded) {
      emit((state as SearchLoaded).copyWith(searchQuery: event.query));
      add(PerformSearch(event.query));
    }
  }

  void _onStartVoiceSearch(StartVoiceSearch event, Emitter<SearchState> emit) {
    if (state is SearchLoaded) {
      emit((state as SearchLoaded).copyWith(isListening: true));
    }
  }

  void _onStopVoiceSearch(StopVoiceSearch event, Emitter<SearchState> emit) {
    if (state is SearchLoaded) {
      emit((state as SearchLoaded).copyWith(isListening: false));
    }
  }

  void _onVoiceSearchResult(
    VoiceSearchResult event,
    Emitter<SearchState> emit,
  ) {
    if (state is SearchLoaded) {
      emit((state as SearchLoaded).copyWith(searchQuery: event.text));

      if (event.isFinal) {
        add(PerformSearch(event.text));
      }
    }
  }

  void _onLoadRecentSearches(
    LoadRecentSearches event,
    Emitter<SearchState> emit,
  ) {
    if (state is SearchLoaded) {
      // TODO: Load from persistent storage
      final mockRecent = [
        'Weekly Review',
        'Meeting Notes',
        'Project Planning',
        'Shopping List',
      ];

      emit((state as SearchLoaded).copyWith(recentSearches: mockRecent));
    }
  }
}
