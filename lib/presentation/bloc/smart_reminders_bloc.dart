import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mynotes/domain/repositories/smart_reminder_repository.dart';

// Smart Reminders BLoC - Events
abstract class SmartRemindersEvent extends Equatable {
  const SmartRemindersEvent();
  @override
  List<Object?> get props => [];
}

class LoadSuggestionsEvent extends SmartRemindersEvent {
  const LoadSuggestionsEvent();
}

class LoadPatternsEvent extends SmartRemindersEvent {
  const LoadPatternsEvent();
}

class AcceptSuggestionEvent extends SmartRemindersEvent {
  final String suggestionId;
  const AcceptSuggestionEvent({required this.suggestionId});
  @override
  List<Object?> get props => [suggestionId];
}

class RejectSuggestionEvent extends SmartRemindersEvent {
  final String suggestionId;
  const RejectSuggestionEvent({required this.suggestionId});
  @override
  List<Object?> get props => [suggestionId];
}

class ToggleLearningEvent extends SmartRemindersEvent {
  final String settingKey;
  final bool isEnabled;
  const ToggleLearningEvent({
    required this.settingKey,
    required this.isEnabled,
  });
  @override
  List<Object?> get props => [settingKey, isEnabled];
}

// Smart Reminders BLoC - States
abstract class SmartRemindersState extends Equatable {
  const SmartRemindersState();
  @override
  List<Object?> get props => [];
}

class SmartRemindersInitial extends SmartRemindersState {
  const SmartRemindersInitial();
}

class SmartRemindersLoading extends SmartRemindersState {
  const SmartRemindersLoading();
}

class SuggestionsLoaded extends SmartRemindersState {
  final List<Map<String, dynamic>> suggestions;
  final int acceptedCount;

  const SuggestionsLoaded({
    required this.suggestions,
    required this.acceptedCount,
  });

  @override
  List<Object?> get props => [suggestions, acceptedCount];
}

class PatternsLoaded extends SmartRemindersState {
  final List<Map<String, dynamic>> patterns;
  final double averageCompletionRate;

  const PatternsLoaded({
    required this.patterns,
    required this.averageCompletionRate,
  });

  @override
  List<Object?> get props => [patterns, averageCompletionRate];
}

class SmartRemindersError extends SmartRemindersState {
  final String message;
  const SmartRemindersError({required this.message});
  @override
  List<Object?> get props => [message];
}

class SmartRemindersLoaded extends SmartRemindersState {
  final List<dynamic> reminders;
  const SmartRemindersLoaded({required this.reminders});
  @override
  List<Object?> get props => [reminders];
}

// Smart Reminders BLoC - Implementation
class SmartRemindersBloc
    extends Bloc<SmartRemindersEvent, SmartRemindersState> {
  final SmartReminderRepository smartReminderRepository;

  SmartRemindersBloc({required this.smartReminderRepository})
    : super(const SmartRemindersInitial()) {
    on<LoadSuggestionsEvent>(_onLoadSuggestions);
    on<LoadPatternsEvent>(_onLoadPatterns);
    on<AcceptSuggestionEvent>(_onAcceptSuggestion);
    on<RejectSuggestionEvent>(_onRejectSuggestion);
    on<ToggleLearningEvent>(_onToggleLearning);
  }

  // Mock data
  final List<Map<String, dynamic>> _suggestions = [
    {
      'id': '1',
      'title': 'Team Meeting',
      'suggestedTime': '2:00 PM',
      'confidence': 0.92,
      'frequency': 'Weekly on Tuesday',
      'reason': 'Based on meeting history',
    },
    {
      'id': '2',
      'title': 'Project Review',
      'suggestedTime': '4:30 PM',
      'confidence': 0.85,
      'frequency': 'Weekly on Friday',
      'reason': 'Detected from completion patterns',
    },
    {
      'id': '3',
      'title': 'Grocery Shopping',
      'suggestedTime': '6:00 PM',
      'confidence': 0.78,
      'frequency': 'Every Saturday',
      'reason': 'Learned from your routine',
    },
  ];

  final List<Map<String, dynamic>> _patterns = [
    {
      'id': '1',
      'title': 'Morning Routine',
      'time': '8:00 AM',
      'frequency': 'Daily',
      'completed': 94,
      'total': 100,
      'completionRate': 0.94,
    },
    {
      'id': '2',
      'title': 'Work Check-in',
      'time': '10:00 AM',
      'frequency': 'Weekdays',
      'completed': 87,
      'total': 100,
      'completionRate': 0.87,
    },
    {
      'id': '3',
      'title': 'Evening Review',
      'time': '9:00 PM',
      'frequency': 'Daily',
      'completed': 76,
      'total': 100,
      'completionRate': 0.76,
    },
  ];

  Future<void> _onLoadSuggestions(
    LoadSuggestionsEvent event,
    Emitter<SmartRemindersState> emit,
  ) async {
    try {
      emit(const SmartRemindersLoading());

      await Future.delayed(const Duration(milliseconds: 500));

      emit(SuggestionsLoaded(suggestions: _suggestions, acceptedCount: 0));
    } catch (e) {
      emit(SmartRemindersError(message: e.toString()));
    }
  }

  Future<void> _onLoadPatterns(
    LoadPatternsEvent event,
    Emitter<SmartRemindersState> emit,
  ) async {
    try {
      emit(const SmartRemindersLoading());

      await Future.delayed(const Duration(milliseconds: 500));

      final avgRate =
          _patterns.fold<double>(
            0,
            (sum, p) => sum + (p['completionRate'] as double),
          ) /
          _patterns.length;

      emit(PatternsLoaded(patterns: _patterns, averageCompletionRate: avgRate));
    } catch (e) {
      emit(SmartRemindersError(message: e.toString()));
    }
  }

  Future<void> _onAcceptSuggestion(
    AcceptSuggestionEvent event,
    Emitter<SmartRemindersState> emit,
  ) async {
    try {
      if (state is! SuggestionsLoaded) return;

      final currentState = state as SuggestionsLoaded;
      _suggestions.removeWhere((s) => s['id'] == event.suggestionId);

      emit(
        SuggestionsLoaded(
          suggestions: _suggestions,
          acceptedCount: currentState.acceptedCount + 1,
        ),
      );
    } catch (e) {
      emit(SmartRemindersError(message: e.toString()));
    }
  }

  Future<void> _onRejectSuggestion(
    RejectSuggestionEvent event,
    Emitter<SmartRemindersState> emit,
  ) async {
    try {
      if (state is! SuggestionsLoaded) return;

      final currentState = state as SuggestionsLoaded;
      _suggestions.removeWhere((s) => s['id'] == event.suggestionId);

      emit(
        SuggestionsLoaded(
          suggestions: _suggestions,
          acceptedCount: currentState.acceptedCount,
        ),
      );
    } catch (e) {
      emit(SmartRemindersError(message: e.toString()));
    }
  }

  Future<void> _onToggleLearning(
    ToggleLearningEvent event,
    Emitter<SmartRemindersState> emit,
  ) async {
    try {
      // Store setting in SharedPreferences or database
      // For now, just acknowledge the change
      if (state is SuggestionsLoaded) {
        emit(state as SuggestionsLoaded);
      } else if (state is PatternsLoaded) {
        emit(state as PatternsLoaded);
      }
    } catch (e) {
      emit(SmartRemindersError(message: e.toString()));
    }
  }
}
