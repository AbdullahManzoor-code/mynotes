import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'recurrence_event.dart';
part 'recurrence_state.dart';

class RecurrenceBloc extends Bloc<RecurrenceEvent, RecurrenceState> {
  RecurrenceBloc()
    : super(
        const RecurrenceInitial(frequency: 'weekly', selectedDays: {1, 3, 5}),
      ) {
    on<UpdateFrequencyEvent>(_onUpdateFrequency);
    on<ToggleDayEvent>(_onToggleDay);
    on<UpdateCustomPatternEvent>(_onUpdateCustomPattern);
  }

  void _onUpdateFrequency(
    UpdateFrequencyEvent event,
    Emitter<RecurrenceState> emit,
  ) {
    emit(state.copyWith(frequency: event.frequency));
  }

  void _onToggleDay(ToggleDayEvent event, Emitter<RecurrenceState> emit) {
    final newDays = Set<int>.from(state.selectedDays);
    if (newDays.contains(event.day)) {
      newDays.remove(event.day);
    } else {
      newDays.add(event.day);
    }
    emit(state.copyWith(selectedDays: newDays));
  }

  void _onUpdateCustomPattern(
    UpdateCustomPatternEvent event,
    Emitter<RecurrenceState> emit,
  ) {
    emit(state.copyWith(customPattern: event.pattern));
  }
}
