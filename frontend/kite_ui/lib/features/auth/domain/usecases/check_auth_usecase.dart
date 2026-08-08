import '../repositories/auth_repository.dart';

class CheckAuthUseCase {
  final AuthRepository repository;

  CheckAuthUseCase(this.repository);

  Future<bool> execute() async {
    return await repository.checkAuthStatus();
  }

  Future<String?> getUserId() async {
    return await repository.getSavedUserId();
  }
}
