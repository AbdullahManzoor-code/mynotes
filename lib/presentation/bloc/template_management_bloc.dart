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
  const TemplatesLoaded(this.templates);

  @override
  List<Object?> get props => [templates];
}

class TemplateError extends TemplateManagementState {
  final String message;
  const TemplateError(this.message);

  @override
  List<Object?> get props => [message];
}

// Template Management BLoC - Implementation
class TemplateManagementBloc
    extends Bloc<TemplateManagementEvent, TemplateManagementState> {
  TemplateManagementBloc() : super(const TemplatesLoading()) {
    on<LoadTemplatesEvent>((event, emit) {
      emit(TemplatesLoaded(_sampleTemplates));
    });

    on<CreateTemplateEvent>((event, emit) {
      // Stub implementation
    });

    on<DeleteTemplateEvent>((event, emit) {
      // Stub implementation
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
