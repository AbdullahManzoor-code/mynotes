import 'package:flutter/material.dart';
import 'unified_settings_screen.dart';

/// DEPRECATED: Use [UnifiedSettingsScreen] instead
///
/// This screen has been merged into [UnifiedSettingsScreen] which combines
/// all advanced settings, quick actions, and developer tools in one unified
/// interface with tabbed navigation.
///
/// Features:
/// - Settings Tab: Appearance, Privacy, Notifications, Voice, Data Management
/// - Quick Actions Tab: Analytics, Search, Focus, Backup, Security
/// - Developer Tab: Developer tools and debug info (when enabled)
///
/// Migration: Replace AdvancedSettingsScreen() with UnifiedSettingsScreen()
class AdvancedSettingsScreen extends StatelessWidget {
  const AdvancedSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const UnifiedSettingsScreen();
  }
}
