import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

part 'folders_bloc_event.dart';
part 'folders_bloc_state.dart';

/* ════════════════════════════════════════════════════════════════════════════
   O001: FOLDER SYSTEM CONSOLIDATION — DEPRECATED (Session 16)
   
   STATUS: 🟡 DEPRECATED — Use NoteFoldersBloc instead
   
   ISSUE IDENTIFIED:
   Two folder management systems exist in the codebase:
   
   1. NoteFoldersBloc (PRIMARY - RECOMMENDED)
      - Location: lib/presentation/bloc/note_folders/note_folders_bloc.dart
      - Features: Shallow folder structure with UI icons & colors
      - Default folders: Inbox, Favorites, Archive (visually distinct)
      - Storage: SharedPreferences + folder-note mappings
      - Status: ✅ Actively used, integrated with UI
      - Architecture: Simple, flat structure suitable for notes app
   
   2. FoldersBloc (SECONDARY - THIS FILE - DEPRECATED)
      - Location: lib/presentation/bloc/folders/folders_bloc.dart (THIS)
      - Features: Hierarchical nesting (parentId, order) for complex structures
      - Default folders: Personal, Work, Archive (generic)
      - Storage: SharedPreferences (SAME KEY as NoteFoldersBloc!)
      - Status: ❌ NOT registered in DI, NOT used in screens, UNUSED
      - Problem: File not imported anywhere, events never dispatched
      - Storage conflict: Uses same 'note_folders' key but different data format
   
   ROOT CAUSE:
   FoldersBloc was created for hierarchical folder structure but architectural
   decision was made to use simpler NoteFoldersBloc for notes organization.
   FoldersBloc remains in codebase but disconnected from DI and routes.
   
   CONSOLIDATION DECISION:
   ✅ PRIMARY: NoteFoldersBloc
      - Simplicity matches offline note-taking app needs
      - Already integrated with UI and screens
      - Has folder-to-note mapping infrastructure
      - Used in practice
   
   ❌ SECONDARY: FoldersBloc (this file)
      - Should be removed to eliminate:
        * Storage key conflicts
        * Event name collisions (CreateFolderEvent in both)
        * Maintenance burden of unused code
        * Confusion in codebase
   
   MIGRATION PATH (If hierarchical folders needed in future):
   1. Update NoteFoldersBloc to support parentId (nesting)
   2. Add hierarchy navigation UI
   3. Remove FoldersBloc entirely
   4. Keep this comment as historical reference
   
   CURRENT ACTION: Marked as DEPRECATED
   - File preserved for reference
   - NOT registered in DI (safe to ignore)
   - Should be removed in next cleanup phase
   - All folder operations should use NoteFoldersBloc
   
   Files that need update if removed:
   - lib/presentation/bloc/folders/folders_bloc.dart (DELETE)
   - lib/presentation/bloc/folders/folders_bloc_event.dart (DELETE)
   - lib/presentation/bloc/folders/folders_bloc_state.dart (DELETE)
   - folders/ directory (DELETE)
═══════════════════════════════════════════════════════════════════════════════ */

/// ⚠️  DEPRECATED: Folders BLoC for managing folder hierarchy
///
/// Use NoteFoldersBloc instead. See file header for consolidation details.
class FoldersBloc extends Bloc<FoldersBlocEvent, FoldersBlocState> {
  final List<FolderItem> _folders = [];
  static const String _foldersKey = 'note_folders';

  FoldersBloc() : super(const FoldersBlocInitial()) {
    on<LoadFoldersEvent>(_onLoadFolders);
    on<CreateFolderEvent>(_onCreateFolder);
    on<RenameFolderEvent>(_onRenameFolder);
    on<DeleteFolderEvent>(_onDeleteFolder);
    on<MoveFolderEvent>(_onMoveFolder);
    on<ReorderFoldersEvent>(_onReorderFolders);
  }

