import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mynotes/domain/repositories/smart_collection_repository.dart';
import 'package:mynotes/domain/entities/smart_collection.dart';
import 'package:mynotes/presentation/bloc/params/smart_collections_params.dart';
import 'package:uuid/uuid.dart';

// Smart Collections BLoC - Events
abstract class SmartCollectionsEvent extends Equatable {
  const SmartCollectionsEvent();
  @override
  List<Object?> get props => [];
}

class LoadSmartCollectionsEvent extends SmartCollectionsEvent {
  const LoadSmartCollectionsEvent();
}

class FilterChangedEvent extends SmartCollectionsEvent {
  final String filter;
  const FilterChangedEvent(this.filter);
  @override
  List<Object?> get props => [filter];
}

class CreateSmartCollectionEvent extends SmartCollectionsEvent {
  final String name;
  final String description;
  final List<CollectionRule> rules;
  final String logic;

  const CreateSmartCollectionEvent({
    required this.name,
    required this.description,
    required this.rules,
    this.logic = 'AND',
  });
  @override
  List<Object?> get props => [name, description, rules, logic];
}

class UpdateSmartCollectionEvent extends SmartCollectionsEvent {
  final String collectionId;
  final String name;
  final List<CollectionRule> rules;
  const UpdateSmartCollectionEvent({
    required this.collectionId,
    required this.name,
    required this.rules,
  });
  @override
  List<Object?> get props => [collectionId, name, rules];
}

class DeleteSmartCollectionEvent extends SmartCollectionsEvent {
  final String collectionId;
  const DeleteSmartCollectionEvent({required this.collectionId});
  @override
  List<Object?> get props => [collectionId];
}

class SearchSmartCollectionsEvent extends SmartCollectionsEvent {
  final String query;
  const SearchSmartCollectionsEvent({required this.query});
  @override
  List<Object?> get props => [query];
}

class ArchiveSmartCollectionEvent extends SmartCollectionsEvent {
  final String collectionId;
  const ArchiveSmartCollectionEvent({required this.collectionId});
  @override
  List<Object?> get props => [collectionId];
}

// Smart Collections BLoC - States
abstract class SmartCollectionsState extends Equatable {
  final SmartCollectionsParams params;
  const SmartCollectionsState(this.params);
  @override
  List<Object?> get props => [params];
}

class SmartCollectionsInitial extends SmartCollectionsState {
  const SmartCollectionsInitial() : super(const SmartCollectionsParams());
}

class SmartCollectionsLoading extends SmartCollectionsState {
  const SmartCollectionsLoading(super.params);
}

class SmartCollectionsLoaded extends SmartCollectionsState {
  const SmartCollectionsLoaded(super.params);
}

class SmartCollectionsError extends SmartCollectionsState {
  final String message;
  const SmartCollectionsError(super.params, {required this.message});
  @override
  List<Object?> get props => [params, message];
}

// Smart Collections BLoC - Implementation
class SmartCollectionsBloc
    extends Bloc<SmartCollectionsEvent, SmartCollectionsState> {
  final SmartCollectionRepository smartCollectionRepository;

  SmartCollectionsBloc({required this.smartCollectionRepository})
    : super(const SmartCollectionsInitial()) {
    on<LoadSmartCollectionsEvent>(_onLoadCollections);
    on<FilterChangedEvent>(_onFilterChanged);
    on<CreateSmartCollectionEvent>(_onCreateCollection);
    on<UpdateSmartCollectionEvent>(_onUpdateCollection);
    on<DeleteSmartCollectionEvent>(_onDeleteCollection);
    on<ArchiveSmartCollectionEvent>(_onArchiveCollection);
    on<SearchSmartCollectionsEvent>(_onSearchCollections);
  }

  void _onFilterChanged(
    FilterChangedEvent event,
    Emitter<SmartCollectionsState> emit,
  ) {
    emit(
      SmartCollectionsLoaded(
        state.params.copyWith(selectedFilter: event.filter),
      ),
    );
  }

  Future<void> _onSearchCollections(
    SearchSmartCollectionsEvent event,
    Emitter<SmartCollectionsState> emit,
  ) async {
    emit(
      SmartCollectionsLoaded(state.params.copyWith(searchQuery: event.query)),
    );
  }

  Future<void> _onLoadCollections(
    LoadSmartCollectionsEvent event,
    Emitter<SmartCollectionsState> emit,
  ) async {
    try {
      emit(SmartCollectionsLoading(state.params.copyWith(isLoading: true)));

      final collections = await smartCollectionRepository.loadCollections();

      emit(
        SmartCollectionsLoaded(
          state.params.copyWith(collections: collections, isLoading: false),
        ),
      );
    } catch (e) {
      emit(
        SmartCollectionsError(
          state.params.copyWith(isLoading: false),
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> _onCreateCollection(
    CreateSmartCollectionEvent event,
    Emitter<SmartCollectionsState> emit,
  ) async {
    try {
      final collection = SmartCollection(
        id: const Uuid().v4(),
        name: event.name,
        description: event.description,
        rules: event.rules,
        itemCount: 0,
        lastUpdated: DateTime.now(),
        isActive: true,
        logic: event.logic,
      );

      await smartCollectionRepository.createCollection(collection);
      add(const LoadSmartCollectionsEvent());
    } catch (e) {
      emit(
        SmartCollectionsError(
          state.params,
          message: 'Failed to create collection: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onUpdateCollection(
    UpdateSmartCollectionEvent event,
    Emitter<SmartCollectionsState> emit,
  ) async {
    try {
      // Implement update in repository
      add(const LoadSmartCollectionsEvent());
    } catch (e) {
      emit(SmartCollectionsError(state.params, message: e.toString()));
    }
  }

  Future<void> _onDeleteCollection(
    DeleteSmartCollectionEvent event,
    Emitter<SmartCollectionsState> emit,
  ) async {
    try {
      await smartCollectionRepository.deleteCollection(event.collectionId);
      add(const LoadSmartCollectionsEvent());
    } catch (e) {
      emit(
        SmartCollectionsError(
          state.params,
          message: 'Failed to delete collection: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onArchiveCollection(
    ArchiveSmartCollectionEvent event,
    Emitter<SmartCollectionsState> emit,
  ) async {
    try {
      await smartCollectionRepository.archiveCollection(event.collectionId);
      add(const LoadSmartCollectionsEvent());
    } catch (e) {
      emit(
        SmartCollectionsError(
          state.params,
          message: 'Failed to archive collection: ${e.toString()}',
        ),
      );
    }
  }
}
