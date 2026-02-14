import 'package:flutter/material.dart';
import 'package:mynotes/core/services/location_permission_manager.dart';
import 'package:mynotes/injection_container.dart' show getIt;
import 'package:mynotes/core/services/global_ui_service.dart';

/// Permission Request Dialog
/// Shows a dialog requesting various permissions for location reminders
class LocationPermissionDialog extends StatefulWidget {
  final VoidCallback? onPermissionsGranted;
  final VoidCallback? onPermissionsDenied;

  const LocationPermissionDialog({
    super.key,
    this.onPermissionsGranted,
    this.onPermissionsDenied,
  });

  @override
  State<LocationPermissionDialog> createState() =>
      _LocationPermissionDialogState();
}

class _LocationPermissionDialogState extends State<LocationPermissionDialog> {
  final _permissionManager = LocationPermissionManager();
  bool _isLoading = false;
  int _currentStep = 0;

  final List<_PermissionStep> _permissionSteps = [
    _PermissionStep(
      title: 'Location Permission',
      description:
          'We need access to your current location to create location-based reminders.',
      icon: Icons.location_on,
      permission: 'location',
    ),
    _PermissionStep(
      title: 'Background Location',
      description:
          'We need background location access to trigger reminders even when the app is closed.',
      icon: Icons.location_on_outlined,
      permission: 'locationAlways',
    ),
    _PermissionStep(
      title: 'Notifications',
      description:
          'We need permission to send you notifications when you enter or leave a location.',
      icon: Icons.notifications_active,
      permission: 'notification',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _checkExistingPermissions();
  }

  Future<void> _checkExistingPermissions() async {
    // Skip already granted permissions
    while (_currentStep < _permissionSteps.length) {
      final isGranted = await _isPermissionGranted(
        _permissionSteps[_currentStep].permission,
      );
      if (isGranted) {
        setState(() => _currentStep++);
      } else {
        break;
      }
    }
  }

  Future<bool> _isPermissionGranted(String permission) async {
    switch (permission) {
      case 'location':
        return await _permissionManager.isLocationPermissionGranted();
      case 'locationAlways':
        return await _permissionManager.isBackgroundLocationPermissionGranted();
      case 'notification':
        return await _permissionManager.isNotificationPermissionGranted();
      default:
        return false;
    }
  }

  Future<void> _requestCurrentPermission() async {
    if (_currentStep >= _permissionSteps.length) {
      widget.onPermissionsGranted?.call();
      Navigator.pop(context);
      return;
    }

    setState(() => _isLoading = true);

    try {
      bool granted = false;

      switch (_permissionSteps[_currentStep].permission) {
        case 'location':
          granted =
              await _permissionManager.isLocationPermissionGranted() ||
              await _permissionManager.isLocationPermissionGranted();
          break;
        case 'locationAlways':
          granted =
              await _permissionManager
                  .isBackgroundLocationPermissionGranted() ||
              await _permissionManager.isBackgroundLocationPermissionGranted();
          break;
        case 'notification':
          granted = await _permissionManager.requestNotificationPermission();
          break;
      }

      if (granted) {
        setState(() => _currentStep++);
        await Future.delayed(const Duration(milliseconds: 500));

        if (_currentStep >= _permissionSteps.length) {
          widget.onPermissionsGranted?.call();
          if (mounted) Navigator.pop(context);
        }
      } else {
        _showPermissionDeniedSnackbar();
      }
    } catch (e) {
      _showErrorSnackbar('Error requesting permission: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showPermissionDeniedSnackbar() {
    getIt<GlobalUiService>().showWarning(
      '${_permissionSteps[_currentStep].title} permission is required for this feature.',
      actionLabel: 'Settings',
      onActionPressed: () => _permissionManager.openAppSettings(),
    );
  }

  void _showErrorSnackbar(String message) {
    getIt<GlobalUiService>().showError(message);
  }

  void _skipPermission() {
    setState(() => _currentStep++);
    if (_currentStep >= _permissionSteps.length) {
      widget.onPermissionsDenied?.call();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = _permissionSteps[_currentStep];

    return AlertDialog(
      title: Text(currentStep.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(currentStep.icon, size: 40, color: Colors.blue),
            ),
            const SizedBox(height: 24),

            // Description
            Text(
              currentStep.description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            // Progress indicator
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (_currentStep + 1) / _permissionSteps.length,
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Step ${_currentStep + 1} of ${_permissionSteps.length}',
              style: Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : _skipPermission,
          child: const Text('Skip'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _requestCurrentPermission,
          child: _isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                )
              : const Text('Continue'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _permissionManager.dispose();
    super.dispose();
  }
}

class _PermissionStep {
  final String title;
  final String description;
  final IconData icon;
  final String permission;

  _PermissionStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.permission,
  });
}

/// Permission Banner Widget
/// Shows a persistent banner when permissions are not granted
class LocationPermissionBanner extends StatefulWidget {
  final VoidCallback? onPermissionGranted;

  const LocationPermissionBanner({super.key, this.onPermissionGranted});

  @override
  State<LocationPermissionBanner> createState() =>
      _LocationPermissionBannerState();
}

class _LocationPermissionBannerState extends State<LocationPermissionBanner> {
  final _permissionManager = LocationPermissionManager();
  late Stream<Map<String, dynamic>> _permissionStream;

  @override
  void initState() {
    super.initState();
    _permissionStream = _permissionManager.permissionStatusStream;
  }

  Future<void> _checkAndRequestPermissions() async {
    final context = this.context;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LocationPermissionDialog(
        onPermissionsGranted: () {
          widget.onPermissionGranted?.call();
          setState(() {});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: _permissionStream,
      builder: (context, snapshot) {
        // Check permissions
        return FutureBuilder<bool>(
          future: _permissionManager.areAllPermissionsGranted(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox.shrink();
            }

            final areGranted = snapshot.data ?? false;

            if (areGranted) {
              return const SizedBox.shrink();
            }

            return Material(
              child: Container(
                color: Colors.orange[100],
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.orange[800]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Permissions Required',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(color: Colors.orange[800]),
                          ),
                          Text(
                            'Enable permissions for location reminders',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: Colors.orange[700]),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: _checkAndRequestPermissions,
                      child: Text(
                        'Enable',
                        style: TextStyle(color: Colors.orange[800]),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _permissionManager.dispose();
    super.dispose();
  }
}
