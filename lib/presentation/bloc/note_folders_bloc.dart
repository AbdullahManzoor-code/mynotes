import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

part 'note_folders_event.dart';
part 'note_folders_state.dart';

class NoteFolder {
  final String id;
  final String name;
  final IconData icon;
  final int color;
  final bool isDefault;
  final List<String> subfolders;

  NoteFolder({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.isDefault = false,
    this.subfolders = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'color': color,
    'isDefault': isDefault,
    'subfolders': subfolders,
  };

  factory NoteFolder.fromJson(Map<String, dynamic> json) => NoteFolder(
    id: json['id'] as String,
    name: json['name'] as String,
    icon: Icons.folder,
    color: json['color'] as int? ?? 0xFF2196F3,
    isDefault: json['isDefault'] as bool? ?? false,
    subfolders: List<String>.from(json['subfolders'] as List? ?? []),
  );
}

class NoteFoldersBloc extends Bloc<NoteFoldersEvent, NoteFoldersState> {
  late SharedPreferences _prefs;
  final Map<String, NoteFolder> _folders = {};
  final Map<String, Set<String>> _folderNotes = {};
  static const String _foldersKey = 'note_folders';

  NoteFoldersBloc() : super(const NoteFoldersInitial()) {
    on<LoadFoldersEvent>(_onLoadFolders);
    on<CreateFolderEvent>(_onCreateFolder);
    on<RenameFolderEvent>(_onRenameFolder);
    on<DeleteFolderEvent>(_onDeleteFolder);
    on<MoveFolderEvent>(_onMoveFolder);
    on<ReorderFoldersEvent>(_onReorderFolders);
    on<AddNoteToFolderEvent>(_onAddNoteToFolder);
    on<RemoveNoteFromFolderEvent>(_onRemoveNoteFromFolder);
  }

  Future<void> _onLoadFolders(
    LoadFoldersEvent event,
    Emitter<NoteFoldersState> emit,
  ) async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _folders.clear();
      _folderNotes.clear();

      final foldersJson = _prefs.getString(_foldersKey);
      if (foldersJson != null) {
        final List<dynamic> decoded = jsonDecode(foldersJson);
        for (var item in decoded) {
          final folder = NoteFolder.fromJson(item as Map<String, dynamic>);
          _folders[folder.id] = folder;
          _folderNotes[folder.id] = {};
        }
      } else {
        _initializeDefaultFolders();
      }

      emit(FoldersLoaded(List.from(_folders.values)));
    } catch (e) {
      emit(FoldersError('Failed to load folders: $e'));
    }
  }

  void _initializeDefaultFolders() {
    _folders['inbox'] = NoteFolder(
      id: 'inbox',
      name: 'Inbox',
      icon: Icons.inbox,
      color: 0xFF2196F3,
      isDefault: true,
    );
    _folders['favorites'] = NoteFolder(
      id: 'favorites',
      name: 'Favorites',
      icon: Icons.star,
      color: 0xFFFFC107,
      isDefault: true,
    );
    _folders['archive'] = NoteFolder(
      id: 'archive',
      name: 'Archive',
      icon: Icons.archive,
      color: 0xFF9E9E9E,
      isDefault: true,
    );
    for (var folder in _folders.values) {
      _folderNotes[folder.id] = {};
    }
  }

  Future<void> _onCreateFolder(
    CreateFolderEvent event,
    Emitter<NoteFoldersState> emit,
  ) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final folder = NoteFolder(
        id: id,
        name: event.name,
        icon: Icons.folder,
        color: event.color ?? 0xFF2196F3,
        isDefault: false,
      );
      _folders[id] = folder;
      _folderNotes[id] = {};
      await _saveFolders();
      emit(FoldersLoaded(List.from(_folders.values)));
    } catch (e) {
      emit(FoldersError('Failed to create folder: $e'));
    }
  }

  Future<void> _onRenameFolder(
    RenameFolderEvent event,
    Emitter<NoteFoldersState> emit,
  ) async {
    try {
      if (_folders.containsKey(event.folderId)) {
        final folder = _folders[event.folderId]!;
        _folders[event.folderId] = NoteFolder(
          id: folder.id,
          name: event.newName,
          icon: folder.icon,
          color: folder.color,
          isDefault: folder.isDefault,
          subfolders: folder.subfolders,
        );
        await _saveFolders();
        emit(FoldersLoaded(List.from(_folders.values)));
      }
    } catch (e) {
      emit(FoldersError('Failed to rename folder: $e'));
    }
  }

  Future<void> _onDeleteFolder(
    DeleteFolderEvent event,
    Emitter<NoteFoldersState> emit,
  ) async {
    try {
      _folders.remove(event.folderId);
      _folderNotes.remove(event.folderId);
      await _saveFolders();
      emit(FoldersLoaded(List.from(_folders.values)));
    } catch (e) {
      emit(FoldersError('Failed to delete folder: $e'));
    }
  }

  Future<void> _onMoveFolder(
    MoveFolderEvent event,
    Emitter<NoteFoldersState> emit,
  ) async {
    try {
      if (_folders.containsKey(event.folderId) &&
          _folders.containsKey(event.targetParentId)) {
        final folder = _folders[event.folderId]!;
        _folders[event.folderId] = NoteFolder(
          id: folder.id,
          name: folder.name,
          icon: folder.icon,
          color: folder.color,
          isDefault: folder.isDefault,
          subfolders: folder.subfolders,
        );
        await _saveFolders();
        emit(FoldersLoaded(List.from(_folders.values)));
      }
    } catch (e) {
      emit(FoldersError('Failed to move folder: $e'));
    }
  }

  Future<void> _onReorderFolders(
    ReorderFoldersEvent event,
    Emitter<NoteFoldersState> emit,
  ) async {
    try {
      await _saveFolders();
      emit(FoldersLoaded(List.from(_folders.values)));
    } catch (e) {
      emit(FoldersError('Failed to reorder folders: $e'));
    }
  }

  Future<void> _onAddNoteToFolder(
    AddNoteToFolderEvent event,
    Emitter<NoteFoldersState> emit,
  ) async {
    try {
      _folderNotes.putIfAbsent(event.folderId, () => {});
      _folderNotes[event.folderId]!.add(event.noteId);
      emit(FoldersLoaded(List.from(_folders.values)));
    } catch (e) {
      emit(FoldersError('Failed to add note to folder: $e'));
    }
  }

  Future<void> _onRemoveNoteFromFolder(
    RemoveNoteFromFolderEvent event,
    Emitter<NoteFoldersState> emit,
  ) async {
    try {
      _folderNotes[event.folderId]?.remove(event.noteId);
      emit(FoldersLoaded(List.from(_folders.values)));
    } catch (e) {
      emit(FoldersError('Failed to remove note from folder: $e'));
    }
  }

  Future<void> _saveFolders() async {
    final foldersList = _folders.values.map((f) => f.toJson()).toList();
    await _prefs.setString(_foldersKey, jsonEncode(foldersList));
  }
}
