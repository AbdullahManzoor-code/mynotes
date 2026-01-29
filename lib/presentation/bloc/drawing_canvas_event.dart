part of 'drawing_canvas_bloc.dart';

abstract class DrawingCanvasEvent extends Equatable {
  const DrawingCanvasEvent();

  @override
  List<Object?> get props => [];
}

class AddPathEvent extends DrawingCanvasEvent {
  final DrawingPath path;

  const AddPathEvent(this.path);

  @override
  List<Object?> get props => [path];
}

class ClearCanvasEvent extends DrawingCanvasEvent {
  const ClearCanvasEvent();
}

class UndoEvent extends DrawingCanvasEvent {
  const UndoEvent();
}

class RedoEvent extends DrawingCanvasEvent {
  const RedoEvent();
}

class SetPenColorEvent extends DrawingCanvasEvent {
  final int color;

  const SetPenColorEvent(this.color);

  @override
  List<Object?> get props => [color];
}

class SetPenWidthEvent extends DrawingCanvasEvent {
  final double width;

  const SetPenWidthEvent(this.width);

  @override
  List<Object?> get props => [width];
}

class SetToolEvent extends DrawingCanvasEvent {
  final String tool;

  const SetToolEvent(this.tool);

  @override
  List<Object?> get props => [tool];
}

class SaveDrawingEvent extends DrawingCanvasEvent {
  final String filePath;

  const SaveDrawingEvent(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class LoadDrawingEvent extends DrawingCanvasEvent {
  final String filePath;

  const LoadDrawingEvent(this.filePath);

  @override
  List<Object?> get props => [filePath];
}
