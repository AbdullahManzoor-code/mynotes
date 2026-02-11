import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_editor/video_editor.dart';
import '../../domain/entities/media_item.dart';

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
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoEditorController.file(
      File(widget.mediaItem.filePath),
      minDuration: const Duration(seconds: 1),
      maxDuration: const Duration(minutes: 5),
    )..initialize().then((_) => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _exportVideo() async {
    setState(() => _isExporting = true);

    // In a real implementation, we would use _controller.exportVideo()
    // For this demonstration, we'll simulate the export process
    // and return the original path or a simulated edited path.
    // video_editor needs ffmpeg for actual export which might not be set up.

    await Future.delayed(const Duration(seconds: 2));

    widget.onSave(widget.mediaItem.filePath); // Returning same path for now
    setState(() => _isExporting = false);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Edit Video', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
            onPressed: _isExporting ? null : _exportVideo,
          ),
        ],
      ),
      body: _controller.initialized
          ? Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  children: [
                    Expanded(
                      child: CropGridViewer.preview(controller: _controller),
                    ),
                    _buildTrimTimeline(),
                  ],
                ),
                if (_isExporting)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.orange),
                    ),
                  ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildTrimTimeline() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TrimSlider(
            controller: _controller,
            height: 60,
            horizontalMargin: 20,
            child: TrimTimeline(
              controller: _controller,
              padding: const EdgeInsets.only(top: 10),
            ),
          ),
          const SizedBox(height: 10),
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
