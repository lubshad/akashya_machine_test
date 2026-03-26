import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthUserChanged extends AuthEvent {
  final User? user;
  const AuthUserChanged(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthLoginEmailRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthLoginEmailRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterEmailRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthRegisterEmailRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class AuthSendOTPRequested extends AuthEvent {
  final String phoneNumber;
  const AuthSendOTPRequested(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

class AuthVerifyOTPRequested extends AuthEvent {
  final String verificationId;
  final String smsCode;
  const AuthVerifyOTPRequested(this.verificationId, this.smsCode);

  @override
  List<Object?> get props => [verificationId, smsCode];
}

class AuthResetPasswordRequested extends AuthEvent {
  final String email;
  const AuthResetPasswordRequested(this.email);

  @override
  List<Object?> get props => [email];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthErrorResetRequested extends AuthEvent {}
