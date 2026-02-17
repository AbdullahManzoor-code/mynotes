// // ════════════════════════════════════════════════════════════════════════════
// // MYNOTES BLOC STANDARDIZATION TEMPLATE
// // ════════════════════════════════════════════════════════════════════════════
// //
// // This is the standard template for ALL BLoCs in the mynotes app.
// // Follow this pattern to ensure consistency across all 50+ BLoCs.
// //
// // ════════════════════════════════════════════════════════════════════════════

// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:equatable/equatable.dart';
// import 'package:mynotes/core/services/app_logger.dart';

// // ════════════════════════════════════════════════════════════════════════════
// // EVENTS
// // ════════════════════════════════════════════════════════════════════════════

// /// Events for [FeatureBloc]
// /// Each event represents a user action or external trigger
// abstract class FeatureEvent extends Equatable {
//   const FeatureEvent();

//   @override
//   List<Object?> get props => [];
// }

// /// Load all items
// class LoadFeatureItemsEvent extends FeatureEvent {
//   final String? filter;
//   final int page;

//   const LoadFeatureItemsEvent({this.filter, this.page = 1});

//   @override
//   List<Object?> get props => [filter, page];
// }

// /// Create new item
// class CreateFeatureItemEvent extends FeatureEvent {
//   final String title;
//   final String description;

//   const CreateFeatureItemEvent({
//     required this.title,
//     required this.description,
//   });

//   @override
//   List<Object?> get props => [title, description];
// }

// /// Update existing item
// class UpdateFeatureItemEvent extends FeatureEvent {
//   final String id;
//   final String title;
//   final String description;

//   const UpdateFeatureItemEvent({
//     required this.id,
//     required this.title,
//     required this.description,
//   });

//   @override
//   List<Object?> get props => [id, title, description];
// }

// /// Delete item
// class DeleteFeatureItemEvent extends FeatureEvent {
//   final String id;

//   const DeleteFeatureItemEvent(this.id);

//   @override
//   List<Object?> get props => [id];
// }

// // ════════════════════════════════════════════════════════════════════════════
// // STATES
// // ════════════════════════════════════════════════════════════════════════════

// /// States for [FeatureBloc]
// abstract class FeatureState extends Equatable {
//   const FeatureState();

//   @override
//   List<Object?> get props => [];
// }

// /// Initial state (before any action)
// class FeatureInitial extends FeatureState {
//   const FeatureInitial();
// }

// /// Loading state (data is being fetched/processed)
// class FeatureLoading extends FeatureState {
//   final String message;

//   const FeatureLoading({this.message = 'Loading...'});

//   @override
//   List<Object?> get props => [message];
// }

// /// Loaded state (data successfully retrieved)
// class FeatureLoaded extends FeatureState {
//   final List<dynamic> items;
//   final String filter;
//   final int totalCount;

//   const FeatureLoaded({
//     required this.items,
//     this.filter = 'all',
//     this.totalCount = 0,
//   });

//   @override
//   List<Object?> get props => [items, filter, totalCount];
// }

// /// Success state (operation completed successfully)
// class FeatureSuccess extends FeatureState {
//   final String message;
//   final dynamic data;

//   const FeatureSuccess({required this.message, this.data});

//   @override
//   List<Object?> get props => [message, data];
// }

// /// Error state (operation failed)
// class FeatureError extends FeatureState {
//   final String message;
//   final String code;
//   final Exception? exception;

//   const FeatureError({
//     required this.message,
//     this.code = 'UNKNOWN_ERROR',
//     this.exception,
//   });

//   @override
//   List<Object?> get props => [message, code, exception];
// }

// // ════════════════════════════════════════════════════════════════════════════
// // BLOC
// // ════════════════════════════════════════════════════════════════════════════

// /// BLoC for managing Feature [FeatureState] and [FeatureEvent]
// /// Handles all business logic for feature and emits states to UI
// class FeatureBloc extends Bloc<FeatureEvent, FeatureState> {
//   final FeatureRepository _repository;

//   // ════════════════════════════════════════════════════════════════════════
//   // CONSTRUCTOR
//   // ════════════════════════════════════════════════════════════════════════

