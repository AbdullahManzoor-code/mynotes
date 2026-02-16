// import 'package:image_picker/image_picker.dart';
// import 'package:mynotes/core/database/core_database.dart';
// import 'package:mynotes/core/database/mappers/media_mapper.dart';
// import 'package:mynotes/core/database/dao/tables_reference.dart';
// import 'package:uuid/uuid.dart';
// import 'package:record/record.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart' as path;
// import '../../core/constants/media_constants.dart';
// import '../../core/services/permission_service.dart';
// import '../../domain/repositories/media_repository.dart';
// import '../../domain/entities/media_item.dart';

// /// Real MediaRepository implementation with image/video picker and audio recording
// class MediaRepositoryImpl implements MediaRepository {
//   final CoreDatabase database;
//   final ImagePicker _picker = ImagePicker();
//   final AudioRecorder _recorder = AudioRecorder();
//   final AudioPlayer _audioPlayer = AudioPlayer();
//   final Uuid _uuid = const Uuid();

//   MediaRepositoryImpl({required this.database});

//   @override
//   Future<List<MediaItem>> getAllMedia() async {
//     final db = await database.database;
//     final List<Map<String, dynamic>> maps = await db.query(
//       TablesReference.mediaTable,
//       orderBy: 'createdAt DESC',
//     );
//     return List.generate(maps.length, (i) => MediaMapper.fromMap(maps[i]));
//   }

//   @override
//   Future<List<MediaItem>> filterMediaByType(String type) async {
//     final db = await database.database;
//     final List<Map<String, dynamic>> maps = await db.query(
//       TablesReference.mediaTable,
//       where: 'type = ?',
//       whereArgs: [type],
//       orderBy: 'createdAt DESC',
//     );
//     return List.generate(maps.length, (i) => MediaMapper.fromMap(maps[i]));
//   }

//   @override
//   Future<List<MediaItem>> searchMedia(String query) async {
//     final db = await database.database;
//     final List<Map<String, dynamic>> maps = await db.query(
//       TablesReference.mediaTable,
//       where: 'caption LIKE ? OR ocrText LIKE ?',
//       whereArgs: ['%$query%', '%$query%'],
//       orderBy: 'createdAt DESC',
//     );
//     return List.generate(maps.length, (i) => MediaMapper.fromMap(maps[i]));
//   }

//   @override
//   Future<MediaItem?> getMediaById(String id) async {
//     final db = await database.database;
//     final List<Map<String, dynamic>> maps = await db.query(
//       TablesReference.mediaTable,
//       where: 'id = ?',
//       whereArgs: [id],
//     );

//     if (maps.isEmpty) return null;
//     return MediaMapper.fromMap(maps.first);
//   }

//   @override
//   Future<bool> deleteMedia(String id) async {
//     try {
//       final db = await database.database;
//       final count = await db.delete(
//         TablesReference.mediaTable,
//         where: 'id = ?',
//         whereArgs: [id],
//       );
//       return count > 0;
//     } catch (e) {
//       return false;
//     }
//   }

//   @override
//   Future<bool> archiveMedia(String id) async {
//     // Current schema doesn't support archiving media directly
//     return false;
//   }

//   @override
//   Future<Map<String, int>> getMediaStats() async {
//     final db = await database.database;
//     final allMedia = await db.query(TablesReference.mediaTable);

//     int images = 0;
//     int videos = 0;
//     int audio = 0;

//     for (final map in allMedia) {
//       final type = map['type'] as String;
//       if (type == 'image') {
//         images++;
//       } else if (type == 'video')
//         videos++;
//       else if (type == 'audio')
//         audio++;
//     }

//     return {
//       'total': allMedia.length,
//       'image': images,
//       'video': videos,
//       'audio': audio,
//     };
//   }

//   @override
//   Future<List<MediaItem>> getRecentMedia({int limit = 10}) async {
//     final db = await database.database;
//     final List<Map<String, dynamic>> maps = await db.query(
//       TablesReference.mediaTable,
//       orderBy: 'createdAt DESC',
//       limit: limit,
//     );
//     return List.generate(maps.length, (i) => MediaMapper.fromMap(maps[i]));
//   }

//   @override
//   Future<String> addMedia(MediaItem item) async {
//     throw UnimplementedError('Use addImageToNote or addVideoToNote instead');
//   }

//   @override
//   Future<bool> updateMedia(MediaItem item) async {
//     try {
//       final db = await database.database;
//       final existing = await db.query(
//         TablesReference.mediaTable,
//         columns: ['noteId', 'createdAt'],
//         where: 'id = ?',
//         whereArgs: [item.id],
//       );

//       if (existing.isEmpty) return false;

//       final noteId = existing.first['noteId'] as String;

//       final map = {
//         'id': item.id,
//         'noteId': noteId,
//         'type': item.type.toString().split('.').last,
//         'filePath': item.filePath,
//         'thumbnailPath': item.thumbnailPath,
//         'durationMs': item.durationMs,
//         'updatedAt': DateTime.now().toIso8601String(),
//         'caption': item.name,
//       };

