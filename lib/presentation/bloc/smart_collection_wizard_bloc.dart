import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Smart Collection Wizard BLoC - Events
abstract class SmartCollectionWizardEvent extends Equatable {
  const SmartCollectionWizardEvent();
  @override
  List<Object?> get props => [];
}

class UpdateWizardBasicInfoEvent extends SmartCollectionWizardEvent {
  final String name;
  final String description;
  const UpdateWizardBasicInfoEvent({
    required this.name,
    required this.description,
  });
  @override
  List<Object?> get props => [name, description];
}

class AddWizardRuleEvent extends SmartCollectionWizardEvent {
  final Map<String, dynamic> rule;
  const AddWizardRuleEvent({required this.rule});
  @override
  List<Object?> get props => [rule];
}

class RemoveWizardRuleEvent extends SmartCollectionWizardEvent {
  final int index;
  const RemoveWizardRuleEvent({required this.index});
  @override
  List<Object?> get props => [index];
}

class UpdateWizardRulesEvent extends SmartCollectionWizardEvent {
  final List<Map<String, dynamic>> rules;
  const UpdateWizardRulesEvent({required this.rules});
  @override
  List<Object?> get props => [rules];
}

class UpdateWizardLogicEvent extends SmartCollectionWizardEvent {
  final String logic;
  const UpdateWizardLogicEvent({required this.logic});
  @override
  List<Object?> get props => [logic];
}

class UpdateWizardStepEvent extends SmartCollectionWizardEvent {
  final int step;
  const UpdateWizardStepEvent({required this.step});
  @override
  List<Object?> get props => [step];
}

// Smart Collection Wizard BLoC - State
class SmartCollectionWizardState extends Equatable {
  final int currentStep;
  final String name;
  final String description;
  final List<Map<String, dynamic>> rules;
  final String logic;

  const SmartCollectionWizardState({
    this.currentStep = 0,
    this.name = '',
    this.description = '',
    this.rules = const [],
    this.logic = 'AND',
  });

  SmartCollectionWizardState copyWith({
    int? currentStep,
    String? name,
    String? description,
    List<Map<String, dynamic>>? rules,
    String? logic,
  }) {
    return SmartCollectionWizardState(
      currentStep: currentStep ?? this.currentStep,
      name: name ?? this.name,
      description: description ?? this.description,
      rules: rules ?? this.rules,
      logic: logic ?? this.logic,
    );
  }

  @override
  List<Object?> get props => [currentStep, name, description, rules, logic];
}

// Smart Collection Wizard BLoC - Implementation
class SmartCollectionWizardBloc
    extends Bloc<SmartCollectionWizardEvent, SmartCollectionWizardState> {
  SmartCollectionWizardBloc() : super(const SmartCollectionWizardState()) {
    on<UpdateWizardBasicInfoEvent>((event, emit) {
      emit(state.copyWith(name: event.name, description: event.description));
    });

    on<AddWizardRuleEvent>((event, emit) {
      final newRules = List<Map<String, dynamic>>.from(state.rules)
        ..add(event.rule);
      emit(state.copyWith(rules: newRules));
    });

    on<RemoveWizardRuleEvent>((event, emit) {
      final newRules = List<Map<String, dynamic>>.from(state.rules)
        ..removeAt(event.index);
      emit(state.copyWith(rules: newRules));
    });

    on<UpdateWizardRulesEvent>((event, emit) {
      emit(state.copyWith(rules: event.rules));
    });

    on<UpdateWizardLogicEvent>((event, emit) {
      emit(state.copyWith(logic: event.logic));
    });

    on<UpdateWizardStepEvent>((event, emit) {
      emit(state.copyWith(currentStep: event.step));
    });
  }
}
