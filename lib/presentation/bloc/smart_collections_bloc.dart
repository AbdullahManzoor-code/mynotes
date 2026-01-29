import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mynotes/domain/repositories/smart_collection_repository.dart';

// Smart Collections BLoC - Events
abstract class SmartCollectionsEvent extends Equatable {
  const SmartCollectionsEvent();
  @override
  List<Object?> get props => [];
}

class LoadSmartCollectionsEvent extends SmartCollectionsEvent {
  const LoadSmartCollectionsEvent();
}

class CreateSmartCollectionEvent extends SmartCollectionsEvent {
  final String name;
  final String description;
  final List<Map<String, dynamic>> rules;
  const CreateSmartCollectionEvent({
    required this.name,
    required this.description,
    required this.rules,
  });
  @override
  List<Object?> get props => [name, description, rules];
}

class UpdateSmartCollectionEvent extends SmartCollectionsEvent {
  final String collectionId;
  final String name;
  final List<Map<String, dynamic>> rules;
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

class ArchiveSmartCollectionEvent extends SmartCollectionsEvent {
  final String collectionId;
  const ArchiveSmartCollectionEvent({required this.collectionId});
  @override
  List<Object?> get props => [collectionId];
}

// Smart Collections BLoC - States
abstract class SmartCollectionsState extends Equatable {
  const SmartCollectionsState();
  @override
  List<Object?> get props => [];
}

class SmartCollectionsInitial extends SmartCollectionsState {
  const SmartCollectionsInitial();
}

class SmartCollectionsLoading extends SmartCollectionsState {
  const SmartCollectionsLoading();
}

class SmartCollectionsLoaded extends SmartCollectionsState {
  final List<Map<String, dynamic>> collections;
  final int totalItems;

  const SmartCollectionsLoaded({
    required this.collections,
    required this.totalItems,
  });

  @override
  List<Object?> get props => [collections, totalItems];
}

class SmartCollectionsError extends SmartCollectionsState {
  final String message;
  const SmartCollectionsError({required this.message});
  @override
  List<Object?> get props => [message];
}

// Smart Collections BLoC - Implementation
class SmartCollectionsBloc
    extends Bloc<SmartCollectionsEvent, SmartCollectionsState> {
  final SmartCollectionRepository smartCollectionRepository;

  SmartCollectionsBloc({required this.smartCollectionRepository})
    : super(const SmartCollectionsInitial()) {
    on<LoadSmartCollectionsEvent>(_onLoadCollections);
    on<CreateSmartCollectionEvent>(_onCreateCollection);
    on<UpdateSmartCollectionEvent>(_onUpdateCollection);
    on<DeleteSmartCollectionEvent>(_onDeleteCollection);
    on<ArchiveSmartCollectionEvent>(_onArchiveCollection);
  }

  Future<void> _onLoadCollections(
    LoadSmartCollectionsEvent event,
    Emitter<SmartCollectionsState> emit,
  ) async {
    try {
      emit(const SmartCollectionsLoading());

      final collections = await smartCollectionRepository.loadCollections();

      final collectionsData = collections
          .map(
            (c) => {
              'id': c.id,
              'name': c.name,
              'description': c.description,
              'itemCount': c.itemCount,
              'lastUpdated': c.lastUpdated.toString(),
              'isActive': c.isActive,
            },
          )
          .toList();

      final totalItems = collectionsData.fold<int>(
        0,
        (sum, c) => sum + (c['itemCount'] as int),
      );

      emit(
        SmartCollectionsLoaded(
          collections: collectionsData,
          totalItems: totalItems,
        ),
      );
    } catch (e) {
      emit(SmartCollectionsError(message: e.toString()));
    }
  }

  Future<void> _onCreateCollection(
    CreateSmartCollectionEvent event,
    Emitter<SmartCollectionsState> emit,
  ) async {
    try {
      // Create in repository stub (needs proper entity mapping)
      // await smartCollectionRepository.createCollection(...);
      add(const LoadSmartCollectionsEvent());
    } catch (e) {
      emit(
        SmartCollectionsError(
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
      // Update in repository stub
      // await smartCollectionRepository.updateCollection(...);
      add(const LoadSmartCollectionsEvent());
    } catch (e) {
      emit(SmartCollectionsError(message: e.toString()));
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
          message: 'Failed to archive collection: ${e.toString()}',
        ),
      );
    }
  }
}
