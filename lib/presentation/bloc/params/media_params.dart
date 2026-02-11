import 'package:equatable/equatable.dart';

/// Complete Param Model for Media Gallery Operations
/// 📦 Container for all media-related data
class MediaParams extends Equatable {
  final String? mediaId;
  final String filePath;
  final String mediaType; // image, video, audio
  final String? fileName;
  final int? fileSizeBytes;
  final DateTime? uploadedAt;
  final String? mimeType;
  final Map<String, dynamic>? metadata;
  final bool isLocal;
  final String? noteId;

  const MediaParams({
    this.mediaId,
    required this.filePath,
    this.mediaType = 'image',
    this.fileName,
    this.fileSizeBytes,
    this.uploadedAt,
    this.mimeType,
    this.metadata,
    this.isLocal = true,
    this.noteId,
  });

  MediaParams copyWith({
    String? mediaId,
    String? filePath,
    String? mediaType,
    String? fileName,
    int? fileSizeBytes,
    DateTime? uploadedAt,
    String? mimeType,
    Map<String, dynamic>? metadata,
    bool? isLocal,
    String? noteId,
  }) {
    return MediaParams(
      mediaId: mediaId ?? this.mediaId,
      filePath: filePath ?? this.filePath,
      mediaType: mediaType ?? this.mediaType,
      fileName: fileName ?? this.fileName,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      mimeType: mimeType ?? this.mimeType,
      metadata: metadata ?? this.metadata,
      isLocal: isLocal ?? this.isLocal,
      noteId: noteId ?? this.noteId,
    );
  }

  @override
  List<Object?> get props => [
    mediaId,
    filePath,
    mediaType,
    fileName,
    fileSizeBytes,
    uploadedAt,
    mimeType,
    metadata,
    isLocal,
    noteId,
  ];
}
