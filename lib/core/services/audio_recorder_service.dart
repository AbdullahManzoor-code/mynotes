import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

/// Service for audio recording functionality using the 'record' package
class AudioRecorderService {
  final AudioRecorder _audioRecorder = AudioRecorder();

  /// Check and request microphone permission
  Future<bool> checkPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// Start recording to a local file
  Future<void> startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final path =
            '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

        const config = RecordConfig(); // Default configuration

        // Start recording to file
        await _audioRecorder.start(config, path: path);
      }
    } catch (e) {
      print('Error starting recording: $e');
    }
  }

  /// Stop recording and return the file path
  Future<String?> stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      return path;
    } catch (e) {
      print('Error stopping recording: $e');
      return null;
    }
  }

  /// Pause recording
  Future<void> pauseRecording() async {
    await _audioRecorder.pause();
  }

  /// Resume recording
  Future<void> resumeRecording() async {
    await _audioRecorder.resume();
  }

  /// Check if currently recording
  Future<bool> isRecording() async {
    return await _audioRecorder.isRecording();
  }

  /// Dispose the recorder
  void dispose() {
    _audioRecorder.dispose();
  }
}