//   FeatureBloc({required FeatureRepository repository})
//     : _repository = repository,
//       super(const FeatureInitial()) {
//     // ═════════════════════════════════════════════════════════════════════
//     // Register event handlers
//     // Register handlers in logical order (Load, Create, Update, Delete)
//     // ═════════════════════════════════════════════════════════════════════

//     on<LoadFeatureItemsEvent>(_onLoadFeatureItems);
//     on<CreateFeatureItemEvent>(_onCreateFeatureItem);
//     on<UpdateFeatureItemEvent>(_onUpdateFeatureItem);
//     on<DeleteFeatureItemEvent>(_onDeleteFeatureItem);
//   }

//   // ════════════════════════════════════════════════════════════════════════
//   // EVENT HANDLERS
//   // ════════════════════════════════════════════════════════════════════════

//   /// Handle [LoadFeatureItemsEvent]
//   Future<void> _onLoadFeatureItems(
//     LoadFeatureItemsEvent event,
//     Emitter<FeatureState> emit,
//   ) async {
//     try {
//       // Step 1: Emit loading state
//       emit(const FeatureLoading(message: 'Loading items...'));

//       // Step 2: Log the action
//       AppLogger.i('Loading feature items with filter: ${event.filter}');

//       // Step 3: Fetch data from repository
//       final items = await _repository.getItems(
//         filter: event.filter,
//         page: event.page,
//       );

//       // Step 4: Log success
//       AppLogger.i('Successfully loaded ${items.length} items');

//       // Step 5: Emit loaded state
//       emit(
//         FeatureLoaded(
//           items: items,
//           filter: event.filter ?? 'all',
//           totalCount: items.length,
//         ),
//       );
//     } on RepositoryException catch (e) {
//       // Handle known exceptions
//       AppLogger.e('Repository error: ${e.message}', e, e.stackTrace);
//       emit(FeatureError(message: e.message, code: e.code, exception: e));
//     } catch (e, stackTrace) {
//       // Handle unexpected exceptions
//       AppLogger.e('Unexpected error loading items: $e', e, stackTrace);
//       emit(
//         FeatureError(
//           message: 'Failed to load items: $e',
//           code: 'LOAD_ERROR',
//           exception: Exception(e.toString()),
//         ),
//       );
//     }
//   }

//   /// Handle [CreateFeatureItemEvent]
//   Future<void> _onCreateFeatureItem(
//     CreateFeatureItemEvent event,
//     Emitter<FeatureState> emit,
//   ) async {
//     try {
//       emit(const FeatureLoading(message: 'Creating item...'));

//       AppLogger.i('Creating feature item: ${event.title}');

//       final newItem = await _repository.createItem(
//         title: event.title,
//         description: event.description,
//       );

//       AppLogger.i('Successfully created item: ${newItem.id}');

//       emit(FeatureSuccess(message: 'Item created successfully', data: newItem));

//       // Reload list after creation
//       add(const LoadFeatureItemsEvent());
//     } on ValidationException catch (e) {
//       AppLogger.w('Validation error: ${e.message}');
//       emit(FeatureError(message: e.message, code: 'VALIDATION_ERROR'));
//     } on RepositoryException catch (e) {
//       AppLogger.e('Repository error: ${e.message}', e, e.stackTrace);
//       emit(FeatureError(message: e.message, code: e.code));
//     } catch (e, stackTrace) {
//       AppLogger.e('Unexpected error creating item: $e', e, stackTrace);
//       emit(
//         FeatureError(
//           message: 'Failed to create item: $e',
//           code: 'CREATE_ERROR',
//         ),
//       );
//     }
//   }

//   /// Handle [UpdateFeatureItemEvent]
//   Future<void> _onUpdateFeatureItem(
//     UpdateFeatureItemEvent event,
//     Emitter<FeatureState> emit,
//   ) async {
//     try {
//       emit(const FeatureLoading(message: 'Updating item...'));

//       AppLogger.i('Updating feature item: ${event.id}');

//       final updatedItem = await _repository.updateItem(
//         id: event.id,
//         title: event.title,
//         description: event.description,
//       );

