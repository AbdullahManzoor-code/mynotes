import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui' as ui;

/// Drawing Canvas Widget - Sketch and annotate images
/// Supports multiple colors, brush sizes, undo/redo, and export
class DrawingCanvasWidget extends StatefulWidget {
  final String? initialImagePath;
  final Function(ui.Image) onDrawingComplete;
  final bool allowImageUpload;

  const DrawingCanvasWidget({
    super.key,
    this.initialImagePath,
    required this.onDrawingComplete,
    this.allowImageUpload = true,
  });

  @override
  State<DrawingCanvasWidget> createState() => _DrawingCanvasWidgetState();
}

class _DrawingCanvasWidgetState extends State<DrawingCanvasWidget> {
  late ui.PictureRecorder _pictureRecorder;
  late Canvas _canvas;
  final List<DrawingPoint> _points = [];
  final List<List<DrawingPoint>> _undoStack = [];
  Color _currentColor = Colors.black;
  double _currentStrokeWidth = 3.0;
  bool _isErasing = false;

  final List<Color> _colors = [
    Colors.black,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.pink,
  ];

  final List<double> _strokeWidths = [1.0, 3.0, 5.0, 8.0, 12.0];

  @override
  void initState() {
    super.initState();
    _initializeCanvas();
  }

  void _initializeCanvas() {
    _pictureRecorder = ui.PictureRecorder();
    _canvas = Canvas(_pictureRecorder);
    _canvas.drawRect(
      Rect.fromLTWH(0, 0, 500, 700),
      Paint()..color = Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildToolbar(),
        Expanded(child: _buildCanvas()),
        _buildActionBar(),
      ],
    );
  }

  Widget _buildToolbar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        child: Row(
          children: [
            // Color picker
            ..._colors.map(
              (color) => GestureDetector(
                onTap: () {
                  setState(() {
                    _currentColor = color;
                    _isErasing = false;
                  });
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  width: 32.w,
                  height: 32.h,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _currentColor == color && !_isErasing
                          ? Colors.black
                          : Colors.grey,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            // Eraser
            GestureDetector(
              onTap: () {
                setState(() {
                  _isErasing = true;
                });
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                width: 32.w,
                height: 32.h,
                decoration: BoxDecoration(
                  color: _isErasing ? Colors.grey[300] : Colors.grey[100],
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _isErasing ? Colors.black : Colors.grey,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.cleaning_services,
                    size: 16.sp,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            // Stroke width selector
            Text('Brush:', style: TextStyle(fontSize: 12.sp)),
            ..._strokeWidths.map(
              (width) => GestureDetector(
                onTap: () {
                  setState(() {
                    _currentStrokeWidth = width;
                  });
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 6.w),
                  width: 24.w,
                  height: 24.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _currentStrokeWidth == width
                          ? Colors.black
                          : Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: width,
                      height: width,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCanvas() {
    return GestureDetector(
      onPanStart: (details) {
        setState(() {
          _points.add(
            DrawingPoint(
              offset: details.localPosition,
              color: _currentColor,
              strokeWidth: _currentStrokeWidth,
              isErasing: _isErasing,
            ),
          );
        });
      },
      onPanUpdate: (details) {
        setState(() {
          _points.add(
            DrawingPoint(
              offset: details.localPosition,
              color: _currentColor,
              strokeWidth: _currentStrokeWidth,
              isErasing: _isErasing,
            ),
          );
        });
      },
      onPanEnd: (details) {
        // Save current state to undo stack
        _undoStack.add(List.from(_points));
      },
      child: CustomPaint(
        painter: DrawingPainter(points: _points),
        size: Size.infinite,
      ),
    );
  }

  Widget _buildActionBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(Icons.undo),
            onPressed: _points.isNotEmpty ? _undo : null,
            tooltip: 'Undo',
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _clearCanvas,
            tooltip: 'Clear',
          ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveDrawing,
            tooltip: 'Save',
          ),
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Cancel',
          ),
        ],
      ),
    );
  }

  void _undo() {
    if (_undoStack.isNotEmpty) {
      setState(() {
        _points.clear();
        _points.addAll(_undoStack.removeLast());
      });
    }
  }

  void _clearCanvas() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear Canvas?'),
        content: Text('Are you sure you want to clear the canvas?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _points.clear();
                _undoStack.clear();
              });
              Navigator.pop(context);
            },
            child: Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _saveDrawing() {
    // Create final image
    _pictureRecorder = ui.PictureRecorder();
    _canvas = Canvas(_pictureRecorder);

    // Draw white background
    _canvas.drawRect(
      Rect.fromLTWH(0, 0, 500, 700),
      Paint()..color = Colors.white,
    );

    // Draw all points
    for (int i = 0; i < _points.length - 1; i++) {
      if (_points[i].isErasing) {
        _canvas.drawLine(
          _points[i].offset,
          _points[i + 1].offset,
          Paint()
            ..color = Colors.white
            ..strokeWidth = _points[i].strokeWidth
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        );
      } else {
        _canvas.drawLine(
          _points[i].offset,
          _points[i + 1].offset,
          Paint()
            ..color = _points[i].color
            ..strokeWidth = _points[i].strokeWidth
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        );
      }
    }

    final picture = _pictureRecorder.endRecording();
    _saveDrawingAsync(picture);
    Navigator.pop(context);
  }

  Future<void> _saveDrawingAsync(ui.Picture picture) async {
    final image = await picture.toImage(500, 700);
    widget.onDrawingComplete(image);
  }
}

class DrawingPoint {
  final Offset offset;
  final Color color;
  final double strokeWidth;
  final bool isErasing;

  DrawingPoint({
    required this.offset,
    required this.color,
    required this.strokeWidth,
    this.isErasing = false,
  });
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint> points;

  DrawingPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw white background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.white,
    );

    // Draw all points
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i].isErasing) {
        canvas.drawLine(
          points[i].offset,
          points[i + 1].offset,
          Paint()
            ..color = Colors.white
            ..strokeWidth = points[i].strokeWidth
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        );
      } else {
        canvas.drawLine(
          points[i].offset,
          points[i + 1].offset,
          Paint()
            ..color = points[i].color
            ..strokeWidth = points[i].strokeWidth
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        );
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}
