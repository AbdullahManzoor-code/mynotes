import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../design_system/design_system.dart';

/// Video Trimming Screen
/// Trim video clips by selecting start and end points
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
  int _startPositionMs = 0;
  int _endPositionMs = 0;
  int _currentPositionMs = 0;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoTrimController(widget.videoDurationMs);
    _endPositionMs = widget.videoDurationMs;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildTrimAppBar(context),
      body: Column(
        children: [
          // Video Preview
          Expanded(child: _buildVideoPreview(context)),
          // Duration Display
          _buildDurationDisplay(context),
          // Timeline with Trim Handles
          _buildTimelineWithHandles(context),
          // Playback Controls
          _buildPlaybackControls(context),
          // Action Buttons
          _buildActionButtons(context),
        ],
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

  Widget _buildVideoPreview(BuildContext context) {
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
                '${_formatDuration(_currentPositionMs)} / ${_formatDuration(widget.videoDurationMs)}',
                style: TextStyle(fontSize: 12.sp, color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationDisplay(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trimmedDuration = (_endPositionMs - _startPositionMs).clamp(
      0,
      widget.videoDurationMs,
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
                _formatDuration(_startPositionMs),
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
                _formatDuration(_endPositionMs),
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

  Widget _buildTimelineWithHandles(BuildContext context) {
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
                    (_startPositionMs / widget.videoDurationMs) *
                    (MediaQuery.of(context).size.width - 32.w),
                right:
                    ((widget.videoDurationMs - _endPositionMs) /
                        widget.videoDurationMs) *
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
                    (_startPositionMs / widget.videoDurationMs) *
                    (MediaQuery.of(context).size.width - 32.w),
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      _startPositionMs =
                          ((_startPositionMs +
                                      (details.delta.dx /
                                              (MediaQuery.of(
                                                    context,
                                                  ).size.width -
                                                  32.w)) *
                                          widget.videoDurationMs)
                                  .clamp(0, _endPositionMs - 1000))
                              .toInt();
                    });
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
                    ((widget.videoDurationMs - _endPositionMs) /
                        widget.videoDurationMs) *
                    (MediaQuery.of(context).size.width - 32.w),
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      _endPositionMs =
                          ((_endPositionMs +
                                      (details.delta.dx /
                                              (MediaQuery.of(
                                                    context,
                                                  ).size.width -
                                                  32.w)) *
                                          widget.videoDurationMs)
                                  .clamp(
                                    _startPositionMs + 1000,
                                    widget.videoDurationMs,
                                  ))
                              .toInt();
                    });
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

  Widget _buildPlaybackControls(BuildContext context) {
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
            icon: Icon(_isPlaying ? Icons.pause_circle : Icons.play_circle),
            iconSize: 40.sp,
            onPressed: () {
              setState(() => _isPlaying = !_isPlaying);
            },
          ),
          SizedBox(width: 24.w),
          IconButton(
            icon: const Icon(Icons.stop_circle),
            iconSize: 32.sp,
            onPressed: () {
              setState(() {
                _isPlaying = false;
                _currentPositionMs = _startPositionMs;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
              onPressed: () => _saveTrimmedVideo(),
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

  void _saveTrimmedVideo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Trimmed Video'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trimmed Duration: ${_formatDuration(_endPositionMs - _startPositionMs)}',
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

