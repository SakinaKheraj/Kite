import '../repositories/auth_repository.dart';
import '../../data/models/auth_models.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<AuthResponse> execute(LoginRequest request) async {
    return await repository.login(request);
  }
}
