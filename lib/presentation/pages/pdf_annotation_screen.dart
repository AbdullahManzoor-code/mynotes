import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../design_system/design_system.dart';
import '../bloc/pdf_annotation/pdf_annotation_bloc.dart';
import '../bloc/pdf_annotation/pdf_annotation_state.dart';
import '../bloc/pdf_annotation/pdf_annotation_event.dart';

/// Annotation tools available in PDF editor
enum AnnotationTool { pen, highlight, eraser, text }

/// Model representing a single annotation on PDF
class Annotation {
  final List<Offset> points;
  final Color color;
  final double opacity;
  final AnnotationTool tool;
  final DateTime? createdAt;

  Annotation({
    required this.points,
    required this.color,
    required this.opacity,
    required this.tool,
    this.createdAt,
  });

  Annotation copyWith({
    List<Offset>? points,
    Color? color,
    double? opacity,
    AnnotationTool? tool,
    DateTime? createdAt,
  }) {
    return Annotation(
      points: points ?? this.points,
      color: color ?? this.color,
      opacity: opacity ?? this.opacity,
      tool: tool ?? this.tool,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// PDF Annotation Screen - Annotate PDFs with drawings and highlights
class PDFAnnotationScreen extends StatelessWidget {
  final String pdfPath;
  final String pdfTitle;

  const PDFAnnotationScreen({
    super.key,
    required this.pdfPath,
    required this.pdfTitle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PdfAnnotationBloc(),
      child: _PDFAnnotationView(pdfTitle: pdfTitle),
    );
  }
}

class _PDFAnnotationView extends StatelessWidget {
  final String pdfTitle;

  const _PDFAnnotationView({required this.pdfTitle});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PdfAnnotationBloc, PdfAnnotationState>(
      builder: (context, state) {
        return Scaffold(
          appBar: _buildAnnotationAppBar(context, state),
          body: Column(
            children: [
              // Main PDF Canvas
              Expanded(child: _buildAnnotationCanvas(context, state)),
              // Toolbar
              _buildAnnotationToolbar(context, state),
              // Page Navigation
              _buildPageNavigator(context, state),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAnnotationAppBar(
    BuildContext context,
    PdfAnnotationState state,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppBar(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        pdfTitle,
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
      ),
      actions: [
        PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Text('Save'),
              onTap: () => _savePDF(context),
            ),
            PopupMenuItem(
              child: const Text('Export'),
              onTap: () => _exportPDF(context),
            ),
            PopupMenuItem(
              child: const Text('Clear'),
              onTap: () => _clearAnnotations(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnnotationCanvas(
    BuildContext context,
    PdfAnnotationState state,
  ) {
    return Container(
      color: Colors.grey[200],
      child: Stack(
        children: [
          // PDF Background (placeholder)
          Container(
            color: Colors.white,
            child: Center(
              child: Text(
                'PDF Page ${state.currentPage} / ${state.totalPages}',
                style: TextStyle(fontSize: 18.sp, color: Colors.grey[400]),
              ),
            ),
          ),
          // Annotation Canvas
          GestureDetector(
            onPanDown: (details) => context.read<PdfAnnotationBloc>().add(
              StartDrawing(details.localPosition),
            ),
            onPanUpdate: (details) => context.read<PdfAnnotationBloc>().add(
              UpdateDrawing(details.localPosition),
            ),
            onPanEnd: (details) =>
                context.read<PdfAnnotationBloc>().add(const EndDrawing()),
            child: CustomPaint(
              painter: AnnotationPainter(
                (state.annotations as List<Annotation>?) ?? [],
                state.currentStroke,
              ),
              size: Size.infinite,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnotationToolbar(
    BuildContext context,
    PdfAnnotationState state,
  ) {
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
                _buildToolButton(
                  context,
                  AnnotationTool.pen,
                  Icons.create,
                  'Pen',
                  state.selectedTool,
                ),
                SizedBox(width: 8.w),
                _buildToolButton(
                  context,
                  AnnotationTool.highlight,
                  Icons.highlight,
                  'Highlight',
                  state.selectedTool,
                ),
                SizedBox(width: 8.w),
                _buildToolButton(
                  context,
                  AnnotationTool.eraser,
                  Icons.cleaning_services,
                  'Eraser',
                  state.selectedTool,
                ),
                SizedBox(width: 8.w),
                _buildToolButton(
                  context,
                  AnnotationTool.text,
                  Icons.text_fields,
                  'Text',
                  state.selectedTool,
                ),
                SizedBox(width: 12.w),
                Divider(thickness: 2, height: 40.h),
                SizedBox(width: 12.w),
                // Undo/Redo
                IconButton(
                  icon: const Icon(Icons.undo),
                  onPressed: () => context.read<PdfAnnotationBloc>().add(
                    const UndoAnnotation(),
                  ),
                  tooltip: 'Undo',
                ),
                IconButton(
                  icon: const Icon(Icons.redo),
                  onPressed: () => context.read<PdfAnnotationBloc>().add(
                    const RedoAnnotation(),
                  ),
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
                    context.read<PdfAnnotationBloc>().add(
                      ChangeAnnotationColor(color),
                    );
                  },
                  child: Container(
                    width: 32.w,
                    height: 32.w,
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    decoration: BoxDecoration(
                      color: color,
                      border: state.selectedColor == color
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
            value: state.selectedOpacity,
            onChanged: (value) {
              context.read<PdfAnnotationBloc>().add(
                ChangeAnnotationOpacity(value),
              );
            },
            label: '${(state.selectedOpacity * 100).toInt()}%',
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton(
    BuildContext context,
    AnnotationTool tool,
    IconData icon,
    String label,
    AnnotationTool selectedTool,
  ) {
    final isSelected = selectedTool == tool;
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
        context.read<PdfAnnotationBloc>().add(SelectAnnotationTool(tool));
      },
    );
  }

  Widget _buildPageNavigator(BuildContext context, PdfAnnotationState state) {
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
            onPressed: state.currentPage > 1
                ? () => context.read<PdfAnnotationBloc>().add(
                    ChangePdfPage(state.currentPage - 1),
                  )
                : null,
          ),
          Text(
            'Page ${state.currentPage} / ${state.totalPages}',
            style: TextStyle(fontSize: 14.sp),
          ),
          IconButton(
            icon: const Icon(Icons.navigate_next),
            onPressed: state.currentPage < state.totalPages
                ? () => context.read<PdfAnnotationBloc>().add(
                    ChangePdfPage(state.currentPage + 1),
                  )
                : null,
          ),
        ],
      ),
    );
  }

  void _savePDF(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('PDF saved successfully')));
  }

  void _exportPDF(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Exporting PDF...')));
  }

  void _clearAnnotations(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear All Annotations?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<PdfAnnotationBloc>().add(const ClearAnnotations());
              Navigator.pop(dialogContext);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// Annotation Painter remains similar but uses the Annotation model from BLoC
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
      // For current stroke, we use the default pen style as it's being drawn
      // OR we could pass the current settings to the painter.
      // For simplicity, let's use a standard pen.
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
