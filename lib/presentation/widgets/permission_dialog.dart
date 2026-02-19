import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/permission_handler_service.dart';

/// Permission request dialog widget
class PermissionDialog extends StatelessWidget {
  final Permission permission;
  final String? customMessage;
  final VoidCallback? onGranted;

  const PermissionDialog({
    super.key,
    required this.permission,
    this.customMessage,
    this.onGranted,
  });

  static Future<bool?> show(
    BuildContext context, {
    required Permission permission,
    String? customMessage,
    VoidCallback? onGranted,
  }) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PermissionDialog(
        permission: permission,
        customMessage: customMessage,
        onGranted: onGranted,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = PermissionHandlerService();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      title: Row(
        children: [
          Icon(
            _getPermissionIcon(),
            color: AppColors.primaryColor,
            size: 24.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              '${service.getPermissionName(permission)} Permission',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        customMessage ?? service.getPermissionRationale(permission),
        style: TextStyle(
          fontSize: 14.sp,
          color: isDark ? Colors.white70 : Colors.black87,
          height: 1.5,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            'Not Now',
            style: TextStyle(color: Colors.grey, fontSize: 14.sp),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            final granted = await service.checkAndRequestPermission(
              permission,
              onGranted: onGranted,
              onPermanentlyDenied: () async {
                if (context.mounted) {
                  Navigator.pop(context, false);
                  await _showSettingsDialog(context, service);
                }
              },
            );

            if (context.mounted) {
              Navigator.pop(context, granted);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          ),
          child: Text(
            'Allow',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  IconData _getPermissionIcon() {
    if (permission == Permission.camera) {
      return Icons.camera_alt;
    } else if (permission == Permission.microphone) {
      return Icons.mic;
    } else if (permission == Permission.storage ||
        permission == Permission.photos) {
      return Icons.photo_library;
    } else if (permission == Permission.notification) {
      return Icons.notifications;
    } else if (permission == Permission.speech) {
      return Icons.keyboard_voice;
    }
    return Icons.settings;
  }

  static Future<void> _showSettingsDialog(
    BuildContext context,
    PermissionHandlerService service,
  ) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Row(
          children: [
            Icon(Icons.settings, color: AppColors.primaryColor, size: 24.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'Permission Required',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'This permission was previously denied. Please enable it in Settings to continue.',
          style: TextStyle(
            fontSize: 14.sp,
            color: isDark ? Colors.white70 : Colors.black87,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey, fontSize: 14.sp),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
            child: Text(
              'Open Settings',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

/// Permission status screen showing all permissions
class PermissionStatusScreen extends StatefulWidget {
  const PermissionStatusScreen({super.key});

  @override
  State<PermissionStatusScreen> createState() => _PermissionStatusScreenState();
}

class _PermissionStatusScreenState extends State<PermissionStatusScreen> {
  final PermissionHandlerService _service = PermissionHandlerService();
  Map<Permission, PermissionStatus> _permissions = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    setState(() => _isLoading = true);
    _permissions = await _service.checkAllPermissions();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      appBar: AppBar(
        title: const Text('Permissions'),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkPermissions,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(20.w),
              children: [
                Text(
                  'App Permissions',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Manage permissions required for app features',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                ),
                SizedBox(height: 24.h),
                ..._permissions.entries.map((entry) {
                  return _buildPermissionTile(entry.key, entry.value, isDark);
                }),
                SizedBox(height: 24.h),
                ElevatedButton.icon(
                  onPressed: () async {
                    await _service.requestEssentialPermissions();
                    await _checkPermissions();
                  },
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Request All Permissions'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPermissionTile(
    Permission permission,
    PermissionStatus status,
    bool isDark,
  ) {
    final isGranted = status.isGranted;

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      color: isDark ? AppColors.surfaceDark : Colors.white,
      elevation: 1,
      child: ListTile(
        leading: Icon(
          _getPermissionIcon(permission),
          color: isGranted ? AppColors.successColor : Colors.grey,
          size: 24.sp,
        ),
        title: Text(
          _service.getPermissionName(permission),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Text(
          _service.getPermissionStatusMessage(status),
          style: TextStyle(
            fontSize: 12.sp,
            color: isGranted ? AppColors.successColor : Colors.grey,
          ),
        ),
        trailing: isGranted
            ? Icon(
                Icons.check_circle,
                color: AppColors.successColor,
                size: 20.sp,
              )
            : TextButton(
                onPressed: () async {
                  await _service.checkAndRequestPermission(permission);
                  await _checkPermissions();
                },
                child: const Text('Enable'),
              ),
      ),
    );
  }

  IconData _getPermissionIcon(Permission permission) {
    if (permission == Permission.camera) {
      return Icons.camera_alt;
    } else if (permission == Permission.microphone) {
      return Icons.mic;
    } else if (permission == Permission.storage ||
        permission == Permission.photos) {
      return Icons.photo_library;
    } else if (permission == Permission.notification) {
      return Icons.notifications;
    }
    return Icons.settings;
  }
}


