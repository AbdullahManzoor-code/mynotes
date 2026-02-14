import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import '../bloc/drawing_canvas/drawing_canvas_bloc.dart';
import '../design_system/design_system.dart';

/// Drawing Canvas Screen
/// Freehand drawing capability with shapes, colors, and tools
/// Refactored to use BLoC and StatelessWidget
class DrawingCanvasScreen extends StatelessWidget {
  final Function(Uint8List)? onDrawingSaved;

  const DrawingCanvasScreen({super.key, this.onDrawingSaved});

  void _showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Drawing?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<DrawingCanvasBloc>().add(const ClearCanvasEvent());
              Navigator.pop(ctx);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveDrawing(
    BuildContext context,
    List<DrawingPath> paths,
  ) async {
    try {
      // Create a recorder to capture the canvas
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final size = MediaQuery.of(context).size;
      final rect = Rect.fromLTWH(0, 0, size.width, size.height - 120);

      // Draw white background
      canvas.drawRect(rect, Paint()..color = Colors.white);

      // Draw all paths
      for (final path in paths) {
        final paint = Paint()
          ..color = Color(path.color)
          ..strokeWidth = path.width
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

        if (path.tool == 'eraser') {
          paint.blendMode = BlendMode.clear;
        }

        if (path.points.length > 1) {
          for (int i = 0; i < path.points.length - 1; i++) {
            canvas.drawLine(path.points[i], path.points[i + 1], paint);
          }
        } else if (path.points.isNotEmpty) {
          canvas.drawPoints(ui.PointMode.points, path.points, paint);
        }
      }

      // Convert to image
      final picture = recorder.endRecording();
      final image = await picture.toImage(
        size.width.toInt(),
        (size.height - 120).toInt(),
      );

      // Convert to PNG bytes
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final imageBytes = bytes!.buffer.asUint8List();

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Drawing saved!')));
        onDrawingSaved?.call(imageBytes);
        Navigator.of(context).pop(imageBytes);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving drawing: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DrawingCanvasBloc, DrawingCanvasState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Drawing Canvas'),
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.undo),
                onPressed: state.paths.isEmpty
                    ? null
                    : () => context.read<DrawingCanvasBloc>().add(
                        const UndoEvent(),
                      ),
                tooltip: 'Undo',
              ),
              IconButton(
                icon: const Icon(Icons.redo),
                onPressed: () =>
                    context.read<DrawingCanvasBloc>().add(const RedoEvent()),
                tooltip: 'Redo',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _showClearDialog(context),
                tooltip: 'Clear',
              ),
              IconButton(
                icon: const Icon(Icons.save_alt),
                onPressed: () => _saveDrawing(context, state.paths),
                tooltip: 'Save',
              ),
            ],
          ),
          body: Column(
            children: [
              // Canvas Area
              Expanded(
                child: GestureDetector(
                  onPanStart: (details) {
                    context.read<DrawingCanvasBloc>().add(
                      StartPathEvent(details.localPosition),
                    );
                  },
                  onPanUpdate: (details) {
                    context.read<DrawingCanvasBloc>().add(
                      UpdatePathEvent(details.localPosition),
                    );
                  },
                  onPanEnd: (details) {
                    context.read<DrawingCanvasBloc>().add(EndPathEvent());
                  },
                  child: Container(
                    color: Colors.white,
                    child: CustomPaint(
                      painter: DrawingPainter(paths: state.paths),
                      isComplex: true,
                      willChange: true,
                    ),
                  ),
                ),
              ),

              // Toolbar
              _buildToolbar(context, state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToolbar(BuildContext context, DrawingCanvasState state) {
    final List<int> colorOptions = [
      0xFF000000,
      0xFFFF0000,
      0xFF00FF00,
      0xFF0000FF,
      0xFFFFFF00,
      0xFFFF00FF,
      0xFF00FFFF,
      0xFFFFFFFF,
    ];

    final List<double> widthOptions = [1.0, 2.0, 4.0, 6.0, 8.0];

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      padding: EdgeInsets.all(12.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _toolButton(
                  context,
                  Icons.edit,
                  'Pen',
                  state.currentTool == 'pen',
                  'pen',
                ),
                _toolButton(
                  context,
                  Icons.cleaning_services,
                  'Eraser',
                  state.currentTool == 'eraser',
                  'eraser',
                ),
                _toolButton(
                  context,
                  Icons.square_outlined,
                  'Rectangle',
                  state.currentTool == 'rectangle',
                  'rectangle',
                ),
                _toolButton(
                  context,
                  Icons.circle_outlined,
                  'Circle',
                  state.currentTool == 'circle',
                  'circle',
                ),
                _toolButton(
                  context,
                  Icons.remove,
                  'Line',
                  state.currentTool == 'line',
                  'line',
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: colorOptions
                        .map(
                          (color) => GestureDetector(
                            onTap: () => context.read<DrawingCanvasBloc>().add(
                              SetPenColorEvent(color),
                            ),
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 4.w),
                              width: 30.w,
                              height: 30.w,
                              decoration: BoxDecoration(
                                color: Color(color),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: state.currentPenColor == color
                                      ? Colors.blue
                                      : Colors.grey,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 30.h,
                color: Colors.grey[400],
                margin: EdgeInsets.symmetric(horizontal: 8.w),
              ),
              DropdownButton<double>(
                value: widthOptions.contains(state.currentPenWidth)
                    ? state.currentPenWidth
                    : widthOptions.first,
                items: widthOptions
                    .map(
                      (w) => DropdownMenuItem(
                        value: w,
                        child: Text('${w.toInt()}px'),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    context.read<DrawingCanvasBloc>().add(
                      SetPenWidthEvent(val),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _toolButton(
    BuildContext context,
    IconData icon,
    String label,
    bool isSelected,
    String tool,
  ) {
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: ActionChip(
        avatar: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.black,
          size: 16,
        ),
        label: Text(label),
        onPressed: () =>
            context.read<DrawingCanvasBloc>().add(SetToolEvent(tool)),
        backgroundColor: isSelected ? Colors.blue : Colors.white,
        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
      ),
    );
  }
}

/// Custom Painter for Drawing Canvas
class DrawingPainter extends CustomPainter {
  final List<DrawingPath> paths;

  DrawingPainter({required this.paths});

  @override
  void paint(Canvas canvas, Size size) {
    for (final path in paths) {
      final paint = Paint()
        ..color = Color(path.color)
        ..strokeWidth = path.width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      if (path.tool == 'eraser') {
        paint.blendMode = BlendMode.clear;
      }

      if (path.points.length > 1) {
        for (int i = 0; i < path.points.length - 1; i++) {
          canvas.drawLine(path.points[i], path.points[i + 1], paint);
        }
      } else if (path.points.isNotEmpty) {
        canvas.drawPoints(ui.PointMode.points, path.points, paint);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) {
    return oldDelegate.paths.length != paths.length;
  }
}

