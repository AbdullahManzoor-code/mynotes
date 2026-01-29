part of 'activity_tag_bloc.dart';

abstract class ActivityTagEvent extends Equatable {
  const ActivityTagEvent();

  @override
  List<Object?> get props => [];
}

class LoadTagsEvent extends ActivityTagEvent {
  const LoadTagsEvent();
}

class CreateTagEvent extends ActivityTagEvent {
  final String name;
  final int color;

  const CreateTagEvent({required this.name, required this.color});

  @override
  List<Object?> get props => [name, color];
}

class SelectTagEvent extends ActivityTagEvent {
  final String tagId;

  const SelectTagEvent(this.tagId);

  @override
  List<Object?> get props => [tagId];
}

class DeleteTagEvent extends ActivityTagEvent {
  final String tagId;

  const DeleteTagEvent(this.tagId);

  @override
  List<Object?> get props => [tagId];
}

class UpdatePrivacyModeEvent extends ActivityTagEvent {
  final bool isPrivate;

  const UpdatePrivacyModeEvent({required this.isPrivate});

  @override
  List<Object?> get props => [isPrivate];
}
