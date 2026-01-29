import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

part 'activity_tag_event.dart';
part 'activity_tag_state.dart';

class ActivityTagBloc extends Bloc<ActivityTagEvent, ActivityTagState> {
  static const String _tagsKey = 'activity_tags';
  static const String _privacyModeKey = 'privacy_mode_enabled';

  ActivityTagBloc() : super(ActivityTagInitial()) {
    on<LoadTagsEvent>(_onLoadTags);
    on<CreateTagEvent>(_onCreateTag);
    on<SelectTagEvent>(_onSelectTag);
    on<DeleteTagEvent>(_onDeleteTag);
    on<UpdatePrivacyModeEvent>(_onUpdatePrivacyMode);
  }

  Future<void> _onLoadTags(
    LoadTagsEvent event,
    Emitter<ActivityTagState> emit,
  ) async {
    emit(TagsLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final tagsJson = prefs.getString(_tagsKey);

      List<Map<String, dynamic>> tags;
      if (tagsJson != null) {
        tags = List<Map<String, dynamic>>.from(jsonDecode(tagsJson));
      } else {
        // Default tags
        tags = [
          {'id': '1', 'name': 'Work', 'color': 0xFF3498DB},
          {'id': '2', 'name': 'Personal', 'color': 0xFFE74C3C},
          {'id': '3', 'name': 'Learning', 'color': 0xFFF39C12},
        ];
        await prefs.setString(_tagsKey, jsonEncode(tags));
      }

      emit(TagsLoaded(tags: tags));
    } catch (e) {
      emit(ActivityTagError(e.toString()));
    }
  }

  Future<void> _onCreateTag(
    CreateTagEvent event,
    Emitter<ActivityTagState> emit,
  ) async {
    if (state is TagsLoaded) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final tags = List<Map<String, dynamic>>.from(
          (state as TagsLoaded).tags,
        );
        tags.add({
          'id': '${DateTime.now().millisecondsSinceEpoch}',
          'name': event.name,
          'color': event.color,
        });
        await prefs.setString(_tagsKey, jsonEncode(tags));
        emit(TagsLoaded(tags: tags));
      } catch (e) {
        emit(ActivityTagError(e.toString()));
      }
    }
  }

  Future<void> _onSelectTag(
    SelectTagEvent event,
    Emitter<ActivityTagState> emit,
  ) async {
    if (state is TagsLoaded) {
      try {
        emit(TagSelected(tagId: event.tagId, tags: (state as TagsLoaded).tags));
      } catch (e) {
        emit(ActivityTagError(e.toString()));
      }
    }
  }

  Future<void> _onDeleteTag(
    DeleteTagEvent event,
    Emitter<ActivityTagState> emit,
  ) async {
    if (state is TagsLoaded) {
      try {
        final tags = (state as TagsLoaded).tags
            .where((tag) => tag['id'] != event.tagId)
            .toList();
        emit(TagsLoaded(tags: tags));
      } catch (e) {
        emit(ActivityTagError(e.toString()));
      }
    }
  }

  Future<void> _onUpdatePrivacyMode(
    UpdatePrivacyModeEvent event,
    Emitter<ActivityTagState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_privacyModeKey, event.isPrivate);

      emit(
        PrivacyModeUpdated(
          isPrivate: event.isPrivate,
          tags: (state is TagsLoaded) ? (state as TagsLoaded).tags : [],
        ),
      );
    } catch (e) {
      emit(ActivityTagError(e.toString()));
    }
  }
}
