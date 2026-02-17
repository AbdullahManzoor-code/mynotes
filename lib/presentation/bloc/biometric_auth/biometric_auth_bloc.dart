import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import '../../../core/services/biometric_auth_service.dart';

// Events
abstract class BiometricAuthEvent extends Equatable {
  const BiometricAuthEvent();
  @override
  List<Object?> get props => [];
}

class CheckBiometricsEvent extends BiometricAuthEvent {}

class AuthenticateEvent extends BiometricAuthEvent {
  final String reason;
  const AuthenticateEvent({this.reason = 'Unlock your notes'});
  @override
  List<Object?> get props => [reason];
}

// States
abstract class BiometricAuthState extends Equatable {
  const BiometricAuthState();
  @override
  List<Object?> get props => [];
}

class BiometricAuthInitial extends BiometricAuthState {}

class BiometricAuthLoading extends BiometricAuthState {
  final List<BiometricType> availableBiometrics;
  const BiometricAuthLoading({this.availableBiometrics = const []});
  @override
  List<Object?> get props => [availableBiometrics];
}

class BiometricAuthChecking extends BiometricAuthState {}

class BiometricAuthReady extends BiometricAuthState {
  final List<BiometricType> availableBiometrics;
  final String message;
  final bool isAuthenticating;

  const BiometricAuthReady({
    required this.availableBiometrics,
    this.message = 'Tap to unlock',
    this.isAuthenticating = false,
  });

  BiometricAuthReady copyWith({
    List<BiometricType>? availableBiometrics,
    String? message,
    bool? isAuthenticating,
  }) {
    return BiometricAuthReady(
      availableBiometrics: availableBiometrics ?? this.availableBiometrics,
      message: message ?? this.message,
      isAuthenticating: isAuthenticating ?? this.isAuthenticating,
    );
  }

  @override
  List<Object?> get props => [availableBiometrics, message, isAuthenticating];
}

class BiometricAuthenticated extends BiometricAuthState {}

class BiometricAuthFailure extends BiometricAuthState {
  final List<BiometricType> availableBiometrics;
  final String message;

  const BiometricAuthFailure({
    required this.availableBiometrics,
    required this.message,
  });

  @override
  List<Object?> get props => [availableBiometrics, message];
}

// BLoC
class BiometricAuthBloc extends Bloc<BiometricAuthEvent, BiometricAuthState> {
  final BiometricAuthService _authService;
  List<BiometricType> _availableBiometrics = [];

  BiometricAuthBloc({required BiometricAuthService authService})
    : _authService = authService,
      super(BiometricAuthInitial()) {
    on<CheckBiometricsEvent>(_onCheckBiometrics);
    on<AuthenticateEvent>(_onAuthenticate);
  }

  Future<void> _onCheckBiometrics(
    CheckBiometricsEvent event,
    Emitter<BiometricAuthState> emit,
  ) async {
    emit(BiometricAuthChecking());
    _availableBiometrics = await _authService.getAvailableBiometrics();
    emit(BiometricAuthReady(availableBiometrics: _availableBiometrics));
  }

  Future<void> _onAuthenticate(
    AuthenticateEvent event,
    Emitter<BiometricAuthState> emit,
  ) async {
    if (state is BiometricAuthReady &&
        (state as BiometricAuthReady).isAuthenticating) {
      return;
    }

    final currentAvailable = _availableBiometrics;

    emit(
      BiometricAuthReady(
        availableBiometrics: currentAvailable,
        isAuthenticating: true,
        message: 'Authenticating...',
      ),
    );

    final authenticated = await _authService.authenticate(
      reason: event.reason,
      useErrorDialogs: true,
      stickyAuth: true,
    );

    if (authenticated) {
      emit(BiometricAuthenticated());
    } else {
      emit(
        BiometricAuthFailure(
          availableBiometrics: currentAvailable,
          message: 'Authentication failed. Tap to retry',
        ),
      );
      // Re-emit ready but with failure message so user can retry
      emit(
        BiometricAuthReady(
          availableBiometrics: currentAvailable,
          message: 'Authentication failed. Tap to retry',
          isAuthenticating: false,
        ),
      );
    }
  }
}
