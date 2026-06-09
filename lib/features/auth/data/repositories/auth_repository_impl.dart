import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:shopease/core/errors/failures.dart';
import 'package:shopease/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:shopease/features/auth/domain/entities/user.dart';
import 'package:shopease/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, User>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.signIn(
        email: email,
        password: password,
      );
      return Right(user);
    } on firebase.FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapAuthError(e)));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final user = await remoteDataSource.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      return Right(user);
    } on firebase.FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapAuthError(e)));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      final user = await remoteDataSource.signInWithGoogle();
      return Right(user);
    } on firebase.FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapAuthError(e)));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<bool> isSignedIn() async {
    try {
      return await remoteDataSource.isSignedIn();
    } catch (_) {
      return false;
    }
  }

  String _mapAuthError(firebase.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-email':
        return 'Invalid email address';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'weak-password':
        return 'Password should be at least 6 characters';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled';
      case 'canceled':
        return 'Sign-in was canceled';
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different credential';
      default:
        return e.message ?? 'An unexpected error occurred';
    }
  }
}
