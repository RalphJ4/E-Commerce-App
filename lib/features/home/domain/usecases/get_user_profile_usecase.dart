import 'package:dartz/dartz.dart';
import 'package:shopease/core/errors/failures.dart';
import 'package:shopease/features/home/domain/entities/user_profile.dart';
import 'package:shopease/features/home/domain/repositories/home_repository.dart';

class GetUserProfileUseCase {
  final HomeRepository repository;

  GetUserProfileUseCase(this.repository);

  Future<Either<Failure, UserProfile>> call(String uid) {
    return repository.getUserProfile(uid);
  }
}
