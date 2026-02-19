import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../design_system/app_colors.dart';
import '../bloc/audio_playback/audio_playback_bloc.dart';
import '../bloc/audio_playback/audio_playback_event.dart';
import '../bloc/audio_playback/audio_playback_state.dart';

/// WhatsApp-style voice message widget with animated waveform
/// Uses AudioPlaybackBloc for state management
class VoiceMessageWidget extends StatefulWidget {
  final String audioPath;
  final Duration? duration;
  final bool isSent; // true = sent by user, false = received
  final VoidCallback? onDelete;

  const VoiceMessageWidget({
    super.key,
    required this.audioPath,
    this.duration,
    this.isSent = true,
    this.onDelete,
  });

  @override
  State<VoiceMessageWidget> createState() => _VoiceMessageWidgetState();
}

class _VoiceMessageWidgetState extends State<VoiceMessageWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;
  late AudioPlaybackBloc _audioBloc;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _audioBloc = AudioPlaybackBloc();
    _audioBloc.add(
      InitializeAudioEvent(
        audioPath: widget.audioPath,
        initialDuration: widget.duration,
      ),
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    _audioBloc.add(const DisposeAudioEvent());
    _audioBloc.close();
    super.dispose();
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
        : (isDark ? AppColors.darkCardBackground : AppColors.lightBackground);

    return GestureDetector(
      onLongPress: widget.onDelete,
      child: BlocProvider<AudioPlaybackBloc>.value(
        value: _audioBloc,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: BlocBuilder<AudioPlaybackBloc, AudioPlaybackState>(
            bloc: _audioBloc,
            builder: (context, state) {
              final isPlaying = state.isPlaying;
              final currentPosition = state.position;
              final totalDuration = state.duration;

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Play/Pause button
                  GestureDetector(
                    onTap: () {
                      if (isPlaying) {
                        _audioBloc.add(const PauseAudioEvent());
                      } else {
                        _audioBloc.add(const PlayAudioEvent());
                      }
                    },
                    child: Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.isSent
                            ? AppColors.primaryColor
                            : (isDark
                                  ? AppColors.darkCardBackgroundAlt
                                  : AppColors.grey400),
                      ),
                      child: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: AppColors.lightText,
                        size: 20.sp,
                      ),
                    ),
                  ),

                  SizedBox(width: 8.w),

                  // Waveform visualization
                  Expanded(
                    child: isPlaying
                        ? _buildAnimatedWaveform(
                            currentPosition,
                            totalDuration,
                            isDark,
                          )
                        : _buildStaticWaveform(isDark),
                  ),

                  SizedBox(width: 8.w),

                  // Duration
                  Text(
                    isPlaying
                        ? _formatDuration(currentPosition)
                        : _formatDuration(totalDuration),
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: isDark
                          ? AppColors.secondaryTextDark
                          : AppColors.secondaryText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedWaveform(
    Duration position,
    Duration duration,
    bool isDark,
  ) {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return CustomPaint(
          size: Size(double.infinity, 30.h),
          painter: WaveformPainter(
            progress: duration.inMilliseconds > 0
                ? position.inMilliseconds / duration.inMilliseconds
                : 0.0,
            animationValue: _waveController.value,
            color: widget.isSent
                ? AppColors.primaryColor
                : (isDark ? AppColors.grey500 : AppColors.grey400),
            isAnimating: true,
          ),
        );
      },
    );
  }

  Widget _buildStaticWaveform(bool isDark) {
    return CustomPaint(
      size: Size(double.infinity, 30.h),
      painter: WaveformPainter(
        progress: 0.0,
        animationValue: 0.5,
        color: widget.isSent
            ? AppColors.primaryColor.withOpacity(0.6)
            : (isDark ? AppColors.grey500 : AppColors.grey400),
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