//       final count = await db.update(
//         TablesReference.mediaTable,
//         map,
//         where: 'id = ?',
//         whereArgs: [item.id],
//       );
//       return count > 0;
//     } catch (e) {
//       return false;
//     }
//   }

//   @override
//   Future<List<MediaItem>> getArchivedMedia() async {
//     return [];
//   }

//   @override
//   Future<bool> restoreMedia(String id) async {
//     return false;
//   }

//   @override
//   Future<MediaItem> addImageToNote(String noteId, String imagePath) async {
//     try {
//       final hasPermission = await PermissionService.requestPhotosPermission();
//       if (!hasPermission) {
//         throw Exception('Photo library access denied');
//       }

//       String finalPath = imagePath;
//       if (imagePath.isEmpty) {
//         final XFile? image = await _picker.pickImage(
//           source: ImageSource.gallery,
//           maxWidth: MediaConstants.maxImageWidth.toDouble(),
//           maxHeight: MediaConstants.maxImageHeight.toDouble(),
//           imageQuality: MediaConstants.imageCompressionQuality,
//         );

//         if (image == null) {
//           throw Exception('No image was selected');
//         }
//         finalPath = image.path;
//       }

//       final mediaItem = MediaItem(
//         id: _uuid.v4(),
//         type: MediaType.image,
//         filePath: finalPath,
//         createdAt: DateTime.now(),
//       );

//       await database.addMediaToNote(noteId, mediaItem);
//       return mediaItem;
//     } catch (e) {
//       throw Exception('Failed to add image to note: $e');
//     }
//   }

//   @override
//   Future<MediaItem> addVideoToNote(
//     String noteId,
//     String videoPath, {
//     String? thumbnailPath,
//   }) async {
//     try {
//       String finalPath = videoPath;
//       if (videoPath.isEmpty) {
//         final XFile? video = await _picker.pickVideo(
//           source: ImageSource.gallery,
//           maxDuration: Duration(
//             minutes: MediaConstants.maxVideoDurationMinutes,
//           ),
//         );

//         if (video == null) {
//           throw Exception('No video was selected');
//         }
//         finalPath = video.path;
//       }

//       final mediaItem = MediaItem(
//         id: _uuid.v4(),
//         type: MediaType.video,
//         filePath: finalPath,
//         thumbnailPath: thumbnailPath ?? '',
//         createdAt: DateTime.now(),
//       );

//       await database.addMediaToNote(noteId, mediaItem);
//       return mediaItem;
//     } catch (e) {
//       throw Exception('Failed to add video to note: $e');
//     }
//   }

//   @override
//   Future<void> removeMediaFromNote(String noteId, String mediaId) async {
//     await database.removeMediaFromNote(noteId, mediaId);
//   }

//   @override
//   Future<MediaItem> compressMedia(MediaItem media) async {
//     try {
//       if (media.type == MediaType.image) {
//         final file = File(media.filePath);
//         final dir = await getTemporaryDirectory();
//         final targetPath = path.join(
//           dir.path,
//           'compressed_${path.basename(media.filePath)}',
//         );

//         final compressedFile = await FlutterImageCompress.compressAndGetFile(
//           file.absolute.path,
//           targetPath,
//           quality: MediaConstants.compressedImageQuality,
//           minWidth: MediaConstants.compressedMinWidth,
//           minHeight: MediaConstants.compressedMinHeight,
//         );

//         if (compressedFile == null) return media;
//         return media.copyWith(filePath: compressedFile.path);
//       }
//       return media;
//     } catch (e) {
//       return media;
//     }
//   }

//   @override
//   Future<void> startAudioRecording(String noteId) async {
//     final hasPermission = await PermissionService.requestMicrophonePermission();
//     if (!hasPermission) throw Exception('Microphone permission denied');

//     if (await _recorder.hasPermission()) {
//       final dir = await getApplicationDocumentsDirectory();
//       final audioPath = path.join(
//         dir.path,
//         'audio_${DateTime.now().millisecondsSinceEpoch}.${MediaConstants.audioFormat}',
//       );
//       await _recorder.start(
//         const RecordConfig(encoder: AudioEncoder.aacLc),
//         path: audioPath,
//       );
//     } else {
//       throw Exception('Microphone permission denied');
//     }
//   }

//   @override
//   Future<void> stopAudioRecording(String noteId) async {
//     final audioPath = await _recorder.stop();
//     if (audioPath != null) {
//       final mediaItem = MediaItem(
//         id: _uuid.v4(),
//         type: MediaType.audio,
//         filePath: audioPath,
//         createdAt: DateTime.now(),
//       );
//       await database.addMediaToNote(noteId, mediaItem);
//     }
//   }

//   @override
//   Future<void> playMedia(String noteId, String mediaId) async {
//     final mediaItems = await database.getMediaForNote(noteId);
//     final media = mediaItems.firstWhere((m) => m.id == mediaId);
//     if (media.type == MediaType.audio) {
//       await _audioPlayer.play(DeviceFileSource(media.filePath));
//     }
//   }

//   @override
//   Future<void> pauseMedia(String noteId, String mediaId) async {
//     await _audioPlayer.pause();
//   }

//   Future<void> dispose() async {
//     await _recorder.dispose();
//     await _audioPlayer.dispose();
//   }
// }
