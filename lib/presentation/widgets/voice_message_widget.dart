import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../core/constants/app_colors.dart';
import 'dart:async';

/// WhatsApp-style voice message widget with animated waveform
class VoiceMessageWidget extends StatefulWidget {
  final String audioPath;
  final Duration? duration;
  final bool isSent; // true = sent by user, false = received
  final VoidCallback? onDelete;

  const VoiceMessageWidget({
    Key? key,
    required this.audioPath,
    this.duration,
    this.isSent = true,
    this.onDelete,
  }) : super(key: key);

  @override
  State<VoiceMessageWidget> createState() => _VoiceMessageWidgetState();
}

class _VoiceMessageWidgetState extends State<VoiceMessageWidget>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  late AnimationController _waveController;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _completeSubscription;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _totalDuration = widget.duration ?? Duration.zero;
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    _positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() => _currentPosition = position);
      }
    });

    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() => _totalDuration = duration);
      }
    });

    _completeSubscription = _audioPlayer.onPlayerComplete.listen((_) {
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
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _completeSubscription?.cancel();
    _audioPlayer.dispose();
    _waveController.dispose();
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() => _isPlaying = false);
    } else {
      await _audioPlayer.play(DeviceFileSource(widget.audioPath));
      setState(() => _isPlaying = true);
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = widget.isSent
        ? (isDark
              ? AppColors.primaryColor.withOpacity(0.2)
              : AppColors.primaryColor.withOpacity(0.15))
        : (isDark ? Colors.grey.shade800 : Colors.grey.shade200);

    return GestureDetector(
      onLongPress: widget.onDelete,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Play/Pause button
            GestureDetector(
              onTap: _togglePlayback,
              child: Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isSent
                      ? AppColors.primaryColor
                      : (isDark ? Colors.grey.shade700 : Colors.grey.shade400),
                ),
                child: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
            ),

            SizedBox(width: 8.w),

            // Waveform visualization
            Expanded(
              child: _isPlaying
                  ? _buildAnimatedWaveform()
                  : _buildStaticWaveform(),
            ),

            SizedBox(width: 8.w),

            // Duration
            Text(
              _isPlaying
                  ? _formatDuration(_currentPosition)
                  : _formatDuration(_totalDuration),
              style: TextStyle(
                fontSize: 11.sp,
                color: isDark ? Colors.white70 : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedWaveform() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return CustomPaint(
          size: Size(double.infinity, 30.h),
          painter: WaveformPainter(
            progress: _totalDuration.inMilliseconds > 0
                ? _currentPosition.inMilliseconds /
                      _totalDuration.inMilliseconds
                : 0.0,
            animationValue: _waveController.value,
            color: widget.isSent
                ? AppColors.primaryColor
                : (Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade400
                      : Colors.grey.shade600),
            isAnimating: true,
          ),
        );
      },
    );
  }

  Widget _buildStaticWaveform() {
    return CustomPaint(
      size: Size(double.infinity, 30.h),
      painter: WaveformPainter(
        progress: 0.0,
        animationValue: 0.5,
        color: widget.isSent
            ? AppColors.primaryColor.withOpacity(0.6)
            : (Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade500
                  : Colors.grey.shade500),
        isAnimating: false,
      ),
    );
  }
}

/// Custom painter for waveform visualization
class WaveformPainter extends CustomPainter {
  final double progress;
  final double animationValue;
  final Color color;
  final bool isAnimating;

  WaveformPainter({
    required this.progress,
    required this.animationValue,
    required this.color,
    required this.isAnimating,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    const barCount = 30;
    final barWidth = size.width / (barCount * 2 - 1);
    final centerY = size.height / 2;

    for (int i = 0; i < barCount; i++) {
      final x = i * barWidth * 2;

      // Create varied heights for waveform effect
      double heightFactor;
      if (isAnimating) {
        // Animated waveform with variation
        heightFactor =
            0.3 +
            (0.7 * ((i % 3) / 3.0)) +
            (0.3 * animationValue * ((i % 2 == 0) ? 1 : -1));
      } else {
        // Static waveform pattern
        heightFactor = 0.3 + (0.5 * ((i % 4) / 4.0));
      }

      final barHeight = size.height * heightFactor.clamp(0.2, 1.0);

      // Color based on progress
      final isPassed = (i / barCount) <= progress;
      paint.color = isPassed ? color : color.withOpacity(0.3);

      // Draw rounded bar
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(x, centerY),
          width: barWidth * 0.8,
          height: barHeight,
        ),
        Radius.circular(barWidth / 2),
      );

      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.isAnimating != isAnimating;
  }
}
