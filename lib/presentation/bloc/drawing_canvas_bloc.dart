import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'drawing_canvas_event.dart';
part 'drawing_canvas_state.dart';

class DrawingPath {
  final List<Offset> points;
  final int color;
  final double width;
  final String tool; // pen, eraser, line, shape

  DrawingPath({
    required this.points,
    required this.color,
    required this.width,
    required this.tool,
  });
}

class DrawingCanvasBloc extends Bloc<DrawingCanvasEvent, DrawingCanvasState> {
  final List<DrawingPath> _paths = [];
  final List<List<DrawingPath>> _undoStack = [];
  final List<List<DrawingPath>> _redoStack = [];
  int _currentPenColor = 0xFF000000;
  double _currentPenWidth = 2.0;
  String _currentTool = 'pen';

  DrawingCanvasBloc() : super(const DrawingCanvasInitial()) {
    on<AddPathEvent>(_onAddPath);
    on<ClearCanvasEvent>(_onClearCanvas);
    on<UndoEvent>(_onUndo);
    on<RedoEvent>(_onRedo);
    on<SetPenColorEvent>(_onSetPenColor);
    on<SetPenWidthEvent>(_onSetPenWidth);
    on<SetToolEvent>(_onSetTool);
    on<SaveDrawingEvent>(_onSaveDrawing);
    on<LoadDrawingEvent>(_onLoadDrawing);
  }

  Future<void> _onAddPath(
    AddPathEvent event,
    Emitter<DrawingCanvasState> emit,
  ) async {
    try {
      _undoStack.add(List.from(_paths));
      _redoStack.clear();
      _paths.add(event.path);
      emit(CanvasPathAdded(List.from(_paths)));
    } catch (e) {
      emit(CanvasError('Failed to add path: $e'));
    }
  }

  Future<void> _onClearCanvas(
    ClearCanvasEvent event,
    Emitter<DrawingCanvasState> emit,
  ) async {
    try {
      _undoStack.add(List.from(_paths));
      _redoStack.clear();
      _paths.clear();
      emit(const CanvasCleared());
    } catch (e) {
      emit(CanvasError('Failed to clear canvas: $e'));
    }
  }

  Future<void> _onUndo(
    UndoEvent event,
    Emitter<DrawingCanvasState> emit,
  ) async {
    try {
      if (_undoStack.isNotEmpty) {
        _redoStack.add(List.from(_paths));
        _paths.clear();
        _paths.addAll(_undoStack.removeLast());
        emit(CanvasUndone(List.from(_paths)));
      }
    } catch (e) {
      emit(CanvasError('Failed to undo: $e'));
    }
  }

  Future<void> _onRedo(
    RedoEvent event,
    Emitter<DrawingCanvasState> emit,
  ) async {
    try {
      if (_redoStack.isNotEmpty) {
        _undoStack.add(List.from(_paths));
        _paths.clear();
        _paths.addAll(_redoStack.removeLast());
        emit(CanvasRedone(List.from(_paths)));
      }
    } catch (e) {
      emit(CanvasError('Failed to redo: $e'));
    }
  }

  Future<void> _onSetPenColor(
    SetPenColorEvent event,
    Emitter<DrawingCanvasState> emit,
  ) async {
    _currentPenColor = event.color;
    emit(CanvasPathAdded(List.from(_paths)));
  }

  Future<void> _onSetPenWidth(
    SetPenWidthEvent event,
    Emitter<DrawingCanvasState> emit,
  ) async {
    _currentPenWidth = event.width;
    emit(CanvasPathAdded(List.from(_paths)));
  }

  Future<void> _onSetTool(
    SetToolEvent event,
    Emitter<DrawingCanvasState> emit,
  ) async {
    _currentTool = event.tool;
    emit(CanvasPathAdded(List.from(_paths)));
  }

  Future<void> _onSaveDrawing(
    SaveDrawingEvent event,
    Emitter<DrawingCanvasState> emit,
  ) async {
    try {
      // TODO: Implement actual file save
      emit(DrawingSaved(event.filePath));
    } catch (e) {
      emit(CanvasError('Failed to save drawing: $e'));
    }
  }

  Future<void> _onLoadDrawing(
    LoadDrawingEvent event,
    Emitter<DrawingCanvasState> emit,
  ) async {
    try {
      // TODO: Implement actual file load
      emit(DrawingLoaded(List.from(_paths)));
    } catch (e) {
      emit(CanvasError('Failed to load drawing: $e'));
    }
  }
}
