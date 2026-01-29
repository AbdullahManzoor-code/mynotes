part of 'command_palette_bloc.dart';

abstract class CommandPaletteEvent extends Equatable {
  const CommandPaletteEvent();

  @override
  List<Object?> get props => [];
}

class OpenCommandPaletteEvent extends CommandPaletteEvent {
  const OpenCommandPaletteEvent();
}

class CloseCommandPaletteEvent extends CommandPaletteEvent {
  const CloseCommandPaletteEvent();
}

class SearchCommandsEvent extends CommandPaletteEvent {
  final String query;

  const SearchCommandsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class ExecuteCommandEvent extends CommandPaletteEvent {
  final String commandId;

  const ExecuteCommandEvent(this.commandId);

  @override
  List<Object?> get props => [commandId];
}

class LoadCommandsEvent extends CommandPaletteEvent {
  const LoadCommandsEvent();
}

class AddCustomCommandEvent extends CommandPaletteEvent {
  final String id;
  final String label;
  final String? shortcut;
  final Function() onExecute;

  const AddCustomCommandEvent({
    required this.id,
    required this.label,
    this.shortcut,
    required this.onExecute,
  });

  @override
  List<Object?> get props => [id, label, shortcut];
}

class RemoveCustomCommandEvent extends CommandPaletteEvent {
  final String commandId;

  const RemoveCustomCommandEvent(this.commandId);

  @override
  List<Object?> get props => [commandId];
}
