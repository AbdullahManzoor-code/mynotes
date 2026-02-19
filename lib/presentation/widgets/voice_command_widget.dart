import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/presentation/design_system/design_system.dart';
import '../bloc/voice_command/voice_command_bloc.dart';

/// Voice command types
enum VoiceCommandType {
  createNote,
  createTodo,
  startFocus,
  pauseFocus,
  stopFocus,
  startReflection,
  search,
  openSettings,
  other,
}

/// Voice command parser (VOC-002)
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

  /// Parse voice input and return command type
  static VoiceCommandType parseCommand(String input) {
    final normalized = input.toLowerCase().trim();

    for (final pattern in commandPatterns.entries) {
      if (normalized.contains(pattern.key)) {
        return pattern.value;
      }
    }

    return VoiceCommandType.other;
  }

  /// Get command description
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

  /// Extract note/task content from voice input
  static String? extractContent(String input, VoiceCommandType command) {
    switch (command) {
      case VoiceCommandType.createNote:
        return _extractAfterKeyword(input, [
          'create note',
          'new note',
          'write note',
        ]);
      case VoiceCommandType.createTodo:
        return _extractAfterKeyword(input, [
          'create todo',
          'add task',
          'new task',
        ]);
      case VoiceCommandType.search:
        return _extractAfterKeyword(input, ['search']);
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

/// Audio feedback service (VOC-003) - LEGACY (deprecated, use VoiceCommandBloc)
class AudioFeedbackService extends ChangeNotifier {
  bool _isSoundEnabled = true;
  bool _isVibrationEnabled = true;

  bool get isSoundEnabled => _isSoundEnabled;
  bool get isVibrationEnabled => _isVibrationEnabled;

  /// Play command recognized feedback
  Future<void> playCommandRecognized() async {
    if (_isSoundEnabled) {
      // Play short positive beep
      _playBeep(frequency: 800, duration: 100);
    }
    if (_isVibrationEnabled) {
      // Would trigger vibration here
    }
  }

  /// Play command executed feedback
  Future<void> playCommandExecuted() async {
    if (_isSoundEnabled) {
      _playBeep(frequency: 1000, duration: 150);
    }
    if (_isVibrationEnabled) {
      // Would trigger vibration here
    }
  }

  /// Play error feedback
  Future<void> playErrorFeedback() async {
    if (_isSoundEnabled) {
      _playBeep(frequency: 400, duration: 200);
    }
    if (_isVibrationEnabled) {
      // Would trigger vibration here
    }
  }

  /// Play listening feedback
  Future<void> playListeningFeedback() async {
    if (_isSoundEnabled) {
      _playBeep(frequency: 600, duration: 80);
    }
  }

  void _playBeep({required int frequency, required int duration}) {
    // Audio playback implementation would go here
  }

  /// Toggle sound feedback
  void toggleSound(bool enabled) {
    _isSoundEnabled = enabled;
    notifyListeners();
  }

  /// Toggle vibration feedback
  void toggleVibration(bool enabled) {
    _isVibrationEnabled = enabled;
    notifyListeners();
  }
}

/// Voice command widget
class VoiceCommandWidget extends StatefulWidget {
  final ValueChanged<VoiceCommandType> onCommandRecognized;
  final ValueChanged<String>? onContentExtracted;

  const VoiceCommandWidget({
    super.key,
    required this.onCommandRecognized,
    this.onContentExtracted,
  });

  @override
  State<VoiceCommandWidget> createState() => _VoiceCommandWidgetState();
}

class _VoiceCommandWidgetState extends State<VoiceCommandWidget> {
  bool _isListening = false;
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _processVoiceInput() {
    if (_textController.text.isEmpty) return;

    final command = VoiceCommandParser.parseCommand(_textController.text);
    widget.onCommandRecognized(command);

    final content = VoiceCommandParser.extractContent(
      _textController.text,
      command,
    );
    if (content != null) {
      widget.onContentExtracted?.call(content);
    }

    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Voice Commands',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            // Input field
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Say or type a command...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.mic_external_off_rounded),
                suffixIcon: _isListening
                    ? Padding(
                        padding: EdgeInsets.all(8.w),
                        child: CircularProgressIndicator(),
                      )
                    : null,
              ),
              onSubmitted: (_) => _processVoiceInput(),
            ),
            SizedBox(height: 12.h),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.mic),
                    label: Text('Listen'),
                    onPressed: () {
                      setState(() => _isListening = !_isListening);
                      // Would trigger voice recognition here
                    },
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.send),
                    label: Text('Process'),
                    onPressed: _processVoiceInput,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            // Command help
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Commands:',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  ...[
                    'create note / new note',
                    'create todo / add task',
                    'start focus / pomodoro',
                    'pause / stop',
                    'reflect',
                    'search',
                  ].map(
                    (cmd) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      child: Text(
                        '• $cmd',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.infoDark,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Voice settings panel (now using BLoC)
class VoiceSettingsPanel extends StatelessWidget {
  final VoidCallback? onClose;

  const VoiceSettingsPanel({super.key, this.onClose});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VoiceCommandBloc, VoiceCommandState>(
      builder: (context, state) => ListView(
        children: [
          SwitchListTile(
            title: const Text('Voice Commands'),
            subtitle: const Text('Enable voice input'),
            value: state is! VoiceCommandInitial,
            onChanged: (value) {
              context.read<VoiceCommandBloc>().add(
                value
                    ? const StartListeningEvent()
                    : const StopListeningEvent(),
              );
            },
          ),
          if (state is VoiceCommandFeedbackToggled) ...[
            SwitchListTile(
              title: Text('Command Feedback Sound'),
              subtitle: Text('Play sound when command is recognized'),
              value: (state).soundEnabled,
              onChanged: (value) {
                context.read<VoiceCommandBloc>().add(
                  ToggleSoundFeedbackEvent(value),
                );
              },
            ),
            SwitchListTile(
              title: Text('Vibration Feedback'),
              subtitle: Text('Vibrate when command is recognized'),
              value: (state).vibrationEnabled,
              onChanged: (value) {
                context.read<VoiceCommandBloc>().add(
                  ToggleVibrationFeedbackEvent(value),
                );
              },
            ),
          ] else ...[
            SwitchListTile(
              title: Text('Command Feedback Sound'),
              subtitle: Text('Play sound when command is recognized'),
              value: true,
              onChanged: (value) {
                context.read<VoiceCommandBloc>().add(
                  ToggleSoundFeedbackEvent(value),
                );
              },
            ),
            SwitchListTile(
              title: Text('Vibration Feedback'),
              subtitle: Text('Vibrate when command is recognized'),
              value: true,
              onChanged: (value) {
                context.read<VoiceCommandBloc>().add(
                  ToggleVibrationFeedbackEvent(value),
                );
              },
            ),
          ],
          Divider(),
          ListTile(
            title: Text('Available Commands'),
            trailing: Icon(Icons.info_outline),
          ),
          ...VoiceCommandParser.commandPatterns.values.toSet().map((cmd) {
            return ListTile(
              leading: Icon(Icons.keyboard_voice),
              title: Text(VoiceCommandParser.getCommandDescription(cmd)),
              dense: true,
            );
          }),
        ],
      ),
    );
  }
}
