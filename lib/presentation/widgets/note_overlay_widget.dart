import 'package:flutter/material.dart';
import '../../domain/entities/annotation_stroke.dart';

class NoteOverlayWidget extends StatefulWidget {
  final List<AnnotationStroke> strokes;
  final Function(AnnotationStroke) onStrokeAdded;
  final bool isDrawingMode;

  const NoteOverlayWidget({
    super.key,
    required this.strokes,
    required this.onStrokeAdded,
    this.isDrawingMode = false,
  });

  @override
  State<NoteOverlayWidget> createState() => _NoteOverlayWidgetState();
}

class _NoteOverlayWidgetState extends State<NoteOverlayWidget> {
  List<Offset> _currentPoints = [];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        return GestureDetector(
          onPanStart: widget.isDrawingMode
              ? (details) {
                  setState(() {
                    _currentPoints = [
                      Offset(
                        details.localPosition.dx / size.width,
                        details.localPosition.dy / size.height,
                      ),
                    ];
                  });
                }
              : null,
          onPanUpdate: widget.isDrawingMode
              ? (details) {
                  setState(() {
                    _currentPoints.add(
                      Offset(
                        details.localPosition.dx / size.width,
                        details.localPosition.dy / size.height,
                      ),
                    );
                  });
                }
              : null,
          onPanEnd: widget.isDrawingMode
              ? (details) {
                  if (_currentPoints.isNotEmpty) {
                    widget.onStrokeAdded(
                      AnnotationStroke(points: List.from(_currentPoints)),
                    );
                    setState(() {
                      _currentPoints = [];
                    });
                  }
                }
              : null,
          child: CustomPaint(
            painter: _AnnotationPainter(
              strokes: widget.strokes,
              currentPoints: _currentPoints,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }
}

class _AnnotationPainter extends CustomPainter {
  final List<AnnotationStroke> strokes;
  final List<Offset> currentPoints;

  _AnnotationPainter({required this.strokes, required this.currentPoints});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final stroke in strokes) {
      paint.color = stroke.color;
      paint.strokeWidth = stroke.strokeWidth;
      paint.style = PaintingStyle.stroke;

      final path = Path();
      if (stroke.points.isNotEmpty) {
        path.moveTo(
          stroke.points.first.dx * size.width,
          stroke.points.first.dy * size.height,
        );
        for (var i = 1; i < stroke.points.length; i++) {
          path.lineTo(
            stroke.points[i].dx * size.width,
            stroke.points[i].dy * size.height,
          );
        }
        canvas.drawPath(path, paint);
      }
    }

    if (currentPoints.isNotEmpty) {
      paint.color = Colors.red;
      paint.strokeWidth = 3.0;
      paint.style = PaintingStyle.stroke;

      final path = Path();
      path.moveTo(
        currentPoints.first.dx * size.width,
        currentPoints.first.dy * size.height,
      );
      for (var i = 1; i < currentPoints.length; i++) {
        path.lineTo(
          currentPoints[i].dx * size.width,
          currentPoints[i].dy * size.height,
        );
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AnnotationPainter oldDelegate) => true;
}
