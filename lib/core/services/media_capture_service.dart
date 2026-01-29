import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import './permission_handler_service.dart';

/// Service for capturing media (photos, videos, audio)
class MediaCaptureService {
  static final MediaCaptureService _instance = MediaCaptureService._internal();
  final ImagePicker _imagePicker = ImagePicker();
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

      // Mock: In real app, use record package
      // For now, just return success
      return true;
    } catch (e) {
      print('Error starting audio recording: $e');
      return false;
    }
  }

  /// Stop audio recording and return file path
  Future<String?> stopAudioRecording() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath =
          '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
      // Mock: In real app, would be set by record package
      return filePath;
    } catch (e) {
      print('Error stopping audio recording: $e');
    }
    return null;
  }

  /// Check if currently recording
  Future<bool> isRecording() async {
    try {
      // Mock implementation
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Pause audio recording
  Future<void> pauseAudioRecording() async {
    try {
      // Mock implementation
    } catch (e) {
      print('Error pausing audio recording: $e');
    }
  }

  /// Resume audio recording
  Future<void> resumeAudioRecording() async {
    try {
      // Mock implementation
    } catch (e) {
      print('Error resuming audio recording: $e');
    }
  }

  /// Get audio duration in seconds
  Future<int?> getAudioDuration(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        // In a real app, use audio_session or similar to get duration
        // For now, return file size as approximation
        final fileSize = await file.length();
        return (fileSize / 16000).toInt(); // Rough estimate
      }
    } catch (e) {
      print('Error getting audio duration: $e');
    }
    return null;
  }

  /// Cleanup - dispose resources
  Future<void> dispose() async {
    try {
      // Mock implementation
    } catch (e) {
      print('Error disposing media capture service: $e');
    }
  }
}
