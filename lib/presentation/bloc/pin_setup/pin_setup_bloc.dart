import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

// Events
abstract class PinSetupEvent extends Equatable {
  const PinSetupEvent();

  @override
  List<Object?> get props => [];
}

class EnteredPin extends PinSetupEvent {
  final String pinValue;
  const EnteredPin(this.pinValue);

  @override
  List<Object?> get props => [pinValue];
}

class PinChanged extends PinSetupEvent {
  const PinChanged();
}

class ResetPin extends PinSetupEvent {
  const ResetPin();
}

// State
class PinSetupState extends Equatable {
  final String pin;
  final String confirmPin;
  final String currentPin;
  final bool isConfirming;
  final bool isVerifyingCurrent;
  final String errorMessage;
  final bool isSuccess;
  final bool isFirstSetup;
  final bool isChanging;

  const PinSetupState({
    this.pin = '',
    this.confirmPin = '',
    this.currentPin = '',
    this.isConfirming = false,
    this.isVerifyingCurrent = false,
    this.errorMessage = '',
    this.isSuccess = false,
    this.isFirstSetup = false,
    this.isChanging = false,
  });

  PinSetupState copyWith({
    String? pin,
    String? confirmPin,
    String? currentPin,
    bool? isConfirming,
    bool? isVerifyingCurrent,
    String? errorMessage,
    bool? isSuccess,
    bool? isFirstSetup,
    bool? isChanging,
  }) {
    return PinSetupState(
      pin: pin ?? this.pin,
      confirmPin: confirmPin ?? this.confirmPin,
      currentPin: currentPin ?? this.currentPin,
      isConfirming: isConfirming ?? this.isConfirming,
      isVerifyingCurrent: isVerifyingCurrent ?? this.isVerifyingCurrent,
      errorMessage: errorMessage ?? this.errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
      isFirstSetup: isFirstSetup ?? this.isFirstSetup,
      isChanging: isChanging ?? this.isChanging,
    );
  }

  @override
  List<Object?> get props => [
    pin,
    confirmPin,
    currentPin,
    isConfirming,
    isVerifyingCurrent,
    errorMessage,
    isSuccess,
    isFirstSetup,
    isChanging,
  ];
}

// Bloc
class PinSetupBloc extends Bloc<PinSetupEvent, PinSetupState> {
  static const String _pinHashKey = 'pin_hash';
  static const String _pinEnabledKey = 'pin_enabled';

  PinSetupBloc({required bool isFirstSetup, required bool isChanging})
    : super(
        PinSetupState(
          isFirstSetup: isFirstSetup,
          isChanging: isChanging,
          isVerifyingCurrent: isChanging,
        ),
      ) {
    on<EnteredPin>(_onEnteredPin);
    on<PinChanged>(_onPinChanged);
    on<ResetPin>(_onResetPin);
  }

  void _onPinChanged(PinChanged event, Emitter<PinSetupState> emit) {
    emit(state.copyWith(errorMessage: ''));
  }

  void _onResetPin(ResetPin event, Emitter<PinSetupState> emit) {
    emit(
      state.copyWith(
        pin: '',
        confirmPin: '',
        isConfirming: false,
        errorMessage: '',
      ),
    );
  }

  Future<void> _onEnteredPin(
    EnteredPin event,
    Emitter<PinSetupState> emit,
  ) async {
    final value = event.pinValue;

    if (state.isVerifyingCurrent) {
      await _verifyCurrentPin(value, emit);
    } else if (state.isConfirming) {
      await _confirmPinSetup(value, emit);
    } else {
      emit(state.copyWith(pin: value, isConfirming: true, errorMessage: ''));
    }
  }

  Future<void> _verifyCurrentPin(
    String value,
    Emitter<PinSetupState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedHash = prefs.getString(_pinHashKey);

      if (storedHash == null) {
        emit(
          state.copyWith(errorMessage: 'No PIN found. Please contact support.'),
        );
        return;
      }

      final inputHash = _hashPin(value);
      if (inputHash == storedHash) {
        emit(
          state.copyWith(
            isVerifyingCurrent: false,
            currentPin: '',
            errorMessage: '',
          ),
        );
      } else {
        emit(
          state.copyWith(
            errorMessage: 'Incorrect PIN. Please try again.',
            currentPin: '',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(errorMessage: 'Verification failed. Please try again.'),
      );
    }
  }

  Future<void> _confirmPinSetup(
    String value,
    Emitter<PinSetupState> emit,
  ) async {
    if (state.pin != value) {
      emit(
        state.copyWith(
          errorMessage: 'PINs do not match. Please try again.',
          isConfirming: false,
          pin: '',
          confirmPin: '',
        ),
      );
      return;
    }

    try {
      await _savePinHash(value);
      emit(state.copyWith(isSuccess: true));
    } catch (e) {
      emit(
        state.copyWith(errorMessage: 'Failed to save PIN. Please try again.'),
      );
    }
  }

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _savePinHash(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final hash = _hashPin(pin);
    await prefs.setString(_pinHashKey, hash);
    await prefs.setBool(_pinEnabledKey, true);
  }
}
