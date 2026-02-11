import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'params/unified_items_params.dart';

// Unified Items BLoC - Events
abstract class UnifiedItemsEvent extends Equatable {
  const UnifiedItemsEvent();
  @override
  List<Object?> get props => [];
}

class ChangeFilterEvent extends UnifiedItemsEvent {
  final String filter;
  const ChangeFilterEvent(this.filter);
  @override
  List<Object?> get props => [filter];
}

class ChangeSortEvent extends UnifiedItemsEvent {
  final String sortBy;
  const ChangeSortEvent(this.sortBy);
  @override
  List<Object?> get props => [sortBy];
}

class TogglePinnedFilterEvent extends UnifiedItemsEvent {
  const TogglePinnedFilterEvent();
}

class UpdateSearchQueryEvent extends UnifiedItemsEvent {
  final String query;
  const UpdateSearchQueryEvent(this.query);
  @override
  List<Object?> get props => [query];
}

// Unified Items BLoC - States
class UnifiedItemsState extends Equatable {
  final UnifiedItemsParams params;
  const UnifiedItemsState({required this.params});
  @override
  List<Object?> get props => [params];
}

class UnifiedItemsBloc extends Bloc<UnifiedItemsEvent, UnifiedItemsState> {
  UnifiedItemsBloc() : super(const UnifiedItemsState(params: UnifiedItemsParams())) {
    on<ChangeFilterEvent>(_onChangeFilter);
    on<ChangeSortEvent>(_onChangeSort);
    on<TogglePinnedFilterEvent>(_onTogglePinned);
    on<UpdateSearchQueryEvent>(_onUpdateSearch);
  }

  void _onChangeFilter(ChangeFilterEvent event, Emitter<UnifiedItemsState> emit) {
    emit(UnifiedItemsState(params: state.params.copyWith(selectedFilter: event.filter)));
  }

  void _onChangeSort(ChangeSortEvent event, Emitter<UnifiedItemsState> emit) {
    emit(UnifiedItemsState(params: state.params.copyWith(sortBy: event.sortBy)));
  }

  void _onTogglePinned(TogglePinnedFilterEvent event, Emitter<UnifiedItemsState> emit) {
    emit(UnifiedItemsState(params: state.params.copyWith(showOnlyPinned: !state.params.showOnlyPinned)));
  }

  void _onUpdateSearch(UpdateSearchQueryEvent event, Emitter<UnifiedItemsState> emit) {
    emit(UnifiedItemsState(params: state.params.copyWith(searchQuery: event.query)));
  }
}
