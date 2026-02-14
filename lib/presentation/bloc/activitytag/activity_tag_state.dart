part of 'activity_tag_bloc.dart';

abstract class ActivityTagState extends Equatable {
  const ActivityTagState();

  @override
  List<Object?> get props => [];
}

class ActivityTagInitial extends ActivityTagState {
  const ActivityTagInitial();
}

class TagsLoading extends ActivityTagState {
  const TagsLoading();
}

class TagsLoaded extends ActivityTagState {
  final List<Map<String, dynamic>> tags;

  const TagsLoaded({required this.tags});

  @override
  List<Object?> get props => [tags];
}

class TagSelected extends ActivityTagState {
  final String tagId;
  final List<Map<String, dynamic>> tags;

  const TagSelected({required this.tagId, required this.tags});

  @override
  List<Object?> get props => [tagId, tags];
}

class PrivacyModeUpdated extends ActivityTagState {
  final bool isPrivate;
  final List<Map<String, dynamic>> tags;

  const PrivacyModeUpdated({required this.isPrivate, required this.tags});

  @override
  List<Object?> get props => [isPrivate, tags];
}

class ActivityTagError extends ActivityTagState {
  final String message;

  const ActivityTagError(this.message);

  @override
  List<Object?> get props => [message];
}
