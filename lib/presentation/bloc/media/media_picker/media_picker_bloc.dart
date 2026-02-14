import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';

// Events
abstract class MediaPickerEvent extends Equatable {
  const MediaPickerEvent();
  @override
  List<Object?> get props => [];
}

class CheckPermissionAndLoadAssetsEvent extends MediaPickerEvent {
  final String mediaType;
  const CheckPermissionAndLoadAssetsEvent({required this.mediaType});
  @override
  List<Object?> get props => [mediaType];
}

class ToggleAssetSelectionEvent extends MediaPickerEvent {
  final AssetEntity asset;
  final int maxSelection;
  const ToggleAssetSelectionEvent({
    required this.asset,
    required this.maxSelection,
  });
  @override
  List<Object?> get props => [asset, maxSelection];
}

class ConfirmSelectionEvent extends MediaPickerEvent {
  const ConfirmSelectionEvent();
}

// States
abstract class MediaPickerState extends Equatable {
  const MediaPickerState();
  @override
  List<Object?> get props => [];
}

class MediaPickerInitial extends MediaPickerState {}

class MediaPickerLoading extends MediaPickerState {}

class MediaPickerPermissionDenied extends MediaPickerState {}

class MediaPickerLoaded extends MediaPickerState {
  final List<AssetEntity> assets;
  final Set<AssetEntity> selectedAssets;
  final String? error;

  const MediaPickerLoaded({
    required this.assets,
    required this.selectedAssets,
    this.error,
  });

  MediaPickerLoaded copyWith({
    List<AssetEntity>? assets,
    Set<AssetEntity>? selectedAssets,
    String? error,
  }) {
    return MediaPickerLoaded(
      assets: assets ?? this.assets,
      selectedAssets: selectedAssets ?? this.selectedAssets,
      error: error,
    );
  }

  @override
  List<Object?> get props => [assets, selectedAssets, error];
}

class MediaPickerSelectionConfirmed extends MediaPickerState {
  final List<Map<String, dynamic>> selectedFiles;
  const MediaPickerSelectionConfirmed(this.selectedFiles);
  @override
  List<Object?> get props => [selectedFiles];
}

// BLoC
class MediaPickerBloc extends Bloc<MediaPickerEvent, MediaPickerState> {
  MediaPickerBloc() : super(MediaPickerInitial()) {
    on<CheckPermissionAndLoadAssetsEvent>(_onCheckPermissionAndLoad);
    on<ToggleAssetSelectionEvent>(_onToggleSelection);
    on<ConfirmSelectionEvent>(_onConfirmSelection);
  }

  Future<void> _onCheckPermissionAndLoad(
    CheckPermissionAndLoadAssetsEvent event,
    Emitter<MediaPickerState> emit,
  ) async {
    emit(MediaPickerLoading());

    final permission = await PhotoManager.requestPermissionExtend();
    if (permission.isAuth) {
      RequestType requestType;
      switch (event.mediaType) {
        case 'image':
          requestType = RequestType.image;
          break;
        case 'video':
          requestType = RequestType.video;
          break;
        default:
          requestType = RequestType.common;
      }

      final albums = await PhotoManager.getAssetPathList(type: requestType);
      if (albums.isNotEmpty) {
        final recentAlbum = albums.first;
        final assets = await recentAlbum.getAssetListPaged(page: 0, size: 100);
        emit(MediaPickerLoaded(assets: assets, selectedAssets: {}));
      } else {
        emit(const MediaPickerLoaded(assets: [], selectedAssets: {}));
      }
    } else {
      emit(MediaPickerPermissionDenied());
    }
  }

  void _onToggleSelection(
    ToggleAssetSelectionEvent event,
    Emitter<MediaPickerState> emit,
  ) {
    if (state is MediaPickerLoaded) {
      final currentState = state as MediaPickerLoaded;
      final selectedAssets = Set<AssetEntity>.from(currentState.selectedAssets);

      String? error;
      if (selectedAssets.contains(event.asset)) {
        selectedAssets.remove(event.asset);
      } else if (selectedAssets.length < event.maxSelection) {
        selectedAssets.add(event.asset);
      } else {
        error = 'Maximum ${event.maxSelection} items can be selected';
      }

      emit(currentState.copyWith(selectedAssets: selectedAssets, error: error));
    }
  }

  Future<void> _onConfirmSelection(
    ConfirmSelectionEvent event,
    Emitter<MediaPickerState> emit,
  ) async {
    if (state is MediaPickerLoaded) {
      final currentState = state as MediaPickerLoaded;
      if (currentState.selectedAssets.isEmpty) return;

      final List<Map<String, dynamic>> selectedFiles = [];

      for (final asset in currentState.selectedAssets) {
        final file = await asset.file;
        if (file != null) {
          selectedFiles.add({
            'path': file.path,
            'type': asset.type == AssetType.video ? 'video' : 'image',
            'isFromCamera': false,
          });
        }
      }

      emit(MediaPickerSelectionConfirmed(selectedFiles));
    }
  }
}
