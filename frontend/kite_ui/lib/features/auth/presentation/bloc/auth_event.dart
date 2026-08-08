import 'package:equatable/equatable.dart';
import '../../data/models/auth_models.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class SignupRequested extends AuthEvent {
  final SignupRequest request;

  const SignupRequested(this.request);

  @override
  List<Object?> get props => [request];
}

class LoginRequested extends AuthEvent {
  final LoginRequest request;

  const LoginRequested(this.request);

  @override
  List<Object?> get props => [request];
}

class CheckAuthStatusRequested extends AuthEvent {
  const CheckAuthStatusRequested();
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
