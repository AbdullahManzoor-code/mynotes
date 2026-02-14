import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphview/GraphView.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/todo_item.dart';
import '../../domain/entities/alarm.dart';
import '../bloc/graph/graph_bloc.dart';
import '../../injection_container.dart' show getIt;
import '../design_system/design_system.dart';
import '../design_system/components/layouts/glass_container.dart';

/// Universal Graph View (ORG-009)
/// Visualizes relationships between notes, todos, and reminders with a high-end neural network aesthetic.
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Neural Action Graph',
          style: AppTypography.heading3(context, Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () {
              HapticFeedback.lightImpact();
              context.read<GraphBloc>().add(LoadGraphData());
            },
          ),
          SizedBox(width: 8.w),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              const Color(0xFF1E293B),
              const Color(0xFF0F172A),
              const Color(0xFF020617),
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: BlocBuilder<GraphBloc, GraphState>(
          builder: (context, state) {
            if (state is GraphLoading) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (state is GraphError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 64.sp,
                      color: Colors.red.shade400,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      state.message,
                      style: AppTypography.bodyMedium(context, Colors.white70),
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onPressed: () =>
                          context.read<GraphBloc>().add(LoadGraphData()),
                      child: const Text('Retry Connection'),
                    ),
                  ],
                ),
              );
            }

            if (state is GraphLoaded) {
              if (state.graph.nodes.isEmpty) {
                return _buildEmptyState(context);
              }

              return Stack(
                children: [
                  // Animated Background Elements (Subtle Grid)
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.05,
                      child: GridPaper(
                        color: Colors.white,
                        divisions: 1,
                        subdivisions: 1,
                        interval: 100.w,
                      ),
                    ),
                  ),
                  InteractiveViewer(
                    constrained: false,
                    boundaryMargin: const EdgeInsets.all(800),
                    minScale: 0.05,
                    maxScale: 2.0,
                    child: GraphView(
                      graph: state.graph,
                      algorithm: builder!,
                      paint: Paint()
                        ..color = Colors.white.withOpacity(0.12)
                        ..strokeWidth = 1.2
                        ..style = PaintingStyle.stroke,
                      builder: (Node node) {
                        final data = state.nodeData[node];
                        return AppAnimations.tapScale(
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              if (data is Note) {
                                Navigator.pushNamed(
                                  context,
                                  '/note_editor',
                                  arguments: data,
                                );
                              }
                            },
                            child: _buildNodeWidget(context, data),
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 30.h,
                    left: 20.w,
                    right: 20.w,
                    child: _buildGlassLegend(context),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: AppAnimations.tapScale(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.hub_outlined,
                size: 80.sp,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Neural Network Empty',
              style: AppTypography.heading3(context, Colors.white),
            ),
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.w),
              child: Text(
                'Create nodes and link them using [[Note Title]] to see your knowledge grow.',
                // textAlign: TextAlign.center,
                style: AppTypography.bodyMedium(
                  context,
                  Colors.white.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNodeWidget(BuildContext context, dynamic data) {
    String title = 'Unknown';
    IconData icon = Icons.help_outline_rounded;
    Color color = AppColors.primary;
    double scale = 1.0;

    if (data is Note) {
      title = data.title.isEmpty ? 'Untitled Note' : data.title;
      icon = Icons.description_rounded;
      color = const Color(0xFF60A5FA); // Bright Blue
      scale = 1.2;
    } else if (data is TodoItem) {
      title = data.text;
      icon = Icons.check_circle_rounded;
      color = const Color(0xFF34D399); // Bright Emerald
    } else if (data is Alarm) {
      title = data.message;
      icon = Icons.notifications_active_rounded;
      color = const Color(0xFFFBBF24); // Bright Amber
    }

    return GlassContainer(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      borderRadius: 14.r,
      blur: 8,
      // borderOpacity: 0.3,
      color: Colors.white.withOpacity(0.05),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16.sp * scale),
          SizedBox(width: 8.w),
          Flexible(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  AppTypography.bodySmall(
                    context,
                    Colors.white.withOpacity(0.9),
                  ).copyWith(
                    fontWeight: scale > 1 ? FontWeight.bold : FontWeight.w500,
                    fontSize: 12.sp,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassLegend(BuildContext context) {
    return AppAnimations.tapScale(
      // direction: Axis.vertical,
      // offset: 50.0,
      child: GlassContainer(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        borderRadius: 20.r,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _legendItem(
              Icons.description_rounded,
              const Color(0xFF60A5FA),
              'Notes',
            ),
            _divider(),
            _legendItem(
              Icons.check_circle_rounded,
              const Color(0xFF34D399),
              'To-Dos',
            ),
            _divider(),
            _legendItem(
              Icons.notifications_active_rounded,
              const Color(0xFFFBBF24),
              'Reminders',
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() =>
      Container(height: 20.h, width: 1.w, color: Colors.white.withOpacity(0.1));

  Widget _legendItem(IconData icon, Color color, String label) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16.sp),
        SizedBox(width: 8.w),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

//   Widget _buildLegend() {
//     return Container(
//       padding: EdgeInsets.all(16.w),
//       decoration: BoxDecoration(
//         color: const Color(0xFF1E293B).withOpacity(0.8),
//         borderRadius: BorderRadius.circular(16.r),
//         border: Border.all(color: Colors.white.withOpacity(0.1)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildLegendItem('Notes', const Color(0xFF3B82F6)),
//           SizedBox(height: 8.h),
//           _buildLegendItem('Todos', const Color(0xFF10B981)),
//           SizedBox(height: 8.h),
//           _buildLegendItem('Reminders', const Color(0xFFF59E0B)),
//         ],
//       ),
//     );
//   }

//   Widget _buildLegendItem(String label, Color color) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Container(
//           width: 12.w,
//           height: 12.w,
//           decoration: BoxDecoration(color: color, shape: BoxShape.circle),
//         ),
//         SizedBox(width: 8.w),
//         Text(
//           label,
//           style: TextStyle(
//             color: Colors.white.withOpacity(0.8),
//             fontSize: 12.sp,
//           ),
//         ),
//       ],
//     );
//   }
// }
