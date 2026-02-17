import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../design_system/design_system.dart';
import '../bloc/video_trimming/video_trimming_bloc.dart';
import '../../injection_container.dart' show getIt;

/* ════════════════════════════════════════════════════════════════════════════
   M010: CONSOLIDATED FINDINGS - VIDEO TRIMMING IMPLEMENTATION
   
   ARCHITECTURE ASSESSMENT:
   This screen provides comprehensive trimming UI but NO actual video processing:
   
   ✅ WORKING:
   • Custom timeline with trim handles
   • Start/end position selection with validation
   • Playback preview and position tracking
   • Duration calculation and display
   • Complete state management via VideoTrimmingBloc
   
   ⚠️  MISSING/PLACEHOLDER:
   • Actual video file trimming (no FFmpeg integration)
   • Export/save functionality (onApplyTrimming just returns state)
   • MediaProcessingService lacks trimVideo() method
   
   DUPLICATION IDENTIFIED:
   VideoEditorScreen (media_viewer_screen.dart) also provides trimming:
   • Uses video_editor package's TrimSlider + TrimTimeline
   • Alternative trimming UI for same operation
   • Less functional than this implementation
   
   RECOMMENDATION:
   1. Consolidate UI to VideoEditorScreen (uses proven package)
   2. Implement actual trimming in MediaProcessingService
   3. Route both trim requests to VideoEditorScreen
   4. Archive VideoTrimmingScreen or keep as alternative
   
   KEPT: As-is for now, flagged for backend implementation
═══════════════════════════════════════════════════════════════════════════════ */

/// Video Trimming Screen
/// Trim video clips by selecting start and end points
///
/// ⚠️  NOTE: UI-only implementation. Actual video trimming/export not implemented.
///    See VideoEditorScreen for integration approach.
class VideoTrimmingScreen extends StatefulWidget {
  final String videoPath;
  final String videoTitle;
  final int videoDurationMs;

  const VideoTrimmingScreen({
    super.key,
    required this.videoPath,
    required this.videoTitle,
    this.videoDurationMs = 60000, // 60 seconds default
  });

  @override
  State<VideoTrimmingScreen> createState() => _VideoTrimmingScreenState();
}

