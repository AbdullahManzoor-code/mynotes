import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mynotes/core/services/places_service.dart';
import 'package:mynotes/domain/entities/location_reminder_model.dart';

/// Events used to keep the Location Picker screen in sync with UI interactions.
abstract class LocationPickerEvent extends Equatable {
  const LocationPickerEvent();

  @override
  List<Object?> get props => [];
}

class InitializeLocationPicker extends LocationPickerEvent {
  final LocationReminder? reminder;

  const InitializeLocationPicker([this.reminder]);

  @override
  List<Object?> get props => [reminder];
}

class SetLoadingState extends LocationPickerEvent {
  final bool isLoading;

  const SetLoadingState(this.isLoading);

  @override
  List<Object?> get props => [isLoading];
}

class SelectLocation extends LocationPickerEvent {
  final LatLng location;

  const SelectLocation(this.location);

  @override
  List<Object?> get props => [location];
}

class UpdateAddress extends LocationPickerEvent {
  final String address;

  const UpdateAddress(this.address);

  @override
  List<Object?> get props => [address];
}

class UpdateRadius extends LocationPickerEvent {
  final double radius;

  const UpdateRadius(this.radius);

  @override
  List<Object?> get props => [radius];
}

class UpdateTriggerType extends LocationPickerEvent {
  final LocationTriggerType triggerType;

  const UpdateTriggerType(this.triggerType);

  @override
  List<Object?> get props => [triggerType];
}

class UpdateMessageText extends LocationPickerEvent {
  final String message;

  const UpdateMessageText(this.message);

  @override
  List<Object?> get props => [message];
}

class UpdateLinkedNoteId extends LocationPickerEvent {
  final String? linkedNote;

  const UpdateLinkedNoteId(this.linkedNote);

  @override
  List<Object?> get props => [linkedNote];
}

class UpdatePlacePredictions extends LocationPickerEvent {
  final List<PlacePrediction> predictions;

  const UpdatePlacePredictions(this.predictions);

  @override
  List<Object?> get props => [predictions];
}

class TogglePredictions extends LocationPickerEvent {
  final bool show;

  const TogglePredictions(this.show);

  @override
  List<Object?> get props => [show];
}

/// UI state for the location picker.
class LocationPickerState extends Equatable {
  final bool isLoading;
  final LatLng? selectedLocation;
  final String selectedAddress;
  final String messageText;
  final LocationTriggerType triggerType;
  final double radius;
  final String? linkedNoteId;
  final List<PlacePrediction> placePredictions;
  final bool showPredictions;

  const LocationPickerState({
    this.isLoading = false,
    this.selectedLocation,
    this.selectedAddress = '',
    this.messageText = '',
    this.triggerType = LocationTriggerType.arrive,
    this.radius = 100,
    this.linkedNoteId,
    this.placePredictions = const [],
    this.showPredictions = false,
  });

  LocationPickerState copyWith({
    bool? isLoading,
    LatLng? selectedLocation,
    String? selectedAddress,
    String? messageText,
    LocationTriggerType? triggerType,
    double? radius,
    String? linkedNoteId,
    List<PlacePrediction>? placePredictions,
    bool? showPredictions,
  }) {
    return LocationPickerState(
      isLoading: isLoading ?? this.isLoading,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      messageText: messageText ?? this.messageText,
      triggerType: triggerType ?? this.triggerType,
      radius: radius ?? this.radius,
      linkedNoteId: linkedNoteId ?? this.linkedNoteId,
      placePredictions: placePredictions ?? this.placePredictions,
      showPredictions: showPredictions ?? this.showPredictions,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        selectedLocation,
        selectedAddress,
        messageText,
        triggerType,
        radius,
        linkedNoteId,
        placePredictions,
        showPredictions,
      ];
}

class LocationPickerBloc
    extends Bloc<LocationPickerEvent, LocationPickerState> {
  LocationPickerBloc() : super(const LocationPickerState()) {
    on<InitializeLocationPicker>(_onInitialize);
    on<SetLoadingState>(_onLoading);
    on<SelectLocation>(_onSelectLocation);
    on<UpdateAddress>(_onUpdateAddress);
    on<UpdateRadius>(_onUpdateRadius);
    on<UpdateTriggerType>(_onUpdateTriggerType);
    on<UpdateMessageText>(_onUpdateMessage);
    on<UpdateLinkedNoteId>(_onUpdateLinkedNote);
    on<UpdatePlacePredictions>(_onUpdatePredictions);
    on<TogglePredictions>(_onTogglePredictions);
  }

  void _onInitialize(
    InitializeLocationPicker event,
    Emitter<LocationPickerState> emit,
  ) {
    if (event.reminder != null) {
      emit(state.copyWith(
        selectedLocation: LatLng(
          event.reminder!.latitude,
          event.reminder!.longitude,
        ),
        selectedAddress: event.reminder!.placeAddress ?? '',
        radius: event.reminder!.radius,
        triggerType: event.reminder!.triggerType,
        messageText: event.reminder!.message,
        linkedNoteId: event.reminder!.linkedNoteId,
      ));
    }
  }

  void _onLoading(
    SetLoadingState event,
    Emitter<LocationPickerState> emit,
  ) {
    emit(state.copyWith(isLoading: event.isLoading));
  }

  void _onSelectLocation(
    SelectLocation event,
    Emitter<LocationPickerState> emit,
  ) {
    emit(state.copyWith(selectedLocation: event.location));
  }

  void _onUpdateAddress(
    UpdateAddress event,
    Emitter<LocationPickerState> emit,
  ) {
    emit(state.copyWith(selectedAddress: event.address));
  }

  void _onUpdateRadius(
    UpdateRadius event,
    Emitter<LocationPickerState> emit,
  ) {
    emit(state.copyWith(radius: event.radius));
  }

  void _onUpdateTriggerType(
    UpdateTriggerType event,
    Emitter<LocationPickerState> emit,
  ) {
    emit(state.copyWith(triggerType: event.triggerType));
  }

  void _onUpdateMessage(
    UpdateMessageText event,
    Emitter<LocationPickerState> emit,
  ) {
    emit(state.copyWith(messageText: event.message));
  }

  void _onUpdateLinkedNote(
    UpdateLinkedNoteId event,
    Emitter<LocationPickerState> emit,
  ) {
    emit(state.copyWith(linkedNoteId: event.linkedNote));
  }

  void _onUpdatePredictions(
    UpdatePlacePredictions event,
    Emitter<LocationPickerState> emit,
  ) {
    emit(state.copyWith(
      placePredictions: event.predictions,
      showPredictions: event.predictions.isNotEmpty,
    ));
  }

  void _onTogglePredictions(
    TogglePredictions event,
    Emitter<LocationPickerState> emit,
  ) {
    emit(state.copyWith(showPredictions: event.show));
  }
}
