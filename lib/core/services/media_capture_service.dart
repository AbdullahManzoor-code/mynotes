import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import './permission_handler_service.dart';

/// Service for capturing media (photos, videos, audio)
class MediaCaptureService {
  static final MediaCaptureService _instance = MediaCaptureService._internal();
  final ImagePicker _imagePicker = ImagePicker();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final PermissionHandlerService _permissionService =
      PermissionHandlerService();

  MediaCaptureService._internal();

  factory MediaCaptureService() {
    return _instance;
  }

  /// Capture photo from camera
  Future<String?> capturePhoto() async {
    try {
      final hasPermission = await _permissionService.requestCameraPermission();
      if (!hasPermission) {
        return null;
      }

      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (pickedFile != null) {
        return pickedFile.path;
      }
    } catch (e) {
      print('Error capturing photo: $e');
    }
    return null;
  }

  /// Pick photo from gallery
  Future<String?> pickPhotoFromGallery() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        return pickedFile.path;
      }
    } catch (e) {
      print('Error picking photo: $e');
    }
    return null;
  }

  /// Capture video from camera
  Future<String?> captureVideo() async {
    try {
      final hasPermission = await _permissionService.requestCameraPermission();
      if (!hasPermission) {
        return null;
      }

      final pickedFile = await _imagePicker.pickVideo(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        maxDuration: const Duration(minutes: 10),
      );

      if (pickedFile != null) {
        return pickedFile.path;
      }
    } catch (e) {
      print('Error capturing video: $e');
    }
    return null;
  }

  /// Pick video from gallery
  Future<String?> pickVideoFromGallery() async {
    try {
      final pickedFile = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 30),
      );

      if (pickedFile != null) {
        return pickedFile.path;
      }
    } catch (e) {
      print('Error picking video: $e');
    }
    return null;
  }

  /// Start audio recording
  Future<bool> startAudioRecording(String fileName) async {
    try {
      final hasPermission = await _permissionService
          .requestMicrophonePermission();
      if (!hasPermission) {
        return false;
      }

      if (await _audioRecorder.isRecording()) {
        return false;
      }

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';

      const config = RecordConfig(); // Default config: AAC, 44.1kHz, etc.

      await _audioRecorder.start(config, path: filePath);
      return true;
    } catch (e) {
      print('Error starting audio recording: $e');
      return false;
    }
  }

  /// Stop audio recording and return file path
  Future<String?> stopAudioRecording() async {
    try {
      final path = await _audioRecorder.stop();
      return path;
    } catch (e) {
      print('Error stopping audio recording: $e');
    }
    return null;
  }

  /// Check if currently recording
  Future<bool> isRecording() async {
    try {
      return await _audioRecorder.isRecording();
    } catch (e) {
      return false;
    }
  }

  /// Pause audio recording
  Future<void> pauseAudioRecording() async {
    try {
      await _audioRecorder.pause();
    } catch (e) {
      print('Error pausing audio recording: $e');
    }
  }

  /// Resume audio recording
  Future<void> resumeAudioRecording() async {
    try {
      await _audioRecorder.resume();
    } catch (e) {
      print('Error resuming audio recording: $e');
    }
  }

  /// Get audio duration in seconds
  Future<int?> getAudioDuration(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        // Ideally we'd use a package like 'audioplayers' or 'just_audio' to read metadata
        // For now, we'll keep the estimate or use the player if available elsewhere
        final fileSize = await file.length();
        return (fileSize / 16000)
            .toInt(); // Still a rough estimate without decoding metadata
      }
    } catch (e) {
      print('Error getting audio duration: $e');
    }
    return null;
  }

  /// Cleanup - dispose resources
  Future<void> dispose() async {
    try {
      await _audioRecorder.dispose();
    } catch (e) {
      print('Error disposing media capture service: $e');
    }
  }
}
