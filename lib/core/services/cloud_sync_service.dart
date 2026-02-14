import 'package:connectivity_plus/connectivity_plus.dart';

/// Cloud Sync Service for preparing sync timestamps and conflict resolution
class CloudSyncService {
  static final CloudSyncService _instance = CloudSyncService._internal();

  CloudSyncService._internal();

  factory CloudSyncService() {
    return _instance;
  }

  /// Prepare sync data with timestamps
  Future<Map<String, dynamic>> prepareSyncData({
    required List<Map<String, dynamic>> notes,
    required List<Map<String, dynamic>> todos,
    required List<Map<String, dynamic>> reminders,
  }) async {
    try {
      final now = DateTime.now();
      
      return {
        'timestamp': now.toIso8601String(),
        'notes': notes.map((n) => {
          ...n,
          'syncTimestamp': now.toIso8601String(),
        }).toList(),
        'todos': todos.map((t) => {
          ...t,
          'syncTimestamp': now.toIso8601String(),
        }).toList(),
        'reminders': reminders.map((r) => {
          ...r,
          'syncTimestamp': now.toIso8601String(),
        }).toList(),
      };
    } catch (e) {
      print('Sync preparation error: ');
      return {};
    }
  }

  /// Resolve conflicts using last-write-wins strategy
  Future<Map<String, dynamic>> resolveConflict({
    required Map<String, dynamic> localVersion,
    required Map<String, dynamic> remoteVersion,
  }) async {
    try {
      final localTime = DateTime.parse(localVersion['updatedAt'] ?? '');
      final remoteTime = DateTime.parse(remoteVersion['updatedAt'] ?? '');
      
      // Last write wins
      if (localTime.isAfter(remoteTime)) {
        return {...localVersion, 'syncStatus': 'local_newer'};
      } else {
        return {...remoteVersion, 'syncStatus': 'remote_newer'};
      }
    } catch (e) {
      print('Conflict resolution error: ');
      return localVersion;
    }
  }

  /// Resolve conflicts using 3-way merge
  Future<Map<String, dynamic>> threeWayMerge({
    required Map<String, dynamic> baseVersion,
    required Map<String, dynamic> localVersion,
    required Map<String, dynamic> remoteVersion,
  }) async {
    try {
      final merged = <String, dynamic>{...baseVersion};
      
      // Merge local changes
      for (final key in localVersion.keys) {
        if (baseVersion[key] != localVersion[key]) {
          merged[key] = localVersion[key];
        }
      }
      
      // Merge remote changes (remote takes precedence if both changed)
      for (final key in remoteVersion.keys) {
        if (baseVersion[key] != remoteVersion[key]) {
          merged[key] = remoteVersion[key];
        }
      }
      
      return merged;
    } catch (e) {
      print('Three-way merge error: ');
      return localVersion;
    }
  }

  /// Check sync readiness
  Future<bool> isSyncReady() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
      return false;
    }
    // In a real app, also check if user is authenticated
    return true;
  }
}
