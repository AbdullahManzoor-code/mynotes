import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mynotes/domain/repositories/reminder_template_repository.dart';

// Reminder Templates BLoC - Events
abstract class ReminderTemplatesEvent extends Equatable {
  const ReminderTemplatesEvent();
  @override
  List<Object?> get props => [];
}

class LoadTemplatesEvent extends ReminderTemplatesEvent {
  const LoadTemplatesEvent();
}

class FilterTemplatesByCategoryEvent extends ReminderTemplatesEvent {
  final String category;
  const FilterTemplatesByCategoryEvent({required this.category});
  @override
  List<Object?> get props => [category];
}

class CreateReminderFromTemplateEvent extends ReminderTemplatesEvent {
  final String templateId;
  const CreateReminderFromTemplateEvent({required this.templateId});
  @override
  List<Object?> get props => [templateId];
}

class ToggleFavoriteTemplateEvent extends ReminderTemplatesEvent {
  final String templateId;
  const ToggleFavoriteTemplateEvent({required this.templateId});
  @override
  List<Object?> get props => [templateId];
}

// Reminder Templates BLoC - States
abstract class ReminderTemplatesState extends Equatable {
  const ReminderTemplatesState();
  @override
  List<Object?> get props => [];
}

class ReminderTemplatesInitial extends ReminderTemplatesState {
  const ReminderTemplatesInitial();
}

class ReminderTemplatesLoading extends ReminderTemplatesState {
  const ReminderTemplatesLoading();
}

class ReminderTemplatesLoaded extends ReminderTemplatesState {
  final List<Map<String, dynamic>> templates;
  final Set<String> favoriteIds;
  final String selectedCategory;
  final List<String> categories;

  const ReminderTemplatesLoaded({
    required this.templates,
    required this.favoriteIds,
    required this.selectedCategory,
    required this.categories,
  });

  @override
  List<Object?> get props => [
    templates,
    favoriteIds,
    selectedCategory,
    categories,
  ];
}

class ReminderTemplatesError extends ReminderTemplatesState {
  final String message;
  const ReminderTemplatesError({required this.message});
  @override
  List<Object?> get props => [message];
}

// Reminder Templates BLoC - Implementation
class ReminderTemplatesBloc
    extends Bloc<ReminderTemplatesEvent, ReminderTemplatesState> {
  final ReminderTemplateRepository reminderTemplateRepository;

  static final List<Map<String, dynamic>> _allTemplates = [
    {
      'id': '1',
      'name': 'Gym Morning',
      'description': 'Go to gym for 1 hour',
      'time': '7:00 AM',
      'frequency': 'Every Day',
      'duration': '60 min',
      'category': 'Health',
      'isFavorite': false,
    },
    {
      'id': '2',
      'name': 'Lunch Break',
      'description': 'Take a break and eat',
      'time': '12:30 PM',
      'frequency': 'Daily',
      'duration': '60 min',
      'category': 'Personal',
      'isFavorite': false,
    },
    {
      'id': '3',
      'name': 'Medication Reminder',
      'description': 'Take your daily medications',
      'time': '8:00 AM, 8:00 PM',
      'frequency': 'Daily',
      'duration': '5 min',
      'category': 'Health',
      'isFavorite': false,
    },
    {
      'id': '4',
      'name': 'Review Goals',
      'description': 'Weekly goal review session',
      'time': 'Friday 5:00 PM',
      'frequency': 'Weekly',
      'duration': '30 min',
      'category': 'Personal',
      'isFavorite': false,
    },
    {
      'id': '5',
      'name': 'Team Meeting',
      'description': 'Weekly team all-hands',
      'time': '2:00 PM',
      'frequency': 'Every Tuesday',
      'duration': '60 min',
      'category': 'Work',
      'isFavorite': false,
    },
    {
      'id': '6',
      'name': 'Workout Session',
      'description': 'Exercise routine',
      'time': '6:00 AM',
      'frequency': 'Mon, Wed, Fri',
      'duration': '45 min',
      'category': 'Health',
      'isFavorite': false,
    },
    {
      'id': '7',
      'name': 'Water Intake',
      'description': 'Drink a glass of water',
      'time': 'Every 2 hours',
      'frequency': 'Daily',
      'duration': '5 min',
      'category': 'Health',
      'isFavorite': false,
    },
    {
      'id': '8',
      'name': 'Project Deadline',
      'description': 'Submit project deliverables',
      'time': '4:00 PM',
      'frequency': 'Custom',
      'duration': '15 min',
      'category': 'Work',
      'isFavorite': false,
    },
  ];

  final Set<String> _favorites = {};

  ReminderTemplatesBloc({required this.reminderTemplateRepository})
    : super(const ReminderTemplatesInitial()) {
    on<LoadTemplatesEvent>(_onLoadTemplates);
    on<FilterTemplatesByCategoryEvent>(_onFilterByCategory);
    on<CreateReminderFromTemplateEvent>(_onCreateFromTemplate);
    on<ToggleFavoriteTemplateEvent>(_onToggleFavorite);
  }

  Future<void> _onLoadTemplates(
    LoadTemplatesEvent event,
    Emitter<ReminderTemplatesState> emit,
  ) async {
    try {
      emit(const ReminderTemplatesLoading());

      await Future.delayed(const Duration(milliseconds: 500));

      final categories = <String>{'All'};
      for (var template in _allTemplates) {
        categories.add(template['category'] as String);
      }

      emit(
        ReminderTemplatesLoaded(
          templates: _allTemplates,
          favoriteIds: _favorites,
          selectedCategory: 'All',
          categories: categories.toList(),
        ),
      );
    } catch (e) {
      emit(ReminderTemplatesError(message: e.toString()));
    }
  }

  Future<void> _onFilterByCategory(
    FilterTemplatesByCategoryEvent event,
    Emitter<ReminderTemplatesState> emit,
  ) async {
    try {
      if (state is! ReminderTemplatesLoaded) return;

      final currentState = state as ReminderTemplatesLoaded;

      final filtered = event.category == 'All'
          ? _allTemplates
          : _allTemplates
                .where((t) => t['category'] == event.category)
                .toList();

      emit(
        ReminderTemplatesLoaded(
          templates: filtered,
          favoriteIds: currentState.favoriteIds,
          selectedCategory: event.category,
          categories: currentState.categories,
        ),
      );
    } catch (e) {
      emit(ReminderTemplatesError(message: e.toString()));
    }
  }

  Future<void> _onCreateFromTemplate(
    CreateReminderFromTemplateEvent event,
    Emitter<ReminderTemplatesState> emit,
  ) async {
    try {
      if (state is! ReminderTemplatesLoaded) return;

      // final template = _allTemplates.firstWhere(
      //   (t) => t['id'] == event.templateId,
      // );

      // Create reminder from template logic
      emit(state as ReminderTemplatesLoaded);
    } catch (e) {
      emit(ReminderTemplatesError(message: e.toString()));
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavoriteTemplateEvent event,
    Emitter<ReminderTemplatesState> emit,
  ) async {
    try {
      if (state is! ReminderTemplatesLoaded) return;

      final currentState = state as ReminderTemplatesLoaded;

      if (_favorites.contains(event.templateId)) {
        _favorites.remove(event.templateId);
      } else {
        _favorites.add(event.templateId);
      }

      emit(
        ReminderTemplatesLoaded(
          templates: currentState.templates,
          favoriteIds: _favorites,
          selectedCategory: currentState.selectedCategory,
          categories: currentState.categories,
        ),
      );
    } catch (e) {
      emit(ReminderTemplatesError(message: e.toString()));
    }
  }
}
