import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Events
abstract class AdvancedSearchEvent extends Equatable {
  const AdvancedSearchEvent();
  @override
  List<Object?> get props => [];
}

class LoadAdvancedSearchHistoryEvent extends AdvancedSearchEvent {
  const LoadAdvancedSearchHistoryEvent();
}

class AddToSearchHistoryEvent extends AdvancedSearchEvent {
  final String query;
  const AddToSearchHistoryEvent(this.query);
  @override
  List<Object?> get props => [query];
}

class ClearSearchHistoryEvent extends AdvancedSearchEvent {
  const ClearSearchHistoryEvent();
}

class RemoveFromSearchHistoryEvent extends AdvancedSearchEvent {
  final String query;
  const RemoveFromSearchHistoryEvent(this.query);
  @override
  List<Object?> get props => [query];
}

class SaveSearchEvent extends AdvancedSearchEvent {
  final String query;
  const SaveSearchEvent(this.query);
  @override
  List<Object?> get props => [query];
}

class RemoveSavedSearchEvent extends AdvancedSearchEvent {
  final String query;
  const RemoveSavedSearchEvent(this.query);
  @override
  List<Object?> get props => [query];
}

class UpdateSearchFilterEvent extends AdvancedSearchEvent {
  final String filter;
  const UpdateSearchFilterEvent(this.filter);
  @override
  List<Object?> get props => [filter];
}

class UpdateSearchSortEvent extends AdvancedSearchEvent {
  final String sort;
  const UpdateSearchSortEvent(this.sort);
  @override
  List<Object?> get props => [sort];
}

class AdvancedSearchQueryChangedEvent extends AdvancedSearchEvent {
  final String query;
  const AdvancedSearchQueryChangedEvent(this.query);
  @override
  List<Object?> get props => [query];
}

// State
class AdvancedSearchState extends Equatable {
  final List<String> searchHistory;
  final List<String> savedSearches;
  final String selectedFilter;
  final String selectedSort;
  final bool isLoading;

  const AdvancedSearchState({
    this.searchHistory = const [],
    this.savedSearches = const [],
    this.selectedFilter = 'all',
    this.selectedSort = 'relevance',
    this.isLoading = false,
  });

  AdvancedSearchState copyWith({
    List<String>? searchHistory,
    List<String>? savedSearches,
    String? selectedFilter,
    String? selectedSort,
    bool? isLoading,
  }) {
    return AdvancedSearchState(
      searchHistory: searchHistory ?? this.searchHistory,
      savedSearches: savedSearches ?? this.savedSearches,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      selectedSort: selectedSort ?? this.selectedSort,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
    searchHistory,
    savedSearches,
    selectedFilter,
    selectedSort,
    isLoading,
  ];
}

// BLoC
class AdvancedSearchBloc
    extends Bloc<AdvancedSearchEvent, AdvancedSearchState> {
  static const String _historyKey = 'search_history';
  static const String _savedSearchesKey = 'saved_searches';

  AdvancedSearchBloc() : super(const AdvancedSearchState()) {
    on<LoadAdvancedSearchHistoryEvent>(_onLoadHistory);
    on<AddToSearchHistoryEvent>(_onAddToHistory);
    on<ClearSearchHistoryEvent>(_onClearHistory);
    on<RemoveFromSearchHistoryEvent>(_onRemoveFromHistory);
    on<SaveSearchEvent>(_onSaveSearch);
    on<RemoveSavedSearchEvent>(_onRemoveSavedSearch);
    on<UpdateSearchFilterEvent>(_onUpdateFilter);
    on<UpdateSearchSortEvent>(_onUpdateSort);
    on<AdvancedSearchQueryChangedEvent>(_onQueryChanged);
  }

  Future<void> _onQueryChanged(
    AdvancedSearchQueryChangedEvent event,
    Emitter<AdvancedSearchState> emit,
  ) async {
    // In a real app, this would trigger search ranking or similar
  }

  Future<void> _onLoadHistory(
    LoadAdvancedSearchHistoryEvent event,
    Emitter<AdvancedSearchState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_historyKey) ?? [];
      final saved = prefs.getStringList(_savedSearchesKey) ?? [];
      emit(
        state.copyWith(
          searchHistory: history,
          savedSearches: saved,
          isLoading: false,
        ),
      );
    } catch (_) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _onAddToHistory(
    AddToSearchHistoryEvent event,
    Emitter<AdvancedSearchState> emit,
  ) async {
    if (event.query.trim().isEmpty) return;

    final history = List<String>.from(state.searchHistory);
    if (history.contains(event.query)) {
      history.remove(event.query);
    }
    history.insert(0, event.query);
    if (history.length > 20) history.removeLast();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_historyKey, history);
      emit(state.copyWith(searchHistory: history));
    } catch (_) {
      // Silently fail for history
    }
  }

  Future<void> _onClearHistory(
    ClearSearchHistoryEvent event,
    Emitter<AdvancedSearchState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
      emit(state.copyWith(searchHistory: const []));
    } catch (_) {}
  }

  Future<void> _onRemoveFromHistory(
    RemoveFromSearchHistoryEvent event,
    Emitter<AdvancedSearchState> emit,
  ) async {
    final history = List<String>.from(state.searchHistory)..remove(event.query);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_historyKey, history);
      emit(state.copyWith(searchHistory: history));
    } catch (_) {}
  }

  Future<void> _onSaveSearch(
    SaveSearchEvent event,
    Emitter<AdvancedSearchState> emit,
  ) async {
    if (event.query.trim().isEmpty) return;
    if (state.savedSearches.contains(event.query)) return;

    final saved = List<String>.from(state.savedSearches)
      ..insert(0, event.query);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_savedSearchesKey, saved);
      emit(state.copyWith(savedSearches: saved));
    } catch (_) {}
  }

  Future<void> _onRemoveSavedSearch(
    RemoveSavedSearchEvent event,
    Emitter<AdvancedSearchState> emit,
  ) async {
    final saved = List<String>.from(state.savedSearches)..remove(event.query);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_savedSearchesKey, saved);
      emit(state.copyWith(savedSearches: saved));
    } catch (_) {}
  }

  void _onUpdateFilter(
    UpdateSearchFilterEvent event,
    Emitter<AdvancedSearchState> emit,
  ) {
    emit(state.copyWith(selectedFilter: event.filter));
  }

  void _onUpdateSort(
    UpdateSearchSortEvent event,
    Emitter<AdvancedSearchState> emit,
  ) {
    emit(state.copyWith(selectedSort: event.sort));
  }
}
