import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/models/search_filters.dart';
import '../../data/repositories/unified_repository.dart';
import 'params/global_search_params.dart';

// Events
abstract class GlobalSearchEvent extends Equatable {
  const GlobalSearchEvent();
  @override
  List<Object?> get props => [];
}

class SearchQueryChangedEvent extends GlobalSearchEvent {
  final String query;
  const SearchQueryChangedEvent(this.query);
  @override
  List<Object?> get props => [query];
}

class SearchFiltersChangedEvent extends GlobalSearchEvent {
  final SearchFilters filters;
  const SearchFiltersChangedEvent(this.filters);
  @override
  List<Object?> get props => [filters];
}

class ClearSearchEvent extends GlobalSearchEvent {}

// States
abstract class GlobalSearchState extends Equatable {
  final GlobalSearchParams params;
  const GlobalSearchState(this.params);
  @override
  List<Object?> get props => [params];
}

class GlobalSearchInitial extends GlobalSearchState {
  const GlobalSearchInitial() : super(const GlobalSearchParams());
}

class GlobalSearchLoading extends GlobalSearchState {
  const GlobalSearchLoading(super.params);
}

class GlobalSearchLoaded extends GlobalSearchState {
  const GlobalSearchLoaded(super.params);
}

class GlobalSearchError extends GlobalSearchState {
  final String message;
  const GlobalSearchError(super.params, this.message);
  @override
  List<Object?> get props => [params, message];
}

// BLoC
class GlobalSearchBloc extends Bloc<GlobalSearchEvent, GlobalSearchState> {
  final UnifiedRepository _repository = UnifiedRepository.instance;

  GlobalSearchBloc() : super(const GlobalSearchInitial()) {
    on<SearchQueryChangedEvent>(_onSearchQueryChanged);
    on<SearchFiltersChangedEvent>(_onSearchFiltersChanged);
    on<ClearSearchEvent>(_onClearSearch);
  }

  Future<void> _onSearchQueryChanged(
    SearchQueryChangedEvent event,
    Emitter<GlobalSearchState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(
        GlobalSearchLoaded(
          state.params.copyWith(
            query: '',
            searchResults: [],
            isSearching: false,
          ),
        ),
      );
      return;
    }

    emit(
      GlobalSearchLoading(
        state.params.copyWith(query: event.query, isSearching: true),
      ),
    );

    try {
      final results = await _repository.searchItems(
        event.query,
        types: state.params.filters.types,
        startDate: state.params.filters.startDate,
        endDate: state.params.filters.endDate,
        category: state.params.filters.category,
        sortBy: state.params.filters.sortBy,
        sortDescending: state.params.filters.sortDescending,
      );

      emit(
        GlobalSearchLoaded(
          state.params.copyWith(searchResults: results, isSearching: false),
        ),
      );
    } catch (e) {
      emit(
        GlobalSearchError(
          state.params.copyWith(isSearching: false),
          'Search failed: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onSearchFiltersChanged(
    SearchFiltersChangedEvent event,
    Emitter<GlobalSearchState> emit,
  ) async {
    emit(
      GlobalSearchLoading(
        state.params.copyWith(filters: event.filters, isSearching: true),
      ),
    );

    try {
      final results = await _repository.searchItems(
        state.params.query,
        types: event.filters.types,
        startDate: event.filters.startDate,
        endDate: event.filters.endDate,
        category: event.filters.category,
        sortBy: event.filters.sortBy,
        sortDescending: event.filters.sortDescending,
      );

      emit(
        GlobalSearchLoaded(
          state.params.copyWith(searchResults: results, isSearching: false),
        ),
      );
    } catch (e) {
      emit(
        GlobalSearchError(
          state.params.copyWith(isSearching: false),
          'Filter update failed: ${e.toString()}',
        ),
      );
    }
  }

  void _onClearSearch(ClearSearchEvent event, Emitter<GlobalSearchState> emit) {
    emit(const GlobalSearchInitial());
  }
}