  Future<void> _onLoadFolders(
    LoadFoldersEvent event,
    Emitter<FoldersBlocState> emit,
  ) async {
    try {
      emit(const FoldersBlocLoading());

      final prefs = await SharedPreferences.getInstance();
      final foldersJson = prefs.getString(_foldersKey);

      if (foldersJson != null) {
        final decoded = jsonDecode(foldersJson) as List;
        _folders.clear();
        _folders.addAll(
          decoded.map((f) => FolderItem.fromJson(f as Map<String, dynamic>)),
        );
      } else {
        // Default folders
        _folders.addAll([
          FolderItem(id: '1', name: 'Personal', parentId: null, order: 0),
          FolderItem(id: '2', name: 'Work', parentId: null, order: 1),
          FolderItem(id: '3', name: 'Archive', parentId: null, order: 2),
        ]);
        await _saveFolders();
      }

      emit(FoldersLoaded(folders: _folders));
    } catch (e) {
      emit(FoldersBlocError(e.toString()));
    }
  }

  Future<void> _onCreateFolder(
    CreateFolderEvent event,
    Emitter<FoldersBlocState> emit,
  ) async {
    try {
      emit(const FoldersBlocLoading());

      final newFolder = FolderItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: event.folderName,
        parentId: event.parentId,
        order: _folders.length,
      );

      _folders.add(newFolder);
      await _saveFolders();

      emit(FolderCreated(folder: newFolder));
    } catch (e) {
      emit(FoldersBlocError(e.toString()));
    }
  }

  Future<void> _onRenameFolder(
    RenameFolderEvent event,
    Emitter<FoldersBlocState> emit,
  ) async {
    try {
      emit(const FoldersBlocLoading());

      final index = _folders.indexWhere((f) => f.id == event.folderId);
      if (index >= 0) {
        _folders[index] = _folders[index].copyWith(name: event.newName);
        await _saveFolders();
        emit(FolderRenamed(folderId: event.folderId, newName: event.newName));
      } else {
        emit(const FoldersBlocError('Folder not found'));
      }
    } catch (e) {
      emit(FoldersBlocError(e.toString()));
    }
  }

  Future<void> _onDeleteFolder(
    DeleteFolderEvent event,
    Emitter<FoldersBlocState> emit,
  ) async {
    try {
      emit(const FoldersBlocLoading());

      _folders.removeWhere((f) => f.id == event.folderId);
      await _saveFolders();

      emit(FolderDeleted(folderId: event.folderId));
    } catch (e) {
      emit(FoldersBlocError(e.toString()));
    }
  }

  Future<void> _onMoveFolder(
    MoveFolderEvent event,
    Emitter<FoldersBlocState> emit,
  ) async {
    try {
      emit(const FoldersBlocLoading());

      final index = _folders.indexWhere((f) => f.id == event.folderId);
      if (index >= 0) {
        _folders[index] = _folders[index].copyWith(parentId: event.newParentId);
        await _saveFolders();
        emit(
          FolderMoved(folderId: event.folderId, newParentId: event.newParentId),
        );
      }
    } catch (e) {
      emit(FoldersBlocError(e.toString()));
    }
  }

  Future<void> _onReorderFolders(
    ReorderFoldersEvent event,
    Emitter<FoldersBlocState> emit,
  ) async {
    try {
      emit(const FoldersBlocLoading());

      // Update order based on new sequence
      for (int i = 0; i < event.folderIds.length; i++) {
        final index = _folders.indexWhere((f) => f.id == event.folderIds[i]);
        if (index >= 0) {
          _folders[index] = _folders[index].copyWith(order: i);
        }
      }

      await _saveFolders();
      emit(FoldersReordered(folderIds: event.folderIds));
    } catch (e) {
      emit(FoldersBlocError(e.toString()));
    }
  }

  Future<void> _saveFolders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_foldersKey, jsonEncode(_folders));
  }
}

class FolderItem extends Equatable {
  final String id;
  final String name;
  final String? parentId;
  final int order;

  const FolderItem({
    required this.id,
    required this.name,
    required this.parentId,
    required this.order,
  });

  FolderItem copyWith({
    String? id,
    String? name,
    String? parentId,
    int? order,
  }) {
    return FolderItem(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      order: order ?? this.order,
    );
  }

  factory FolderItem.fromJson(Map<String, dynamic> json) {
    return FolderItem(
      id: json['id'] as String,
      name: json['name'] as String,
      parentId: json['parentId'] as String?,
      order: json['order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'parentId': parentId, 'order': order};
  }

  @override
  List<Object?> get props => [id, name, parentId, order];
}
