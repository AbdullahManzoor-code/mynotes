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

  DrawingCanvasBloc() : super(const DrawingCanvasState()) {
    on<StartPathEvent>(_onStartPath);
    on<UpdatePathEvent>(_onUpdatePath);
    on<EndPathEvent>(_onEndPath);
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

  void _onStartPath(StartPathEvent event, Emitter<DrawingCanvasState> emit) {
    _undoStack.add(List.from(_paths));
    _redoStack.clear();
    _paths.add(
      DrawingPath(
        points: [event.point],
        color: state.currentPenColor,
        width: state.currentPenWidth,
        tool: state.currentTool,
      ),
    );
    emit(state.copyWith(paths: List.from(_paths), isDrawing: true));
  }

  void _onUpdatePath(UpdatePathEvent event, Emitter<DrawingCanvasState> emit) {
    if (_paths.isNotEmpty) {
      _paths.last.points.add(event.point);
      emit(state.copyWith(paths: List.from(_paths)));
    }
  }

  void _onEndPath(EndPathEvent event, Emitter<DrawingCanvasState> emit) {
    emit(state.copyWith(isDrawing: false));
  }

  Future<void> _onAddPath(
    AddPathEvent event,
    Emitter<DrawingCanvasState> emit,
  ) async {
    try {
      _undoStack.add(List.from(_paths));
      _redoStack.clear();
      _paths.add(event.path);
      emit(state.copyWith(paths: List.from(_paths)));
    } catch (e) {
      emit(state.copyWith(error: 'Failed to add path: $e'));
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
      emit(state.copyWith(paths: []));
    } catch (e) {
      emit(state.copyWith(error: 'Failed to clear canvas: $e'));
    }
  }

  Future<void> _onUndo(
    UndoEvent event,
    Emitter<DrawingCanvasState> emit,
  ) async {
    try {
      if (_paths.isNotEmpty) {
        _redoStack.add(List.from(_paths));
        _paths.removeLast();
        emit(state.copyWith(paths: List.from(_paths)));
      } else if (_undoStack.isNotEmpty) {
        // Alternative implementation if we want to undo a whole state
      }
    } catch (e) {
      emit(state.copyWith(error: 'Failed to undo: $e'));
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
        emit(state.copyWith(paths: List.from(_paths)));
      }
    } catch (e) {
      emit(state.copyWith(error: 'Failed to redo: $e'));
    }
  }

  Future<void> _onSetPenColor(
    SetPenColorEvent event,
    Emitter<DrawingCanvasState> emit,
  ) async {
    emit(state.copyWith(currentPenColor: event.color));
  }

  Future<void> _onSetPenWidth(
    SetPenWidthEvent event,
    Emitter<DrawingCanvasState> emit,
  ) async {
    emit(state.copyWith(currentPenWidth: event.width));
  }

  Future<void> _onSetTool(
    SetToolEvent event,
    Emitter<DrawingCanvasState> emit,
  ) async {
    emit(state.copyWith(currentTool: event.tool));
  }

  Future<void> _onSaveDrawing(
    SaveDrawingEvent event,
    Emitter<DrawingCanvasState> emit,
  ) async {
    try {
      emit(state.copyWith(savedImagePath: event.filePath));
    } catch (e) {
      emit(state.copyWith(error: 'Failed to save drawing: $e'));
    }
  }

  Future<void> _onLoadDrawing(
    LoadDrawingEvent event,
    Emitter<DrawingCanvasState> emit,
  ) async {
    try {
      emit(state.copyWith(paths: List.from(_paths)));
    } catch (e) {
      emit(state.copyWith(error: 'Failed to load drawing: $e'));
    }
  }
}
