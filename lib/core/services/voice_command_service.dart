/// Voice command callback type
typedef CommandCallback = void Function();

/// Service for recognizing and executing voice commands
class VoiceCommandService {
  /// Registered commands map
  final Map<String, CommandCallback> _commands = {};

  /// Command patterns for formatting
  static const Map<String, List<String>> commandPatterns = {
    'bold': ['make bold', 'bold text', 'apply bold'],
    'italic': ['make italic', 'italic text', 'italicize'],
    'underline': ['underline', 'underline text'],
    'heading1': ['heading one', 'heading 1', 'h1', 'make heading one'],
    'heading2': ['heading two', 'heading 2', 'h2', 'make heading two'],
    'heading3': ['heading three', 'heading 3', 'h3', 'make heading three'],
    'bullet_list': ['bullet list', 'bullet points', 'create list'],
    'numbered_list': ['numbered list', 'number list', 'create numbered list'],
    'checklist': ['checklist', 'check list', 'create checklist', 'todo list'],
    'quote': ['quote', 'blockquote', 'make quote'],
    'save': ['save note', 'save', 'save this'],
    'undo': ['undo', 'undo that'],
    'redo': ['redo', 'redo that'],
    'clear_format': ['clear formatting', 'remove formatting', 'plain text'],
    'new_line': ['new line', 'next line'],
    'new_paragraph': ['new paragraph', 'paragraph'],
  };

  /// Register a command
  void registerCommand(String commandKey, CommandCallback callback) {
    _commands[commandKey] = callback;
  }

  /// Unregister a command
  void unregisterCommand(String commandKey) {
    _commands.remove(commandKey);
  }

  /// Clear all commands
  void clearAllCommands() {
    _commands.clear();
  }

  /// Detect and execute command from speech text
  /// Returns true if a command was executed, false otherwise
  bool detectAndExecute(String spokenText) {
    final lowerText = spokenText.toLowerCase().trim();

    // Check each command pattern
    for (final entry in commandPatterns.entries) {
      final commandKey = entry.key;
      final patterns = entry.value;

      // Check if any pattern matches
      for (final pattern in patterns) {
        if (lowerText.contains(pattern)) {
          // Execute registered callback if exists
          if (_commands.containsKey(commandKey)) {
            _commands[commandKey]!();
            return true;
          }
        }
      }
    }

    return false;
  }

  /// Extract text without commands
  /// Removes command phrases from the spoken text
  String extractTextWithoutCommands(String spokenText) {
    String cleanText = spokenText;

    // Remove all command patterns
    for (final patterns in commandPatterns.values) {
      for (final pattern in patterns) {
        cleanText = cleanText.replaceAll(
          RegExp(pattern, caseSensitive: false),
          '',
        );
      }
    }

    return cleanText.trim();
  }

  /// Check if text contains a command
  bool containsCommand(String spokenText) {
    final lowerText = spokenText.toLowerCase().trim();

    for (final patterns in commandPatterns.values) {
      for (final pattern in patterns) {
        if (lowerText.contains(pattern)) {
          return true;
        }
      }
    }

    return false;
  }

  /// Get all available commands as a list
  List<String> getAvailableCommands() {
    final List<String> commands = [];
    for (final patterns in commandPatterns.values) {
      commands.addAll(patterns);
    }
    return commands;
  }

  /// Get command description for help
  Map<String, String> getCommandDescriptions() {
    return {
      'bold': 'Say "make bold" to apply bold formatting',
      'italic': 'Say "make italic" to apply italic formatting',
      'underline': 'Say "underline" to underline text',
      'heading1': 'Say "heading one" for large heading',
      'heading2': 'Say "heading two" for medium heading',
      'heading3': 'Say "heading three" for small heading',
      'bullet_list': 'Say "bullet list" to create a list',
      'numbered_list': 'Say "numbered list" for numbered items',
      'checklist': 'Say "checklist" to create a todo list',
      'quote': 'Say "quote" to create a blockquote',
      'save': 'Say "save note" to save your work',
      'undo': 'Say "undo" to undo last action',
      'redo': 'Say "redo" to redo last action',
      'clear_format': 'Say "clear formatting" to remove styles',
    };
  }
}