//       AppLogger.i('Successfully updated item: ${event.id}');

//       emit(
//         FeatureSuccess(message: 'Item updated successfully', data: updatedItem),
//       );

//       // Reload list after update
//       add(const LoadFeatureItemsEvent());
//     } on RepositoryException catch (e) {
//       AppLogger.e('Repository error: ${e.message}', e, e.stackTrace);
//       emit(FeatureError(message: e.message, code: e.code));
//     } catch (e, stackTrace) {
//       AppLogger.e('Unexpected error updating item: $e', e, stackTrace);
//       emit(
//         FeatureError(
//           message: 'Failed to update item: $e',
//           code: 'UPDATE_ERROR',
//         ),
//       );
//     }
//   }

//   /// Handle [DeleteFeatureItemEvent]
//   Future<void> _onDeleteFeatureItem(
//     DeleteFeatureItemEvent event,
//     Emitter<FeatureState> emit,
//   ) async {
//     try {
//       emit(const FeatureLoading(message: 'Deleting item...'));

//       AppLogger.i('Deleting feature item: ${event.id}');

//       await _repository.deleteItem(event.id);

//       AppLogger.i('Successfully deleted item: ${event.id}');

//       emit(const FeatureSuccess(message: 'Item deleted successfully'));

//       // Reload list after deletion
//       add(const LoadFeatureItemsEvent());
//     } on RepositoryException catch (e) {
//       AppLogger.e('Repository error: ${e.message}', e, e.stackTrace);
//       emit(FeatureError(message: e.message, code: e.code));
//     } catch (e, stackTrace) {
//       AppLogger.e('Unexpected error deleting item: $e', e, stackTrace);
//       emit(
//         FeatureError(
//           message: 'Failed to delete item: $e',
//           code: 'DELETE_ERROR',
//         ),
//       );
//     }
//   }
// }

// // ════════════════════════════════════════════════════════════════════════════
// // STANDARDIZATION RULES
// // ════════════════════════════════════════════════════════════════════════════
// //
// // 1. NAMING CONVENTIONS:
// //    - Events: [Action]Event (e.g., LoadNotesEvent, CreateNoteEvent)
// //    - States: [Status]State (e.g., NotesLoading, NotesLoaded, NotesError)
// //    - Handlers: _on[Event] (e.g., _onLoadNotes, _onCreateNote)
// //
// // 2. EVENT ORDER:
// //    Register handlers in this order: Load → Create → Update → Delete → Others
// //    This makes the code easier to navigate
// //
// // 3. STATE ORDER:
// //    Initial → Loading → Loaded/Success → Error
// //    This follows the logical flow of async operations
// //
// // 4. ERROR HANDLING:
// //    - Use try-catch in EVERY event handler
// //    - Log with AppLogger.i() for info, .w() for warnings, .e() for errors
// //    - Include exception and stackTrace in error logs
// //    - Emit FeatureError with message, code, and exception
// //
// // 5. REPOSITORY CALLS:
// //    - Always inject repository in constructor
// //    - Use repository for all data access (no direct DB calls)
// //    - Handle RepositoryException as known error
// //    - Handle generic exceptions as unexpected errors
// //
// // 6. LOGGING:
// //    - Log START of operation with event details
// //    - Log SUCCESS with result details
// //    - Log ERRORS with exception details
// //    - Use consistent prefixes like [BLOC-FEATURE] [HANDLER-NAME]
// //
// // 7. STATE EMISSION:
// //    - Always emit Loading first
// //    - Emit final state (Loaded/Success/Error) last
// //    - Include meaningful messages in states
// //
// // 8. IMMUTABILITY:
// //    - Use 'const' for all Event and State constructors
// //    - Use Equatable for value comparison
// //    - Implement props properly - include ALL fields
// //
// // 9. DOCUMENTATION:
// //    - Add doc comments (///) to BLoC class
// //    - Add doc comments to each event handler
// //    - Explain the sequence of states emitted
// //
// // 10. RELOADING LISTS:
// //     After Create/Update/Delete, reload the list:
// //     add(const LoadFeatureItemsEvent());
// //
// // ════════════════════════════════════════════════════════════════════════════
