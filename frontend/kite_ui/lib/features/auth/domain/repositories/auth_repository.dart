import '../../data/models/auth_models.dart';

abstract class AuthRepository {
  Future<AuthResponse> signup(SignupRequest request);
  Future<AuthResponse> login(LoginRequest request);
  Future<bool> checkAuthStatus();
  Future<void> logout();
  Future<String?> getSavedUserId();
}
