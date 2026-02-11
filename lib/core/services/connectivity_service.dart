import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mynotes/core/services/global_ui_service.dart';
import 'package:mynotes/injection_container.dart';
import 'package:mynotes/core/services/app_logger.dart';

/// Professional Connectivity Service
/// Monitors network state and provides feedback
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isFirstCheck = true;

  void initialize() {
    _subscription = _connectivity.onConnectivityChanged.listen(
      _handleStatusChange,
    );
  }

  void _handleStatusChange(List<ConnectivityResult> results) {
    if (_isFirstCheck) {
      _isFirstCheck = false;
      return; // Skip initial status on app start
    }

    final result = results.isNotEmpty ? results.last : ConnectivityResult.none;
    if (result == ConnectivityResult.none) {
      AppLogger.w('Internet connection lost');
      getIt<GlobalUiService>().showWarning('No internet connection');
    } else {
      AppLogger.i('Internet connection restored: $result');
      getIt<GlobalUiService>().showSuccess('Connected to internet');
    }
  }

  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  void dispose() {
    _subscription?.cancel();
  }
}
