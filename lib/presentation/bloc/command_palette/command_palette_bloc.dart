import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:shared_preferences/shared_preferences.dart';

part 'command_palette_event.dart';
part 'command_palette_state.dart';

/// Command Palette BLoC for power users
/// Provides keyboard shortcut support and command search
class CommandPaletteBloc
    extends Bloc<CommandPaletteEvent, CommandPaletteState> {
  final List<CommandItem> _allCommands = [];
  final Map<String, Function()> _customCommands = {};
  static const String _commandsKey = 'command_palette_commands';

  CommandPaletteBloc() : super(const CommandPaletteInitial()) {
    on<LoadCommandsEvent>(_onLoadCommands);
    on<OpenCommandPaletteEvent>(_onOpenCommandPalette);
    on<CloseCommandPaletteEvent>(_onCloseCommandPalette);
    on<SearchCommandsEvent>(_onSearchCommands);
    on<ExecuteCommandEvent>(_onExecuteCommand);
    on<AddCustomCommandEvent>(_onAddCustomCommand);
    on<RemoveCustomCommandEvent>(_onRemoveCustomCommand);
  }

  Future<void> _onLoadCommands(
    LoadCommandsEvent event,
    Emitter<CommandPaletteState> emit,
  ) async {
    try {
      emit(const CommandPaletteLoading());

      // Load default commands
      _allCommands.addAll([
        CommandItem(
          id: 'new_note',
          label: 'New Note',
          description: 'Create a new note',
          shortcut: 'Ctrl+N',
          category: 'Note',
        ),
        CommandItem(
          id: 'new_todo',
          label: 'New Todo',
          description: 'Create a new todo',
          shortcut: 'Ctrl+T',
          category: 'Todo',
        ),
        CommandItem(
          id: 'new_reminder',
          label: 'New Reminder',
          description: 'Create a new reminder',
          shortcut: 'Ctrl+R',
          category: 'Reminder',
        ),
        CommandItem(
          id: 'search',
          label: 'Global Search',
          description: 'Open global search',
          shortcut: 'Ctrl+F',
          category: 'Navigation',
        ),
        CommandItem(
          id: 'settings',
          label: 'Settings',
          description: 'Open settings',
          shortcut: 'Ctrl+,',
          category: 'Navigation',
        ),
        CommandItem(
          id: 'focus_mode',
          label: 'Focus Mode (Pomodoro)',
          description: 'Start focus session',
          shortcut: 'Ctrl+Shift+F',
          category: 'Focus',
        ),
        CommandItem(
          id: 'dark_mode',
          label: 'Toggle Dark Mode',
          description: 'Toggle dark/light theme',
          shortcut: 'Ctrl+Shift+D',
          category: 'Theme',
        ),
        CommandItem(
          id: 'backup',
          label: 'Backup Data',
          description: 'Create backup of all data',
          shortcut: 'Ctrl+Shift+B',
          category: 'Data',
        ),
      ]);

      // Load custom commands from preferences
      final prefs = await SharedPreferences.getInstance();
      final commandsJson = prefs.getString(_commandsKey);
      if (commandsJson != null) {
        // Deserialize and load custom commands
      }

      emit(CommandPaletteOpen(commands: _allCommands));
    } catch (e) {
      emit(CommandPaletteError(e.toString()));
    }
  }

  Future<void> _onOpenCommandPalette(
    OpenCommandPaletteEvent event,
    Emitter<CommandPaletteState> emit,
  ) async {
    emit(CommandPaletteOpen(commands: _allCommands));
  }

  Future<void> _onCloseCommandPalette(
    CloseCommandPaletteEvent event,
    Emitter<CommandPaletteState> emit,
  ) async {
    emit(const CommandPaletteClosed());
  }

  Future<void> _onSearchCommands(
    SearchCommandsEvent event,
    Emitter<CommandPaletteState> emit,
  ) async {
    try {
      final query = event.query.toLowerCase().trim();

      if (query.isEmpty) {
        emit(CommandPaletteOpen(commands: _allCommands, query: query));
        return;
      }

      final filtered = _allCommands
          .where(
            (cmd) =>
                cmd.label.toLowerCase().contains(query) ||
                (cmd.description?.toLowerCase().contains(query) ?? false) ||
                (cmd.shortcut?.toLowerCase().contains(query) ?? false),
          )
          .toList();

      emit(CommandPaletteFiltered(filteredCommands: filtered, query: query));
    } catch (e) {
      emit(CommandPaletteError(e.toString()));
    }
  }

  Future<void> _onExecuteCommand(
    ExecuteCommandEvent event,
    Emitter<CommandPaletteState> emit,
  ) async {
    try {
      emit(CommandPaletteExecuting(event.commandId));

      final command = _allCommands.firstWhere(
        (cmd) => cmd.id == event.commandId,
        orElse: () => throw Exception('Command not found'),
      );

      // Execute custom command if registered
      if (_customCommands.containsKey(event.commandId)) {
        _customCommands[event.commandId]!();
      } else if (command.onExecute != null) {
        command.onExecute!();
      }

      emit(CommandPaletteExecuted(event.commandId));
      emit(const CommandPaletteClosed());
    } catch (e) {
      emit(CommandPaletteError(e.toString()));
    }
  }

  Future<void> _onAddCustomCommand(
    AddCustomCommandEvent event,
    Emitter<CommandPaletteState> emit,
  ) async {
    try {
      final newCommand = CommandItem(
        id: event.id,
        label: event.label,
        shortcut: event.shortcut,
        onExecute: event.onExecute,
        category: 'Custom',
      );

      _allCommands.add(newCommand);
      _customCommands[event.id] = event.onExecute;

      // Save to preferences
      final prefs = await SharedPreferences.getInstance();
      // Serialize and save

      emit(CommandPaletteOpen(commands: _allCommands));
    } catch (e) {
      emit(CommandPaletteError(e.toString()));
    }
  }

  Future<void> _onRemoveCustomCommand(
    RemoveCustomCommandEvent event,
    Emitter<CommandPaletteState> emit,
  ) async {
    try {
      _allCommands.removeWhere((cmd) => cmd.id == event.commandId);
      _customCommands.remove(event.commandId);

      // Save to preferences
      final prefs = await SharedPreferences.getInstance();
      // Serialize and save
      emit(CommandPaletteOpen(commands: _allCommands));
    } catch (e) {
      emit(CommandPaletteError(e.toString()));
    }
  }
}
