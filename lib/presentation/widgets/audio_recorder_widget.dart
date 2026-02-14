import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import '../../core/services/audio_recorder_service.dart';
import '../design_system/design_system.dart';
import '../design_system/components/layouts/glass_container.dart';
// import '../design_system/components/animations/app_animations.dart';
import 'dart:async';
import 'dart:ui' as ui;

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
    if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    }
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
    super.key,
    required this.onRecordingComplete,
    this.onCancel,
  });

  @override
  State<AudioRecorderWidget> createState() => _AudioRecorderWidgetState();
}

class _AudioRecorderWidgetState extends State<AudioRecorderWidget>
    with SingleTickerProviderStateMixin {
  final AudioRecorderService _recorderService = GetIt.I<AudioRecorderService>();
  bool _isRecording = false;
  Duration _recordingDuration = Duration.zero;
  Timer? _timer;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final hasPermission = await _recorderService.checkPermission();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission denied')),
        );
      }
      return;
    }

    await _recorderService.startRecording();
    HapticFeedback.mediumImpact();

    setState(() {
      _isRecording = true;
      _recordingDuration = Duration.zero;
    });

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _recordingDuration = Duration(
          milliseconds: _recordingDuration.inMilliseconds + 100,
        );
      });
    });
  }

  Future<void> _stopRecording() async {
    final path = await _recorderService.stopRecording();
    _timer?.cancel();
    HapticFeedback.lightImpact();

    if (path != null) {
      widget.onRecordingComplete(path, _recordingDuration);
    }

    setState(() {
      _isRecording = false;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 24.r,
      blur: 20,
      color: AppColors.surface(context).withOpacity(0.95),
      padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 40.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.only(bottom: 24.h),
            decoration: BoxDecoration(
              color: AppColors.textSecondary(context).withOpacity(0.2),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          Text(
            _isRecording ? 'Recording...' : 'Audio Recorder',
            style: AppTypography.heading3(context).copyWith(
              color: _isRecording
                  ? Colors.red.shade400
                  : AppColors.textPrimary(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 32.h),
          Stack(
            alignment: Alignment.center,
            children: [
              if (_isRecording)
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Container(
                      width: 140.w + (20 * _animationController.value),
                      height: 140.w + (20 * _animationController.value),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red.withOpacity(
                          0.1 * (1 - _animationController.value),
                        ),
                      ),
                    );
                  },
                ),
              Text(
                _formatDuration(_recordingDuration),
                style: AppTypography.heading1(context).copyWith(
                  fontSize: 56.sp,
                  fontWeight: FontWeight.w300,
                  letterSpacing: -1,
                  fontFeatures: [const ui.FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          SizedBox(height: 48.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlCircle(
                icon: Icons.close_rounded,
                color: AppColors.textSecondary(context).withOpacity(0.1),
                iconColor: AppColors.textPrimary(context),
                onTap: () {
                  if (_isRecording) _recorderService.stopRecording();
                  widget.onCancel?.call();
                },
              ),
              GestureDetector(
                onTap: _isRecording ? _stopRecording : _startRecording,
                child: Container(
                  width: 84.w,
                  height: 84.w,
                  decoration: BoxDecoration(
                    color: _isRecording ? Colors.red : AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (_isRecording ? Colors.red : AppColors.primary)
                            .withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                      color: Colors.white,
                      size: 36.sp,
                    ),
                  ),
                ),
              ),
              _buildControlCircle(
                icon: Icons.check_rounded,
                color: _isRecording
                    ? Colors.green.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                iconColor: _isRecording ? Colors.green : Colors.grey,
                onTap: _isRecording ? _stopRecording : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlCircle({
    required IconData icon,
    required Color color,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: () {
        if (onTap != null) {
          HapticFeedback.lightImpact();
          onTap();
        }
      },
      borderRadius: BorderRadius.circular(30.r),
      child: Container(
        width: 52.w,
        height: 52.w,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 24.sp),
      ),
    );
  }
}

/// Audio playback widget using audioplayers
class AudioPlayerWidget extends StatefulWidget {
  final AudioMetadata audio;
  final VoidCallback? onDelete;

  const AudioPlayerWidget({super.key, required this.audio, this.onDelete});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _totalDuration = widget.audio.duration;

    _audioPlayer.onPositionChanged.listen((p) {
      if (mounted) setState(() => _currentPosition = p);
    });

    _audioPlayer.onDurationChanged.listen((d) {
      if (mounted) setState(() => _totalDuration = d);
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _currentPosition = Duration.zero;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _togglePlayPause() async {
    HapticFeedback.lightImpact();
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        final file = File(widget.audio.filePath);
        if (!await file.exists()) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Audio file not found')),
            );
          }
          return;
        }
        await _audioPlayer.play(DeviceFileSource(widget.audio.filePath));
      }
      if (mounted) setState(() => _isPlaying = !_isPlaying);
    } catch (e) {
      debugPrint('Error playing audio: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Playback failed: $e')));
      }
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      borderRadius: 16.r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildPlayButton(),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.audio.fileName,
                      style: AppTypography.heading4(
                        context,
                      ).copyWith(fontSize: 14.sp, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${widget.audio.formattedSize} • ${_formatDuration(_totalDuration)}',
                      style: AppTypography.bodySmall(context),
                    ),
                  ],
                ),
              ),
              if (widget.onDelete != null)
                IconButton(
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red.withOpacity(0.7),
                    size: 22.sp,
                  ),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    widget.onDelete!();
                  },
                ),
            ],
          ),
          SizedBox(height: 8.h),
          Theme(
            data: Theme.of(context).copyWith(
              sliderTheme: SliderThemeData(
                trackHeight: 2.h,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.r),
                overlayShape: RoundSliderOverlayShape(overlayRadius: 14.r),
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: AppColors.textSecondary(
                  context,
                ).withOpacity(0.1),
                thumbColor: AppColors.primary,
              ),
            ),
            child: Slider(
              value: _currentPosition.inMilliseconds.toDouble(),
              max: _totalDuration.inMilliseconds.toDouble() > 0
                  ? _totalDuration.inMilliseconds.toDouble()
                  : 1.0,
              onChanged: (value) async {
                await _audioPlayer.seek(Duration(milliseconds: value.toInt()));
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(_currentPosition),
                  style: AppTypography.bodySmall(
                    context,
                  ).copyWith(fontSize: 10.sp),
                ),
                Text(
                  _formatDuration(_totalDuration),
                  style: AppTypography.bodySmall(
                    context,
                  ).copyWith(fontSize: 10.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayButton() {
    return GestureDetector(
      onTap: _togglePlayPause,
      child: Container(
        width: 44.w,
        height: 44.w,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: AppColors.primary,
          size: 28.sp,
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
    super.key,
    required this.audios,
    required this.onAudioDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (audios.isEmpty) {
      return const SizedBox.shrink();
    }

    return AppAnimations.tapScale(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4.w, bottom: 8.h, top: 16.h),
            child: Text(
              'Audio Notes',
              style: AppTypography.heading4(context).copyWith(
                color: AppColors.textSecondary(context),
                letterSpacing: 0.5,
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: audios.length,
            itemBuilder: (context, index) {
              return AudioPlayerWidget(
                audio: audios[index],
                onDelete: () => onAudioDelete(index),
              );
            },
          ),
        ],
      ),
    );
  }
}
