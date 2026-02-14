import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Template Management BLoC - Events
abstract class TemplateManagementEvent extends Equatable {
  const TemplateManagementEvent();
  @override
  List<Object?> get props => [];
}

class LoadTemplatesEvent extends TemplateManagementEvent {
  const LoadTemplatesEvent();
}

class CreateTemplateEvent extends TemplateManagementEvent {
  final String name;
  final String description;
  final String category;
  final List<dynamic> fields;

  const CreateTemplateEvent({
    required this.name,
    required this.description,
    required this.category,
    required this.fields,
  });

  @override
  List<Object?> get props => [name, description, category, fields];
}

class DeleteTemplateEvent extends TemplateManagementEvent {
  final String templateId;
  const DeleteTemplateEvent({required this.templateId});

  @override
  List<Object?> get props => [templateId];
}

// Template Management BLoC - States
abstract class TemplateManagementState extends Equatable {
  const TemplateManagementState();
  @override
  List<Object?> get props => [];
}

class TemplatesLoading extends TemplateManagementState {
  const TemplatesLoading();
}

class TemplatesLoaded extends TemplateManagementState {
  final List<dynamic> templates;
  final String searchQuery;
  final String selectedCategory;

  // Editor State
  final String editingName;
  final String editingDescription;
  final String editingCategory;
  final List<Map<String, String>> editingFields;

  const TemplatesLoaded(
    this.templates, {
    this.searchQuery = '',
    this.selectedCategory = 'All',
    this.editingName = '',
    this.editingDescription = '',
    this.editingCategory = 'Personal',
    this.editingFields = const [],
  });

  TemplatesLoaded copyWith({
    List<dynamic>? templates,
    String? searchQuery,
    String? selectedCategory,
    String? editingName,
    String? editingDescription,
    String? editingCategory,
    List<Map<String, String>>? editingFields,
  }) {
    return TemplatesLoaded(
      templates ?? this.templates,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      editingName: editingName ?? this.editingName,
      editingDescription: editingDescription ?? this.editingDescription,
      editingCategory: editingCategory ?? this.editingCategory,
      editingFields: editingFields ?? this.editingFields,
    );
  }

  @override
  List<Object?> get props => [
    templates,
    searchQuery,
    selectedCategory,
    editingName,
    editingDescription,
    editingCategory,
    editingFields,
  ];
}

class StartEditingTemplateEvent extends TemplateManagementEvent {
  final dynamic template;
  const StartEditingTemplateEvent({this.template});
  @override
  List<Object?> get props => [template];
}

class UpdateEditingTemplateEvent extends TemplateManagementEvent {
  final String? name;
  final String? description;
  final String? category;
  final List<Map<String, String>>? fields;

  const UpdateEditingTemplateEvent({
    this.name,
    this.description,
    this.category,
    this.fields,
  });

  @override
  List<Object?> get props => [name, description, category, fields];
}

class SearchTemplatesEvent extends TemplateManagementEvent {
  final String query;
  const SearchTemplatesEvent(this.query);
  @override
  List<Object?> get props => [query];
}

class FilterTemplatesEvent extends TemplateManagementEvent {
  final String category;
  const FilterTemplatesEvent(this.category);
  @override
  List<Object?> get props => [category];
}

// Template Management BLoC - Implementation
class TemplateManagementBloc
    extends Bloc<TemplateManagementEvent, TemplateManagementState> {
  TemplateManagementBloc() : super(const TemplatesLoading()) {
    on<LoadTemplatesEvent>((event, emit) {
      emit(TemplatesLoaded(_sampleTemplates));
    });

    on<SearchTemplatesEvent>((event, emit) {
      if (state is TemplatesLoaded) {
        final currentState = state as TemplatesLoaded;
        emit(
          TemplatesLoaded(
            currentState.templates,
            searchQuery: event.query,
            selectedCategory: currentState.selectedCategory,
          ),
        );
      }
    });

    on<FilterTemplatesEvent>((event, emit) {
      if (state is TemplatesLoaded) {
        final currentState = state as TemplatesLoaded;
        emit(
          TemplatesLoaded(
            currentState.templates,
            searchQuery: currentState.searchQuery,
            selectedCategory: event.category,
          ),
        );
      }
    });

    on<CreateTemplateEvent>((event, emit) {
      // Stub implementation
    });

    on<DeleteTemplateEvent>((event, emit) {
      // Stub implementation
    });

    on<StartEditingTemplateEvent>((event, emit) {
      if (state is TemplatesLoaded) {
        final currentState = state as TemplatesLoaded;
        if (event.template != null) {
          emit(
            currentState.copyWith(
              editingName: event.template.name,
              editingDescription: event.template.description,
              editingCategory: event.template.category,
              editingFields: List<Map<String, String>>.from(
                (event.template.fields as List).map(
                  (e) => Map<String, String>.from(e),
                ),
              ),
            ),
          );
        } else {
          emit(
            currentState.copyWith(
              editingName: '',
              editingDescription: '',
              editingCategory: 'Personal',
              editingFields: [],
            ),
          );
        }
      }
    });

    on<UpdateEditingTemplateEvent>((event, emit) {
      if (state is TemplatesLoaded) {
        final currentState = state as TemplatesLoaded;
        emit(
          currentState.copyWith(
            editingName: event.name,
            editingDescription: event.description,
            editingCategory: event.category,
            editingFields: event.fields,
          ),
        );
      }
    });

    // Initial load
    add(const LoadTemplatesEvent());
  }

  static final List<dynamic> _sampleTemplates = [
    _Template(
      id: '1',
      name: 'Meeting Minutes',
      description: 'Standard meeting notes template',
      category: 'Work',
      fields: [
        {'name': 'Attendees', 'type': 'text'},
        {'name': 'Agenda', 'type': 'text'},
      ],
    ),
    _Template(
      id: '2',
      name: 'Daily Journal',
      description: 'Track your daily thoughts',
      category: 'Personal',
      fields: [
        {'name': 'Mood', 'type': 'text'},
        {'name': 'Achievements', 'type': 'text'},
      ],
    ),
  ];
}

// Minimal internal class for sample data
class _Template {
  final String id;
  final String name;
  final String description;
  final String category;
  final List<dynamic> fields;

  _Template({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.fields,
  });
}
