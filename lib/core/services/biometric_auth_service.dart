import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for handling biometric authentication (fingerprint/face ID)
class BiometricAuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _lastAuthTimeKey = 'last_auth_time';

  /// Check if device supports biometric authentication
  Future<bool> isBiometricAvailable() async {
    try {
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheckBiometrics && isDeviceSupported;
    } catch (e) {
      print('Biometric availability check failed: $e');
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      print('Failed to get biometric types: $e');
      return [];
    }
  }

  /// Authenticate using biometrics
  /// Returns true if authenticated, false otherwise
  /// Throws exception with specific error message on failure
  Future<bool> authenticate({
    String reason = 'Please authenticate to access your notes',
    bool useErrorDialogs = true,
    bool stickyAuth = true,
  }) async {
    try {
      final bool canAuth = await isBiometricAvailable();
      if (!canAuth) {
        throw Exception(
          'Biometric authentication not available on this device',
        );
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason,
        persistAcrossBackgrounding: stickyAuth,
        biometricOnly: false,
      );

      if (didAuthenticate) {
        await _updateLastAuthTime();
      }

      return didAuthenticate;
    } on Exception {
      // Re-throw custom exceptions
      rethrow;
    } catch (e) {
      // Platform-specific errors
      if (e.toString().contains('NotAvailable')) {
        throw Exception('Biometric hardware not available');
      } else if (e.toString().contains('NotEnrolled')) {
        throw Exception(
          'No biometric credentials enrolled. Please set up fingerprint/face in device settings',
        );
      } else if (e.toString().contains('LockedOut')) {
        throw Exception('Too many failed attempts. Please try again later');
      } else if (e.toString().contains('PermanentlyLockedOut')) {
        throw Exception(
          'Biometric authentication permanently locked. Please unlock device first',
        );
      }
      throw Exception('Authentication failed: ${e.toString()}');
    }
  }

  /// Check if biometric lock is enabled
  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricEnabledKey) ?? false;
  }

  /// Enable biometric lock
  Future<void> enableBiometric() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.setBool(_biometricEnabledKey, true);
      if (!success) {
        throw Exception('Failed to save biometric setting');
      }
    } catch (e) {
      throw Exception('Could not enable biometric lock: $e');
    }
  }

  /// Disable biometric lock
  Future<void> disableBiometric() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.setBool(_biometricEnabledKey, false);
      if (!success) {
        throw Exception('Failed to save biometric setting');
      }
    } catch (e) {
      throw Exception('Could not disable biometric lock: $e');
    }
  }

  /// Update last authentication time
  Future<void> _updateLastAuthTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastAuthTimeKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Check if authentication is required (based on time)
  Future<bool> isAuthRequired({
    Duration timeout = const Duration(minutes: 5),
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final lastAuthTime = prefs.getInt(_lastAuthTimeKey);

    if (lastAuthTime == null) return true;

    final lastAuth = DateTime.fromMillisecondsSinceEpoch(lastAuthTime);
    final diff = DateTime.now().difference(lastAuth);

    return diff > timeout;
  }

  /// Get biometric type name for display
  String getBiometricTypeName(List<BiometricType> types) {
    if (types.isEmpty) return 'Biometric';

    if (types.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (types.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    } else if (types.contains(BiometricType.iris)) {
      return 'Iris';
    }

    return 'Biometric';
  }
}
