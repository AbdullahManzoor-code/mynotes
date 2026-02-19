import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/presentation/design_system/design_system.dart';
import 'package:video_editor/video_editor.dart';
import '../../domain/entities/media_item.dart';
import '../bloc/video_editor/video_editor_bloc.dart';
import '../../injection_container.dart' show getIt;

/* ════════════════════════════════════════════════════════════════════════════
   M011: CONSOLIDATED FINDINGS - VIDEO EDITOR IMPLEMENTATION
   
   CURRENT STATUS: MINIMAL/PLACEHOLDER EXPORT
   
   ARCHITECTURE:
   • Uses video_editor package (third-party) for UI components
   • VideoEditorBloc manages only export state (not actual editing)
   • VideoEditorController from package handles actual video operations
   • Integration: Called from media_viewer_screen.dart
   
   WHAT'S WORKING: ✅
   • Video preview with CropGridViewer
   • TrimSlider for selecting trim points
   • TrimTimeline for visualization
   • Playback controls (play/pause)
   • UI state transitions (ready → exporting → success/error)
   
   WHAT'S NOT WORKING: ⚠️
   • VideoEditorBloc._onExport: Just 2-second mock delay
   • No actual video file generation/trimming
   • Export button shows success but file is not modified
   • MediaProcessingService has no trimVideo() integration
   
   DUPLICATION:
   VideoTrimmingScreen also provides trimming (separate implementation):
   • More comprehensive state management
   • Custom UI separate from video_editor package
   • Unused in most workflows
   
   RECOMMENDATIONS:
   1. Implement real export: Replace mock delay with video_editor API calls
   2. Add MediaProcessingService.trimVideo() using VideoEditorController
   3. Handle file permissions and path management
   4. Consolidate: Route VideoTrimmingScreen to VideoEditorScreen
   5. Consider: Keep VideoTrimmingScreen as advanced/standalone option
   
   PRIORITY: HIGH - Export is critical functionality currently broken
═══════════════════════════════════════════════════════════════════════════════ */

class VideoEditorScreen extends StatefulWidget {
  final MediaItem mediaItem;
  final Function(String editedPath) onSave;

  const VideoEditorScreen({
    super.key,
    required this.mediaItem,
    required this.onSave,
  });

  @override
  State<VideoEditorScreen> createState() => _VideoEditorScreenState();
}

class _VideoEditorScreenState extends State<VideoEditorScreen> {
  late VideoEditorController _controller;
  late final VideoEditorBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = getIt<VideoEditorBloc>();
    _bloc.add(InitializeVideoEditorEvent(filePath: widget.mediaItem.filePath));
    _controller = VideoEditorController.file(
      File(widget.mediaItem.filePath),
      minDuration: const Duration(seconds: 1),
      maxDuration: const Duration(minutes: 5),
    )..initialize().then((_) => _bloc.add(const VideoEditorReadyEvent()));
  }

  @override
  void dispose() {
    _controller.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocListener<VideoEditorBloc, VideoEditorState>(
        listener: (context, state) {
          if (state is VideoEditorExportSuccess) {
            widget.onSave(state.filePath);
            if (mounted) Navigator.pop(context);
          } else if (state is VideoEditorError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Export failed')),
            );
          }
        },
        child: BlocBuilder<VideoEditorBloc, VideoEditorState>(
          builder: (context, state) {
            final isExporting = state.isExporting;
            final isReady = state.isInitialized && _controller.initialized;

            return Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.black,
                title: const Text(
                  'Edit Video',
                  style: TextStyle(color: Colors.white),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: isExporting
                        ? null
                        : () {
                            context.read<VideoEditorBloc>().add(
                              ExportVideoEvent(
                                filePath: widget.mediaItem.filePath,
                              ),
                            );
                          },
                  ),
                ],
              ),
              body: isReady
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        Column(
                          children: [
                            Expanded(
                              child: CropGridViewer.preview(
                                controller: _controller,
                              ),
                            ),
                            _buildTrimTimeline(),
                          ],
                        ),
                        if (isExporting)
                          Container(
                            color: Colors.black54,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.orange,
                              ),
                            ),
                          ),
                      ],
                    )
                  : const Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTrimTimeline() {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TrimSlider(
            controller: _controller,
            height: 60,
            horizontalMargin: 20,
            child: TrimTimeline(
              controller: _controller,
              padding: EdgeInsets.only(top: 10.h),
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  _controller.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: () {
                  setState(() {
                    _controller.isPlaying
                        ? _controller.video.pause()
                        : _controller.video.play();
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
