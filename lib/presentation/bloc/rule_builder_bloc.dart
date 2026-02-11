import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mynotes/domain/services/rule_evaluation_engine.dart';

// Rule Builder BLoC - Events
abstract class RuleBuilderEvent extends Equatable {
  const RuleBuilderEvent();
  @override
  List<Object?> get props => [];
}

class UpdateRuleFieldEvent extends RuleBuilderEvent {
  final String field;
  const UpdateRuleFieldEvent({required this.field});
  @override
  List<Object?> get props => [field];
}

class UpdateRuleOperatorEvent extends RuleBuilderEvent {
  final String operator;
  const UpdateRuleOperatorEvent({required this.operator});
  @override
  List<Object?> get props => [operator];
}

class UpdateRuleValueEvent extends RuleBuilderEvent {
  final String value;
  const UpdateRuleValueEvent({required this.value});
  @override
  List<Object?> get props => [value];
}

class AddRuleEvent extends RuleBuilderEvent {
  final Map<String, dynamic> rule;
  const AddRuleEvent({required this.rule});
  @override
  List<Object?> get props => [rule];
}

class RemoveRuleIndexEvent extends RuleBuilderEvent {
  final int index;
  const RemoveRuleIndexEvent({required this.index});
  @override
  List<Object?> get props => [index];
}

class ClearAllRulesEvent extends RuleBuilderEvent {
  const ClearAllRulesEvent();
}

class InitializeRuleBuilderEvent extends RuleBuilderEvent {
  final List<Map<String, dynamic>> initialRules;
  const InitializeRuleBuilderEvent({required this.initialRules});
  @override
  List<Object?> get props => [initialRules];
}

// Rule Builder BLoC - State
class RuleBuilderState extends Equatable {
  final String field;
  final String operator;
  final String value;
  final List<Map<String, dynamic>> builtRules;

  const RuleBuilderState({
    this.field = '',
    this.operator = '=',
    this.value = '',
    this.builtRules = const [],
  });

  RuleBuilderState copyWith({
    String? field,
    String? operator,
    String? value,
    List<Map<String, dynamic>>? builtRules,
  }) {
    return RuleBuilderState(
      field: field ?? this.field,
      operator: operator ?? this.operator,
      value: value ?? this.value,
      builtRules: builtRules ?? this.builtRules,
    );
  }

  @override
  List<Object?> get props => [field, operator, value, builtRules];
}

// Rule Builder BLoC - Implementation
class RuleBuilderBloc extends Bloc<RuleBuilderEvent, RuleBuilderState> {
  final RuleEvaluationEngine ruleEngine;

  RuleBuilderBloc({required this.ruleEngine})
    : super(const RuleBuilderState()) {
    on<UpdateRuleFieldEvent>((event, emit) {
      emit(state.copyWith(field: event.field));
    });

    on<UpdateRuleOperatorEvent>((event, emit) {
      emit(state.copyWith(operator: event.operator));
    });

    on<UpdateRuleValueEvent>((event, emit) {
      emit(state.copyWith(value: event.value));
    });

    on<AddRuleEvent>((event, emit) {
      final newRules = List<Map<String, dynamic>>.from(state.builtRules)
        ..add(event.rule);
      emit(
        state.copyWith(
          builtRules: newRules,
          field: '',
          value: '',
          operator: '=',
        ),
      );
    });

    on<RemoveRuleIndexEvent>((event, emit) {
      final newRules = List<Map<String, dynamic>>.from(state.builtRules)
        ..removeAt(event.index);
      emit(state.copyWith(builtRules: newRules));
    });

    on<ClearAllRulesEvent>((event, emit) {
      emit(state.copyWith(builtRules: []));
    });

    on<InitializeRuleBuilderEvent>((event, emit) {
      emit(state.copyWith(builtRules: event.initialRules));
    });
  }
}
