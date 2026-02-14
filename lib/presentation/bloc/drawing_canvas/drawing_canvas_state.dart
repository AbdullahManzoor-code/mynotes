part of 'drawing_canvas_bloc.dart';

class DrawingCanvasState extends Equatable {
  final List<DrawingPath> paths;
  final int currentPenColor;
  final double currentPenWidth;
  final String currentTool;
  final bool isDrawing;
  final String? error;
  final String? savedImagePath;

  const DrawingCanvasState({
    this.paths = const [],
    this.currentPenColor = 0xFF000000,
    this.currentPenWidth = 2.0,
    this.currentTool = 'pen',
    this.isDrawing = false,
    this.error,
    this.savedImagePath,
  });

  DrawingCanvasState copyWith({
    List<DrawingPath>? paths,
    int? currentPenColor,
    double? currentPenWidth,
    String? currentTool,
    bool? isDrawing,
    String? error,
    String? savedImagePath,
  }) {
    return DrawingCanvasState(
      paths: paths ?? this.paths,
      currentPenColor: currentPenColor ?? this.currentPenColor,
      currentPenWidth: currentPenWidth ?? this.currentPenWidth,
      currentTool: currentTool ?? this.currentTool,
      isDrawing: isDrawing ?? this.isDrawing,
      error: error,
      savedImagePath: savedImagePath ?? this.savedImagePath,
    );
  }

  @override
  List<Object?> get props => [
    paths,
    currentPenColor,
    currentPenWidth,
    currentTool,
    isDrawing,
    error,
    savedImagePath,
  ];
}
