import 'package:dartz/dartz.dart';
import 'package:shopease/core/errors/failures.dart';
import 'package:shopease/features/auth/domain/entities/user.dart';
import 'package:shopease/features/auth/domain/repositories/auth_repository.dart';

class GoogleSignInUseCase {
  final AuthRepository repository;

  GoogleSignInUseCase(this.repository);

  Future<Either<Failure, User>> call() {
    return repository.signInWithGoogle();
  }
}
