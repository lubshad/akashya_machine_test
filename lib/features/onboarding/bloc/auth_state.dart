import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  final String? error;
  const AuthUnauthenticated({this.error});

  @override
  List<Object?> get props => [error];
}

class AuthOTPSent extends AuthState {
  final String verificationId;
  final String phoneNumber;
  const AuthOTPSent(this.verificationId, this.phoneNumber);

  @override
  List<Object?> get props => [verificationId, phoneNumber];
}

class AuthResetPasswordEmailSent extends AuthState {
  final String email;
  const AuthResetPasswordEmailSent(this.email);

  @override
  List<Object?> get props => [email];
}
