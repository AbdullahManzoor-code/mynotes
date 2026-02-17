part of 'voice_command_bloc.dart';

class VoiceCommandParser {
  static const Map<String, VoiceCommandType> commandPatterns = {
    'create note': VoiceCommandType.createNote,
    'new note': VoiceCommandType.createNote,
    'write note': VoiceCommandType.createNote,
    'create todo': VoiceCommandType.createTodo,
    'add task': VoiceCommandType.createTodo,
    'new task': VoiceCommandType.createTodo,
    'start focus': VoiceCommandType.startFocus,
    'pomodoro': VoiceCommandType.startFocus,
    'pause': VoiceCommandType.pauseFocus,
    'stop': VoiceCommandType.stopFocus,
    'reflect': VoiceCommandType.startReflection,
    'search': VoiceCommandType.search,
    'settings': VoiceCommandType.openSettings,
  };

  static VoiceCommandType parseCommand(String input) {
    final normalized = input.toLowerCase().trim();
    for (final pattern in commandPatterns.entries) {
      if (normalized.contains(pattern.key)) {
        return pattern.value;
      }
    }
    return VoiceCommandType.other;
  }

  static String getCommandDescription(VoiceCommandType command) {
    switch (command) {
      case VoiceCommandType.createNote:
        return 'Create a new note';
      case VoiceCommandType.createTodo:
        return 'Create a new task';
      case VoiceCommandType.startFocus:
        return 'Start focus session';
      case VoiceCommandType.pauseFocus:
        return 'Pause focus session';
      case VoiceCommandType.stopFocus:
        return 'Stop focus session';
      case VoiceCommandType.startReflection:
        return 'Start reflection';
      case VoiceCommandType.search:
        return 'Search notes and tasks';
      case VoiceCommandType.openSettings:
        return 'Open settings';
      case VoiceCommandType.other:
        return 'Unknown command';
    }
  }

  static String? extractContent(String input, VoiceCommandType command) {
    final normalized = input.toLowerCase().trim();

    switch (command) {
      case VoiceCommandType.createNote:
        return _extractAfterKeyword(normalized, [
          'create note',
          'new note',
          'write note',
        ]);
      case VoiceCommandType.createTodo:
        return _extractAfterKeyword(normalized, [
          'create todo',
          'add task',
          'new task',
        ]);
      case VoiceCommandType.search:
        return _extractAfterKeyword(normalized, ['search']);
      default:
        return null;
    }
  }

  static String? _extractAfterKeyword(String input, List<String> keywords) {
    for (final keyword in keywords) {
      if (input.toLowerCase().contains(keyword)) {
        final idx = input.toLowerCase().indexOf(keyword);
        final extracted = input.substring(idx + keyword.length).trim();
        return extracted.isNotEmpty ? extracted : null;
      }
    }
    return null;
  }
}

abstract class VoiceCommandState {
  const VoiceCommandState();
}

class VoiceCommandInitial extends VoiceCommandState {
  const VoiceCommandInitial();
}

class VoiceCommandListening extends VoiceCommandState {
  const VoiceCommandListening();
}

class VoiceCommandProcessing extends VoiceCommandState {
  const VoiceCommandProcessing();
}

class VoiceCommandRecognized extends VoiceCommandState {
  final VoiceCommandType commandType;
  final String? extractedContent;

  const VoiceCommandRecognized({
    required this.commandType,
    required this.extractedContent,
  });
}

class VoiceCommandFeedbackToggled extends VoiceCommandState {
  final bool soundEnabled;
  final bool vibrationEnabled;

  const VoiceCommandFeedbackToggled({
    required this.soundEnabled,
    required this.vibrationEnabled,
  });
}

class VoiceCommandFeedbackPlayed extends VoiceCommandState {
  final VoiceCommandFeedbackType type;

  const VoiceCommandFeedbackPlayed(this.type);
}

class VoiceCommandError extends VoiceCommandState {
  final String message;

  const VoiceCommandError(this.message);
}
