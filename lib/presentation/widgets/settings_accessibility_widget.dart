import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/presentation/bloc/settings/settings_bloc.dart';
import 'package:mynotes/presentation/bloc/accessibility_features/accessibility_features_bloc.dart';

/// Encrypted preferences service (SEC-003)
class EncryptedPreferencesService extends ChangeNotifier {
  bool _isEncryptionEnabled = true;
  final Map<String, String> _encryptedData = {};

  bool get isEncryptionEnabled => _isEncryptionEnabled;

  /// Store encrypted value
  Future<void> storeEncrypted(String key, String value) async {
    // In real app, would use flutter_secure_storage or similar
    _encryptedData[key] = value;
    notifyListeners();
  }

  /// Retrieve encrypted value
  Future<String?> retrieveEncrypted(String key) async {
    return _encryptedData[key];
  }

  /// Toggle encryption
  void setEncryptionEnabled(bool enabled) {
    _isEncryptionEnabled = enabled;
    notifyListeners();
  }
}

/// Storage settings panel (SET-005) - Now using BLoC
class StorageSettingsPanel extends StatelessWidget {
  final VoidCallback? onClose;

  const StorageSettingsPanel({super.key, this.onClose});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        if (state is! SettingsLoaded) {
          return Center(child: CircularProgressIndicator());
        }

        return Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Storage Settings',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                SwitchListTile(
                  title: Text('Auto Backup'),
                  subtitle: Text('Automatically backup data'),
                  value: state.autoBackupEnabled,
                  onChanged: (value) {
                    context.read<SettingsBloc>().add(
                      UpdateSettingsEvent.toggleCloudSync(state.params),
                    );
                  },
                  contentPadding: EdgeInsets.zero,
                ),
                if (state.autoBackupEnabled) ...[
                  SizedBox(height: 12),
                  ListTile(
                    title: Text('Backup Frequency'),
                    subtitle: Text(state.backupFrequency),
                    trailing: DropdownButton<String>(
                      value: state.backupFrequency,
                      items: ['daily', 'weekly', 'monthly']
                          .map(
                            (freq) => DropdownMenuItem(
                              value: freq,
                              child: Text(freq),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          context.read<SettingsBloc>().add(
                            UpdateSettingsEvent(
                              state.params.copyWith(
                                notificationFrequency: value,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Default settings panel (SET-007) - Now using BLoC
class DefaultSettingsPanel extends StatelessWidget {
  final VoidCallback? onClose;

  const DefaultSettingsPanel({super.key, this.onClose});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        if (state is! SettingsLoaded) {
          return Center(child: CircularProgressIndicator());
        }

        return Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Default Settings',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                ListTile(
                  title: Text('Font Family'),
                  subtitle: Text(state.fontFamily),
                  trailing: DropdownButton<String>(
                    value: state.fontFamily,
                    items: ['Roboto', 'OpenSans', 'Lato']
                        .map(
                          (font) =>
                              DropdownMenuItem(value: font, child: Text(font)),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        context.read<SettingsBloc>().add(
                          UpdateSettingsEvent(state.params.copyWith()),
                        );
                      }
                    },
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  title: Text('Language'),
                  subtitle: Text(state.languageCode),
                  trailing: DropdownButton<String>(
                    value: state.languageCode,
                    items: ['en', 'es', 'fr']
                        .map(
                          (lang) =>
                              DropdownMenuItem(value: lang, child: Text(lang)),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        context.read<SettingsBloc>().add(
                          UpdateSettingsEvent(
                            state.params.copyWith(language: value),
                          ),
                        );
                      }
                    },
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
                SizedBox(height: 12),
                SwitchListTile(
                  title: Text('Dark Mode'),
                  subtitle: Text('Use dark theme'),
                  value: state.darkModeEnabled,
                  onChanged: (value) {
                    context.read<SettingsBloc>().add(
                      UpdateSettingsEvent.toggleDarkMode(state.params),
                    );
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Quick stats widget for dashboard (DSH-004)
class QuickStatsWidget extends StatelessWidget {
  final int notesCount;
  final int todosCount;
  final int todosCompleted;
  final int reflectionsCount;

  const QuickStatsWidget({
    super.key,
    required this.notesCount,
    required this.todosCount,
    required this.todosCompleted,
    required this.reflectionsCount,
  });

  @override
  Widget build(BuildContext context) {
    final completionPercent = todosCount > 0
        ? ((todosCompleted / todosCount) * 100).toInt()
        : 0;

    return Column(
      children: [
        // Stats grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _buildStatCard(
              context,
              'Notes',
              '$notesCount',
              Icons.note,
              Colors.blue,
            ),
            _buildStatCard(
              context,
              'Tasks',
              '$todosCount',
              Icons.check_circle,
              Colors.green,
            ),
            _buildStatCard(
              context,
              'Completed',
              '$todosCompleted',
              Icons.done_all,
              Colors.orange,
            ),
            _buildStatCard(
              context,
              'Reflections',
              '$reflectionsCount',
              Icons.favorite,
              Colors.red,
            ),
          ],
        ),
        SizedBox(height: 16),
        // Completion gauge
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Task Completion',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    Text(
                      '$completionPercent%',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: completionPercent / 100,
                    strokeWidth: 6,
                    valueColor: AlwaysStoppedAnimation(Colors.green),
                    backgroundColor: Colors.grey.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

/// Accessibility settings widget - Now using BLoC
class AccessibilitySettingsWidget extends StatelessWidget {
  final VoidCallback? onClose;

  const AccessibilitySettingsWidget({super.key, this.onClose});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        if (state is! SettingsLoaded) {
          return Center(child: CircularProgressIndicator());
        }

        return Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Accessibility',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                // Accessibility features (A11Y-004/005)
                SwitchListTile(
                  title: Text('Enable Accessibility'),
                  subtitle: Text(
                    'Enhanced navigation and screen reader support',
                  ),
                  value: state.accessibilityEnabled,
                  onChanged: (value) {
                    context.read<SettingsBloc>().add(
                      UpdateSettingsEvent.toggleNotifications(state.params),
                    );
                  },
                  contentPadding: EdgeInsets.zero,
                ),
                SizedBox(height: 16),
                // Text scaling
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Text Scaling (${state.fontSize})',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    SizedBox(height: 8),
                    Slider(
                      value: state.fontSize.toDouble(),
                      min: 12,
                      max: 24,
                      divisions: 6,
                      label: state.fontSize.toString(),
                      onChanged: (value) {
                        context.read<SettingsBloc>().add(
                          UpdateSettingsEvent(
                            state.params.copyWith(
                              fontSizePreference: value < 14
                                  ? 'small'
                                  : value > 16
                                  ? 'large'
                                  : 'medium',
                            ),
                          ),
                        );
                      },
                    ),
                    Text(
                      'Preview text with current scaling',
                      style: TextStyle(fontSize: state.fontSize.toDouble()),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
