import 'package:dartz/dartz.dart';
import 'package:shopease/core/errors/failures.dart';
import 'package:shopease/features/auth/domain/entities/user.dart';
import 'package:shopease/features/auth/domain/repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<Either<Failure, User>> call({
    required String email,
    required String password,
    required String displayName,
  }) {
    return repository.signUp(
      email: email,
      password: password,
      displayName: displayName,
    );
  }
}
