import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// --- Events ---
abstract class FiltersEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AddConditionEvent extends FiltersEvent {}

class RemoveConditionEvent extends FiltersEvent {
  final int index;
  RemoveConditionEvent(this.index);

  @override
  List<Object?> get props => [index];
}

class UpdateConditionEvent extends FiltersEvent {
  final int index;
  final String field;
  final dynamic value;
  UpdateConditionEvent(this.index, this.field, this.value);

  @override
  List<Object?> get props => [index, field, value];
}

class UpdateLogicEvent extends FiltersEvent {
  final String logic;
  UpdateLogicEvent(this.logic);

  @override
  List<Object?> get props => [logic];
}

class ResetFiltersEvent extends FiltersEvent {}

// --- State ---
class FiltersState extends Equatable {
  final List<Map<String, dynamic>> conditions;
  final String logic;

  const FiltersState({required this.conditions, required this.logic});

  factory FiltersState.initial() {
    return const FiltersState(
      conditions: [
        {'type': 'tag', 'operator': 'contains', 'value': ''},
      ],
      logic: 'AND',
    );
  }

  FiltersState copyWith({
    List<Map<String, dynamic>>? conditions,
    String? logic,
  }) {
    return FiltersState(
      conditions: conditions ?? this.conditions,
      logic: logic ?? this.logic,
    );
  }

  @override
  List<Object?> get props => [conditions, logic];
}

// --- Bloc ---
class FiltersBloc extends Bloc<FiltersEvent, FiltersState> {
  FiltersBloc() : super(FiltersState.initial()) {
    on<AddConditionEvent>((event, emit) {
      final newConditions = List<Map<String, dynamic>>.from(state.conditions);
      newConditions.add({'type': 'tag', 'operator': 'contains', 'value': ''});
      emit(state.copyWith(conditions: newConditions));
    });

    on<RemoveConditionEvent>((event, emit) {
      if (state.conditions.length > 1) {
        final newConditions = List<Map<String, dynamic>>.from(state.conditions);
        newConditions.removeAt(event.index);
        emit(state.copyWith(conditions: newConditions));
      }
    });

    on<UpdateConditionEvent>((event, emit) {
      final newConditions = List<Map<String, dynamic>>.from(state.conditions);
      final updatedCondition = Map<String, dynamic>.from(
        newConditions[event.index],
      );
      updatedCondition[event.field] = event.value;
      newConditions[event.index] = updatedCondition;
      emit(state.copyWith(conditions: newConditions));
    });

    on<UpdateLogicEvent>((event, emit) {
      emit(state.copyWith(logic: event.logic));
    });

    on<ResetFiltersEvent>((event, emit) {
      emit(FiltersState.initial());
    });
  }
}
