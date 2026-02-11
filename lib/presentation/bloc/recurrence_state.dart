part of 'recurrence_bloc.dart';

class RecurrenceState extends Equatable {
  final String frequency;
  final Set<int> selectedDays;
  final String customPattern;

  const RecurrenceState({
    required this.frequency,
    required this.selectedDays,
    this.customPattern = '',
  });

  RecurrenceState copyWith({
    String? frequency,
    Set<int>? selectedDays,
    String? customPattern,
  }) {
    return RecurrenceState(
      frequency: frequency ?? this.frequency,
      selectedDays: selectedDays ?? this.selectedDays,
      customPattern: customPattern ?? this.customPattern,
    );
  }

  @override
  List<Object?> get props => [frequency, selectedDays, customPattern];
}

class RecurrenceInitial extends RecurrenceState {
  const RecurrenceInitial({
    required super.frequency,
    required super.selectedDays,
    super.customPattern,
  });
}
