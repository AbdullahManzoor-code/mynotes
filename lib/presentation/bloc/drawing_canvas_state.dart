part of 'drawing_canvas_bloc.dart';

abstract class DrawingCanvasState extends Equatable {
  const DrawingCanvasState();

  @override
  List<Object?> get props => [];
}

class DrawingCanvasInitial extends DrawingCanvasState {
  const DrawingCanvasInitial();
}

class DrawingCanvasLoading extends DrawingCanvasState {
  const DrawingCanvasLoading();
}

class CanvasPathAdded extends DrawingCanvasState {
  final List<DrawingPath> paths;

  const CanvasPathAdded(this.paths);

  @override
  List<Object?> get props => [paths];
}

class CanvasCleared extends DrawingCanvasState {
  const CanvasCleared();
}

class CanvasUndone extends DrawingCanvasState {
  final List<DrawingPath> paths;

  const CanvasUndone(this.paths);

  @override
  List<Object?> get props => [paths];
}

class CanvasRedone extends DrawingCanvasState {
  final List<DrawingPath> paths;

  const CanvasRedone(this.paths);

  @override
  List<Object?> get props => [paths];
}

class DrawingSaved extends DrawingCanvasState {
  final String filePath;

  const DrawingSaved(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class DrawingLoaded extends DrawingCanvasState {
  final List<DrawingPath> paths;

  const DrawingLoaded(this.paths);

  @override
  List<Object?> get props => [paths];
}

class CanvasError extends DrawingCanvasState {
  final String message;

  const CanvasError(this.message);

  @override
  List<Object?> get props => [message];
}
