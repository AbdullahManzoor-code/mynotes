import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import '../design_system/design_system.dart';

/// Drawing Canvas Screen
/// Freehand drawing capability with shapes, colors, and tools
/// Features: pen, eraser, shapes, color picker, save as image
class DrawingCanvasScreen extends StatefulWidget {
  final Function(Uint8List)? onDrawingSaved;

  const DrawingCanvasScreen({super.key, this.onDrawingSaved});

  @override
  State<DrawingCanvasScreen> createState() => _DrawingCanvasScreenState();
}

class _DrawingCanvasScreenState extends State<DrawingCanvasScreen>
    with TickerProviderStateMixin {
  late List<DrawingPath> _paths = [];
  late List<List<DrawingPath>> _undoStack = [];
  late List<List<DrawingPath>> _redoStack = [];

  int _currentColor = 0xFF000000; // Black
  double _currentWidth = 2.0;
  String _currentTool = 'pen';
  bool _isDrawing = false;

  late AnimationController _toolbarController;
  final List<int> _colorOptions = [
    0xFF000000, // Black
    0xFFFF0000, // Red
    0xFF00FF00, // Green
    0xFF0000FF, // Blue
    0xFFFFFF00, // Yellow
    0xFFFF00FF, // Magenta
    0xFF00FFFF, // Cyan
    0xFFFFFFFF, // White
  ];

  final List<double> _widthOptions = [1.0, 2.0, 4.0, 6.0, 8.0];

  @override
  void initState() {
    super.initState();
    _toolbarController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _toolbarController.forward();
  }

  @override
  void dispose() {
    _toolbarController.dispose();
    super.dispose();
  }

  void _addPath(Offset point) {
    setState(() {
      if (_paths.isEmpty || _paths.last.tool != _currentTool) {
        _paths.add(
          DrawingPath(
            points: [point],
            color: _currentColor,
            width: _currentWidth,
            tool: _currentTool,
          ),
        );
      } else {
        _paths.last.points.add(point);
      }
    });
  }

  void _undo() {
    if (_paths.isNotEmpty) {
      setState(() {
        _undoStack.add(List.from(_paths));
        _paths.removeLast();
      });
    }
  }

  void _redo() {
    if (_undoStack.isNotEmpty) {
      setState(() {
        _paths = _undoStack.removeLast();
        _redoStack.add(List.from(_paths));
      });
    }
  }

  void _clear() {
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
              setState(() => _paths.clear());
              Navigator.pop(ctx);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveDrawing() async {
    try {
      // Create a recorder to capture the canvas
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final size = MediaQuery.of(context).size;
      final rect = Rect.fromLTWH(0, 0, size.width, size.height - 120);

      // Draw white background
      canvas.drawRect(rect, Paint()..color = Colors.white);

      // Draw all paths
      for (final path in _paths) {
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

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Drawing saved!')));

        widget.onDrawingSaved?.call(imageBytes);

        // Pop with result
        Navigator.of(context).pop(imageBytes);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving drawing: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drawing Canvas'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: _paths.isEmpty ? null : _undo,
            tooltip: 'Undo',
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            onPressed: _undoStack.isEmpty ? null : _redo,
            tooltip: 'Redo',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clear,
            tooltip: 'Clear',
          ),
        ],
      ),
      body: Column(
        children: [
          // Canvas Area
          Expanded(
            child: GestureDetector(
              onPanStart: (details) {
                setState(() => _isDrawing = true);
                _addPath(details.localPosition);
              },
              onPanUpdate: (details) {
                if (_isDrawing) {
                  _addPath(details.localPosition);
                }
              },
              onPanEnd: (details) {
                setState(() => _isDrawing = false);
              },
              child: Container(
                color: Colors.white,
                child: CustomPaint(
                  painter: DrawingPainter(paths: _paths),
                  isComplex: true,
                  willChange: true,
                ),
              ),
            ),
          ),

          // Toolbar
          SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: _toolbarController,
                    curve: Curves.easeOut,
                  ),
                ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              padding: EdgeInsets.all(12.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tool Buttons
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _ToolButton(
                          icon: Icons.edit,
                          label: 'Pen',
                          isSelected: _currentTool == 'pen',
                          onPressed: () {
                            setState(() => _currentTool = 'pen');
                          },
                        ),
                        _ToolButton(
                          icon: Icons.cleaning_services,
                          label: 'Eraser',
                          isSelected: _currentTool == 'eraser',
                          onPressed: () {
                            setState(() => _currentTool = 'eraser');
                          },
                        ),
                        _ToolButton(
                          icon: Icons.square_outlined,
                          label: 'Rectangle',
                          isSelected: _currentTool == 'rectangle',
                          onPressed: () {
                            setState(() => _currentTool = 'rectangle');
                          },
                        ),
                        _ToolButton(
                          icon: Icons.circle_outlined,
                          label: 'Circle',
                          isSelected: _currentTool == 'circle',
                          onPressed: () {
                            setState(() => _currentTool = 'circle');
                          },
                        ),
                        _ToolButton(
                          icon: Icons.remove,
                          label: 'Line',
                          isSelected: _currentTool == 'line',
                          onPressed: () {
                            setState(() => _currentTool = 'line');
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 8.h),

                  // Color & Width Selection
                  Row(
                    children: [
                      // Colors
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              Text('Color:', style: TextStyle(fontSize: 12.sp)),
                              SizedBox(width: 8.w),
                              ..._colorOptions.map(
                                (color) => GestureDetector(
                                  onTap: () {
                                    setState(() => _currentColor = color);
                                  },
                                  child: Container(
                                    width: 30.w,
                                    height: 30.w,
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 4.w,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color(color),
                                      border: Border.all(
                                        color: _currentColor == color
                                            ? Colors.black
                                            : Colors.grey[400]!,
                                        width: _currentColor == color ? 2 : 1,
                                      ),
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8.h),

                  // Pen Width
                  Row(
                    children: [
                      Text('Width:', style: TextStyle(fontSize: 12.sp)),
                      SizedBox(width: 8.w),
                      ..._widthOptions.map(
                        (width) => GestureDetector(
                          onTap: () {
                            setState(() => _currentWidth = width);
                          },
                          child: Container(
                            width: 40.w,
                            height: 40.w,
                            margin: EdgeInsets.symmetric(horizontal: 4.w),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _currentWidth == width
                                    ? Colors.black
                                    : Colors.grey[400]!,
                                width: _currentWidth == width ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Center(
                              child: Container(
                                width: width,
                                height: width,
                                decoration: BoxDecoration(
                                  color: Color(_currentColor),
                                  borderRadius: BorderRadius.circular(
                                    width / 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saveDrawing,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Drawing'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tool Button Widget
class _ToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const _ToolButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Tooltip(
        message: label,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.white,
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.grey[400]!,
              ),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : Colors.black,
              size: 20.sp,
            ),
          ),
        ),
      ),
    );
  }
}

/// Drawing Path Model
class DrawingPath {
  final List<Offset> points;
  final int color;
  final double width;
  final String tool;

  DrawingPath({
    required this.points,
    required this.color,
    required this.width,
    required this.tool,
  });
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
