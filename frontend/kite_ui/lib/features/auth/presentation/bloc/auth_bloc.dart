import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/check_auth_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignupUseCase signupUseCase;
  final LoginUseCase loginUseCase;
  final CheckAuthUseCase checkAuthUseCase;
  final LogoutUseCase logoutUseCase;

  AuthBloc({
    required this.signupUseCase,
    required this.loginUseCase,
    required this.checkAuthUseCase,
    required this.logoutUseCase,
  }) : super(const AuthInitial()) {
    on<CheckAuthStatusRequested>(_onCheckAuthStatusRequested);
    on<SignupRequested>(_onSignupRequested);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onCheckAuthStatusRequested(
    CheckAuthStatusRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final isAuthenticated = await checkAuthUseCase.execute();
      if (isAuthenticated) {
        final userId = await checkAuthUseCase.getUserId() ?? '';
        emit(Authenticated(token: 'PERSISTED_TOKEN', userId: userId));
      } else {
        emit(const Unauthenticated());
      }
    } catch (_) {
      emit(const Unauthenticated());
    }
  }

  Future<void> _onSignupRequested(
    SignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final response = await signupUseCase.execute(event.request);
      emit(Authenticated(
        token: response.accessToken,
        userId: event.request.username,
      ));
    } catch (e) {
      emit(AuthFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final response = await loginUseCase.execute(event.request);
      emit(Authenticated(
        token: response.accessToken,
        userId: event.request.username,
      ));
    } catch (e) {
      emit(AuthFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await logoutUseCase.execute();
    emit(const Unauthenticated());
  }
}
