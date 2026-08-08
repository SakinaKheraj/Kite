import '../../../../core/utils/storage_service.dart';

import '../datasources/auth_remote_data_source.dart';
import '../models/auth_models.dart';

import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final StorageService storageService;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.storageService,
  });

  @override
  Future<AuthResponse> signup(SignupRequest request) async {
    final response = await remoteDataSource.signup(request);
    if (response.accessToken.isNotEmpty) {
      await storageService.saveAuthData(
        token: response.accessToken,
        userId: request.username,
      );
    }
    return response;
  }

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    final response = await remoteDataSource.login(request);
    if (response.accessToken.isNotEmpty) {
      await storageService.saveAuthData(
        token: response.accessToken,
        userId: request.username,
      );
    }
    return response;
  }

  @override
  Future<bool> checkAuthStatus() async {
    final token = await storageService.getToken();
    if (token == null || token.isEmpty) {
      return false;
    }
    return true;
  }

  @override
  Future<void> logout() async {
    await storageService.clearAuthData();
  }

  @override
  Future<String?> getSavedUserId() async {
    return await storageService.getUserId();
  }
}
