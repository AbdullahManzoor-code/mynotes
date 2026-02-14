part of 'command_palette_bloc.dart';

abstract class CommandPaletteState extends Equatable {
  const CommandPaletteState();

  @override
  List<Object?> get props => [];
}

class CommandPaletteInitial extends CommandPaletteState {
  const CommandPaletteInitial();
}

class CommandPaletteLoading extends CommandPaletteState {
  const CommandPaletteLoading();
}

class CommandPaletteOpen extends CommandPaletteState {
  final List<CommandItem> commands;
  final String query;

  const CommandPaletteOpen({required this.commands, this.query = ''});

  @override
  List<Object?> get props => [commands, query];
}

class CommandPaletteFiltered extends CommandPaletteState {
  final List<CommandItem> filteredCommands;
  final String query;

  const CommandPaletteFiltered({
    required this.filteredCommands,
    required this.query,
  });

  @override
  List<Object?> get props => [filteredCommands, query];
}

class CommandPaletteExecuting extends CommandPaletteState {
  final String commandId;

  const CommandPaletteExecuting(this.commandId);

  @override
  List<Object?> get props => [commandId];
}

class CommandPaletteExecuted extends CommandPaletteState {
  final String commandId;

  const CommandPaletteExecuted(this.commandId);

  @override
  List<Object?> get props => [commandId];
}

class CommandPaletteClosed extends CommandPaletteState {
  const CommandPaletteClosed();
}

class CommandPaletteError extends CommandPaletteState {
  final String message;

  const CommandPaletteError(this.message);

  @override
  List<Object?> get props => [message];
}

class CommandItem {
  final String id;
  final String label;
  final String? description;
  final String? shortcut;
  final Function()? onExecute;
  final String category;

  CommandItem({
    required this.id,
    required this.label,
    this.description,
    this.shortcut,
    this.onExecute,
    this.category = 'General',
  });
}
