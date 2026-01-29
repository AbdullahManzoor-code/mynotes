import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../design_system/design_system.dart';

/// Audio Recorder Screen
/// Records voice notes with waveform visualization
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

  bool _isRecording = false;
  bool _isPaused = false;
  bool _hasRecording = false;
  bool _isPlaying = false;
  String? _recordingPath;

  Duration _recordingDuration = Duration.zero;
  Duration _playbackDuration = Duration.zero;
  Duration _totalDuration = Duration.zero;
  Timer? _timer;

  late AnimationController _pulseController;
  late AnimationController _waveController;
  List<double> _waveformData = [];

  static const int maxDurationSeconds = 60;

  @override
  void initState() {
    super.initState();
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
    _timer?.cancel();
    _pulseController.dispose();
    _waveController.dispose();
    _recorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _initializeRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Microphone permission is required'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _setupAudioPlayerListeners() {
    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _playbackDuration = position;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _totalDuration = duration;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _playbackDuration = Duration.zero;
        });
      }
    });
  }

  Future<void> _startRecording() async {
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

        setState(() {
          _isRecording = true;
          _isPaused = false;
          _hasRecording = false;
          _recordingPath = path;
          _recordingDuration = Duration.zero;
          _waveformData = [];
        });

        _startTimer();
        _startWaveformSimulation();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to start recording: $e')));
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isRecording && !_isPaused) {
        setState(() {
          _recordingDuration += const Duration(seconds: 1);
        });

        // Auto-stop at max duration
        if (_recordingDuration.inSeconds >= maxDurationSeconds) {
          _stopRecording();
        }
      }
    });
  }

  void _startWaveformSimulation() {
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_isRecording || _isPaused) {
        timer.cancel();
        return;
      }

      if (mounted) {
        setState(() {
          _waveformData.add(math.Random().nextDouble() * 0.8 + 0.2);
          if (_waveformData.length > 50) {
            _waveformData.removeAt(0);
          }
        });
      }
    });
  }

  Future<void> _pauseRecording() async {
    await _recorder.pause();
    setState(() {
      _isPaused = true;
    });
  }

  Future<void> _resumeRecording() async {
    await _recorder.resume();
    setState(() {
      _isPaused = false;
    });
    _startWaveformSimulation();
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    final path = await _recorder.stop();

    setState(() {
      _isRecording = false;
      _isPaused = false;
      _hasRecording = path != null;
      _recordingPath = path;
    });
  }

  Future<void> _playRecording() async {
    if (_recordingPath == null) return;

    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() {
        _isPlaying = false;
      });
    } else {
      await _audioPlayer.play(DeviceFileSource(_recordingPath!));
      setState(() {
        _isPlaying = true;
      });
    }
  }

  void _discardRecording() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard recording?'),
        content: const Text('This recording will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
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
    if (_recordingPath != null) {
      Navigator.pop(context, {
        'audioPath': _recordingPath,
        'duration': _recordingDuration.inSeconds,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: AppColors.textPrimary(context)),
          onPressed: () {
            if (_hasRecording || _isRecording) {
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
          if (_hasRecording && !_isRecording)
            TextButton(
              onPressed: _saveRecording,
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
                      _isRecording ? _recordingDuration : _playbackDuration,
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
                    _isRecording
                        ? (_isPaused ? 'Paused' : 'Recording...')
                        : (_hasRecording
                              ? (_isPlaying ? 'Playing' : 'Ready to save')
                              : 'Tap to record'),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: _isRecording && !_isPaused
                          ? AppColors.error
                          : AppColors.textSecondary(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 48.h),

                  // Waveform visualization
                  SizedBox(
                    height: 100.h,
                    child: _isRecording
                        ? _buildWaveform()
                        : (_hasRecording
                              ? _buildPlaybackProgress()
                              : _buildIdleWaveform(isDark)),
                  ),
                  SizedBox(height: 48.h),

                  // Max duration indicator
                  if (_isRecording)
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
              child: _buildControls(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaveform() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return CustomPaint(
          size: Size(double.infinity, 100.h),
          painter: _WaveformPainter(
            data: _waveformData,
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

  Widget _buildPlaybackProgress() {
    final progress = _totalDuration.inMilliseconds > 0
        ? _playbackDuration.inMilliseconds / _totalDuration.inMilliseconds
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
                _formatDuration(_playbackDuration),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary(context),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 32.w),
              child: Text(
                _formatDuration(_totalDuration),
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

  Widget _buildControls(bool isDark) {
    if (_hasRecording && !_isRecording) {
      // Playback controls
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Re-record button
          GestureDetector(
            onTap: () {
              setState(() {
                _hasRecording = false;
                _recordingPath = null;
                _playbackDuration = Duration.zero;
              });
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
            onTap: _playRecording,
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
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 40.sp,
              ),
            ),
          ),
          SizedBox(width: 24.w),

          // Delete button
          GestureDetector(
            onTap: _discardRecording,
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
        if (_isRecording) ...[
          // Stop button
          GestureDetector(
            onTap: _stopRecording,
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
          onTap: _isRecording
              ? (_isPaused ? _resumeRecording : _pauseRecording)
              : _startRecording,
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final scale = _isRecording && !_isPaused
                  ? 1.0 + (_pulseController.value * 0.1)
                  : 1.0;

              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    color: _isRecording ? AppColors.error : AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            (_isRecording ? AppColors.error : AppColors.primary)
                                .withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isRecording
                        ? (_isPaused ? Icons.play_arrow : Icons.pause)
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

