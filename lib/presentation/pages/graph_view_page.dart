import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphview/GraphView.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/todo_item.dart';
import '../../domain/entities/alarm.dart';
import '../bloc/graph/graph_bloc.dart';
import '../../injection_container.dart' show getIt;
import '../design_system/app_colors.dart';
import '../design_system/app_typography.dart';

/// Universal Graph View (ORG-009)
/// Visualizes relationships between notes, todos, and reminders.
class GraphViewPage extends StatelessWidget {
  const GraphViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<GraphBloc>()..add(LoadGraphData()),
      child: const _GraphViewContent(),
    );
  }
}

class _GraphViewContent extends StatefulWidget {
  const _GraphViewContent();

  @override
  State<_GraphViewContent> createState() => _GraphViewContentState();
}

class _GraphViewContentState extends State<_GraphViewContent> {
  Algorithm? builder;

  @override
  void initState() {
    super.initState();
    builder = FruchtermanReingoldAlgorithm(FruchtermanReingoldConfiguration());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Universal Action Graph',
          style: AppTypography.heading3(context, Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<GraphBloc>().add(LoadGraphData()),
          ),
        ],
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFF020617),
      body: BlocBuilder<GraphBloc, GraphState>(
        builder: (context, state) {
          if (state is GraphLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is GraphError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
                  SizedBox(height: 16.h),
                  Text(
                    state.message,
                    style: const TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<GraphBloc>().add(LoadGraphData()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is GraphLoaded) {
            if (state.graph.nodes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.hub_outlined,
                      size: 64.sp,
                      color: Colors.white24,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Your knowledge graph is empty.',
                      style: AppTypography.bodyLarge(context, Colors.white70),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Start by creating notes or linking items with [[Note Name]].',
                      style: AppTypography.caption(context, Colors.white38),
                    ),
                  ],
                ),
              );
            }

            return Stack(
              children: [
                InteractiveViewer(
                  constrained: false,
                  boundaryMargin: const EdgeInsets.all(500),
                  minScale: 0.1,
                  maxScale: 2.0,
                  child: GraphView(
                    graph: state.graph,
                    algorithm: builder!,
                    paint: Paint()
                      ..color = Colors.white.withOpacity(0.15)
                      ..strokeWidth = 1.5
                      ..style = PaintingStyle.stroke,
                    builder: (Node node) {
                      final data = state.nodeData[node];
                      return GestureDetector(
                        onTap: () {
                          if (data is Note) {
                            Navigator.pushNamed(
                              context,
                              '/note_editor',
                              arguments: data,
                            );
                          } else if (data is TodoItem && data.noteId != null) {
                            // Focus linked note logic
                          }
                        },
                        child: _buildNodeWidget(data),
                      );
                    },
                  ),
                ),
                Positioned(bottom: 24.h, left: 24.w, child: _buildLegend()),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildNodeWidget(dynamic data) {
    String title = '';
    IconData icon = Icons.description;
    Color color = AppColors.primaryColor;
    double size = 1.0;

    if (data is Note) {
      title = data.title;
      icon = Icons.description;
      color = const Color(0xFF3B82F6); // Blue
      size = 1.2;
    } else if (data is TodoItem) {
      title = data.text;
      icon = Icons.check_circle_outline;
      color = const Color(0xFF10B981); // Emerald
    } else if (data is Alarm) {
      title = data.message;
      icon = Icons.notifications_active_outlined;
      color = const Color(0xFFF59E0B); // Amber
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      constraints: BoxConstraints(maxWidth: 150.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.9),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.5), width: 1.5 * size),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14.sp),
          SizedBox(width: 8.w),
          Flexible(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.8),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLegendItem('Notes', const Color(0xFF3B82F6)),
          SizedBox(height: 8.h),
          _buildLegendItem('Todos', const Color(0xFF10B981)),
          SizedBox(height: 8.h),
          _buildLegendItem('Reminders', const Color(0xFFF59E0B)),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 8.w),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }
}
