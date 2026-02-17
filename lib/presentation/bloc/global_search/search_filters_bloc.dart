import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/domain/models/search_filters.dart';

abstract class SearchFiltersEvent extends Equatable {
  const SearchFiltersEvent();

  @override
  List<Object?> get props => [];
}

class ResetSearchFiltersEvent extends SearchFiltersEvent {
  const ResetSearchFiltersEvent();
}

class ToggleSearchFilterTypeEvent extends SearchFiltersEvent {
  final String type;
  final bool selected;

  const ToggleSearchFilterTypeEvent(this.type, this.selected);

  @override
  List<Object?> get props => [type, selected];
}

class UpdateSearchFilterStartDateEvent extends SearchFiltersEvent {
  final DateTime? date;

  const UpdateSearchFilterStartDateEvent(this.date);

  @override
  List<Object?> get props => [date];
}

class UpdateSearchFilterEndDateEvent extends SearchFiltersEvent {
  final DateTime? date;

  const UpdateSearchFilterEndDateEvent(this.date);

  @override
  List<Object?> get props => [date];
}

class UpdateSearchFilterCategoryEvent extends SearchFiltersEvent {
  final String? category;

  const UpdateSearchFilterCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}

class UpdateSearchSortByEvent extends SearchFiltersEvent {
  final String sortBy;

  const UpdateSearchSortByEvent(this.sortBy);

  @override
  List<Object?> get props => [sortBy];
}

class UpdateSearchSortDescendingEvent extends SearchFiltersEvent {
  final bool sortDescending;

  const UpdateSearchSortDescendingEvent(this.sortDescending);

  @override
  List<Object?> get props => [sortDescending];
}

class SearchFiltersState extends Equatable {
  final SearchFilters filters;

  const SearchFiltersState(this.filters);

  @override
  List<Object?> get props => [filters];
}

class SearchFiltersBloc extends Bloc<SearchFiltersEvent, SearchFiltersState> {
  SearchFiltersBloc(SearchFilters initialFilters)
    : super(SearchFiltersState(initialFilters)) {
    on<ResetSearchFiltersEvent>(_onReset);
    on<ToggleSearchFilterTypeEvent>(_onToggleType);
    on<UpdateSearchFilterStartDateEvent>(_onUpdateStartDate);
    on<UpdateSearchFilterEndDateEvent>(_onUpdateEndDate);
    on<UpdateSearchFilterCategoryEvent>(_onUpdateCategory);
    on<UpdateSearchSortByEvent>(_onUpdateSortBy);
    on<UpdateSearchSortDescendingEvent>(_onUpdateSortDescending);
  }

  void _onReset(
    ResetSearchFiltersEvent event,
    Emitter<SearchFiltersState> emit,
  ) {
    emit(const SearchFiltersState(SearchFilters()));
  }

  void _onToggleType(
    ToggleSearchFilterTypeEvent event,
    Emitter<SearchFiltersState> emit,
  ) {
    final types = List<String>.from(state.filters.types);
    if (event.selected) {
      if (!types.contains(event.type)) {
        types.add(event.type);
      }
    } else {
      types.remove(event.type);
    }
    emit(SearchFiltersState(state.filters.copyWith(types: types)));
  }

  void _onUpdateStartDate(
    UpdateSearchFilterStartDateEvent event,
    Emitter<SearchFiltersState> emit,
  ) {
    emit(SearchFiltersState(state.filters.copyWith(startDate: event.date)));
  }

  void _onUpdateEndDate(
    UpdateSearchFilterEndDateEvent event,
    Emitter<SearchFiltersState> emit,
  ) {
    emit(SearchFiltersState(state.filters.copyWith(endDate: event.date)));
  }

  void _onUpdateCategory(
    UpdateSearchFilterCategoryEvent event,
    Emitter<SearchFiltersState> emit,
  ) {
    emit(SearchFiltersState(state.filters.copyWith(category: event.category)));
  }

  void _onUpdateSortBy(
    UpdateSearchSortByEvent event,
    Emitter<SearchFiltersState> emit,
  ) {
    emit(SearchFiltersState(state.filters.copyWith(sortBy: event.sortBy)));
  }

  void _onUpdateSortDescending(
    UpdateSearchSortDescendingEvent event,
    Emitter<SearchFiltersState> emit,
  ) {
    emit(
      SearchFiltersState(
        state.filters.copyWith(sortDescending: event.sortDescending),
      ),
    );
  }
}
