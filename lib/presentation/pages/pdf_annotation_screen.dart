import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui' as ui;

import '../design_system/design_system.dart';

/// PDF Annotation Screen - Annotate PDFs with drawings and highlights
class PDFAnnotationScreen extends StatefulWidget {
  final String pdfPath;
  final String pdfTitle;

  const PDFAnnotationScreen({
    super.key,
    required this.pdfPath,
    required this.pdfTitle,
  });

  @override
  State<PDFAnnotationScreen> createState() => _PDFAnnotationScreenState();
}

class _PDFAnnotationScreenState extends State<PDFAnnotationScreen> {
  late PDFAnnotationController _controller;
  AnnotationTool _selectedTool = AnnotationTool.pen;
  Color _selectedColor = Colors.black;
  double _selectedOpacity = 1.0;
  int _currentPage = 1;
  final int _totalPages = 5; // Placeholder

  @override
  void initState() {
    super.initState();
    _controller = PDFAnnotationController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAnnotationAppBar(context),
      body: Column(
        children: [
          // Main PDF Canvas
          Expanded(child: _buildAnnotationCanvas()),
          // Toolbar
          _buildAnnotationToolbar(context),
          // Page Navigation
          _buildPageNavigator(context),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAnnotationAppBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppBar(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        widget.pdfTitle,
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
      ),
      actions: [
        PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(child: const Text('Save'), onTap: () => _savePDF()),
            PopupMenuItem(
              child: const Text('Export'),
              onTap: () => _exportPDF(),
            ),
            PopupMenuItem(
              child: const Text('Clear'),
              onTap: () => _clearAnnotations(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnnotationCanvas() {
    return Container(
      color: Colors.grey[200],
      child: Stack(
        children: [
          // PDF Background (placeholder)
          Container(
            color: Colors.white,
            child: Center(
              child: Text(
                'PDF Page $_currentPage / $_totalPages',
                style: TextStyle(fontSize: 18.sp, color: Colors.grey[400]),
              ),
            ),
          ),
          // Annotation Canvas
          GestureDetector(
            onPanDown: (details) =>
                _controller.startStroke(details.localPosition),
            onPanUpdate: (details) =>
                _controller.updateStroke(details.localPosition),
            onPanEnd: (details) => _controller.endStroke(),
            child: CustomPaint(
              painter: AnnotationPainter(
                _controller.annotations,
                _controller.currentStroke,
              ),
              size: Size.infinite,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnotationToolbar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(top: BorderSide(color: AppColors.divider(context))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tool Selection
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildToolButton(AnnotationTool.pen, Icons.create, 'Pen'),
                SizedBox(width: 8.w),
                _buildToolButton(
                  AnnotationTool.highlight,
                  Icons.highlight,
                  'Highlight',
                ),
                SizedBox(width: 8.w),
                _buildToolButton(
                  AnnotationTool.eraser,
                  Icons.cleaning_services,
                  'Eraser',
                ),
                SizedBox(width: 8.w),
                _buildToolButton(
                  AnnotationTool.text,
                  Icons.text_fields,
                  'Text',
                ),
                SizedBox(width: 12.w),
                Divider(thickness: 2, height: 40.h),
                SizedBox(width: 12.w),
                // Undo/Redo
                IconButton(
                  icon: const Icon(Icons.undo),
                  onPressed: () => _controller.undo(),
                  tooltip: 'Undo',
                ),
                IconButton(
                  icon: const Icon(Icons.redo),
                  onPressed: () => _controller.redo(),
                  tooltip: 'Redo',
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          // Color & Properties
          Row(
            children: [
              // Color Palette
              ...List.generate(8, (index) {
                final colors = [
                  Colors.black,
                  Colors.red,
                  Colors.orange,
                  Colors.yellow,
                  Colors.green,
                  Colors.blue,
                  Colors.purple,
                  Colors.pink,
                ];
                final color = colors[index];
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedColor = color);
                    _controller.setColor(color);
                  },
                  child: Container(
                    width: 32.w,
                    height: 32.w,
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    decoration: BoxDecoration(
                      color: color,
                      border: _selectedColor == color
                          ? Border.all(color: Colors.grey, width: 2)
                          : null,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                );
              }),
            ],
          ),
          SizedBox(height: 8.h),
          // Opacity Slider
          Slider(
            value: _selectedOpacity,
            onChanged: (value) {
              setState(() => _selectedOpacity = value);
              _controller.setOpacity(value);
            },
            label: '${(_selectedOpacity * 100).toInt()}%',
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton(AnnotationTool tool, IconData icon, String label) {
    final isSelected = _selectedTool == tool;
    return FilterChip(
      label: Row(
        children: [
          Icon(icon, size: 16.sp),
          SizedBox(width: 4.w),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedTool = tool);
        _controller.selectTool(tool);
      },
    );
  }

  Widget _buildPageNavigator(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(top: BorderSide(color: AppColors.divider(context))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.navigate_before),
            onPressed: _currentPage > 1 ? () => _previousPage() : null,
          ),
          Text(
            'Page $_currentPage / $_totalPages',
            style: TextStyle(fontSize: 14.sp),
          ),
          IconButton(
            icon: const Icon(Icons.navigate_next),
            onPressed: _currentPage < _totalPages ? () => _nextPage() : null,
          ),
        ],
      ),
    );
  }

  void _previousPage() {
    if (_currentPage > 1) {
      setState(() => _currentPage--);
    }
  }

  void _nextPage() {
    if (_currentPage < _totalPages) {
      setState(() => _currentPage++);
    }
  }

  void _savePDF() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('PDF saved successfully')));
  }

  void _exportPDF() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Exporting PDF...')));
  }

  void _clearAnnotations() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Annotations?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _controller.clear();
              Navigator.pop(context);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// Annotation Types
enum AnnotationTool { pen, highlight, eraser, text }

// Annotation Model
class Annotation {
  final List<Offset> points;
  final Color color;
  final double opacity;
  final AnnotationTool tool;
  final DateTime createdAt;

  Annotation({
    required this.points,
    required this.color,
    required this.opacity,
    required this.tool,
    required this.createdAt,
  });
}

// PDF Annotation Controller
class PDFAnnotationController {
  final List<Annotation> annotations = [];
  final List<Annotation> _undoStack = [];
  List<Offset> currentStroke = [];
  Color _currentColor = Colors.black;
  double _currentOpacity = 1.0;
  AnnotationTool _currentTool = AnnotationTool.pen;

  void startStroke(Offset point) {
    currentStroke = [point];
  }

  void updateStroke(Offset point) {
    currentStroke.add(point);
  }

  void endStroke() {
    if (currentStroke.isNotEmpty) {
      annotations.add(
        Annotation(
          points: currentStroke,
          color: _currentColor,
          opacity: _currentOpacity,
          tool: _currentTool,
          createdAt: DateTime.now(),
        ),
      );
      currentStroke = [];
    }
  }

  void setColor(Color color) {
    _currentColor = color;
  }

  void setOpacity(double opacity) {
    _currentOpacity = opacity;
  }

  void selectTool(AnnotationTool tool) {
    _currentTool = tool;
  }

  void undo() {
    if (annotations.isNotEmpty) {
      _undoStack.add(annotations.removeLast());
    }
  }

  void redo() {
    if (_undoStack.isNotEmpty) {
      annotations.add(_undoStack.removeLast());
    }
  }

  void clear() {
    annotations.clear();
    _undoStack.clear();
  }

  void dispose() {
    // Cleanup
  }
}

// Custom Painter for Annotations
class AnnotationPainter extends CustomPainter {
  final List<Annotation> annotations;
  final List<Offset> currentStroke;

  AnnotationPainter(this.annotations, this.currentStroke);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw existing annotations
    for (final annotation in annotations) {
      _drawAnnotation(canvas, annotation);
    }

    // Draw current stroke
    if (currentStroke.isNotEmpty) {
      final paint = Paint()
        ..color = Colors.black
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      for (int i = 0; i < currentStroke.length - 1; i++) {
        canvas.drawLine(currentStroke[i], currentStroke[i + 1], paint);
      }
    }
  }

  void _drawAnnotation(Canvas canvas, Annotation annotation) {
    final paint = Paint()
      ..color = annotation.color.withOpacity(annotation.opacity)
      ..strokeWidth = annotation.tool == AnnotationTool.highlight ? 15 : 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (annotation.tool == AnnotationTool.highlight) {
      paint.style = PaintingStyle.fill;
      paint.strokeWidth = 15;
    }

    for (int i = 0; i < annotation.points.length - 1; i++) {
      canvas.drawLine(annotation.points[i], annotation.points[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(AnnotationPainter oldDelegate) => true;
}

