import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/domain/entities/universal_item.dart';
import 'package:mynotes/core/utils/smart_voice_parser.dart';

// Events
abstract class CrossFeatureEvent extends Equatable {
  const CrossFeatureEvent();
  @override
  List<Object?> get props => [];
}

class StartScenario extends CrossFeatureEvent {
  final int scenarioIndex;
  const StartScenario(this.scenarioIndex);
  @override
  List<Object?> get props => [scenarioIndex];
}

class NextStep extends CrossFeatureEvent {}

class CompleteTransformation extends CrossFeatureEvent {}

// State
class CrossFeatureState extends Equatable {
  final int selectedScenario;
  final int currentStep;
  final bool isTransforming;
  final UniversalItem? demoItem;
  final List<String> transformationSteps;

  const CrossFeatureState({
    this.selectedScenario = 0,
    this.currentStep = 0,
    this.isTransforming = false,
    this.demoItem,
    this.transformationSteps = const [],
  });

  CrossFeatureState copyWith({
    int? selectedScenario,
    int? currentStep,
    bool? isTransforming,
    UniversalItem? demoItem,
    List<String>? transformationSteps,
  }) {
    return CrossFeatureState(
      selectedScenario: selectedScenario ?? this.selectedScenario,
      currentStep: currentStep ?? this.currentStep,
      isTransforming: isTransforming ?? this.isTransforming,
      demoItem: demoItem ?? this.demoItem,
      transformationSteps: transformationSteps ?? this.transformationSteps,
    );
  }

  @override
  List<Object?> get props => [
    selectedScenario,
    currentStep,
    isTransforming,
    demoItem,
    transformationSteps,
  ];
}

// Demo Scenarios Data
const List<Map<String, dynamic>> _demoScenarios = [
  {
    'title': 'Meeting Note → Todo → Reminder',
    'steps': [
      'Create meeting note with agenda',
      'Convert to todo: "Follow up with client"',
      'Add reminder for tomorrow at 2 PM',
      'See unified integration in action',
    ],
    'initialText':
        'Team meeting notes:\n- Discussed Q1 targets\n- Client wants proposal by Friday\n- Need to schedule follow-up',
  },
  {
    'title': 'Voice → Smart Everything',
    'steps': [
      'Voice: "Remind me to buy groceries tomorrow at 5 PM"',
      'AI creates todo with reminder automatically',
      'Shows in both Todos and Reminders views',
      'Cross-feature integration complete',
    ],
    'initialText': 'Remind me to buy groceries tomorrow at 5 PM',
  },
  {
    'title': 'Shopping List Evolution',
    'steps': [
      'Start with basic shopping list note',
      'Convert items to individual todos',
      'Add location-based reminders',
      'Track completion across categories',
    ],
    'initialText':
        'Shopping list:\n- Milk and bread\n- Vegetables for dinner\n- Birthday gift for mom',
  },
];

class CrossFeatureBloc extends Bloc<CrossFeatureEvent, CrossFeatureState> {
  CrossFeatureBloc() : super(const CrossFeatureState()) {
    on<StartScenario>(_onStartScenario);
    on<NextStep>(_onNextStep);
    on<CompleteTransformation>(_onCompleteTransformation);
  }

  void _onStartScenario(StartScenario event, Emitter<CrossFeatureState> emit) {
    final scenario = _demoScenarios[event.scenarioIndex];
    final initialItem = SmartVoiceParser.parseVoiceInput(
      scenario['initialText'],
    );

    emit(
      state.copyWith(
        selectedScenario: event.scenarioIndex,
        currentStep: 0,
        transformationSteps: List<String>.from(scenario['steps']),
        isTransforming: false,
        demoItem: initialItem,
      ),
    );
  }

  void _onNextStep(NextStep event, Emitter<CrossFeatureState> emit) {
    if (state.currentStep >= state.transformationSteps.length - 1) return;

    emit(
      state.copyWith(isTransforming: true, currentStep: state.currentStep + 1),
    );
  }

  void _onCompleteTransformation(
    CompleteTransformation event,
    Emitter<CrossFeatureState> emit,
  ) {
    if (state.demoItem == null) {
      emit(state.copyWith(isTransforming: false));
      return;
    }

    UniversalItem newItem = state.demoItem!;

    switch (state.selectedScenario) {
      case 0:
        newItem = _transformMeetingNote(newItem, state.currentStep);
        break;
      case 1:
        newItem = _transformVoiceInput(newItem, state.currentStep);
        break;
      case 2:
        newItem = _transformShoppingList(newItem, state.currentStep);
        break;
    }

    emit(state.copyWith(demoItem: newItem, isTransforming: false));
  }

  UniversalItem _transformMeetingNote(UniversalItem item, int step) {
    switch (step) {
      case 1:
        return item.copyWith(
          title: 'Follow up with client',
          isTodo: true,
          category: 'Work',
        );
      case 2:
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        return item.copyWith(
          reminderTime: DateTime(
            tomorrow.year,
            tomorrow.month,
            tomorrow.day,
            14,
            0,
          ),
          category: 'Work',
        );
      default:
        return item;
    }
  }

  UniversalItem _transformVoiceInput(UniversalItem item, int step) {
    if (step == 1) {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      return item.copyWith(
        title: 'Buy groceries',
        isTodo: true,
        reminderTime: DateTime(
          tomorrow.year,
          tomorrow.month,
          tomorrow.day,
          17,
          0,
        ),
        category: 'Shopping',
        hasVoiceNote: true,
      );
    }
    return item;
  }

  UniversalItem _transformShoppingList(UniversalItem item, int step) {
    switch (step) {
      case 1:
        return item.copyWith(
          title: 'Milk and bread',
          isTodo: true,
          category: 'Shopping',
        );
      case 2:
        final today = DateTime.now();
        return item.copyWith(
          reminderTime: DateTime(today.year, today.month, today.day, 18, 0),
          content: 'Pick up at grocery store on Main Street',
        );
      case 3:
        return item.copyWith(isCompleted: true);
      default:
        return item;
    }
  }
}
