import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;
  const LoginUseCase(this.repository);

  Future<bool> call({required String email, required String password}) {
    return repository.login(email, password);
  }
}
