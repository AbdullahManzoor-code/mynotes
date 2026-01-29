import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

/// Audio recording metadata
class AudioMetadata {
  final String filePath;
  final String fileName;
  final int fileSize;
  final Duration duration;
  final DateTime createdAt;

  AudioMetadata({
    required this.filePath,
    required this.fileName,
    required this.fileSize,
    required this.duration,
    required this.createdAt,
  });

  String get formattedSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024)
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Audio recording recorder widget
class AudioRecorderWidget extends StatefulWidget {
  final Function(String filePath, Duration duration) onRecordingComplete;
  final VoidCallback? onCancel;

  const AudioRecorderWidget({
    Key? key,
    required this.onRecordingComplete,
    this.onCancel,
  }) : super(key: key);

  @override
  State<AudioRecorderWidget> createState() => _AudioRecorderWidgetState();
}

class _AudioRecorderWidgetState extends State<AudioRecorderWidget> {
  bool _isRecording = false;
  bool _isPaused = false;
  Duration _recordingDuration = Duration.zero;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(Duration.zero, () {});
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _isPaused = false;
      _recordingDuration = Duration.zero;
    });

    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        _recordingDuration = Duration(
          milliseconds: _recordingDuration.inMilliseconds + 100,
        );
      });
    });
  }

  void _pauseRecording() {
    setState(() {
      _isPaused = true;
    });
    _timer.cancel();
  }

  void _resumeRecording() {
    setState(() {
      _isPaused = false;
    });

    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        _recordingDuration = Duration(
          milliseconds: _recordingDuration.inMilliseconds + 100,
        );
      });
    });
  }

  void _stopRecording() {
    _timer.cancel();

    // Generate a mock file path (in real implementation, this would be the actual recording file)
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = '/tmp/audio_$timestamp.m4a';

    widget.onRecordingComplete(filePath, _recordingDuration);

    setState(() {
      _isRecording = false;
      _isPaused = false;
      _recordingDuration = Duration.zero;
    });
  }

  void _cancel() {
    _timer.cancel();
    setState(() {
      _isRecording = false;
      _isPaused = false;
      _recordingDuration = Duration.zero;
    });
    widget.onCancel?.call();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Recording indicator
            if (_isRecording)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text('Recording...', style: TextStyle(color: Colors.red)),
                ],
              )
            else
              Text(
                'Audio Recording',
                style: Theme.of(context).textTheme.titleMedium,
              ),

            SizedBox(height: 24),

            // Duration display
            Text(
              _formatDuration(_recordingDuration),
              style: Theme.of(context).textTheme.headlineMedium,
            ),

            SizedBox(height: 24),

            // Waveform visualization (simplified)
            if (_isRecording)
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: List.generate(
                    20,
                    (index) => Container(
                      width: 2,
                      height: 20 + (index % 5) * 8,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                ),
              ),

            SizedBox(height: 24),

            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Cancel button
                if (_isRecording)
                  FloatingActionButton.small(
                    onPressed: _cancel,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.close),
                  ),

                // Record/Pause button
                if (!_isRecording)
                  FloatingActionButton(
                    onPressed: _startRecording,
                    child: Icon(Icons.mic),
                  )
                else if (!_isPaused)
                  FloatingActionButton.small(
                    onPressed: _pauseRecording,
                    child: Icon(Icons.pause),
                  )
                else
                  FloatingActionButton.small(
                    onPressed: _resumeRecording,
                    child: Icon(Icons.play_arrow),
                  ),

                // Stop button
                if (_isRecording)
                  FloatingActionButton.small(
                    onPressed: _stopRecording,
                    backgroundColor: Colors.green,
                    child: Icon(Icons.check),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Audio playback widget
class AudioPlayerWidget extends StatefulWidget {
  final AudioMetadata audio;
  final VoidCallback? onDelete;

  const AudioPlayerWidget({Key? key, required this.audio, this.onDelete})
    : super(key: key);

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  bool _isPlaying = false;
  late Duration _currentPosition;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _currentPosition = Duration.zero;
    _timer = Timer(Duration.zero, () {});
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });

    if (_isPlaying) {
      _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
        setState(() {
          final newPosition = Duration(
            milliseconds: _currentPosition.inMilliseconds + 100,
          );
          if (newPosition <= widget.audio.duration) {
            _currentPosition = newPosition;
          } else {
            _timer.cancel();
            _isPlaying = false;
            _currentPosition = Duration.zero;
          }
        });
      });
    } else {
      _timer.cancel();
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with filename and delete
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.audio.fileName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.audio.formattedSize,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (widget.onDelete != null)
                  IconButton(
                    icon: Icon(Icons.delete_outline),
                    onPressed: widget.onDelete,
                  ),
              ],
            ),

            SizedBox(height: 12),

            // Play controls and progress
            Row(
              children: [
                IconButton(
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: _togglePlayPause,
                ),
                Expanded(
                  child: Column(
                    children: [
                      SliderTheme(
                        data: SliderThemeData(trackHeight: 4),
                        child: Slider(
                          value: _currentPosition.inMilliseconds.toDouble(),
                          max: widget.audio.duration.inMilliseconds.toDouble(),
                          onChanged: (value) {
                            setState(() {
                              _currentPosition = Duration(
                                milliseconds: value.toInt(),
                              );
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(_currentPosition),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              _formatDuration(widget.audio.duration),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Audio attachments list
class AudioAttachmentsList extends StatelessWidget {
  final List<AudioMetadata> audios;
  final Function(int) onAudioDelete;

  const AudioAttachmentsList({
    Key? key,
    required this.audios,
    required this.onAudioDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (audios.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Audio Attachments',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: audios.length,
          separatorBuilder: (_, __) => SizedBox(height: 8),
          itemBuilder: (context, index) {
            return AudioPlayerWidget(
              audio: audios[index],
              onDelete: () => onAudioDelete(index),
            );
          },
        ),
      ],
    );
  }
}
