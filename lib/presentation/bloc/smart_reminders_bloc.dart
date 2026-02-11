import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mynotes/domain/repositories/smart_reminder_repository.dart';
import 'package:mynotes/domain/repositories/note_repository.dart';
import 'package:mynotes/domain/services/ai_suggestion_engine.dart';
import 'package:mynotes/domain/entities/note.dart';
import 'params/smart_reminders_params.dart';

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

class ChangePeriodEvent extends SmartRemindersEvent {
  final String period;
  const ChangePeriodEvent({required this.period});
  @override
  List<Object?> get props => [period];
}

// Smart Reminders BLoC - States
class SmartRemindersState extends Equatable {
  final SmartRemindersParams params;
  const SmartRemindersState({required this.params});
  @override
  List<Object?> get props => [params];
}

class SmartRemindersInitial extends SmartRemindersState {
  const SmartRemindersInitial() : super(params: const SmartRemindersParams());
}

class SmartRemindersLoading extends SmartRemindersState {
  const SmartRemindersLoading({required super.params});
}

class SmartRemindersLoaded extends SmartRemindersState {
  const SmartRemindersLoaded({required super.params});
}

class SmartRemindersError extends SmartRemindersState {
  final String message;
  const SmartRemindersError({required this.message, required super.params});
  @override
  List<Object?> get props => [message, params];
}

class SmartRemindersBloc
    extends Bloc<SmartRemindersEvent, SmartRemindersState> {
  final SmartReminderRepository smartReminderRepository;
  final NoteRepository noteRepository;
  final AISuggestionEngine aiSuggestionEngine;

  SmartRemindersBloc({
    required this.smartReminderRepository,
    required this.noteRepository,
    required this.aiSuggestionEngine,
  }) : super(const SmartRemindersInitial()) {
    on<LoadSuggestionsEvent>(_onLoadSuggestions);
    on<LoadPatternsEvent>(_onLoadPatterns);
    on<AcceptSuggestionEvent>(_onAcceptSuggestion);
    on<RejectSuggestionEvent>(_onRejectSuggestion);
    on<ToggleLearningEvent>(_onToggleLearning);
    on<ChangePeriodEvent>(_onChangePeriod);
  }

  Future<void> _onLoadSuggestions(
    LoadSuggestionsEvent event,
    Emitter<SmartRemindersState> emit,
  ) async {
    emit(SmartRemindersLoading(params: state.params.copyWith(isLoading: true)));
    try {
      final reminders = await _getReminders();
      final reminderData = reminders
          .map(
            (n) => {
              'id': n.id,
              'title': n.title,
              'createdAt': n.createdAt.toIso8601String(),
              'alarms': n.alarms
                  ?.map((a) => a.scheduledTime.toIso8601String())
                  .toList(),
            },
          )
          .toList();

      final suggestions = await aiSuggestionEngine.generateSuggestions(
        reminderHistory: reminderData,
        mediaItems: [],
      );

      emit(
        SmartRemindersLoaded(
          params: state.params.copyWith(
            suggestions: suggestions,
            reminders: reminderData,
            isLoading: false,
          ),
        ),
      );
    } catch (e) {
      emit(
        SmartRemindersError(
          message: e.toString(),
          params: state.params.copyWith(isLoading: false),
        ),
      );
    }
  }

  Future<void> _onLoadPatterns(
    LoadPatternsEvent event,
    Emitter<SmartRemindersState> emit,
  ) async {
    emit(SmartRemindersLoading(params: state.params.copyWith(isLoading: true)));
    try {
      final reminders = await _getReminders();
      final reminderData = reminders
          .map(
            (n) => {
              'id': n.id,
              'title': n.title,
              'createdAt': n.createdAt.toIso8601String(),
            },
          )
          .toList();

      final frequencyPatterns = aiSuggestionEngine.detectFrequencyPatterns(
        reminderData,
      );
      final avgPerDay = frequencyPatterns['avgPerDay'] as double? ?? 0;

      final patterns = <Map<String, dynamic>>[];
      final timePatterns = aiSuggestionEngine.detectTimePatterns(reminderData);
      timePatterns.forEach((key, count) {
        if (count >= 2) {
          patterns.add({
            'id': 'time_$key',
            'title': 'Time Pattern: $key',
            'time': key,
            'frequency': 'Recurring',
            'completed': count,
            'total': count,
            'completionRate': 1.0,
          });
        }
      });

      emit(
        SmartRemindersLoaded(
          params: state.params.copyWith(
            patterns: patterns,
            reminders: reminderData,
            averageCompletionRate: avgPerDay,
            isLoading: false,
          ),
        ),
      );
    } catch (e) {
      emit(
        SmartRemindersError(
          message: e.toString(),
          params: state.params.copyWith(isLoading: false),
        ),
      );
    }
  }

  Future<void> _onAcceptSuggestion(
    AcceptSuggestionEvent event,
    Emitter<SmartRemindersState> emit,
  ) async {
    try {
      await smartReminderRepository.acceptSuggestion(event.suggestionId);
      final suggestions = List<Map<String, dynamic>>.from(
        state.params.suggestions,
      )..removeWhere((s) => s['id'] == event.suggestionId);

      emit(
        SmartRemindersLoaded(
          params: state.params.copyWith(
            suggestions: suggestions,
            acceptedCount: state.params.acceptedCount + 1,
          ),
        ),
      );
    } catch (e) {
      emit(SmartRemindersError(message: e.toString(), params: state.params));
    }
  }

  Future<void> _onRejectSuggestion(
    RejectSuggestionEvent event,
    Emitter<SmartRemindersState> emit,
  ) async {
    try {
      await smartReminderRepository.rejectSuggestion(event.suggestionId);
      final suggestions = List<Map<String, dynamic>>.from(
        state.params.suggestions,
      )..removeWhere((s) => s['id'] == event.suggestionId);

      emit(
        SmartRemindersLoaded(
          params: state.params.copyWith(suggestions: suggestions),
        ),
      );
    } catch (e) {
      emit(SmartRemindersError(message: e.toString(), params: state.params));
    }
  }

  void _onToggleLearning(
    ToggleLearningEvent event,
    Emitter<SmartRemindersState> emit,
  ) {
    final settings = Map<String, bool>.from(state.params.learningSettings)
      ..[event.settingKey] = event.isEnabled;

    emit(
      SmartRemindersLoaded(
        params: state.params.copyWith(learningSettings: settings),
      ),
    );
  }

  void _onChangePeriod(
    ChangePeriodEvent event,
    Emitter<SmartRemindersState> emit,
  ) {
    emit(
      SmartRemindersLoaded(
        params: state.params.copyWith(selectedPeriod: event.period),
      ),
    );
  }

  Future<List<Note>> _getReminders() async {
    final notes = await noteRepository.getAllNotes();
    return notes
        .where((n) => n.alarms != null && n.alarms!.isNotEmpty)
        .toList();
  }
}