class _VideoTrimmingScreenState extends State<VideoTrimmingScreen> {
  late VideoTrimController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoTrimController(widget.videoDurationMs);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<VideoTrimmingBloc>()
        ..add(
          InitializeVideoTrimmingEvent(
            videoPath: widget.videoPath,
            durationMs: widget.videoDurationMs,
          ),
        ),
      child: BlocBuilder<VideoTrimmingBloc, VideoTrimmingState>(
        builder: (context, state) {
          final totalDurationMs = state.totalDurationMs == 0
              ? widget.videoDurationMs
              : state.totalDurationMs;
          final startPositionMs = state.startPositionMs;
          final endPositionMs = state.endPositionMs == 0
              ? totalDurationMs
              : state.endPositionMs;
          final currentPositionMs = state.currentPositionMs;
          final isPlaying = state.isPlaying;

          return Scaffold(
            appBar: _buildTrimAppBar(context),
            body: Column(
              children: [
                // Video Preview
                Expanded(
                  child: _buildVideoPreview(
                    context,
                    currentPositionMs,
                    totalDurationMs,
                  ),
                ),
                // Duration Display
                _buildDurationDisplay(
                  context,
                  startPositionMs,
                  endPositionMs,
                  totalDurationMs,
                ),
                // Timeline with Trim Handles
                _buildTimelineWithHandles(
                  context,
                  startPositionMs,
                  endPositionMs,
                  totalDurationMs,
                ),
                // Playback Controls
                _buildPlaybackControls(context, isPlaying, startPositionMs),
                // Action Buttons
                _buildActionButtons(context, startPositionMs, endPositionMs),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildTrimAppBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppBar(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Trim Video',
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildVideoPreview(
    BuildContext context,
    int currentPositionMs,
    int totalDurationMs,
  ) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam, size: 64, color: Colors.grey[600]),
            SizedBox(height: 16.h),
            Text(
              'Video Preview',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                '${_formatDuration(currentPositionMs)} / ${_formatDuration(totalDurationMs)}',
                style: TextStyle(fontSize: 12.sp, color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationDisplay(
    BuildContext context,
    int startPositionMs,
    int endPositionMs,
    int totalDurationMs,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trimmedDuration = (endPositionMs - startPositionMs).clamp(
      0,
      totalDurationMs,
    );

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(top: BorderSide(color: AppColors.divider(context))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              Text(
                'Start',
                style: TextStyle(fontSize: 11.sp, color: Colors.grey),
              ),
              SizedBox(height: 4.h),
              Text(
                _formatDuration(startPositionMs),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          Column(
            children: [
              Text(
                'Duration',
                style: TextStyle(fontSize: 11.sp, color: Colors.grey),
              ),
              SizedBox(height: 4.h),
              Text(
                _formatDuration(trimmedDuration),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          Column(
            children: [
              Text(
                'End',
                style: TextStyle(fontSize: 11.sp, color: Colors.grey),
              ),
              SizedBox(height: 4.h),
              Text(
                _formatDuration(endPositionMs),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineWithHandles(
    BuildContext context,
    int startPositionMs,
    int endPositionMs,
    int totalDurationMs,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(bottom: BorderSide(color: AppColors.divider(context))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Trim Timeline',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 12.h),
          Stack(
            alignment: Alignment.center,
            children: [
              // Timeline Background
              Container(
                height: 60.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.r),
                  color: Colors.grey[300],
                ),
              ),
              // Trimmed Range Highlight
              Positioned(
                left:
                    (startPositionMs / totalDurationMs) *
                    (MediaQuery.of(context).size.width - 32.w),
                right:
                    ((totalDurationMs - endPositionMs) / totalDurationMs) *
                    (MediaQuery.of(context).size.width - 32.w),
                child: Container(
                  height: 60.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.r),
                    color: Colors.blue.withOpacity(0.5),
                  ),
                ),
              ),
              // Timeline Frame Thumbnails (placeholder)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (index) {
                  return Container(
                    width: 40.w,
                    height: 50.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2.r),
                      color: Colors.grey[400],
                    ),
                    child: Icon(Icons.image, size: 16.sp),
                  );
                }),
              ),
              // Start Handle
              Positioned(
                left:
                    (startPositionMs / totalDurationMs) *
                    (MediaQuery.of(context).size.width - 32.w),
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    final newStartPosition =
                        ((startPositionMs +
                                    (details.delta.dx /
                                            (MediaQuery.of(context).size.width -
                                                32.w)) *
                                        totalDurationMs)
                                .clamp(0, endPositionMs - 1000))
                            .toInt();
                    context.read<VideoTrimmingBloc>().add(
                      UpdateStartPositionEvent(newStartPosition),
                    );
                  },
                  child: Container(
                    width: 12.w,
                    height: 60.h,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(4.r),
                        bottomLeft: Radius.circular(4.r),
                      ),
                    ),
                  ),
                ),
              ),
              // End Handle
              Positioned(
                right:
                    ((totalDurationMs - endPositionMs) / totalDurationMs) *
                    (MediaQuery.of(context).size.width - 32.w),
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    final newEndPosition =
                        ((endPositionMs +
                                    (details.delta.dx /
                                            (MediaQuery.of(context).size.width -
                                                32.w)) *
                                        totalDurationMs)
                                .clamp(startPositionMs + 1000, totalDurationMs))
                            .toInt();
                    context.read<VideoTrimmingBloc>().add(
                      UpdateEndPositionEvent(newEndPosition),
                    );
                  },
                  child: Container(
                    width: 12.w,
                    height: 60.h,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(4.r),
                        bottomRight: Radius.circular(4.r),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaybackControls(
    BuildContext context,
    bool isPlaying,
    int startPositionMs,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(bottom: BorderSide(color: AppColors.divider(context))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(isPlaying ? Icons.pause_circle : Icons.play_circle),
            iconSize: 40.sp,
            onPressed: () {
              context.read<VideoTrimmingBloc>().add(
                const TogglePlaybackEvent(),
              );
            },
          ),
          SizedBox(width: 24.w),
          IconButton(
            icon: const Icon(Icons.stop_circle),
            iconSize: 32.sp,
            onPressed: () {
              if (isPlaying) {
                context.read<VideoTrimmingBloc>().add(
                  const TogglePlaybackEvent(),
                );
              }
              context.read<VideoTrimmingBloc>().add(
                UpdateCurrentPositionEvent(startPositionMs),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    int startPositionMs,
    int endPositionMs,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
              label: const Text('Cancel'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[400],
                foregroundColor: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () =>
                  _saveTrimmedVideo(context, startPositionMs, endPositionMs),
              icon: const Icon(Icons.check),
              label: const Text('Save'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int ms) {
    final seconds = ms ~/ 1000;
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _saveTrimmedVideo(
    BuildContext context,
    int startPositionMs,
    int endPositionMs,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Trimmed Video'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trimmed Duration: ${_formatDuration(endPositionMs - startPositionMs)}',
            ),
            SizedBox(height: 12.h),
            const Text('Exporting will save the trimmed video.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Trimmed video saved successfully'),
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }
}

// Video Trim Controller
class VideoTrimController {
  final int totalDuration;

  VideoTrimController(this.totalDuration);

  void dispose() {
    // Cleanup
  }
}
