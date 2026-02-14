import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/domain/entities/universal_item.dart';
import 'package:mynotes/core/utils/smart_voice_parser.dart';
import 'package:mynotes/data/repositories/unified_repository.dart';
import 'package:mynotes/core/services/app_logger.dart';

// Events
abstract class QuickAddEvent extends Equatable {
  const QuickAddEvent();
  @override
  List<Object?> get props => [];
}

class InitializeQuickAdd extends QuickAddEvent {}

class UpdateText extends QuickAddEvent {
  final String text;
  const UpdateText(this.text);
  @override
  List<Object?> get props => [text];
}

class ToggleListening extends QuickAddEvent {
  final bool isListening;
  const ToggleListening(this.isListening);
  @override
  List<Object?> get props => [isListening];
}

class SetVoiceAvailable extends QuickAddEvent {
  final bool isAvailable;
  const SetVoiceAvailable(this.isAvailable);
  @override
  List<Object?> get props => [isAvailable];
}

class SetSavingState extends QuickAddEvent {
  final bool isSaving;
  const SetSavingState(this.isSaving);
  @override
  List<Object?> get props => [isSaving];
}

class SubmitItem extends QuickAddEvent {
  final UniversalItem item;
  const SubmitItem(this.item);
  @override
  List<Object?> get props => [item];
}

// State
class QuickAddState extends Equatable {
  final String text;
  final bool isListening;
  final bool isVoiceAvailable;
  final UniversalItem? previewItem;
  final double parseConfidence;
  final bool showPreview;
  final bool isSaving;
  final bool isSuccess;
  final String? errorMessage;

  const QuickAddState({
    this.text = '',
    this.isListening = false,
    this.isVoiceAvailable = false,
    this.previewItem,
    this.parseConfidence = 0.0,
    this.showPreview = false,
    this.isSaving = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  QuickAddState copyWith({
    String? text,
    bool? isListening,
    bool? isVoiceAvailable,
    UniversalItem? previewItem,
    double? parseConfidence,
    bool? showPreview,
    bool? isSaving,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return QuickAddState(
      text: text ?? this.text,
      isListening: isListening ?? this.isListening,
      isVoiceAvailable: isVoiceAvailable ?? this.isVoiceAvailable,
      previewItem:
          previewItem ??
          (text != null && text.isEmpty ? null : this.previewItem),
      parseConfidence:
          parseConfidence ??
          (text != null && text.isEmpty ? 0.0 : this.parseConfidence),
      showPreview:
          showPreview ??
          (text != null && text.isEmpty ? false : this.showPreview),
      isSaving: isSaving ?? this.isSaving,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    text,
    isListening,
    isVoiceAvailable,
    previewItem,
    parseConfidence,
    showPreview,
    isSaving,
    isSuccess,
    errorMessage,
  ];
}

// Bloc
class QuickAddBloc extends Bloc<QuickAddEvent, QuickAddState> {
  final UnifiedRepository _repository;

  QuickAddBloc({UnifiedRepository? repository})
    : _repository = repository ?? UnifiedRepository.instance,
      super(const QuickAddState()) {
    on<InitializeQuickAdd>(_onInitialize);
    on<UpdateText>(_onUpdateText);
    on<ToggleListening>(_onToggleListening);
    on<SetVoiceAvailable>(_onSetVoiceAvailable);
    on<SetSavingState>(_onSetSaving);
    on<SubmitItem>(_onSubmitItem);
  }

  Future<void> _onInitialize(
    InitializeQuickAdd event,
    Emitter<QuickAddState> emit,
  ) async {
    try {
      await _repository.initialize();
    } catch (e) {
      AppLogger.e('QuickAddBloc: Repository init error: $e');
    }
  }

  void _onUpdateText(UpdateText event, Emitter<QuickAddState> emit) {
    final text = event.text;

    if (text.isEmpty) {
      emit(
        state.copyWith(
          text: '',
          showPreview: false,
          previewItem: null,
          parseConfidence: 0.0,
        ),
      );
      return;
    }

    try {
      final parseResult = SmartVoiceParser.parseComplexVoice(text);
      emit(
        state.copyWith(
          text: text,
          previewItem: parseResult['item'] as UniversalItem,
          parseConfidence: parseResult['confidence'] as double,
          showPreview: true,
        ),
      );
    } catch (e) {
      AppLogger.e('QuickAddBloc: Parse error: $e');
      emit(state.copyWith(text: text));
    }
  }

  void _onToggleListening(ToggleListening event, Emitter<QuickAddState> emit) {
    emit(state.copyWith(isListening: event.isListening));
  }

  void _onSetVoiceAvailable(
    SetVoiceAvailable event,
    Emitter<QuickAddState> emit,
  ) {
    emit(state.copyWith(isVoiceAvailable: event.isAvailable));
  }

  void _onSetSaving(SetSavingState event, Emitter<QuickAddState> emit) {
    emit(state.copyWith(isSaving: event.isSaving));
  }

  Future<void> _onSubmitItem(
    SubmitItem event,
    Emitter<QuickAddState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, isSuccess: false, errorMessage: null));

    try {
      await _repository.createItem(event.item);
      emit(state.copyWith(isSaving: false, isSuccess: true));
    } catch (error) {
      AppLogger.e('QuickAddBloc: Save error: $error');
      emit(
        state.copyWith(
          isSaving: false,
          isSuccess: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
