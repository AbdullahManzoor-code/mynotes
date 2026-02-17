part of 'video_editor_bloc.dart';

class VideoEditorState extends Equatable {
  final String filePath;
  final bool isInitialized;
  final bool isExporting;
  final String? errorMessage;

  const VideoEditorState({
    this.filePath = '',
    this.isInitialized = false,
    this.isExporting = false,
    this.errorMessage,
  });

  VideoEditorState copyWith({
    String? filePath,
    bool? isInitialized,
    bool? isExporting,
    String? errorMessage,
  }) {
    return VideoEditorState(
      filePath: filePath ?? this.filePath,
      isInitialized: isInitialized ?? this.isInitialized,
      isExporting: isExporting ?? this.isExporting,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    filePath,
    isInitialized,
    isExporting,
    errorMessage,
  ];
}

class VideoEditorInitial extends VideoEditorState {
  const VideoEditorInitial();
}

class VideoEditorReady extends VideoEditorState {
  const VideoEditorReady({required super.filePath})
    : super(isInitialized: true);
}

class VideoEditorExporting extends VideoEditorState {
  const VideoEditorExporting({required super.filePath})
    : super(isInitialized: true, isExporting: true);
}

class VideoEditorExportSuccess extends VideoEditorState {
  const VideoEditorExportSuccess({required super.filePath})
    : super(isInitialized: true, isExporting: false);
}

class VideoEditorError extends VideoEditorState {
  const VideoEditorError({required String message})
    : super(errorMessage: message);
}
