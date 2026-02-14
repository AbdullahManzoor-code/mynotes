import 'package:flutter/material.dart';

/// Activity tag for reflection answers (ANS-003)
class ActivityTag {
  final String id;
  final String name;
  final Color color;
  final String? icon;
  bool isSelected;

  ActivityTag({
    required this.id,
    required this.name,
    this.color = Colors.blue,
    this.icon,
    this.isSelected = false,
  });

  ActivityTag copyWith({
    String? id,
    String? name,
    Color? color,
    String? icon,
    bool? isSelected,
  }) {
    return ActivityTag(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  static List<ActivityTag> getDefaultTags() {
    return [
      ActivityTag(id: '1', name: 'Work', color: Colors.blue, icon: '💼'),
      ActivityTag(id: '2', name: 'Exercise', color: Colors.green, icon: '💪'),
      ActivityTag(id: '3', name: 'Learning', color: Colors.purple, icon: '📚'),
      ActivityTag(id: '4', name: 'Social', color: Colors.pink, icon: '👥'),
      ActivityTag(id: '5', name: 'Hobby', color: Colors.orange, icon: '🎨'),
      ActivityTag(
        id: '6',
        name: 'Family',
        color: Colors.red,
        icon: '👨‍👩‍👧‍👦',
      ),
      ActivityTag(id: '7', name: 'Travel', color: Colors.teal, icon: '✈️'),
      ActivityTag(id: '8', name: 'Health', color: Colors.cyan, icon: '🏥'),
    ];
  }
}

/// Activity tag selector widget
class ActivityTagSelector extends StatefulWidget {
  final List<ActivityTag> availableTags;
  final List<String> selectedTagIds;
  final ValueChanged<List<String>> onTagsSelected;

  const ActivityTagSelector({
    super.key,
    required this.availableTags,
    required this.selectedTagIds,
    required this.onTagsSelected,
  });

  @override
  State<ActivityTagSelector> createState() => _ActivityTagSelectorState();
}

class _ActivityTagSelectorState extends State<ActivityTagSelector> {
  late List<String> _selectedTags;

  @override
  void initState() {
    super.initState();
    _selectedTags = List.from(widget.selectedTagIds);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activity Tags',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.availableTags.map((tag) {
            final isSelected = _selectedTags.contains(tag.id);
            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (tag.icon != null) ...[
                    Text(tag.icon!),
                    SizedBox(width: 4),
                  ],
                  Text(tag.name),
                ],
              ),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  if (isSelected) {
                    _selectedTags.remove(tag.id);
                  } else {
                    _selectedTags.add(tag.id);
                  }
                  widget.onTagsSelected(_selectedTags);
                });
              },
              backgroundColor: tag.color.withOpacity(0.1),
              selectedColor: tag.color.withOpacity(0.3),
              labelStyle: TextStyle(
                color: isSelected ? Colors.black : Colors.grey[700],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Activity tag display widget
class ActivityTagDisplay extends StatelessWidget {
  final List<ActivityTag> tags;

  const ActivityTagDisplay({super.key, required this.tags});

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) return SizedBox.shrink();

    return Wrap(
      spacing: 8,
      children: tags.map((tag) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: tag.color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: tag.color.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (tag.icon != null) ...[Text(tag.icon!), SizedBox(width: 4)],
              Text(
                tag.name,
                style: TextStyle(
                  color: tag.color,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Privacy mode settings (ANS-005)
class PrivacyMode {
  bool isPrivacyModeEnabled;
  bool requireBiometricToView;
  bool hideFromRecents;
  List<String> privateAnswerIds; // Answer IDs marked as private

  PrivacyMode({
    this.isPrivacyModeEnabled = false,
    this.requireBiometricToView = true,
    this.hideFromRecents = false,
    this.privateAnswerIds = const [],
  });

  PrivacyMode copyWith({
    bool? isPrivacyModeEnabled,
    bool? requireBiometricToView,
    bool? hideFromRecents,
    List<String>? privateAnswerIds,
  }) {
    return PrivacyMode(
      isPrivacyModeEnabled: isPrivacyModeEnabled ?? this.isPrivacyModeEnabled,
      requireBiometricToView:
          requireBiometricToView ?? this.requireBiometricToView,
      hideFromRecents: hideFromRecents ?? this.hideFromRecents,
      privateAnswerIds: privateAnswerIds ?? this.privateAnswerIds,
    );
  }
}

/// Privacy settings panel widget
class PrivacySettingsPanel extends StatefulWidget {
  final PrivacyMode initialSettings;
  final ValueChanged<PrivacyMode> onSettingsChanged;

  const PrivacySettingsPanel({
    super.key,
    required this.initialSettings,
    required this.onSettingsChanged,
  });

  @override
  State<PrivacySettingsPanel> createState() => _PrivacySettingsPanelState();
}

class _PrivacySettingsPanelState extends State<PrivacySettingsPanel> {
  late PrivacyMode settings;

  @override
  void initState() {
    super.initState();
    settings = widget.initialSettings;
  }

  void _updateSettings(PrivacyMode newSettings) {
    setState(() => settings = newSettings);
    widget.onSettingsChanged(newSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Mode',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            // Main privacy toggle
            SwitchListTile(
              title: Text('Enable Privacy Mode'),
              subtitle: Text('Add extra protection to sensitive reflections'),
              value: settings.isPrivacyModeEnabled,
              onChanged: (value) {
                _updateSettings(settings.copyWith(isPrivacyModeEnabled: value));
              },
              contentPadding: EdgeInsets.zero,
            ),
            if (settings.isPrivacyModeEnabled) ...[
              SizedBox(height: 12),
              // Biometric requirement
              SwitchListTile(
                title: Text('Require Biometric'),
                subtitle: Text('Authenticate before viewing private entries'),
                value: settings.requireBiometricToView,
                onChanged: (value) {
                  _updateSettings(
                    settings.copyWith(requireBiometricToView: value),
                  );
                },
                contentPadding: EdgeInsets.zero,
              ),
              SizedBox(height: 12),
              // Hide from recents
              SwitchListTile(
                title: Text('Hide from Recents'),
                subtitle: Text('Do not show private entries in recent lists'),
                value: settings.hideFromRecents,
                onChanged: (value) {
                  _updateSettings(settings.copyWith(hideFromRecents: value));
                },
                contentPadding: EdgeInsets.zero,
              ),
              SizedBox(height: 16),
              // Info box
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock, color: Colors.orange, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Private entries are encrypted and require authentication',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Private answer indicator widget
class PrivateAnswerIndicator extends StatelessWidget {
  final bool isPrivate;
  final VoidCallback? onTap;

  const PrivateAnswerIndicator({
    super.key,
    required this.isPrivate,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!isPrivate) return SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock, size: 12, color: Colors.red),
            SizedBox(width: 4),
            Text(
              'Private',
              style: TextStyle(
                fontSize: 10,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
