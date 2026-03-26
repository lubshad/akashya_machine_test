import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../../core/services/auth_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  late StreamSubscription _authSubscription;

  AuthBloc({required AuthService authService})
      : _authService = authService,
        super(AuthInitial()) {
    on<AuthUserChanged>(_onUserChanged);
    on<AuthLoginEmailRequested>(_onLoginEmailRequested);
    on<AuthRegisterEmailRequested>(_onRegisterEmailRequested);
    on<AuthSendOTPRequested>(_onSendOTPRequested);
    on<AuthVerifyOTPRequested>(_onVerifyOTPRequested);
    on<AuthResetPasswordRequested>(_onResetPasswordRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthErrorResetRequested>(_onErrorResetRequested);

    _authSubscription = _authService.authStateChanges.listen(
      (user) => add(AuthUserChanged(user)),
    );
  }

  void _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    if (event.user != null) {
      emit(AuthAuthenticated(event.user!));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLoginEmailRequested(AuthLoginEmailRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authService.signInWithEmail(email: event.email, password: event.password);
      // AuthUserChanged will handle the state update upon success.
    } on FirebaseAuthException catch (e) {
      emit(AuthUnauthenticated(error: _authService.getErrorMessage(e)));
    } catch (e) {
      emit(const AuthUnauthenticated(error: 'An unexpected error occurred.'));
    }
  }

  Future<void> _onRegisterEmailRequested(AuthRegisterEmailRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authService.signUpWithEmail(email: event.email, password: event.password);
      // AuthUserChanged will handle the state update upon success.
    } on FirebaseAuthException catch (e) {
      emit(AuthUnauthenticated(error: _authService.getErrorMessage(e)));
    } catch (e) {
      emit(const AuthUnauthenticated(error: 'An unexpected error occurred.'));
    }
  }

  Future<void> _onSendOTPRequested(AuthSendOTPRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final completer = Completer<void>();
    await _authService.sendOTP(
      phoneNumber: event.phoneNumber,
      onCodeSent: (verificationId) {
        if (!completer.isCompleted) {
          emit(AuthOTPSent(verificationId, event.phoneNumber));
          completer.complete();
        }
      },
      onError: (e) {
        if (!completer.isCompleted) {
          emit(AuthUnauthenticated(error: _authService.getErrorMessage(e)));
          completer.complete();
        }
      },
    );
    return completer.future;
  }

  Future<void> _onVerifyOTPRequested(AuthVerifyOTPRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authService.verifyOTP(
        verificationId: event.verificationId,
        smsCode: event.smsCode,
      );
    } on FirebaseAuthException catch (e) {
      emit(AuthUnauthenticated(error: _authService.getErrorMessage(e)));
    } catch (e) {
      emit(const AuthUnauthenticated(error: 'An unexpected error occurred.'));
    }
  }

  Future<void> _onResetPasswordRequested(AuthResetPasswordRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authService.sendPasswordReset(event.email);
      emit(AuthResetPasswordEmailSent(event.email));
    } on FirebaseAuthException catch (e) {
      emit(AuthUnauthenticated(error: _authService.getErrorMessage(e)));
    } catch (e) {
      emit(const AuthUnauthenticated(error: 'An unexpected error occurred.'));
    }
  }

  Future<void> _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await _authService.signOut();
  }

  void _onErrorResetRequested(AuthErrorResetRequested event, Emitter<AuthState> emit) {
    if (state is AuthUnauthenticated) {
      emit(const AuthUnauthenticated());
    }
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
