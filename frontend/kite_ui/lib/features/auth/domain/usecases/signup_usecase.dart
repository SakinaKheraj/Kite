import '../repositories/auth_repository.dart';
import '../../data/models/auth_models.dart';

class SignupUseCase {
  final AuthRepository repository;

  SignupUseCase(this.repository);

  Future<AuthResponse> execute(SignupRequest request) async {
    return await repository.signup(request);
  }
}
