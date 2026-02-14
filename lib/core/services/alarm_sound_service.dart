import 'package:flutter/material.dart';

/// Alarm sound configuration
enum AlarmSound {
  default_('Default', 'alarm_default'),
  bell('Bell', 'alarm_bell'),
  chime('Chime', 'alarm_chime'),
  digital('Digital', 'alarm_digital'),
  gentle('Gentle', 'alarm_gentle'),
  pulse('Pulse', 'alarm_pulse'),
  siren('Siren', 'alarm_siren'),
  wake_up('Wake Up', 'alarm_wake_up');

  final String displayName;
  final String assetPath;

  const AlarmSound(this.displayName, this.assetPath);
}

/// Alarm sound manager service
class AlarmSoundService {
  static const List<AlarmSound> availableSounds = AlarmSound.values;

  /// Get sound by name
  static AlarmSound getSoundByName(String name) {
    try {
      return AlarmSound.values.firstWhere((s) => s.name == name);
    } catch (e) {
      return AlarmSound.default_;
    }
  }

  /// Get all available sounds
  static List<AlarmSound> getAllSounds() {
    return availableSounds;
  }

  /// Play alarm sound (mock implementation)
  static Future<void> playSound(AlarmSound sound) async {
    // In real app: use flutter_ringtone_player or similar
    debugPrint('Playing sound: ${sound.displayName}');
    // await _audioPlayer.play(AssetSource(sound.assetPath));
  }

  /// Stop alarm sound
  static Future<void> stopSound() async {
    // In real app: stop the audio player
    debugPrint('Stopping sound');
    // await _audioPlayer.stop();
  }

  /// Test alarm sound
  static Future<void> testSound(AlarmSound sound) async {
    await playSound(sound);
    // Stop after 2 seconds
    await Future.delayed(Duration(seconds: 2));
    await stopSound();
  }
}

/// Alarm sound selector widget
class AlarmSoundSelector extends StatefulWidget {
  final AlarmSound selectedSound;
  final Function(AlarmSound) onSoundSelected;

  const AlarmSoundSelector({
    super.key,
    required this.selectedSound,
    required this.onSoundSelected,
  });

  @override
  State<AlarmSoundSelector> createState() => _AlarmSoundSelectorState();
}

class _AlarmSoundSelectorState extends State<AlarmSoundSelector> {
  AlarmSound? _testingSound;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Alarm Sound', style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: AlarmSoundService.getAllSounds().length,
          separatorBuilder: (_, __) => Divider(height: 1),
          itemBuilder: (context, index) {
            final sound = AlarmSoundService.getAllSounds()[index];
            final isTesting = _testingSound == sound;

            return ListTile(
              title: Text(sound.displayName),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      isTesting ? Icons.stop : Icons.play_arrow,
                      color: isTesting ? Colors.orange : Colors.grey,
                    ),
                    onPressed: () async {
                      if (isTesting) {
                        await AlarmSoundService.stopSound();
                        setState(() => _testingSound = null);
                      } else {
                        setState(() => _testingSound = sound);
                        await AlarmSoundService.testSound(sound);
                        setState(() => _testingSound = null);
                      }
                    },
                  ),
                  Radio<AlarmSound>(
                    value: sound,
                    groupValue: widget.selectedSound,
                    onChanged: (value) {
                      if (value != null) {
                        widget.onSoundSelected(value);
                      }
                    },
                  ),
                ],
              ),
              onTap: () => widget.onSoundSelected(sound),
            );
          },
        ),
      ],
    );
  }
}

/// Alarm sound settings panel
class AlarmSoundSettingsPanel extends StatefulWidget {
  final AlarmSound currentSound;
  final Function(AlarmSound) onSoundChanged;

  const AlarmSoundSettingsPanel({
    super.key,
    required this.currentSound,
    required this.onSoundChanged,
  });

  @override
  State<AlarmSoundSettingsPanel> createState() =>
      _AlarmSoundSettingsPanelState();
}

class _AlarmSoundSettingsPanelState extends State<AlarmSoundSettingsPanel> {
  late AlarmSound _selectedSound;

  @override
  void initState() {
    super.initState();
    _selectedSound = widget.currentSound;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: AlarmSoundSelector(
          selectedSound: _selectedSound,
          onSoundSelected: (sound) {
            setState(() => _selectedSound = sound);
            widget.onSoundChanged(sound);
          },
        ),
      ),
    );
  }
}
