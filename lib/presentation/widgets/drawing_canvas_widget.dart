import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import '../design_system/design_system.dart';

/// Drawing Canvas Widget - Sketch and annotate images with a premium feel
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
  final List<DrawingPoint> _points = [];
  final List<List<DrawingPoint>> _history = [];
  Color _currentColor = AppColors.primary;
  double _currentStrokeWidth = 4.0;
  bool _isErasing = false;

  final List<Color> _colors = [
    const Color(0xFF000000), // Black
    const Color(0xFFE91E63), // Pink
    const Color(0xFF9C27B0), // Purple
    const Color(0xFF2196F3), // Blue
    const Color(0xFF4CAF50), // Green
    const Color(0xFFFFEB3B), // Yellow
    const Color(0xFFFF9800), // Orange
    const Color(0xFFF44336), // Red
  ];

  final List<double> _strokeWidths = [2.0, 4.0, 8.0, 12.0, 20.0];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // The Canvas
          Positioned.fill(child: _buildCanvas()),

          // Top Toolbar (Glass)
          Positioned(top: 0, left: 0, right: 0, child: _buildTopToolbar()),

          // Bottom Controls (Glass)
          Positioned(
            bottom: 32.h,
            left: 20.w,
            right: 20.w,
            child: _buildBottomControls(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopToolbar() {
    return GlassContainer(
      blur: 15,
      borderRadius: 0,
      color: Colors.white.withOpacity(0.7),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10.h,
        bottom: 12.h,
        left: 16.w,
        right: 16.w,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.textPrimary(context).withOpacity(0.05),
            ),
          ),
          const Spacer(),
          Text(
            'New Sketch',
            style: AppTypography.heading4(
              context,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          _buildActionButton(
            label: 'Save',
            onTap: _saveDrawing,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return AppAnimations.tapScale(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Color Selector
          GlassContainer(
            borderRadius: 30.r,
            blur: 20,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            color: AppColors.surface(context).withOpacity(0.8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildToolButton(
                    icon: Icons.cleaning_services_rounded,
                    isActive: _isErasing,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _isErasing = true);
                    },
                  ),
                  Container(
                    width: 1,
                    height: 24.h,
                    margin: EdgeInsets.symmetric(horizontal: 12.w),
                    color: AppColors.textSecondary(context).withOpacity(0.1),
                  ),
                  ..._colors.map((color) => _buildColorDot(color)),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),
          // Undo/Redo & Width Selector
          Row(
            children: [
              _buildSimpleRoundButton(
                icon: Icons.undo_rounded,
                onTap: _points.isNotEmpty ? _undo : null,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: GlassContainer(
                  borderRadius: 30.r,
                  blur: 20,
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  color: AppColors.surface(context).withOpacity(0.8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _strokeWidths
                        .map((w) => _buildWidthOption(w))
                        .toList(),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              _buildSimpleRoundButton(
                icon: Icons.delete_outline_rounded,
                onTap: _clearCanvas,
                color: Colors.red.withOpacity(0.1),
                iconColor: Colors.red.shade400,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorDot(Color color) {
    final bool isSelected = _currentColor == color && !_isErasing;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _currentColor = color;
          _isErasing = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.symmetric(horizontal: 6.w),
        width: 32.w,
        height: 32.w,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 3,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
      ),
    );
  }

  Widget _buildWidthOption(double width) {
    final bool isSelected = _currentStrokeWidth == width;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _currentStrokeWidth = width);
      },
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Container(
          width: 2 + (width / 2),
          height: 2 + (width / 2),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : AppColors.textSecondary(context).withOpacity(0.4),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 20.sp,
          color: isActive
              ? Colors.white
              : AppColors.textPrimary(context).withOpacity(0.6),
        ),
      ),
    );
  }

  Widget _buildSimpleRoundButton({
    required IconData icon,
    VoidCallback? onTap,
    Color? color,
    Color? iconColor,
  }) {
    return GlassContainer(
      // width: 52.w,
      // height: 52.w,
      borderRadius: 26.r,
      blur: 20,
      color: color ?? AppColors.surface(context).withOpacity(0.8),
      padding: EdgeInsets.zero,
      child: IconButton(
        icon: Icon(icon, color: iconColor ?? AppColors.textPrimary(context)),
        onPressed: () {
          if (onTap != null) {
            HapticFeedback.lightImpact();
            onTap();
          }
        },
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCanvas() {
    return GestureDetector(
      onPanStart: (details) {
        HapticFeedback.selectionClick();
        setState(() {
          _points.add(
            DrawingPoint(
              offset: details.localPosition,
              color: _isErasing ? Colors.white : _currentColor,
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
              color: _isErasing ? Colors.white : _currentColor,
              strokeWidth: _currentStrokeWidth,
              isErasing: _isErasing,
            ),
          );
        });
      },
      onPanEnd: (details) {
        _history.add(List.from(_points));
      },
      child: CustomPaint(
        painter: DrawingPainter(points: _points),
        size: Size.infinite,
      ),
    );
  }

  void _undo() {
    if (_history.isNotEmpty) {
      setState(() {
        _history.removeLast();
        _points.clear();
        if (_history.isNotEmpty) {
          _points.addAll(_history.last);
        }
      });
    }
  }

  void _clearCanvas() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: const Text('Clear everything?'),
        content: const Text(
          'This will permanently delete your current sketch.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary(context)),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _points.clear();
                _history.clear();
              });
              Navigator.pop(context);
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveDrawing() async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    // White background
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, 1000, 1000),
      Paint()..color = Colors.white,
    );

    // Draw lines
    for (int i = 0; i < _points.length - 1; i++) {
      canvas.drawLine(
        _points[i].offset,
        _points[i + 1].offset,
        Paint()
          ..color = _points[i].color
          ..strokeCap = StrokeCap.round
          ..strokeWidth = _points[i].strokeWidth,
      );
    }

    final ui.Image image = await recorder.endRecording().toImage(1000, 1000);
    widget.onDrawingComplete(image);
    // Don't pop here - let the parent handle navigation
    // if (mounted) Navigator.pop(context);
  }
}

/// Helper class for drawing points
class DrawingPoint {
  final Offset offset;
  final Color color;
  final double strokeWidth;
  final bool isErasing;

  DrawingPoint({
    required this.offset,
    required this.color,
    required this.strokeWidth,
    required this.isErasing,
  });
}

/// Custom painter for the drawing canvas
class DrawingPainter extends CustomPainter {
  final List<DrawingPoint> points;

  DrawingPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    // White background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.white,
    );

    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(
        points[i].offset,
        points[i + 1].offset,
        Paint()
          ..color = points[i].color
          ..strokeCap = StrokeCap.round
          ..strokeWidth = points[i].strokeWidth,
      );
    }
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) => true;
}


