import 'package:equatable/equatable.dart';

/// Complete Param Model for Note Linking Operations
/// 📦 Container for all note link-related data
class NoteLinkParams extends Equatable {
  final String? linkId;
  final String sourceNoteId;
  final String targetNoteId;
  final String linkType; // forward, backward, bidirectional
  final String? description;
  final DateTime? createdAt;

  const NoteLinkParams({
    this.linkId,
    required this.sourceNoteId,
    required this.targetNoteId,
    this.linkType = 'bidirectional',
    this.description,
    this.createdAt,
  });

  NoteLinkParams copyWith({
    String? linkId,
    String? sourceNoteId,
    String? targetNoteId,
    String? linkType,
    String? description,
    DateTime? createdAt,
  }) {
    return NoteLinkParams(
      linkId: linkId ?? this.linkId,
      sourceNoteId: sourceNoteId ?? this.sourceNoteId,
      targetNoteId: targetNoteId ?? this.targetNoteId,
      linkType: linkType ?? this.linkType,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    linkId,
    sourceNoteId,
    targetNoteId,
    linkType,
    description,
    createdAt,
  ];
}
