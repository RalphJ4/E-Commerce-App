import 'package:dartz/dartz.dart';
import 'package:shopease/core/errors/failures.dart';
import 'package:shopease/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> signUp({
    required String email,
    required String password,
    required String displayName,
  });

  Future<Either<Failure, User>> signInWithGoogle();

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, User?>> getCurrentUser();

  Future<bool> isSignedIn();
}
