import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/injection_container.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../bloc/audio_recorder/audio_recorder_bloc.dart';
import '../design_system/design_system.dart' hide TextButton;

/// Audio Recorder Screen
/// Records voice notes with waveform visualization
/// Refactored to use BLoC for state management
class AudioRecorderScreen extends StatefulWidget {
  final String? noteId;

  const AudioRecorderScreen({super.key, this.noteId});

  @override
  State<AudioRecorderScreen> createState() => _AudioRecorderScreenState();
}

class _AudioRecorderScreenState extends State<AudioRecorderScreen>
    with TickerProviderStateMixin {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  late AnimationController _pulseController;
  late AnimationController _waveController;
  Timer? _waveformTimer;

  static const int maxDurationSeconds = 60;

  @override
  void initState() {
    super.initState();
    AppLogger.i('AudioRecorderScreen: Initialized');
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..repeat();

    _initializeRecorder();
    _setupAudioPlayerListeners();
  }

  @override
  void dispose() {
    AppLogger.i('AudioRecorderScreen: Disposed');
    _waveformTimer?.cancel();
    _pulseController.dispose();
    _waveController.dispose();
    _recorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _initializeRecorder() async {
    AppLogger.i('AudioRecorderScreen: Requesting microphone permissions');
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      AppLogger.w('AudioRecorderScreen: Microphone permission denied');
      getIt<GlobalUiService>().showError('Microphone permission is required');
    } else {
      AppLogger.i('AudioRecorderScreen: Microphone permission granted');
    }
  }

  void _setupAudioPlayerListeners() {
    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted && context.mounted) {
        final state = context.read<AudioRecorderBloc>().state;
        context.read<AudioRecorderBloc>().add(
          UpdatePlaybackPosition(position, state.totalDuration),
        );
      }
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted && context.mounted) {
        final state = context.read<AudioRecorderBloc>().state;
        context.read<AudioRecorderBloc>().add(
          UpdatePlaybackPosition(state.playbackDuration, duration),
        );
      }
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted && context.mounted) {
        AppLogger.i('AudioRecorderScreen: Playback completed');
        context.read<AudioRecorderBloc>().add(PlaybackCompleted());
      }
    });
  }

  Future<void> _startRecording() async {
    AppLogger.i('AudioRecorderScreen: _startRecording called');
    try {
      if (await _recorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final path =
            '${dir.path}/voice_note_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: path,
        );

        if (context.mounted) {
          AppLogger.i('AudioRecorderScreen: Recording started at $path');
          context.read<AudioRecorderBloc>().add(StartRecording());
          _startWaveformSimulation();
        }
      } else {
        AppLogger.w('AudioRecorderScreen: Recording failed - No permission');
      }
    } catch (e) {
      AppLogger.e('AudioRecorderScreen: Failed to start recording', e);
      getIt<GlobalUiService>().showError('Failed to start recording: $e');
    }
  }

  void _startWaveformSimulation() {
    _waveformTimer?.cancel();
    _waveformTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final state = context.read<AudioRecorderBloc>().state;
      if (!state.isRecording || state.isPaused) {
        timer.cancel();
        return;
      }

      if (mounted && context.mounted) {
        context.read<AudioRecorderBloc>().add(
          UpdateWaveform(math.Random().nextDouble() * 0.8 + 0.2),
        );
      }
    });
  }

  Future<void> _pauseRecording() async {
    AppLogger.i('AudioRecorderScreen: _pauseRecording called');
    await _recorder.pause();
    if (context.mounted) {
      context.read<AudioRecorderBloc>().add(PauseRecording());
    }
  }

  Future<void> _resumeRecording() async {
    AppLogger.i('AudioRecorderScreen: _resumeRecording called');
    await _recorder.resume();
    if (context.mounted) {
      context.read<AudioRecorderBloc>().add(ResumeRecording());
      _startWaveformSimulation();
    }
  }

  Future<void> _stopRecording() async {
    AppLogger.i('AudioRecorderScreen: _stopRecording called');
    _waveformTimer?.cancel();
    final path = await _recorder.stop();
    if (context.mounted) {
      AppLogger.i('AudioRecorderScreen: Recording stopped. Path: $path');
      context.read<AudioRecorderBloc>().add(StopRecording());
    }
  }

  Future<void> _playRecording() async {
    final state = context.read<AudioRecorderBloc>().state;
    if (state.recordingPath == null) {
      AppLogger.w(
        'AudioRecorderScreen: _playRecording called but no recordingPath',
      );
      return;
    }

    if (state.isPlaying) {
      AppLogger.i('AudioRecorderScreen: Pausing playback');
      await _audioPlayer.pause();
      if (context.mounted) {
        context.read<AudioRecorderBloc>().add(PausePlayback());
      }
    } else {
      AppLogger.i(
        'AudioRecorderScreen: Starting playback for ${state.recordingPath}',
      );
      await _audioPlayer.play(DeviceFileSource(state.recordingPath!));
      if (context.mounted) {
        context.read<AudioRecorderBloc>().add(PlayRecording());
      }
    }
  }

  void _discardRecording() {
    AppLogger.i('AudioRecorderScreen: _discardRecording dialog shown');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard recording?'),
        content: const Text('This recording will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () {
              AppLogger.i('AudioRecorderScreen: Discard cancelled');
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              AppLogger.i('AudioRecorderScreen: Discard confirmed');
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Discard', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _saveRecording() {
    final state = context.read<AudioRecorderBloc>().state;
    AppLogger.i(
      'AudioRecorderScreen: _saveRecording called. Path: ${state.recordingPath}',
    );
    if (state.recordingPath != null) {
      Navigator.pop(context, {
        'audioPath': state.recordingPath,
        'duration': state.recordingDuration.inSeconds,
      });
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.i('AudioRecorderScreen: Building UI');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<AudioRecorderBloc, AudioRecorderState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background(context),
          appBar: AppBar(
            backgroundColor: AppColors.background(context),
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.close, color: AppColors.textPrimary(context)),
              onPressed: () {
                AppLogger.i('AudioRecorderScreen: Close button pressed');
                if (state.hasRecording || state.isRecording) {
                  _discardRecording();
                } else {
                  Navigator.pop(context);
                }
              },
            ),
            title: Text(
              'Voice Note',
              style: AppTypography.bodyLarge(
                context,
                AppColors.textPrimary(context),
                FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              if (state.hasRecording && !state.isRecording)
                TextButton(
                  onPressed: () {
                    AppLogger.i('AudioRecorderScreen: Save button pressed');
                    _saveRecording();
                  },
                  child: Text(
                    'Save',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Timer display
                      Text(
                        _formatDuration(
                          state.isRecording
                              ? state.recordingDuration
                              : state.playbackDuration,
                        ),
                        style: TextStyle(
                          fontSize: 64.sp,
                          fontWeight: FontWeight.w200,
                          color: AppColors.textPrimary(context),
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: 8.h),

                      // Status text
                      Text(
                        state.isRecording
                            ? (state.isPaused ? 'Paused' : 'Recording...')
                            : (state.hasRecording
                                  ? (state.isPlaying
                                        ? 'Playing'
                                        : 'Ready to save')
                                  : 'Tap to record'),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: state.isRecording && !state.isPaused
                              ? AppColors.error
                              : AppColors.textSecondary(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 48.h),

                      // Waveform visualization
                      SizedBox(
                        height: 100.h,
                        child: state.isRecording
                            ? _buildWaveform(state.waveformData)
                            : (state.hasRecording
                                  ? _buildPlaybackProgress(
                                      state.playbackDuration,
                                      state.totalDuration,
                                    )
                                  : _buildIdleWaveform(isDark)),
                      ),
                      SizedBox(height: 48.h),

                      // Max duration indicator
                      if (state.isRecording)
                        Text(
                          'Max ${maxDurationSeconds ~/ 60}:${(maxDurationSeconds % 60).toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                    ],
                  ),
                ),

                // Controls
                Padding(
                  padding: EdgeInsets.all(32.w),
                  child: _buildControls(isDark, state),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWaveform(List<double> waveformData) {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return CustomPaint(
          size: Size(double.infinity, 100.h),
          painter: _WaveformPainter(
            data: waveformData,
            color: AppColors.primary,
          ),
        );
      },
    );
  }

  Widget _buildIdleWaveform(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(30, (index) {
        return Container(
          width: 3.w,
          height: 20.h,
          margin: EdgeInsets.symmetric(horizontal: 1.w),
          decoration: BoxDecoration(
            color: AppColors.textSecondary(context).withOpacity(0.3),
            borderRadius: BorderRadius.circular(2.r),
          ),
        );
      }),
    );
  }

  Widget _buildPlaybackProgress(
    Duration playbackDuration,
    Duration totalDuration,
  ) {
    final progress = totalDuration.inMilliseconds > 0
        ? playbackDuration.inMilliseconds / totalDuration.inMilliseconds
        : 0.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.textSecondary(context).withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 4.h,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 32.w),
              child: Text(
                _formatDuration(playbackDuration),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary(context),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 32.w),
              child: Text(
                _formatDuration(totalDuration),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary(context),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildControls(bool isDark, AudioRecorderState state) {
    if (state.hasRecording && !state.isRecording) {
      // Playback controls
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Re-record button
          GestureDetector(
            onTap: () {
              AppLogger.i('AudioRecorderScreen: Re-record button pressed');
              context.read<AudioRecorderBloc>().add(ResetRecording());
            },
            child: Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border(context)),
              ),
              child: Icon(
                Icons.refresh,
                color: AppColors.textSecondary(context),
                size: 24.sp,
              ),
            ),
          ),
          SizedBox(width: 24.w),

          // Play/Pause button
          GestureDetector(
            onTap: () {
              AppLogger.i('AudioRecorderScreen: Playback control tapped');
              _playRecording();
            },
            child: Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                state.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 40.sp,
              ),
            ),
          ),
          SizedBox(width: 24.w),

          // Delete button
          GestureDetector(
            onTap: () {
              AppLogger.i(
                'AudioRecorderScreen: Discard recording button pressed',
              );
              _discardRecording();
            },
            child: Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_outline,
                color: AppColors.error,
                size: 24.sp,
              ),
            ),
          ),
        ],
      );
    }

    // Recording controls
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (state.isRecording) ...[
          // Stop button
          GestureDetector(
            onTap: () {
              AppLogger.i('AudioRecorderScreen: Stop recording button pressed');
              _stopRecording();
            },
            child: Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border(context)),
              ),
              child: Icon(Icons.stop, color: AppColors.error, size: 24.sp),
            ),
          ),
          SizedBox(width: 24.w),
        ],

        // Record/Pause button
        GestureDetector(
          onTap: () {
            if (state.isRecording) {
              if (state.isPaused) {
                AppLogger.i('AudioRecorderScreen: Resume recording tapped');
                _resumeRecording();
              } else {
                AppLogger.i('AudioRecorderScreen: Pause recording tapped');
                _pauseRecording();
              }
            } else {
              AppLogger.i('AudioRecorderScreen: Start recording tapped');
              _startRecording();
            }
          },
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final scale = state.isRecording && !state.isPaused
                  ? 1.0 + (_pulseController.value * 0.1)
                  : 1.0;

              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    color: state.isRecording
                        ? AppColors.error
                        : AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            (state.isRecording
                                    ? AppColors.error
                                    : AppColors.primary)
                                .withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    state.isRecording
                        ? (state.isPaused ? Icons.play_arrow : Icons.pause)
                        : Icons.mic,
                    color: Colors.white,
                    size: 40.sp,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final List<double> data;
  final Color color;

  _WaveformPainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final barWidth = size.width / (data.length * 2);
    final centerY = size.height / 2;

    for (int i = 0; i < data.length; i++) {
      final x = i * barWidth * 2 + barWidth;
      final amplitude = data[i] * centerY * 0.8;

      canvas.drawLine(
        Offset(x, centerY - amplitude),
        Offset(x, centerY + amplitude),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter oldDelegate) => true;
}


